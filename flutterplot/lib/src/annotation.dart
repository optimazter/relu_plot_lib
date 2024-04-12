
import 'package:flutter/material.dart';
import 'package:flutterplot/flutterplot.dart';
import 'package:flutterplot/src/hittable_plot_object.dart';
import 'package:flutterplot/src/provider.dart';



/// An annotation to attach to a FlutterPlot [Graph].
/// 
/// The annotation can be any widget that the user want to attach 
/// to the graph.
/// The annotation can be moved by clicking and draging it to the 
/// desired the location, the annotation will be attached to this point
/// in the local coordinate system created by the parent [Plot]. 
/// 
class Annotation extends HittablePlotObject {


  Annotation({
    required this.child,
    super.width = 100,
    super.height = 100,
    super.value,
    this.onDragStarted,
    this.onDragEnd,
  });

  /// The widget to use as annotation.
  final Widget child;

  final Function(Offset)? onDragStarted;

  /// Function called every time the annotation is moved
  final Function(Offset)? onDragEnd;



}


class _AnnotationWidget extends StatefulWidget {

  const _AnnotationWidget({
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
  
    final renderBox = widget.context.findRenderObject() as RenderBox;
    final localPoint = renderBox.globalToLocal(point);
    widget.annotation.value = widget.state.getValueFromPixel(localPoint);
    widget.state.currentInteraction = Interaction.crosshair;

    if (widget.annotation.onDragEnd != null) {
      widget.annotation.onDragEnd!(widget.annotation.value!);
    }

  }

  @override
  Widget build(BuildContext context) {

    pixel = widget.state.getPixelFromValue(widget.annotation.value!);

    return Positioned(
          left: pixel.dx - widget.annotation.width / 2,
          top: pixel.dy - widget.annotation.width / 2,
          child: SizedBox(
            width: widget.annotation.width,
            height: widget.annotation.height,
            child: widget.annotation.child,
          )
     );
    }
  }


  class AnnotationLayer extends StatelessWidget {
    
    const AnnotationLayer({super.key, required this.state, required this.context});
    final PlotState state;
    final BuildContext context;


    @override
    Widget build(BuildContext context) {
      final List<_AnnotationWidget> annotationWidgets = [];
      for (var graph in state.plot.graphs) {
        graph.annotations?.forEach(
          (annotation)  => annotationWidgets.add(_AnnotationWidget(annotation: annotation, state: state, context: context)
          )
        );
      }
      return Stack(children: annotationWidgets);

    }



    
  }





