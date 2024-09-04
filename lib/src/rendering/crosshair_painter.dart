import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:relu_plot_lib/relu_plot_lib.dart';
import 'package:relu_plot_lib/src/utils/utils.dart';


class CrosshairPainter extends CustomPainter {

  const CrosshairPainter({
    required this.crosshairs,
    required this.xUnit,
    required this.yUnit,
    required this.logarithmicXLabel,
    required this.logarithmicYLabel,
    required this.transform,
  });

  final List<Crosshair> crosshairs;
  final String? xUnit;
  final String? yUnit;
  final bool logarithmicXLabel;
  final bool logarithmicYLabel;
  final Matrix4 transform;


  @override
  void paint(Canvas canvas, Size size) {

    final linePaint = Paint();
    final boxPaint = Paint();
    TextStyle textStyle = const TextStyle(
          color:  Colors.black, 
    );

    for (var crosshair in crosshairs) {
      final Offset globalPosition = transform.transformOffset(crosshair.position);
      linePaint..color = Colors.black..strokeWidth = 1.1;
      boxPaint..color = crosshair.color..style = PaintingStyle.fill;
      
      canvas.save();
      canvas.clipRect(Rect.fromLTRB(0, 0, size.width, size.height));
      _paintCrosshairLine(canvas, size, globalPosition, crosshair.yPadding, linePaint, boxPaint);
      canvas.restore();

      canvas.save();
      canvas.clipRect(Rect.fromLTRB(-crosshair.halfWidth, -crosshair.halfHeight, size.width + crosshair.halfWidth, size.height + crosshair.halfHeight));
      _paintCrosshairBox(canvas, globalPosition, crosshair.width, crosshair.height, crosshair.yPadding, boxPaint);
      _paintCrosshairText(canvas, crosshair.label, crosshair.position, globalPosition, crosshair.yPadding, textStyle, crosshair.width, crosshair.fractionDigits);
      canvas.restore();
    }
  }

  void _paintCrosshairLine(Canvas canvas, Size size, Offset globalPosition, double padding, Paint linePaint, Paint boxPaint) {
    canvas.drawLine(Offset(0, globalPosition.dy), Offset(size.width, globalPosition.dy), linePaint);
    canvas.drawLine(Offset(globalPosition.dx, padding), Offset(globalPosition.dx, size.height), linePaint);
    canvas.drawCircle(globalPosition, 5, boxPaint);
  }


  void _paintCrosshairText(Canvas canvas, String label, Offset localPosition, Offset globalPosition, double padding, TextStyle textStyle, double width, int fractionDigits) {
    final ParagraphBuilder paragraphBuilder = ParagraphBuilder(
            ParagraphStyle()
          )
          ..pushStyle(textStyle.getTextStyle())
          ..addText(' $label\n  x: ${
            logarithmicXLabel ? pow(10, localPosition.dx).toStringAsFixed(fractionDigits) : (localPosition.dx).toStringAsFixed(fractionDigits) 
            } ${
              xUnit ?? ''
            } \n  y: ${
            logarithmicYLabel ? pow(10, localPosition.dy).toStringAsFixed(fractionDigits) : localPosition.dy.toStringAsFixed(fractionDigits)
            } ${
              yUnit ?? ''}'
    );
    final Paragraph paragraph = paragraphBuilder.build()
    ..layout(ParagraphConstraints(width: width));

    canvas.drawParagraph(paragraph, Offset(globalPosition.dx - width / 2, padding));

  }

  

  void _paintCrosshairBox(Canvas canvas, Offset globalPosition, double width, double height, double yPadding, Paint boxPaint) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(globalPosition.dx, yPadding + height / 3), 
          width: width, 
          height: height), 
        const Radius.circular(8)), boxPaint
    );
  }




  @override
  bool shouldRepaint(covariant CrosshairPainter oldDelegate) {
    return true;
  }



}



