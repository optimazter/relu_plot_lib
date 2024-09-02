import 'package:flutter/material.dart';


/// A draggable plot object which can be placed and moved around the plot.
/// 
abstract class DraggablePlotObject {


  DraggablePlotObject({
    required this.width,
    required this.height,
    this.position = Offset.infinite,
    this.onDragStart,
    this.onDragEnd
  });

  /// The hit box width of the object in pixels.
  final double width;

  /// The hit box height of the object in pixels.
  final double height;

  /// The local position within the plot of the object.
  Offset position;

  /// Function called every time the PlotObject is hit.
  Function(DraggablePlotObject obj)? onDragStart;

  /// Function called every time the PlotObject has been moved
  Function(DraggablePlotObject obj)? onDragEnd;

  /// Function called on PointerMoveEvent if this object is hit.
  void onDrag(PointerMoveEvent event);

  /// Logic for deciding if the object is hit or not.
  bool isHit(PointerDownEvent event, Matrix4 transform);


}