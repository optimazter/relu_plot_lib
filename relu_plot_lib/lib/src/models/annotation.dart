import 'package:flutter/material.dart';
import 'package:relu_plot_lib/src/models/draggable_plot_object.dart';
import 'package:relu_plot_lib/src/utils/utils.dart';



/// An annotation which can be attached to a [Graph].
/// 
/// The annotation can be moved around on the graph by dragging the mouse 
/// while pressing the left mouse button. The annotation can hold a Widget of any kind specified by [child]
/// 
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

  /// The child widget to display.
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
