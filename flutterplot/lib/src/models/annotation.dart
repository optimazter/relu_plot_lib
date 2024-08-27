import 'package:flutter/material.dart';
import 'package:flutterplot/src/models/draggable_plot_object.dart';





// ignore: must_be_immutable
class Annotation extends DraggablePlotObject {
  
   Annotation({
    required super.width,
    required super.height,
    super.position,
    super.onDragStart,
    super.onDragEnd,
    Widget? child,
  })
  : _child = Center(child: child);

  final Widget _child;

  Widget get child => _child;


}
