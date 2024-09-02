import 'dart:ui';



/// A constraints object which specifies the bounding box of a [plot]
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
  }) :
    xMin = min.dx,
    xMax = max.dx,
    yMin = min.dy,
    yMax = max.dy;
  


  PlotConstraints copyWith({
    final double? xMin,
    final double? xMax,
    final double? yMax,
    final double? yMin,
  }) {
    return PlotConstraints(
      xMin: xMin ?? this.xMin, 
      xMax: xMax ?? this.xMax, 
      yMin: yMin ?? this.yMin, 
      yMax: yMax ?? this.yMax
    );
  }

  /// Minimum value on x-axis.
  final double xMin;

  /// Maximum value on x-axis.
  final double xMax;

  /// Minimum value on y-axis.
  final double yMin;
  
  /// Maximum value on y-axis.
  final double yMax;


  bool get isFinite => xMin.isFinite && xMax.isFinite && yMin.isFinite && yMax.isFinite;


  @override
  bool operator ==(covariant PlotConstraints other) {
    return other.xMin == xMin && other.xMax == xMax && other.yMin == yMin && other.yMax == yMax;
  }

  @override
  int get hashCode => xMin.hashCode;

}