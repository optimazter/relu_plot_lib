
import 'package:flutter/material.dart';
import 'package:relu_plot_lib/relu_plot_lib.dart';
import 'package:relu_plot_lib/src/utils/utils.dart';

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
          left: globalPosition.dx - annotation.width / 2,
          top: globalPosition.dy - annotation.height / 2,
          child: annotation.child
        );
      }).toList(),
    );
  }



  
}