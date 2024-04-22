
import 'dart:collection';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterplot/flutterplot.dart';

/// A graph which can be painted in a FlutterPlot [Plot] object
/// 
/// The graph painted must be specified by the [x] and [y] parameters.
/// Note that [x] and [y] must be of equal length.

class Graph {

  Graph( {
    required x, 
    required y,
    this.color,
    this.linethickness,
    this.annotations,
    this.crosshairs, 
    }
  ) : _xUnmodified = x, _yUnmodified = y;

  /// The x coordinates of the graph.
  final List<num> _xUnmodified;

  /// The y coordinates of the graph.
  final List<num> _yUnmodified;

  /// The color of the graph.
  final Color? color;

  /// The linethickness of the graph.
  final double? linethickness;

  /// The Annotations which will be attached to this graph.
  final List<Annotation>? annotations;

  /// The Crosshairs which will be attached to this graph.
  final List<Crosshair>? crosshairs;


  final List<double> _x = [];
  final List<double> _y = [];

  UnmodifiableListView<double> get X => UnmodifiableListView(_x);
  UnmodifiableListView<double> get Y => UnmodifiableListView(_y);


  /// Initializes the graph in either the log space or as is.
  void init({bool xLog = false, bool yLog = false}) {
    if (_x.length != _xUnmodified.length) {
      if (xLog) {
        _x.addAll(_xUnmodified.map((x) => log(x) / ln10));
      } else {
        _x.addAll(_xUnmodified.map((x) => x.toDouble()));
      }
    }
    if (_y.length != _yUnmodified.length) {
      if (yLog) {
        _y.addAll(_yUnmodified.map((y) => log(y) / ln10));
      } else {
        _y.addAll(_yUnmodified.map((y) => y.toDouble()));
      }
    }
  }



  @override
  bool operator ==(Object other) =>
      other is Graph &&
      other.runtimeType == runtimeType &&
      other._x == _x &&
      other._y == _y &&
      listEquals(other.crosshairs, crosshairs) &&
      listEquals(other.annotations, annotations);

  @override
  int get hashCode => _x.hashCode * _y.hashCode;
  
  

}

