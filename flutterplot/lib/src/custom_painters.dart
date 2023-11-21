

import 'package:flutter/material.dart';
import 'package:flutterplot/src/graph.dart';
import 'package:flutterplot/src/plot.dart';

class GraphPainter extends CustomPainter {

  GraphPainter(this.state);

  final PlotState state;
  

  
  @override
  void paint(Canvas canvas, Size size) {

    final Paint graphPaint = Paint();

    for (Graph graph in state.widget.graphs) { 

      graphPaint.color = graph.color ?? Colors.black;
      graphPaint.strokeWidth = graph.linethickness ?? 1;

      _drawGraph(canvas, graphPaint, graph.X, graph.Y);

      }

    }

  void _drawGraph(Canvas canvas,  Paint paintBrush,  List<double> X, List<double> Y) {

    debugPrint('repainting graphs');
    for (int i = 0; i < X.length - 1; i ++) {

      canvas.drawLine(Offset(state.xPixelLUT[X[i]]!, state.yPixelLUT[Y[i]]!), Offset(state.xPixelLUT[X[i+1]]!, state.yPixelLUT[Y[i+1]]!), paintBrush);

    }
    
    
  }


  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {

    return false;

  }


}


class CrosshairPainter extends CustomPainter {

  CrosshairPainter(this.state);

  final PlotState state;

  @override
  void paint(Canvas canvas, Size size) {

    final Paint crosshairLinePaint = Paint();
    final Paint crosshairBoxPaint = Paint();
    final TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr,);



    for (Graph graph in state.widget.graphs) { 

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



