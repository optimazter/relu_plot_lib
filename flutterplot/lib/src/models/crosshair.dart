import 'dart:ui';

import 'package:flutter/src/gestures/events.dart';
import 'package:flutterplot/flutterplot.dart';
import 'package:flutterplot/src/models/draggable_plot_object.dart';
import 'package:flutterplot/src/utils/utils.dart';

/// A crosshair which can be attached to a FlutterPlot [Graph].
/// 
/// The crosshair can be moved around on the graph by dragging the mouse 
/// while pressing the left mouse button. The crosshair will display the 
/// position (x,y) where the crosshair is located on the graph.
/// 
class Crosshair extends DraggablePlotObject {

  Crosshair(
    {required this.label, 
    required this.yPadding,
    required this.color,
    this.fractionDigits = 1,
    super.width = 120,
    super.height = 70,
    super.position,
    super.onDragStart,
    super.onDragEnd,
    })
    : halfWidth = width / 2, 
    halfHeight = height / 2;

  /// The label to display for this crosshair.
  final String label;

  /// The padding (in pixels) on the y-axis which seperates 
  /// the display box from the top of the plot.
  final double yPadding; 

  /// The color of the display box as well as circle for this crosshair.
  Color color;

  /// The [width] divided by 2
  final double halfWidth;

  /// The [height] divided by 2
  final double halfHeight;

  /// The number of fraction digits to show in the crosshair label.
  final int fractionDigits;

  /// The previous index which will be used for searching for the nearest point
  /// when moving the crosshair.
  int prevIndex = 0;

  

  @override
  bool isHit(PointerDownEvent event, Matrix4 transform) {
    final double globalX = transform.transformX(position.dx);
    if (event.localPosition.dx >= globalX - halfWidth && event.localPosition.dx <= globalX + halfWidth
        && event.localPosition.dy >= yPadding && event.localPosition.dy <= yPadding + height) {
      return true;
    }
    return false;
  }

  @override
  void onDrag(PointerMoveEvent event) {
  }

  void adjustPosition(PointerMoveEvent event, List<double> x, List<double> y, double xMin, double xMax) {
    final int? i = _getXIndexFromPixel(x, event.localPosition.dx, xMin, xMax, event.localDelta.dx);
    if (i != null) {
      prevIndex = i;
      position = Offset(x[i], y[i]);
    }
  }



  int? _getXIndexFromPixel(List<double> x, double xCandidate, double xMin, double xMax, double dx) {
    if (xCandidate <= xMin) {
      return 0;
    }
    if (xCandidate >= xMax) {
      return x.length - 1;
    }
    if (dx < 0) {
      for (int i = prevIndex - 1; i > 0; i--) {
        if (x[i - 1] <= xCandidate && xCandidate <= x[i + 1]) {
          return i;
        }
      }
    }
    for (int i = prevIndex + 1; i < x.length - 1; i++) {
      if (x[i - 1] <= xCandidate && xCandidate <= x[i + 1]) {
        return i;
      }
    } 
    return null;

  }


  @override
  bool operator ==(Object other) =>
      other is Crosshair &&
      other.label == label &&
      other.yPadding == yPadding &&
      other.color == color &&
      other.width == width &&
      other.height == height &&
      other.runtimeType == runtimeType &&
      other.position == position &&
      other.fractionDigits == fractionDigits;



  @override
  int get hashCode => label.hashCode * position.hashCode;
  

  
}