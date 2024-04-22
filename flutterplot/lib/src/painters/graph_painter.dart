import 'package:flutter/material.dart';
import 'package:flutterplot/flutterplot.dart';
import 'package:flutterplot/src/painters/render_point.dart';
import 'package:flutterplot/src/utils.dart';


class GraphPainter extends CustomPainter {

  const GraphPainter({
    required this.graphRenderPoints,
    required this.width,
    required this.height,

  });

  final Map<Graph, List<RenderPoint>> graphRenderPoints;
  final double width;
  final double height;

  
  @override
  void paint(Canvas canvas, Size size) {

    debugLog('Repainting Graphs');

    canvas.clipRect(Rect.fromLTRB(0, 0, width, height));

    graphRenderPoints.forEach((key, values) {
        _paintGraphs(canvas, values);
    },);

  }


  void _paintGraphs(Canvas canvas, List<RenderPoint> renderPoints) {

    for (int i = 0; i < renderPoints.length - 1; i++) { 

      canvas.drawLine(renderPoints[i].pixel, renderPoints[i + 1].pixel, renderPoints[i].paint);

    }
  }
    

  @override
  bool shouldRepaint(covariant GraphPainter oldDelegate) {

    return true;

  }


}