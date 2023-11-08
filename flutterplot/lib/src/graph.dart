import 'dart:ui';

import 'package:flutterplot/flutterplot.dart';

class Graph {

  Graph( {
    required this.X, 
    required this.Y,
    this.color,
    this.linethickness,
    this.annotation,
    this.crosshair,
  }
);

  final List<double> X;
  final List<double> Y;
  final Color? color;
  final double? linethickness;
  final List<Annotation>? annotation;
  final List<Crosshair> ?crosshair;

  

}