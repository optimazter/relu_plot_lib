
import 'package:flutter/material.dart';
import 'package:flutterplot/flutterplot.dart';
import 'package:flutterplot/src/utils/utils.dart';

class AnnotationLayer extends StatelessWidget {

  AnnotationLayer({
    required this.annotations,
    required this.transform,
  });

  final List<Annotation> annotations;
  final Matrix4 transform;


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: annotations.map((annotation) {
        final globalPosition = transform.transformOffset(annotation.position);
        return Positioned(
          left: globalPosition.dx,
          top: globalPosition.dy,
          child: annotation.child
        );
      }).toList(),
    );
  }



  
}