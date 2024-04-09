
import 'package:flutter/material.dart';
import 'package:flutterplot/src/provider.dart';



/// An annotation to attach to a FlutterPlot [Graph].
/// 
/// The annotation can be any widget that the user want to attach 
/// to the graph.
/// The annotation can be moved by clicking and draging it to the 
/// desired the location, the annotation will be attached to this point
/// in the local coordinate system created by the parent [Plot]. 
/// 
class Annotation {

  Annotation({
    required this.child,
    this.position,
  });

  /// The widget to use as annotation.
  final Widget child;

  /// The coordinate (in the Plot coordinate system contrary to the screen's pixel coordinates).
  Offset? position;


}


class _AnnotationWidget extends StatefulWidget {

  _AnnotationWidget({
    required this.annotation,
    required this.state,
    required this.context,
  });

  final Annotation annotation;
  final PlotState state;
  final BuildContext context;


  @override
  State<StatefulWidget> createState() => _AnnotationWidgetState();


}

class _AnnotationWidgetState extends State<_AnnotationWidget> {

  late Offset pixel;


  void onDragEnd(Offset point) {
  
    var renderBox = widget.context.findRenderObject() as RenderBox;
    var localPoint = renderBox.globalToLocal(point);
    widget.annotation.position = widget.state.getValueFromPixel(localPoint);
    widget.state.currentInteraction = Interaction.crosshair;
  }

  @override
  Widget build(BuildContext context) {

    pixel = widget.state.getPixelFromValue(widget.annotation.position!);

    return Positioned(
          left: pixel.dx,
          top: pixel.dy,
          child: Draggable(
              child: widget.annotation.child,
              feedback: widget.annotation.child,
              childWhenDragging: Center(),
              onDragStarted: () {
                widget.state.currentInteraction = Interaction.annotation;
              },
              onDragEnd: (details) => setState(() {
                widget.state.debugLog('Repainting Annotation');
                onDragEnd(details.offset);  
              })
          )
        );
    }
  }


  class AnnotationLayer extends StatelessWidget {
    
    AnnotationLayer({required this.state, required this.context});
    final PlotState state;
    final BuildContext context;


    @override
    Widget build(BuildContext context) {
      List<_AnnotationWidget> annotationWidgets = state.annotations.map((annotation) => _AnnotationWidget(annotation: annotation, state: state, context: context)).toList();
      return Stack(children: annotationWidgets);

    }



    
  }





