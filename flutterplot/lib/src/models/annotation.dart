
import 'package:flutter/material.dart';
import 'package:flutterplot/flutterplot.dart';
import 'package:flutterplot/src/models/hittable_plot_object.dart';



/// An annotation to attach to a FlutterPlot [Graph].
/// 
/// The annotation can be any widget that the user want to attach 
/// to the graph.
/// The annotation can be moved by clicking and draging it to the 
/// desired the location, the annotation will be attached to this point
/// in the local coordinate system created by the parent [Plot]. 
/// 
class Annotation<T> extends HittablePlotObject {

  Annotation({
    required this.child,
    super.width = 100,
    super.height = 100,
    super.coordinate,
    this.value,
    super.onDragStarted,
    super.onDragEnd,
  });

  /// The widget to use as annotation.
  final Widget child;

  T? value;


}
