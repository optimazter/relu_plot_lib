import 'dart:ui';
import 'package:relu_plot_lib/relu_plot_lib.dart';
import 'package:relu_plot_lib/src/utils/utils.dart';
import 'package:vector_math/vector_math_64.dart';


class Camera {

  Camera({
    required this.canvasWidth,
    required this.canvasHeight,
    required PlotConstraints localConstraints,
    required this.minimumScale,
    required this.maximumScale,
  }) : 
    _projection = makeOrthographicMatrix(
      localConstraints.xMin, 
      localConstraints.xMax, 
      localConstraints.yMax, 
      localConstraints.yMin, 
      -1, 1)..scale(canvasWidth / 2, canvasHeight / 2),
    _affine = Matrix4.identity()..translate(-localConstraints.xMin, -localConstraints.yMax);
    

  final double canvasWidth;
  final double canvasHeight;

  final double minimumScale;
  final double maximumScale;

  final Matrix4 _affine;
  final Matrix4 _projection;

  Matrix4 get transform => _projection * _affine;
  Matrix4? get transformInverted => Matrix4.tryInvert(transform);


  PlotConstraints get localConstraints {
    final transformInverted = Matrix4.inverted(transform);
    return PlotConstraints.fromOffset(
        min: transformInverted.transformOffset(Offset(0, canvasHeight)), 
        max: transformInverted.transformOffset(Offset(canvasWidth, 0))
      );
  } 


  void scale(double x, double y, double scaleX, double scaleY) {
    _affine.translate(x, y);
    _affine.scale(scaleX, scaleY);
    if (_affine.scaleX < minimumScale || _affine.scaleX > maximumScale) {
      _affine.scale(1 / scaleX, 1 / scaleY);
    }
    if (_affine.scaleY < minimumScale || _affine.scaleY > maximumScale) {
      _affine.scale(1 / scaleX, 1 / scaleY);
    }
    _affine.translate(-x, -y);

  }

  void move(double x, double y) {
    _affine.translate(x, y);
  }



}