import 'package:flutter/material.dart';
import 'package:flutterplot/flutterplot.dart';
import 'package:flutterplot/src/utils.dart';


class _AnnotationWidget extends StatefulWidget {

  const _AnnotationWidget({
    required this.annotation,
    required this.getPixelFromValue,
  });

  final Annotation annotation;
  final Function getPixelFromValue;


  @override
  State<StatefulWidget> createState() => _AnnotationWidgetState();


}

class _AnnotationWidgetState extends State<_AnnotationWidget> {

  late Offset pixel;


  @override
  Widget build(BuildContext context) {

    pixel = widget.getPixelFromValue(widget.annotation.coordinate ?? Offset.zero);

    return Positioned(
          left: pixel.dx - widget.annotation.width / 2,
          top: pixel.dy - widget.annotation.height / 2,
          child: SizedBox(
            width: widget.annotation.width,
            height: widget.annotation.height,
            child: widget.annotation.child,
          )
     );
    }
  }


  class AnnotationLayer extends StatelessWidget {
    
    const AnnotationLayer({super.key, required this.graphs, required this.getPixelFromValue});
    final List<Graph> graphs;
    final Function getPixelFromValue;


    @override
    Widget build(BuildContext context) {
      debugLog('Repainting Annotations');
      final List<_AnnotationWidget> annotationWidgets = [];
      for (var graph in graphs) {
        graph.annotations?.forEach(
          (annotation)  => annotationWidgets.add(_AnnotationWidget(annotation: annotation, getPixelFromValue: getPixelFromValue)
          )
        );
      }
      return Stack(children: annotationWidgets);

    }



    
  }





