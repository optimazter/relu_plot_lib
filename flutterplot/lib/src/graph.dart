import 'dart:ui';

import 'package:flutterplot/flutterplot.dart';

class Graph {

  Graph( {
    required this.X, 
    required this.Y,
    this.color,
    this.linethickness,
    this.annotations,
    this.crosshair,
  }
);

  final List<double> X;
  final List<double> Y;
  final Color? color;
  final double? linethickness;
  final List<Annotation>? annotations;
  final Crosshair? crosshair;



  late final Map<double, double> mapXToY = Map.fromIterables(X, Y);
  late final Map<double, double> mapYToX = Map.fromIterables(X, Y);
  


  @override
  bool operator ==(Object other) =>
      other is Graph &&
      other.runtimeType == runtimeType &&
      other.X == X;


  @override
  int get hashCode => X.hashCode * Y.hashCode;


  

}