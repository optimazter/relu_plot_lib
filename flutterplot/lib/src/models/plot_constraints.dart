import 'dart:ui';

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

  late final double xMin;
  late final double xMax;
  late final double yMin;
  late final double yMax;


  bool get isFinite => xMin.isFinite && xMax.isFinite && yMin.isFinite && yMax.isFinite;


  @override
  bool operator ==(covariant PlotConstraints other) {
    return other.xMin == xMin && other.xMax == xMax && other.yMin == yMin && other.yMax == yMax;
  }

  @override
  int get hashCode => xMin.hashCode;

}