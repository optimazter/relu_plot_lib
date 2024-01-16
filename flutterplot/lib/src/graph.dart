
import 'dart:math';
import 'dart:ui';
import 'package:flutterplot/flutterplot.dart';

class Graph {

  Graph( {
    required this.X, 
    required this.Y,
    this.color,
    this.linethickness,
    this.numHorizontalGridLines,
    this.annotations,
    this.crosshair,
  }
) {
  _initValues();
}

  final List<double> X;
  final List<double> Y;
  final Color? color;
  final double? linethickness;
  final double? numHorizontalGridLines;
  final List<Annotation>? annotations;
  final Crosshair? crosshair;



  late final Map<double, double> mapXToY = Map.fromIterables(X, Y);
  late final Map<double, double> mapYToX = Map.fromIterables(X, Y);

  late final double xMax;
  late final double xMin;
  late final double yMax;
  late final double yMin;



  @override
  bool operator ==(Object other) =>
      other is Graph &&
      other.runtimeType == runtimeType &&
      other.X == X;


  @override
  int get hashCode => X.hashCode * Y.hashCode;
  
  void _initValues() {
    if (X.length != Y.length) {

      throw Exception('X and Y must be the same length');

    }
    if (X.length < 2) {

      throw Exception('A minimum of 2 values are needed to plot a graph');
      
    }
    xMax = X.reduce(max);
    xMin = X.reduce(min);

    yMax = Y.reduce(max);
    yMin = Y.reduce(min);

    

  }
  


  

}