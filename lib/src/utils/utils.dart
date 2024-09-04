import 'dart:math';
import 'package:flutter/material.dart';

void debugLog(String message) {
  debugPrint('relu_plot_lib: $message');
}

extension ReluPlotLibList<T> on List<T> {
  int? firstIndexWhereOrNull(bool Function(T element) test) {
    for (int i = 0; i < length; i++) {
      if (test(this[i])) return i;
    }
    return null;
  }

  updateAll(Function(T element) update) {
    for (int i = 0; i < length; i++) {
      this[i] = update(this[i]);
    }
  }

  keepFromFirstWhere(bool Function(T element) test, [List? other]) {
    for (int i = 0; i < length; i++) {
      if (test(this[i])) {
        break;
      }
      removeAt(i);
      other?.removeAt(i);
    }
  }
}

extension ReluPlotLibDouble on double {
  int magnitude() {
    if (compareTo(0.0) == 0) {
      return 0;
    }
    double m = log(abs()) / ln10;
    var truncated = m.truncate();
    return m < 0 && truncated != m ? truncated - 1 : truncated;
  }

  double toLog10() => log(this) / ln10;
}

extension ReluPlotLibOffset on Offset {
  Offset toLog10(bool x, bool y) =>
      Offset(x ? log(dx) / ln10 : dx, y ? log(dy) / ln10 : dy);
}

extension ReluPlotLibMatrix4 on Matrix4 {
  /// Transform [x] of type [double] using the transformation defined by
  /// this.
  double transformX(double x) => (storage[0] * x) + storage[12];

  /// Transform [y] of type [double] using the transformation defined by
  /// this.
  double transformY(double y) => (storage[5] * y) + storage[13];

  /// Transform [arg] of type [Offset] using the transformation defined by
  /// this.
  Offset transformOffset(Offset arg) {
    final x = arg.dx;
    final y = arg.dy;
    final x_ = (storage[0] * x) + (storage[4] * y) + storage[12];
    final y_ = (storage[1] * x) + (storage[5] * y) + storage[13];
    return Offset(x_, y_);
  }

  double get scaleX => row0.x;
  double get scaleY => row1.y;
}

double toLog10(double a) => a.toLog10();
