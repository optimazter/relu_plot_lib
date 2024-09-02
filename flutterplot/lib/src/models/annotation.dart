import 'package:flutter/material.dart';
import 'package:flutterplot/src/models/draggable_plot_object.dart';
import 'package:flutterplot/src/utils/utils.dart';




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
  
  @override
  bool isHit(PointerDownEvent event, Matrix4 transform) {
    final Offset globalPosition = transform.transformOffset(position);
    if (event.localPosition.dx >= globalPosition.dx && event.localPosition.dx <= globalPosition.dx + width
        && event.localPosition.dy >= globalPosition.dy && event.localPosition.dy <= globalPosition.dy + height) {
      return true;
    }
    return false;
  }
  
  @override
  void onDrag(PointerMoveEvent event) {
    position += event.localDelta;
  }

  @override
  bool operator ==(Object other) =>
      other is Annotation &&
      other.width == width &&
      other.height == height &&
      other.runtimeType == runtimeType &&
      other._child == _child &&
      other.position == position;



  @override
  int get hashCode => child.hashCode * position.hashCode;


}
