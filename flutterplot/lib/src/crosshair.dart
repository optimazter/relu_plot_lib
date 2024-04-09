

import 'dart:ui';


/// A crosshair which can be attached to a FlutterPlot [Graph].
/// 
/// The crosshair can be moved around on the graph by dragging the mouse 
/// while pressing the left mouse button. The crosshair will display the 
/// coordinate (x,y) where the crosshair is located on the graph.
/// 
class Crosshair {
  

  Crosshair(
    {required this.label, 
    required this.active, 
    required this.yPadding,
    this.color,
    this.width = 120,
    this.height = 70,
    this.value,});

  /// The label to display for this crosshair.
  final String label;

  /// The color of the display box as well as circle for this crosshair.
  final Color? color;

  /// The padding (in pixels) on the y-axis which seperates 
  /// the display box from the top of the plot.
  final double yPadding; 

  /// The width (in pixels) of the display box.
  final double width; 

  /// The height (in pixels) of the display box.
  final double height; 

  /// Wheter this crosshair responds on mouse movement or not.
  bool active;

  /// The coordinate (in the Plot coordinate system contrary to the screen's pixel coordinates).
  Offset? value;

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