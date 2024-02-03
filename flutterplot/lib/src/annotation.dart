
import 'package:flutter/material.dart';
import 'package:flutterplot/src/provider.dart';



class Annotation {

  Annotation({
    required this.child,
    this.value,
  });

  final Widget child;

  Offset? value;


}


class _AnnotationWidget extends StatefulWidget {

  _AnnotationWidget({
    required this.annotation,
    required this.state,
  });

  final Annotation annotation;
  final PlotStateManager state;


  @override
  State<StatefulWidget> createState() => _AnnotationWidgetState();


}

class _AnnotationWidgetState extends State<_AnnotationWidget> {

  @override
  Widget build(BuildContext context) {

    Offset pixel = widget.state.getPixelFromValue(widget.annotation.value!);

    return Positioned(
      left: pixel.dx,
      top: pixel.dy,
      child: Draggable(
        child: widget.annotation.child,
        feedback: widget.annotation.child,
        // childWhenDragging: Opacity(
        //       opacity: .3,
        //       child: widget.annotation.child,
        // ),
        onDragStarted: () {
          widget.state.currentInteraction = Interaction.annotation;
        },
        onDragEnd: (details) => setState(() {
          widget.annotation.value = widget.state.getValueFromPixel(details.offset);
          widget.state.currentInteraction = Interaction.crosshair;
        })
      )
    );
}
  }


  class AnnotationLayer extends StatelessWidget {
    
    AnnotationLayer({required this.state});
    final PlotStateManager state;


    @override
    Widget build(BuildContext context) {
      List<_AnnotationWidget> annotationWidgets = state.annotations.map((annotation) => _AnnotationWidget(annotation: annotation, state: state)).toList();
      return Stack(children: annotationWidgets);

    }



    
  }





