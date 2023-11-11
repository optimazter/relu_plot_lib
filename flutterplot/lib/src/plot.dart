import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutterplot/flutterplot.dart';
import 'dart:math';


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
  State<StatefulWidget> createState() => _PlotState();


  

}


class _PlotState extends State<Plot> {


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



    List<double> get xToPaint {

      if (upperXPixelConstraint != null && lowerXPixelConstraint != null) {

          return xPixelLUT.values.where((e) => e <=  upperXPixelConstraint! && e >=  lowerXPixelConstraint!).toList();
        
      }
      if (lowerXPixelConstraint != null) {

        return xPixelLUT.values.where((e) => e >=  lowerXPixelConstraint!).toList();

      }
      if (upperXPixelConstraint != null) {

        return xPixelLUT.values.where((e) => e <=  upperXPixelConstraint!).toList();

      }

      return xPixelLUT.values.toList();
      

    }

    List<double> get yToPaint {

      if (upperYPixelConstraint != null && lowerYPixelConstraint != null) {

          return yPixelLUT.values.where((e) => e <=  upperYPixelConstraint! && e >=  lowerYPixelConstraint!).toList();
        
      }
      if (lowerYPixelConstraint != null) {

        return yPixelLUT.values.where((e) => e >=  lowerYPixelConstraint!).toList();

      }
      if (upperYPixelConstraint != null) {

        return yPixelLUT.values.where((e) => e <=  upperYPixelConstraint!).toList();

      }

      return yPixelLUT.values.toList();
      

    }


    



    double getXValueFromPixel(double pxX) {

      double x = xScaler.inverse(pxX);
      List<double> greater = xPixelLUT.keys.where((e) => e >= x).toList()..sort();
      return greater.first;

    }



  void _onPanStart(DragStartDetails details) {
    for (Graph graph in widget.graphs) {
      if (graph.crosshair == null) {
        continue;
      }
      if (!graph.crosshair!.active) { 
        continue;
      }

      graph.crosshair?.x = getXValueFromPixel(details.globalPosition.dx);

      }



    }

  void _onPanUpdate(DragUpdateDetails details) {
    debugPrint('onUpdate');
    for (Graph graph in widget.graphs) {

      if (graph.crosshair == null) {
        continue;
      }
      if (!graph.crosshair!.active) { 
        continue;
      }
      graph.crosshair!.x = getXValueFromPixel(details.globalPosition.dx);
          
      setState(() {});
      

    }
  
  }

  void _onPanEnd(DragEndDetails details) {
    debugPrint('onEnd');
  }



  void update(List<Graph> graph, BoxConstraints windowConstraints) {

        this.windowConstraints = windowConstraints;

        double xMin = double.infinity;
        double xMax = double.negativeInfinity;
        double yMin = double.infinity;
        double yMax = double.negativeInfinity;
        

        for (Graph graph in widget.graphs) {

        if (graph.X.length != graph.Y.length) {

          throw Exception('Length of X does not match length of Y');

        }

        if (graph.X.length < 2) {

          throw Exception('A minimum of 2 points are needed to create a line');

        }

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
                      painter: _PlotPainter(this),
              )
              ),
            ),


    );
      }
    );
  }

}



class _PlotPainter extends CustomPainter {

  _PlotPainter(this.state);

  final _PlotState state;
  

  
  @override
  void paint(Canvas canvas, Size size) {

    final Paint graphPaint = Paint();
    final Paint crosshairLinePaint = Paint();
    final Paint crosshairBoxPaint = Paint();

    final TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr,);



    for (Graph graph in state.widget.graphs) { 

      graphPaint.color = graph.color ?? Colors.black;
      graphPaint.strokeWidth = graph.linethickness ?? 1;

      _drawGraph(canvas, graphPaint, graph.X, graph.Y);


      if (graph.crosshair != null) {
        textPainter.text = TextSpan(
          style: const TextStyle(color: Colors.white), 
          text: 'x: ${graph.crosshair!.x} \ny: ${graph.mapXToY[graph.crosshair!.x]}');
        textPainter.layout(
              minWidth: 0,
              maxWidth: size.width,
            );
        crosshairLinePaint..color = Colors.black..strokeWidth = 1.3;
        crosshairBoxPaint..color = graph.color??Colors.black..style = PaintingStyle.fill;

        _drawCrosshair(canvas, 
          crosshairLinePaint, 
          crosshairBoxPaint, 
          textPainter, 
          graph.crosshair!.width,
          graph.crosshair!.height,
          state.xPixelLUT[graph.crosshair!.x] ?? 100, 
          graph.crosshair!.yPadding,
          state.windowConstraints?.maxWidth ?? 0,
          state.windowConstraints?.maxWidth ?? 0,
          state.yPixelLUT[graph.mapXToY[graph.crosshair?.x]] ?? 0,
          );

      }

  

    }



    }
    


  void _drawGraph(Canvas canvas,  Paint paintBrush,  List<double> X, List<double> Y) {


    for (int i = 0; i < X.length - 1; i ++) {

      canvas.drawLine(Offset(state.xPixelLUT[X[i]]!, state.yPixelLUT[Y[i]]!), Offset(state.xPixelLUT[X[i+1]]!, state.yPixelLUT[Y[i+1]]!), paintBrush);

    }
    
    
  }



  void _drawCrosshair(Canvas canvas, Paint linePaint, Paint boxPaint, TextPainter textPainter, double width, double height, double pxXBox, double pxYBox, double pxXMax, double pxYMax, double pxY) {

    //Horizontal crosshair line
    canvas.drawLine(Offset(0, pxY), Offset(pxXMax, pxY), linePaint);

    //Vertical crosshair line
    canvas.drawLine(Offset(pxXBox, 0), Offset(pxXBox, pxYMax), linePaint);

    //Crosshair information box
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(pxXBox, pxYBox + height), 
          width: width, 
          height: height), 
        const Radius.circular(8)), boxPaint);

    //Crosshair text
    textPainter.paint(canvas, Offset(pxXBox - width / 2 + 5, pxYBox + height / 2));

  }
  


  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {

    return true;

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

      return (val * (1/_s) - _pxMin) + _min;
    
  }



}
