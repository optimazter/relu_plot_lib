import 'package:flutter/material.dart';
import 'package:flutterplot/flutterplot.dart';
import 'package:flutterplot/src/painters/render_point.dart';
import 'package:flutterplot/src/utils.dart';




class CrosshairPainter extends CustomPainter {

  const CrosshairPainter({
    required this.pixelLUT,
    required this.xCrosshairLabels,
    required this.yCrosshairLabels,
    required this.graphs,
    required this.width,
    required this.height,
    });

  final Map<Offset, RenderPoint> pixelLUT;
  final Map<double, String> xCrosshairLabels;
  final Map<double, String> yCrosshairLabels;
  final List<Graph> graphs;
  final double width;
  final double height;


  @override
  void paint(Canvas canvas, Size size) {

    debugLog('Repainting Crosshairs');

    final linePaint = Paint();
    final boxPaint = Paint();
    final textPainter = TextPainter(textDirection: TextDirection.ltr,);
    final Rect clipRect = Rect.fromLTRB(0, 0, width, height);

    canvas.clipRect(clipRect);

    for (var graph in graphs) {

      if (graph.crosshairs != null) {

        for (var crosshair in graph.crosshairs!) { 
          linePaint..color = Colors.black..strokeWidth = 1.3;
          boxPaint..color = crosshair.active ? crosshair.color : crosshair.color.withAlpha(150)..style = PaintingStyle.fill;
          
          Offset position = pixelLUT[crosshair.coordinate]!.pixel;

          _paintCrosshairLine(canvas, position, linePaint);

          textPainter.text = TextSpan(
            style: const TextStyle(color: Colors.white), 
            text: ' ${crosshair.label}\n  x: ${xCrosshairLabels[crosshair.coordinate!.dx]} \n  y: ${yCrosshairLabels[crosshair.coordinate!.dy]}');
          textPainter.layout(
                minWidth: 0,
                maxWidth: crosshair.width,
              );

          _paintCrosshairBox(
            canvas, 
            position,
            crosshair.width, 
            crosshair.height,
            crosshair.yPadding,
            boxPaint,
            textPainter
            );
        }
      }
    }
  }

  void _paintCrosshairLine(Canvas canvas, Offset position, Paint linePaint) {
    canvas.drawLine(Offset(0, position.dy), Offset(width, position.dy), linePaint);
    canvas.drawLine(Offset(position.dx, height), Offset(position.dx, 0), linePaint);

  }

  

  void _paintCrosshairBox(Canvas canvas, Offset position, double width, double height, double yPadding,  Paint boxPaint, TextPainter textPainter) {

      canvas.drawCircle(position, 5, boxPaint);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(position.dx, yPadding + height / 3), 
            width: width, 
            height: height), 
          const Radius.circular(8)), boxPaint);

      //Crosshair text
      textPainter.paint(canvas, Offset(position.dx - width / 2 + 7,   yPadding));
    }




  @override
  bool shouldRepaint(covariant CrosshairPainter oldDelegate) {

    return true;

  }


}



