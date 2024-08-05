import 'dart:ui';

abstract class HittablePlotObject {

  HittablePlotObject({
    required this.width, 
    required this.height, 
    this.position = Offset.infinite,
    this.onDragStarted,
    this.onDragEnd}) 
    : halfWidth = width / 2, 
      halfHeight = height / 2;

  /// The width of the SizedBox which containts the [child]
  final double width;

  /// The height of the SizedBox which containts the [child]
  final double height;

  /// The [width] divided by 2
  final double halfWidth;

  /// The [height] divided by 2
  final double halfHeight;

  /// The position in the Plot space where the object is lcoated
  Offset position;

  /// Function called every time the object drag has started
  final Function(HittablePlotObject obj)? onDragStarted;

  /// Function called every time the object has been moved
  final Function(HittablePlotObject obj)? onDragEnd;



}