class Scaler {

  double _pxMin = 0;
  double _min = 0;
  double _s = 0;

  void setScaling(double min, double max, double pxMin, double pxMax) {

    _min = min;
    _pxMin = pxMin;
    _s = (pxMax - pxMin) / (max - min);
  }


  double scale(double val) {
      return (val -_min) * _s + _pxMin;
  }

  double inverse(double val) {
      return (val - _pxMin) * (1/_s) + _min;
  }

  

  @override
  bool operator ==(covariant Scaler other) {
    return other._pxMin == _pxMin && other._min == _min && other._s == _s;
  }

  @override
  int get hashCode => _s.hashCode;


}
