
import 'package:flutter/material.dart';
import 'package:flutterplot/src/utils.dart';

class BackgroundPainter extends CustomPainter {

  const BackgroundPainter({
    required this.xTicks,
    required this.yTicks,
    required this.width,
    required this.height,
    required this.padding,

  });

  final Map<String, double> xTicks;
  final Map<String, double> yTicks;
  final double width;
  final double height;
  final double padding;

  
  @override
  void paint(Canvas canvas, Size size) {

    debugLog('Repainting Static Background');

    final primaryLinePaint = Paint()..color = Colors.black..strokeWidth = 2;
    final secondaryLinePaint = Paint()..color = Colors.black..strokeWidth = 0.8;
    final linePaint = Paint()..color = const Color.fromARGB(210, 87, 85, 85)..strokeWidth = 1;
    final textPainter = TextPainter(textDirection: TextDirection.ltr,);

    _paintBorders(canvas, width, height, primaryLinePaint, secondaryLinePaint);
    _paintGridLines(canvas, xTicks, yTicks, linePaint, textPainter);


  }

  void _paintBorders(Canvas canvas, double width, double height, Paint primaryLinePaint, Paint secondaryLinePaint) {

    canvas.drawLine(Offset(0, height), Offset.zero, primaryLinePaint);
    canvas.drawLine(Offset(0, height), Offset(width, height), primaryLinePaint);

    canvas.drawLine(Offset(width, height), Offset(width, 0), secondaryLinePaint);
    canvas.drawLine(Offset.zero, Offset(width, 0), secondaryLinePaint);
  }

  void _paintGridLines(Canvas canvas,  Map<String, double> xTicks, Map<String, double> yTicks, Paint linePaint, TextPainter textPainter) {

    xTicks.forEach((key, coordinate) {
      canvas.drawLine(Offset(coordinate, 0), Offset(coordinate, height), linePaint);
      textPainter.text = TextSpan(
          style: const TextStyle(color: Colors.black), 
          text: key,
      );
      textPainter.layout(
          minWidth: 0,
          maxWidth: width / xTicks.length,
        );
      textPainter.paint(canvas, Offset(coordinate, height));
    });
    yTicks.forEach((key, coordinate) {
      canvas.drawLine(Offset(0, coordinate), Offset(width, coordinate), linePaint);
      textPainter.text = TextSpan(
          style: const TextStyle(color: Colors.black), 
          text: key,
      );
      textPainter.layout(
          minWidth: 0,
          maxWidth: width / xTicks.length,
        );
      textPainter.paint(canvas, Offset(-padding + 5, coordinate));
    });
    
  }
  
  @override
  bool shouldRepaint(covariant BackgroundPainter oldDelegate) {
    return true;
  }


}