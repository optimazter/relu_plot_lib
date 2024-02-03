
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
  late final Map<double, double> mapYToX = Map.fromIterables(Y, X);

  late final double xMax;
  late final double xMin;
  late final double yMax;
  late final double yMin;

  late double _lowerXConstraints;
  late double _upperXConstraints;
  late double _lowerYConstraints;
  late double _upperYConstraints;

  List<double> xToPaint = [];
  List<double> yToPaint = [];

  double get lowerXConstraints => _lowerXConstraints;
  double get upperXConstraints => _upperXConstraints;
  double get lowerYConstraints => _lowerYConstraints;
  double get upperYConstraints => _upperYConstraints;
  
  void setXConstraints(double lower, double upper) {
    print(lower);
    _lowerXConstraints = lower;
    _upperXConstraints = upper;
    xToPaint = _xToPaint;
    yToPaint = _yToPaint;
  }

  void setYConstraints(double lower, double upper) {
    _lowerYConstraints = lower;
    _upperYConstraints = upper;
    xToPaint = _xToPaint;
    yToPaint = _yToPaint;
  }

  List<double> get _xToPaint => X.where((x) => x >= _lowerXConstraints && 
                                              x <= _upperXConstraints &&
                                              mapXToY[x]! >= _lowerYConstraints &&
                                              mapXToY[x]! <= _upperYConstraints).toList();

  List<double> get _yToPaint => xToPaint.map((x) => mapXToY[x]!).toList();

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

    _upperXConstraints = xMax;
    _lowerXConstraints = xMin;

    _upperYConstraints = yMax;
    _lowerYConstraints = yMin;
    
    xToPaint = X;
    yToPaint = Y;


  }
  


  

}