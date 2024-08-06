import 'dart:ui';

import 'package:flutterplot/src/utils/utils.dart';

class PlotConstraints {

  PlotConstraints({
      required this.xMin,
      required this.xMax,
      required this.yMin,
      required this.yMax,
  });

  PlotConstraints.fromOffset({
    required Offset min,
    required Offset max,
  }) {
    xMin = min.dx;
    xMax = max.dx;
    yMin = min.dy;
    yMax = max.dy;
  }

  late double xMin;
  late double xMax;
  late double yMin;
  late double yMax;


  bool get isFinite => xMin.isFinite && xMax.isFinite && yMin.isFinite && yMax.isFinite;


  void toLog10() {
    xMin = xMin.toLog10();
    xMax = xMax.toLog10();
    yMin = yMin.toLog10();
    yMax = yMax.toLog10();
  }

  @override
  bool operator ==(covariant PlotConstraints other) {
    return other.xMin == xMin && other.xMax == xMax && other.yMin == yMin && other.yMax == yMax;
  }

  @override
  int get hashCode => xMin.hashCode;

}