

import 'dart:ui';

import 'package:flutterplot/src/hittable_plot_object.dart';


/// A crosshair which can be attached to a FlutterPlot [Graph].
/// 
/// The crosshair can be moved around on the graph by dragging the mouse 
/// while pressing the left mouse button. The crosshair will display the 
/// coordinate (x,y) where the crosshair is located on the graph.
/// 
class Crosshair extends HittablePlotObject {
  

  Crosshair(
    {required this.label, 
    required this.active, 
    required this.yPadding,
    this.color,
    super.width = 120,
    super.height = 70,
    super.value,});

  /// The label to display for this crosshair.
  final String label;

  /// The color of the display box as well as circle for this crosshair.
  final Color? color;

  /// The padding (in pixels) on the y-axis which seperates 
  /// the display box from the top of the plot.
  final double yPadding; 

  /// Wheter this crosshair should be initially active or not. Only one crosshair should be active.
  bool active;

  /// The previous index which will be used for searching for the nearest point
  /// when moving the crosshair.
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