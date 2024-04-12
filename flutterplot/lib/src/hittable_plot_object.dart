import 'dart:ui';

abstract class HittablePlotObject {

  HittablePlotObject({required this.width, required this.height, required this.value});

  /// The width of the SizedBox which containts the [child]
  final double width;

  /// The height of the SizedBox which containts the [child]
  final double height;

  Offset? value;

  Function? getPixelFromValue;


}