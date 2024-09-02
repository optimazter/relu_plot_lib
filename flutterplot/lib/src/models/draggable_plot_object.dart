
import 'package:flutter/material.dart';

abstract class DraggablePlotObject {


  DraggablePlotObject({
    required this.width,
    required this.height,
    this.position = Offset.infinite,
    final Function(DraggablePlotObject position)? onDragStart,
    final Function(DraggablePlotObject position)? onDragEnd
  }) : 
  _onDragStart = onDragStart,
  _onDragEnd = onDragEnd;

  final double width;
  final double height;

  Offset position;


  /// Function called every time the PlotObject is hit.
  final Function(DraggablePlotObject position)? _onDragStart;

  /// Function called every time the PlotObject has been moved
  final Function(DraggablePlotObject position)? _onDragEnd;


  void onDragStart() {
    _onDragStart?.call(this);
  }

  void onDragEnd() {
    _onDragEnd?.call(this);
  }

  void onDrag(PointerMoveEvent event);

  bool isHit(PointerDownEvent event, Matrix4 transform);


}