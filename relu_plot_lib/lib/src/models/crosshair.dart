import 'dart:math';
import 'dart:ui';

import 'package:flutter/src/gestures/events.dart';
import 'package:relu_plot_lib/relu_plot_lib.dart';
import 'package:relu_plot_lib/src/models/draggable_plot_object.dart';
import 'package:relu_plot_lib/src/utils/utils.dart';

/// A crosshair which can be attached to a [Graph].
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
    });

  /// The label to display for this crosshair.
  final String label;

  /// The padding (in pixels) on the y-axis which seperates 
  /// the display box from the top of the plot.
  final double yPadding; 

  /// The color of the display box as well as circle for this crosshair.
  Color color;

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
  void onDrag(PointerMoveEvent event, Matrix4 eventTransform) {
  }

  void adjustPosition(PointerMoveEvent event, Matrix4 eventTransform, List<double> x, List<double> y, double xMin, double xMax, bool xLog, bool yLog) {
    final xPosition = eventTransform.transformX(event.localPosition.dx);
    if (xPosition <= xMin) {
      prevIndex = 0;
      position = Offset(x[prevIndex], y[prevIndex]);
    }
    else if (xPosition >= xMax) {
      prevIndex = x.length - 1;
      position = Offset(x[prevIndex], y[prevIndex]);
    }
    else if (x.length > 100) {
      final int? i = _getXIndexFromPixel(x, xPosition, event.localDelta.dx);
      if (i != null) {
        prevIndex = i;
        position = Offset(x[i], y[i]);
      }
    } else {
      final int? i = x.firstIndexWhereOrNull((x) => x >= xPosition);
      if (i != null) {
        prevIndex = i;
        position = interpolation(Offset(x[i - 1], y[i - 1]), Offset(x[i], y[i]), xPosition, xLog, yLog);
      }
    }
  }


  Offset interpolation(Offset p1, Offset p2, double x, bool xLog, bool yLog) {
    final y;
    if (xLog && !yLog) {
      y = p1.dy + (pow(10, x) - pow(10, p1.dx)) * (p2.dy - p1.dy) / (pow(10, p2.dx) - pow(10, p1.dx));
    } 
    else if (!xLog && yLog) {
      y = pow(10, p1.dy) + (x - p1.dx) * (pow(10, p2.dy) - pow(10, p1.dy)) / (p2.dx - p1.dx);
    } else {
      y = p1.dy + (x - p1.dx) * (p2.dy - p1.dy) / (p2.dx - p1.dx);
    }
    return Offset(x, y);
  }


  int? _getXIndexFromPixel(List<double> x, double xCandidate, double dx) {
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