


import 'dart:ui';

class DraggablePlotObject {


  final double width;
  final double height;

  Offset position;


  /// Function called every time the PlotObject is hit.
  final Function(DraggablePlotObject position)? onDragStart;

  /// Function called every time the PlotObject has been moved
  final Function(Offset position)? onDragEnd;


  DraggablePlotObject({
    required this.width,
    required this.height,
    this.position = Offset.infinite,
    this.onDragStart,
    this.onDragEnd
  });


}