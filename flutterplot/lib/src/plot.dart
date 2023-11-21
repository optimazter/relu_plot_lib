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

    double? upperXPixelConstraint;
    double? lowerXPixelConstraint;

    double? upperYPixelConstraint;
    double? lowerYPixelConstraint;

    BoxConstraints? windowConstraints;

    final _Scaler xScaler = _Scaler();
    final _Scaler yScaler = _Scaler();

    late final PanGestureRecognizer recognizer;



    double? getXValueFromPixel(double pxX) {

      double x = xScaler.inverse(pxX);
      List<double> greater = xPixelLUT.keys.where((e) => e >= x).toList()..sort();
      return greater.firstOrNull;

    }



  void _onPanStart(DragStartDetails details) {
    for (Graph graph in widget.graphs) {
      if (graph.crosshair == null) {
        continue;
      }
      if (!graph.crosshair!.active) { 
        continue;
      }

      double? x = getXValueFromPixel(details.globalPosition.dx);

      if (x != null) {

          graph.crosshair?.x = x;

      }
      

      }



    }

  void _onPanUpdate(DragUpdateDetails details) {
    
    for (Graph graph in widget.graphs) {

      if (graph.crosshair == null) {
        continue;
      }
      if (!graph.crosshair!.active) { 
        continue;
      }
      double? x = getXValueFromPixel(details.globalPosition.dx);

      if (x != null) {
        graph.crosshair?.x = x;
      }
      
          
      setState(() {});
      

    }
  
  }

  void _onPanEnd(DragEndDetails details) {
    
  }



  void update(List<Graph> graph, BoxConstraints windowConstraints) {

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
  void initState() {
    super.initState();
    recognizer = PanGestureRecognizer()
    ..onStart = _onPanStart
    ..onUpdate = _onPanUpdate
    ..onEnd = _onPanEnd;
  }

  

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, windowConstraints) {

        update(widget.graphs, windowConstraints);


         return Listener(
          onPointerDown: (event) {
            recognizer.addPointer(event);
            } ,

            child: SizedBox(
            width: windowConstraints.maxWidth,
            height: windowConstraints.maxHeight,
            child: RepaintBoundary(
              child: CustomPaint(
                      painter: GraphPainter(this),
                      foregroundPainter: CrosshairPainter(this),
              )
              ),
            ),


    );
      }
    );
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
