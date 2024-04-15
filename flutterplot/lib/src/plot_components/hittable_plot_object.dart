import 'dart:ui';

abstract class HittablePlotObject {

  HittablePlotObject({
    required this.width, 
    required this.height, 
    required this.value,
    this.onDragStarted,
    this.onDragEnd});

  /// The width of the SizedBox which containts the [child]
  final double width;

  /// The height of the SizedBox which containts the [child]
  final double height;

  Offset? value;

  /// Function called every time the object drag has started
  final Function(Offset)? onDragStarted;

  /// Function called every time the object has been moved
  final Function(Offset)? onDragEnd;



}