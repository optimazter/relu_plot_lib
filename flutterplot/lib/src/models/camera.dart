import 'dart:ui';
import 'package:flutterplot/flutterplot.dart';
import 'package:flutterplot/src/utils/utils.dart';
import 'package:vector_math/vector_math_64.dart';


class Camera {

  Camera({
    required this.canvasWidth,
    required this.canvasHeight,
    required PlotConstraints localConstraints,
    required double minimumScale,
    required double maximumScale,
  }) : 
    _minimumScaleX = minimumScale * canvasWidth / 2,
    _maximumScaleX = maximumScale * canvasWidth / 2,
    _minimumScaleY = minimumScale * canvasHeight / 2,
    _maximumScaleY = maximumScale * canvasWidth / 2,
    _projection = makeOrthographicMatrix(
      localConstraints.xMin, 
      localConstraints.xMax, 
      localConstraints.yMax, 
      localConstraints.yMin, 
      -1, 1),
    _scale = Matrix4.identity()..scale(canvasWidth / 2, canvasHeight / 2),
    _translation = Matrix4.identity()..translate((localConstraints.xMax - localConstraints.xMin) / 2, -(localConstraints.yMax - localConstraints.yMin) / 2);
    

  final double canvasWidth;
  final double canvasHeight;

  final double _minimumScaleX;
  final double _maximumScaleX;
  final double _minimumScaleY;
  final double _maximumScaleY;

  final Matrix4 _scale;
  final Matrix4 _translation;
  final Matrix4 _projection;

  Matrix4 get transform => _scale * _projection * _translation;
  Matrix4? get transformInverted => Matrix4.tryInvert(transform);


  PlotConstraints get localConstraints {
    final transformInverted = Matrix4.inverted(transform);
    return PlotConstraints.fromOffset(
        min: transformInverted.transformOffset(Offset(0, canvasHeight)), 
        max: transformInverted.transformOffset(Offset(canvasWidth, 0))
      );
  } 


  void scale(double scaleX, double scaleY) {
    
    _scale.translate(1.0, 1.0);
    _scale.scale(scaleX, scaleY);

    if (_scale.scaleX < _minimumScaleX || _scale.scaleX > _maximumScaleX) {
      _scale.scale(1 / scaleX, 1.0);
    }
    if (_scale.scaleY < _minimumScaleY || _scale.scaleY > _maximumScaleY) {
      _scale.scale(1.0, 1 / scaleY);
    }
   _scale.translate(-1.0, -1.0);

  }

  void move(double x, double y) {
    _translation.translate(x, y);
  }



}