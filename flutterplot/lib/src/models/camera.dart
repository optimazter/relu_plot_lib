import 'dart:ui';

import 'package:flutterplot/flutterplot.dart';
import 'package:flutterplot/src/utils/utils.dart';
import 'package:vector_math/vector_math_64.dart';


class Camera {

  Camera({
    required this.canvasWidth,
    required this.canvasHeight,
    required PlotConstraints localConstraints,
    this.minZoom = 0.5,
    this.maxZoom = 25,
  }) 
  : _projection = makeOrthographicMatrix(
    localConstraints.xMin, 
    localConstraints.xMax, 
    localConstraints.yMax, 
    localConstraints.yMin, 
  -1, 1)
  ..scale(canvasWidth / 2, canvasHeight / 2)
  ..translate(0.0, -(localConstraints.yMax - localConstraints.yMin));


  final double canvasWidth;
  final double canvasHeight;

  final double minZoom;
  final double maxZoom;

  final Matrix4 _scale = Matrix4.identity();
  final Matrix4 _translation = Matrix4.identity();
  final Matrix4 _projection;

  Matrix4 get transform => _scale * _projection * _translation;
  Matrix4? get transformInverted => Matrix4.tryInvert(transform);


  PlotConstraints get localConstraints {
    final transformInverted = Matrix4.inverted(transform);
    return PlotConstraints.fromMinMax(
        min: transformInverted.transformOffset(Offset(0, canvasHeight)), 
        max: transformInverted.transformOffset(Offset(canvasWidth, 0))
      );
  } 


  void zoom(double scaleX, double scaleY) {
    
    _scale.translate(canvasWidth / 2, canvasHeight / 2);
    _scale.scale(scaleX, scaleY);

    if (_scale.scaleX < minZoom || _scale.scaleX > maxZoom) {
      _scale.scale(1 / scaleX, 1.0);
    }
    if (_scale.scaleY < minZoom || _scale.scaleY > maxZoom) {
      _scale.scale(1.0, 1 / scaleY);
    }
    _scale.translate(-canvasWidth / 2, -canvasHeight / 2);

  }

  void move(double x, double y) {
    _translation.translate(x, y);
  }



}