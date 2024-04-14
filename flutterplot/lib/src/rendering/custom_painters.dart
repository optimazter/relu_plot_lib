import 'package:flutter/material.dart';
import 'package:flutterplot/flutterplot.dart';
import 'package:flutterplot/src/app.dart';



class BackgroundPainter extends CustomPainter {

  const BackgroundPainter({
    required this.state,

  });

  final FlutterPlotState state;

  
  @override
  void paint(Canvas canvas, Size size) {

    state.debugLog('Repainting Static Background');

    final primaryLinePaint = Paint()..color = Colors.black..strokeWidth = 2;
    final secondaryLinePaint = Paint()..color = Colors.black..strokeWidth = 0.8;
    final linePaint = Paint()..color = const Color.fromARGB(210, 87, 85, 85)..strokeWidth = 1;
    final textPainter = TextPainter(textDirection: TextDirection.ltr,);

    _paintBorders(canvas, state.windowConstraints.maxWidth, state.windowConstraints.maxHeight, primaryLinePaint, secondaryLinePaint);
    _paintGridLines(canvas, state.xTicks, state.yTicks, linePaint, textPainter);


  }

  void _paintBorders(Canvas canvas, double width, double height, Paint primaryLinePaint, Paint secondaryLinePaint) {

    canvas.drawLine(Offset(0, height), Offset.zero, primaryLinePaint);
    canvas.drawLine(Offset(0, state.windowConstraints.maxHeight), Offset(width, height), primaryLinePaint);

    canvas.drawLine(Offset(width, height), Offset(state.windowConstraints.maxWidth, 0), secondaryLinePaint);
    canvas.drawLine(Offset.zero, Offset(width, 0), secondaryLinePaint);
  }

  void _paintGridLines(Canvas canvas,  Map<String, double> xTicks, Map<String, double> yTicks, Paint linePaint, TextPainter textPainter) {

    xTicks.forEach((key, value) {
      canvas.drawLine(Offset(value, 0), Offset(value, state.windowConstraints.maxHeight), linePaint);
      textPainter.text = TextSpan(
          style: const TextStyle(color: Colors.black), 
          text: key,
      );
      textPainter.layout(
          minWidth: 0,
          maxWidth: state.windowConstraints.maxWidth / xTicks.length,
        );
      textPainter.paint(canvas, Offset(value, state.windowConstraints.maxHeight));
    });
    yTicks.forEach((key, value) {
      canvas.drawLine(Offset(0, value), Offset(state.windowConstraints.maxWidth, value), linePaint);
      textPainter.text = TextSpan(
          style: const TextStyle(color: Colors.black), 
          text: key,
      );
      textPainter.layout(
          minWidth: 0,
          maxWidth: state.windowConstraints.maxWidth / xTicks.length,
        );
      textPainter.paint(canvas, Offset(-state.sidePadding + 5, value));
    });
    
  }
  
  @override
  bool shouldRepaint(covariant BackgroundPainter oldDelegate) {
    return true;
  }


}

class GraphPainter extends CustomPainter {

  const GraphPainter({
    required this.state,

  });

  final FlutterPlotState state;

  
  @override
  void paint(Canvas canvas, Size size) {

    state.debugLog('Repainting Graphs');

    canvas.clipRect(Rect.fromLTRB(0, 0, state.windowConstraints.maxWidth, state.windowConstraints.maxHeight));

    state.graphRenderPoints.forEach((key, values) {
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


class CrosshairPainter extends CustomPainter {

  const CrosshairPainter({
    required this.state
    });

  final FlutterPlotState state;


  @override
  void paint(Canvas canvas, Size size) {

    state.debugLog('Repainting Crosshairs');

    final crosshairLinePaint = Paint();
    final crosshairBoxPaint = Paint();
    final textPainter = TextPainter(textDirection: TextDirection.ltr,);
    
    canvas.clipRect(Rect.fromLTRB(-state.sidePadding, 0, state.windowConstraints.maxWidth + state.sidePadding, state.windowConstraints.maxHeight));

    for (var graph in state.widget.plot.graphs) {

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

      Offset pixelPosition = state.pixelLUT[crosshair.value]!.pixel;

      textPainter.text = TextSpan(
          style: const TextStyle(color: Colors.white), 
          text: ' ${crosshair.label}\n  x: ${state.xCrosshairLabels[crosshair.value!.dx]} \n  y: ${state.yCrosshairLabels[crosshair.value!.dy]}');
        textPainter.layout(
              minWidth: 0,
              maxWidth: crosshair.width,
            );

      canvas.drawLine(Offset(0, pixelPosition.dy), Offset(state.windowConstraints.maxWidth, pixelPosition.dy), linePaint);

      canvas.drawLine(Offset(pixelPosition.dx, state.windowConstraints.maxHeight), Offset(pixelPosition.dx, 0), linePaint);

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



