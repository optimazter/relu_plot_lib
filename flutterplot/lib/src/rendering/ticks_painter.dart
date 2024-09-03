import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutterplot/src/utils/utils.dart';


class TicksPainter extends CustomPainter {


  const TicksPainter({
    required this.xTicks,
    required this.xLabels,
    required this.yTicks,
    required this.yLabels,
    required this.xUnit,
    required this.yUnit,
    required this.bottomPadding, 
    required this.leftPadding,
    required this.transform,
  });

  final List<double>? xTicks;
  final List<String>? xLabels;
  final List<double>? yTicks;
  final List<String>? yLabels;
  final String? xUnit;
  final String? yUnit;
  final double bottomPadding;
  final double leftPadding;
  final Matrix4 transform;


  @override
  void paint(Canvas canvas, Size size) {

    final Paint linePaint = Paint()..color = Colors.black;

    _paintBorders(canvas, size, linePaint);
    if (xTicks != null && yTicks != null && xLabels != null && yLabels != null) {
      final xTicksCanvas = xTicks!.map(transform.transformX).toList();
      final yTicksCanvas = yTicks!.map(transform.transformY).toList();
      _paintTicks(canvas, xTicksCanvas, yTicksCanvas, size, linePaint);
      _paintLabels(canvas, xTicksCanvas, yTicksCanvas, xLabels!, yLabels!, size);
    }
    if (xUnit != null) {
      _paintUnit(canvas, size, xUnit!, Offset(size.width / 2, size.height + bottomPadding / 2));
    }
    if (yUnit != null) {
      _paintUnit(canvas, size, yUnit!, Offset(-leftPadding, size.height / 2));
    }



  }

  void _paintBorders(Canvas canvas, Size size, Paint paint) {
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), paint);
    canvas.drawLine(Offset.zero, Offset(0, size.height), paint);
    canvas.drawLine(Offset.zero, Offset(size.width, 0), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, 0), paint);
  }



  void _paintTicks(Canvas canvas, List<double>? xTicks, List<double>? yTicks, Size size, Paint paint) {
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(0, 0, size.width, size.height));
    xTicks?.forEach((x) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    });
    yTicks?.forEach((y) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    });
    canvas.restore();
  }

  void _paintUnit(Canvas canvas, Size size, String unit, Offset position) {

    final TextStyle textStyle = TextStyle(
      color:  Colors.black, 
      letterSpacing: -0.5,
      fontSize: 15
    );
    final ParagraphBuilder paragraphBuilder = ParagraphBuilder(
      ParagraphStyle()
    )
    ..pushStyle(textStyle.getTextStyle())
    ..addText(unit);

    final Paragraph paragraph = paragraphBuilder.build()
    ..layout(ParagraphConstraints(width: size.width));

    canvas.drawParagraph(paragraph, position);
  }

  void _paintLabels(Canvas canvas, List<double> xTicks, List<double> yTicks, List<String> xLabels, List<String> yLabels, Size size) {

    final TextStyle textStyle = TextStyle(
          color:  Colors.black, 
          letterSpacing: -0.5,
          fontSize: 12.5
        );
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(0, 0, size.width, size.height + bottomPadding));
    for (int i = 0; i < xTicks.length; i++) {

      final ParagraphBuilder paragraphBuilder = ParagraphBuilder(
        ParagraphStyle()
      )
      ..pushStyle(textStyle.getTextStyle())
      ..addText(xLabels[i]);

      final Paragraph paragraph = paragraphBuilder.build()
      ..layout(ParagraphConstraints(width: size.width));

      canvas.drawParagraph(paragraph, Offset(xTicks[i], size.height));
    }

    canvas.restore();

    canvas.save();
    canvas.clipRect(Rect.fromLTRB(-leftPadding, 0, size.width, size.height));

    for (int i = 0; i < yTicks.length; i++) {

      final ParagraphBuilder paragraphBuilder = ParagraphBuilder(
        ParagraphStyle()
      )
      ..pushStyle(textStyle.getTextStyle())
      ..addText(yLabels[i]);

      final Paragraph paragraph = paragraphBuilder.build()
      ..layout(ParagraphConstraints(width: size.width));

      canvas.drawParagraph(paragraph, Offset(0, yTicks[i]));
    }

    canvas.restore();

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }


  
}