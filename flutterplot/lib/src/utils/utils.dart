import 'dart:math';
import 'package:flutter/material.dart';




void debugLog(String message) {
    debugPrint('FlutterPlot: $message');
  }


class FlutterPlotException implements Exception {
  String cause;
  FlutterPlotException(this.cause);
}


extension FlutterPlotList<T> on List<T> {

  int? firstIndexWhereOrNull(bool Function(T element) test) {
    for (int i = 0; i < this.length; i++) {
      if (test(this[i])) return i;
    }
    return null;
  }

  updateAll(Function(T element) update) {
    for (int i = 0; i < this.length; i++) {
      this[i] = update(this[i]);
    }
  }

  keepFromFirstWhere(bool Function(T element) test, [List? other]) {
    for (int i = 0; i < this.length; i++) {
      if (test(this[i])) {
        break;
      }
      this.removeAt(i);
      other?.removeAt(i);
    }
  }


}


extension FlutterPlotDouble on double {

  int magnitude() {
    if (this.compareTo(0.0) == 0) {
      return 0;
    }
    double m = log(this.abs()) / ln10;
    var truncated = m.truncate();
    return m < 0 && truncated != m ? truncated - 1 : truncated;
  }

  double toLog10() => log(this) / ln10;


}

extension FlutterPlotOffset on Offset {

  Offset toLog10(bool x, bool y) => Offset(x ? log(this.dx) / ln10 : dx, y ? log(this.dy) / ln10 : dy);

}

extension FlutterPlotMatrix4 on Matrix4 {


  /// Transform [x] of type [double] using the transformation defined by
  /// this.
  double transformX(double x) => (this.storage[0] * x) + this.storage[12];
  
  /// Transform [y] of type [double] using the transformation defined by
  /// this.
  double transformY(double y) => (this.storage[5] * y) + this.storage[13];


  /// Transform [arg] of type [Offset] using the transformation defined by
  /// this.
  Offset transformOffset(Offset arg) {
    final x = arg.dx;
    final y = arg.dy;
    final x_ = (this.storage[0] * x) +
        (this.storage[4] * y) +
        this.storage[12];
    final y_ = (this.storage[1] * x) +
        (this.storage[5] * y) +
        this.storage[13];
    return Offset(x_, y_);
  }


  double get scaleX => this.row0.x;
  double get scaleY => this.row1.y;
  
}


double toLog10(double a) => a.toLog10();



