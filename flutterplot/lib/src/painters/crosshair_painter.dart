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
    required this.padding
    });

  final Map<Offset, RenderPoint> pixelLUT;
  final Map<double, String> xCrosshairLabels;
  final Map<double, String> yCrosshairLabels;
  final List<Graph> graphs;
  final double width;
  final double height;
  final double padding;


  @override
  void paint(Canvas canvas, Size size) {

    debugLog('Repainting Crosshairs');

    final crosshairLinePaint = Paint();
    final crosshairBoxPaint = Paint();
    final textPainter = TextPainter(textDirection: TextDirection.ltr,);
    
    canvas.clipRect(Rect.fromLTRB(-padding, 0, width + padding, height));

    for (var graph in graphs) {

      if (graph.crosshairs != null) {

        for (var crosshair in graph.crosshairs!) { 
          crosshairLinePaint..color = Colors.black..strokeWidth = 1.3;
          crosshairBoxPaint..color = crosshair.active ? crosshair.color : crosshair.color.withAlpha(150)..style = PaintingStyle.fill;
          
          _paintCrosshair(
            canvas, 
            crosshair,
            crosshairLinePaint, 
            crosshairBoxPaint, 
            textPainter
            );
        }
      }
    }
  }
  

  void _paintCrosshair(Canvas canvas, Crosshair crosshair, Paint linePaint, Paint boxPaint, TextPainter textPainter) {

      Offset pixelPosition = pixelLUT[crosshair.coordinate]!.pixel;

      textPainter.text = TextSpan(
          style: const TextStyle(color: Colors.white), 
          text: ' ${crosshair.label}\n  x: ${xCrosshairLabels[crosshair.coordinate!.dx]} \n  y: ${yCrosshairLabels[crosshair.coordinate!.dy]}');
        textPainter.layout(
              minWidth: 0,
              maxWidth: crosshair.width,
            );

      canvas.drawLine(Offset(0, pixelPosition.dy), Offset(width, pixelPosition.dy), linePaint);

      canvas.drawLine(Offset(pixelPosition.dx, height), Offset(pixelPosition.dx, 0), linePaint);

      canvas.drawCircle(pixelPosition, 5, boxPaint);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(pixelPosition.dx, crosshair.yPadding + crosshair.height / 3), 
            width: crosshair.width, 
            height: crosshair.height), 
          const Radius.circular(8)), boxPaint);

      //Crosshair text
      textPainter.paint(canvas, Offset(pixelPosition.dx - crosshair.width / 2 + 7,   crosshair.yPadding));
    }




  @override
  bool shouldRepaint(covariant CrosshairPainter oldDelegate) {

    return true;

  }


}



