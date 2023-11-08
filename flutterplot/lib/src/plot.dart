import 'package:flutter/material.dart';
import 'package:flutterplot/flutterplot.dart';

class Plot extends StatefulWidget {   
  

  const Plot({
    Key? key,
    required this.graph,
    this.xAxis,
    this.yAxis,
    this.xUnit,
    this.yUnit, 
    this.strokeWidth,
  }) : super(key: key);


  final List<Graph> graph;

  final List<double>? xAxis;
  final List<double>? yAxis;
  
  final String? xUnit;
  final String? yUnit;

  final double? strokeWidth;


  
  @override
  State<StatefulWidget> createState() => PlotState();


  




}


class PlotState extends State<Plot> {



  @override
  Widget build(BuildContext context) {


    return MouseRegion(
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _PlotPainter(this),
              )
          ),
        ),
    );
  }

}


class _PlotPainter extends CustomPainter {

  _PlotPainter(this.state);

  final PlotState state;

  
  @override
  void paint(Canvas canvas, Size size) {

    for (Graph graph in state.widget.graph) {

      if (graph.X.length != graph.Y.length) {

        throw Exception('Length of X does not match length of Y');

      }

      if (graph.X.length < 2) {

        throw Exception('A minimum of 2 points are needed to create a line');

      }

      Paint paint = Paint();
      paint.color = graph.color ?? Colors.black;
      paint.strokeWidth = graph.linethickness ?? 1;

      List<double> pxX = scaleValuesToScreen(size.width, graph.X);
      List<double> pxY = scaleValuesToScreen(size.height, graph.Y);

      drawGraph(canvas, paint, pxX, pxY);

    }
    
  }


  void drawGraph(Canvas canvas,  Paint paint,  List<double> pxX, List<double> pxY) {


    for (int i = 0; i < pxX.length - 1; i ++) {

      canvas.drawLine(Offset(pxX[i], pxY[i]), Offset(pxX[i+1], pxY[i+1]), paint);

    }
    
    
  }
  

  List<double> scaleValuesToScreen(double tMax, List<double> values) {

    List<double> screenCoordinates = [];
    values.sort();
    double max = values.last;
    double min = values.first;

    for (double val in values) { 

      screenCoordinates.add(scaled(val, min, max, tMax));

    }

    return screenCoordinates;

  }


  double scaled(double val, double min, double max, double scalar) {

    return (val-min) / (max-min) * scalar;

  }



  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {

    return true;

  }



}
