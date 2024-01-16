import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutterplot/flutterplot.dart';
import 'dart:math';

import 'package:flutterplot/src/custom_painters.dart';


const int xId = 0;

const int yId = 1;

enum ConversionMethod {nearest, interpolation}


class Plot extends StatefulWidget {   
  
  const Plot({
    Key? key,
    required this.graphs,
    this.xAxis,
    this.yAxis,
    this.xUnit,
    this.yUnit, 
    this.strokeWidth = 1,
    this.padding = 0,
    this.conversionMethod = ConversionMethod.nearest,
  }) : super(key: key);


  final List<Graph> graphs;

  final List<double>? xAxis;
  final List<double>? yAxis;
  
  final String? xUnit;
  final String? yUnit;

  final double strokeWidth;
  final double padding;

  final ConversionMethod conversionMethod;
  
  @override
  State<StatefulWidget> createState() => PlotState();
  
}


class PlotState extends State<Plot> {


  final Map<double, double> xPixelLUT = {};
  final Map<double, double> yPixelLUT = {};


  BoxConstraints? windowConstraints;

  final _Scaler xScaler = _Scaler();
  final _Scaler yScaler = _Scaler();



  double? _getXValueFromPixel(double pxX) {

    double x = xScaler.inverse(pxX);
    List<double> greater = xPixelLUT.keys.where((e) => e >= x).toList()..sort();
    return greater.firstOrNull;

  }


  int _getXIndexFromPixel(Graph graph, double pxX,  Offset delta, int prevIndex) {

    double x = xScaler.inverse(pxX);



    if (delta.dx < 0) {

      for (int i = prevIndex - 1; i > 1; i --) {

        if (graph.X[i - 1] <= x && x <= graph.X[i + 1]) {
          
          return i;

        }
      }
      return 0; 
    }

    for (int i = prevIndex + 1; i < graph.X.length - 1; i ++) {

      if (graph.X[i - 1] <= x && x <= graph.X[i + 1]) {
        
        return i;

      }
    } 
    return graph.X.length - 1;

    }


  void _init(List<Graph> graph, BoxConstraints windowConstraints) {

        debugPrint('Initializing');

        this.windowConstraints = windowConstraints;

        double xMin = double.infinity;
        double xMax = double.negativeInfinity;
        double yMin = double.infinity;
        double yMax = double.negativeInfinity;
        

        for (Graph graph in widget.graphs) {

          xMin = min(xMin, graph.X.reduce(min));
          xMax = max(xMax, graph.X.reduce(max));


          yMin = min(yMin, graph.Y.reduce(min));
          yMax = max(yMax, graph.Y.reduce(max));

        }

        xScaler.setScaling(xMin, xMax, widget.padding, windowConstraints.maxWidth - widget.padding);
        yScaler.setScaling(yMin, yMax, widget.padding, windowConstraints.maxHeight - widget.padding);


        for (Graph graph in widget.graphs) {

          for (int i = 0; i < graph.X.length; i++) {

            double pxX = xScaler.scale(graph.X[i]);
            double pxY = yScaler.scale(graph.Y[i]);

            xPixelLUT[graph.X[i]] = pxX;
            yPixelLUT[graph.Y[i]] = windowConstraints.maxHeight - pxY;


          }

        }


    }


  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, windowConstraints) {

        _init(widget.graphs, windowConstraints);

        return Stack(
          children: [
            BackgroundLayer(state: this),
            ForegroundLayer(state: this),
            ]
        );
      }
    );
  }

}
  


class BackgroundLayer extends StatelessWidget {
  
  const BackgroundLayer({
    super.key, 
    required this.state,
  });

  final PlotState state;
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: state.windowConstraints!.maxWidth,
      height: state.windowConstraints!.maxHeight,
      child: RepaintBoundary(
        child: CustomPaint(
          painter: GraphPainter(state),
          )
        ),
    );
  }
}

class ForegroundLayer extends StatefulWidget {

  const ForegroundLayer({
    super.key, 
    required this.state,
  });

  final PlotState state;
  
  @override
  State<StatefulWidget> createState() => ForegroundState();


}


class ForegroundState extends State<ForegroundLayer> {

  late final PanGestureRecognizer recognizer;


  @override
  void initState() {
    super.initState();
    recognizer = PanGestureRecognizer()
    ..onStart = _onPanStart
    ..onUpdate = _onPanUpdate
    ..onEnd = _onPanEnd;
  }


  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        recognizer.addPointer(event);
        } ,
      child: SizedBox(
        width: widget.state.windowConstraints!.maxWidth,
        height: widget.state.windowConstraints!.maxHeight,
        child: RepaintBoundary(
          child: CustomPaint(
            painter: CrosshairPainter(widget.state),
            )
          ),
      )
    );
  }


  void _onPanStart(DragStartDetails details) {
    for (Graph graph in widget.state.widget.graphs) {
      if (graph.crosshair == null) {
        continue;
      }
      if (!graph.crosshair!.active) { 
        continue;
      }

      double? x = widget.state._getXValueFromPixel(details.globalPosition.dx);

      if (x != null) {

        graph.crosshair?.x = x;

      }
      

      }



    }

  void _onPanUpdate(DragUpdateDetails details) {
    
    for (Graph graph in widget.state.widget.graphs) {

      if (graph.crosshair == null) {
        continue;
      }
      if (!graph.crosshair!.active) { 
        continue;
      }
      
      int i = widget.state._getXIndexFromPixel(graph, details.globalPosition.dx, details.delta, graph.crosshair!.prevIndex);

          
      setState(() {

        graph.crosshair?.x = graph.X[i];
        graph.crosshair?.prevIndex = i;
 
      });
      

    }
  
  }

  void _onPanEnd(DragEndDetails details) {
    
  }


}
    


class _Scaler {


  double _pxMin = 0;
  double _min = 0;
  double _s = 0;


  void setScaling(double min, double max, double pxMin, double pxMax) {
  
    _min = min;
    _pxMin = pxMin;
    _s = (pxMax - pxMin) / (max - min);

  }


  double scale(double val) {

      return (val -_min) * _s + _pxMin;

  }

  double inverse(double val) {

      return (val - _pxMin) * (1/_s) + _min;
    
  }



}
