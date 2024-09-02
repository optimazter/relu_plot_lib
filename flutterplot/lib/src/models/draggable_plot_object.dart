
import 'package:flutter/material.dart';

abstract class DraggablePlotObject {


  DraggablePlotObject({
    required this.width,
    required this.height,
    this.position = Offset.infinite,
    this.onDragStart,
    this.onDragEnd
  });

  final double width;
  final double height;

  Offset position;


  /// Function called every time the PlotObject is hit.
  Function(DraggablePlotObject obj)? onDragStart;

  /// Function called every time the PlotObject has been moved
  Function(DraggablePlotObject obj)? onDragEnd;

  void onDrag(PointerMoveEvent event);

  bool isHit(PointerDownEvent event, Matrix4 transform);


}