import 'dart:ui';

/// A crosshair which can be attached to a FlutterPlot [Graph].
/// 
/// The crosshair can be moved around on the graph by dragging the mouse 
/// while pressing the left mouse button. The crosshair will display the 
/// position (x,y) where the crosshair is located on the graph.
/// 
class Crosshair  {

  Crosshair(
    {required this.label, 
    required this.yPadding,
    required this.color,
    this.width = 120,
    this.height = 70,
    this.position = Offset.infinite,
    this.onDragEnd,})
    : halfWidth = width / 2, 
    halfHeight = height / 2;

  /// The label to display for this crosshair.
  final String label;

  /// The padding (in pixels) on the y-axis which seperates 
  /// the display box from the top of the plot.
  final double yPadding; 

  /// The color of the display box as well as circle for this crosshair.
  Color color;

  /// The width of the Crosshair
  final double width;

  /// The height of the Crosshair
  final double height;

  /// The [width] divided by 2
  final double halfWidth;

  /// The [height] divided by 2
  final double halfHeight;

  /// The position in the Plot space where the Crosshair is lcoated
  Offset position;

  /// Function called every time the Crosshair has been moved
  final Function(Offset position)? onDragEnd;

  /// The previous index which will be used for searching for the nearest point
  /// when moving the crosshair.
  int prevIndex = 0;

  
  @override
  bool operator ==(Object other) =>
      other is Crosshair &&
      other.width == width &&
      other.height == height &&
      other.runtimeType == runtimeType &&
      other.position == position &&
      other.label == label;



  @override
  int get hashCode => label.hashCode * position.hashCode;

  

  
}