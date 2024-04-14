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

  final Function(Offset)? onDragStarted;

  /// Function called every time the annotation is moved
  final Function(Offset)? onDragEnd;



}