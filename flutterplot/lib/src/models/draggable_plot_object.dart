
import 'package:flutter/material.dart';

abstract class DraggablePlotObject {


  DraggablePlotObject({
    required this.width,
    required this.height,
    this.position = Offset.infinite,
    final Function(Offset position)? onDragStart,
    final Function(Offset position)? onDragEnd
  }) : 
  _onDragStart = onDragStart,
  _onDragEnd = onDragEnd;

  final double width;
  final double height;

  Offset position;


  /// Function called every time the PlotObject is hit.
  final Function(Offset position)? _onDragStart;

  /// Function called every time the PlotObject has been moved
  final Function(Offset position)? _onDragEnd;


  void onDragStart() {
    _onDragStart?.call(position);
  }

  void onDragEnd() {
    _onDragEnd?.call(position);
  }

  void onDrag(PointerMoveEvent event);

  bool isHit(PointerDownEvent event, Matrix4 transform);


}