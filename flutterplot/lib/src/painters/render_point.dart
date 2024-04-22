import 'dart:ui';

class RenderPoint {

  RenderPoint({
    required this.pixel,
    required this.paint,
    required this.id,
  });

  Offset pixel;
  final int id;
  final Paint paint;

  static RenderPoint get zero {
    return RenderPoint(pixel: const Offset(0, 0), paint: Paint(), id: -1);
  }

  @override
  bool operator ==(covariant RenderPoint other) {
    return other.id == id;
  }

  @override
  int get hashCode => paint.hashCode;

}