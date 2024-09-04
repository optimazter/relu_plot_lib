import 'package:flutter/material.dart';
import 'package:relu_plot_lib/relu_plot_lib.dart';

class GraphPainter extends CustomPainter {


  const GraphPainter({
    required this.graphPaths, 
    required this.transform, 
    });


  final Map<Graph, Path> graphPaths;
  final Matrix4 transform;



  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(0, 0, size.width, size.height));
    canvas.transform(transform.storage);

    graphPaths.forEach((graph, path) {

      final paint = Paint()..color = graph.color ?? const Color(0x00000000);
      paint.style = PaintingStyle.stroke;
      canvas.drawPath(path, paint);

    }); 

    canvas.restore();
  }


  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }


  
}