

import 'dart:ui';

class Crosshair {
  
  Crosshair(
    {required this.label, 
    required this.active, 
    required this.yPadding,
    this.width = 100,
    this.height = 50,
    this.value,});

  final String label;
  final bool active;
  final double yPadding; //in Pixels
  final double width; //in Pixels
  final double height; //in Pixels

  Offset? value;
  int prevIndex = 0;

  

  @override
  bool operator ==(Object other) =>
      other is Crosshair &&
      other.runtimeType == runtimeType &&
      other.value == value &&
      other.label == label;



  @override
  int get hashCode => label.hashCode * value.hashCode;

  

  
}