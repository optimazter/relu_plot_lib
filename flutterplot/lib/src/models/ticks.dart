import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutterplot/src/utils/utils.dart';




const Map<int, String> SIPrefix = {
  -12:'p', -9:'n', -6:'µ', -3:'m', 0:'', 3: 'k', 6:'M', 9:'G', 12: 'T'
};



const prettyLogTicks = <double>[5, 3, 2, 1];



class Ticks {


  Ticks({
    this.predefinedTicks = const [],
    this.logarithmic = false,
    this.pretty = false,
    this.fractionDigits = 3,
    this.numTicks = 20,
    this.unit,
  }): assert(!(predefinedTicks.isNotEmpty && pretty == true), '[pretty] can not be true if [ticks] is specified.');


  /// Predefine a list of ticks.
  final List<double> predefinedTicks;

  /// Determines if the ticks should be generated using the flutterplot "pretty" strategy. The "naive" strategy is default.
  final bool pretty;

  /// Number of fraction digits to display at each tick.
  final int fractionDigits;

  /// Number of ticks to display. 
  final int numTicks;

  /// The unit to denote the ticks.
  final String? unit;

  /// Determines if the axis should be logarithmic or not. 
  final bool logarithmic;


  bool get empty => predefinedTicks.isEmpty && !pretty && numTicks == 0;

  final List<double> _ticks = [];
  final List<String> _labels = [];

  List<double> get ticks => _ticks;

  List<String> get labels => _labels;
  

  void update(double minimum, double maximum) {
    if (empty) {
      return null;
    }
    _ticks.clear();
    _labels.clear();

    if (pretty) {
      if (logarithmic) {
        _updateTicksPixels125(minimum, maximum);
      } else {
        _updateTicksPixelsBase10(minimum, maximum);
      }
    }
    else if (predefinedTicks.isNotEmpty) {
      _updateTicksPixelsFrom(predefinedTicks);
    }
    else {
      _updateTicksPixelsNaive(minimum, maximum);
    }

    if (logarithmic) {
      _labels.addAll(_ticks.map((x) => pow(10, x).toDouble()).map(_toLabel));
    } else {
      _labels.addAll(_ticks.map(_toLabel));
    }


  }


  String _toLabel(double number) => number >= 1e3 || number <= -1e3 ? '${number.toStringAsExponential(fractionDigits)} ${unit??''}' : '${number.toStringAsPrecision(fractionDigits)} ${unit??''}';



  void _updateTicksPixels125(double minimum, double maximum) {
    
    final double minimumBase10 = pow(10, minimum).toDouble();
    final double maximumBase10 = pow(10, maximum).toDouble();
  
    if ((maximumBase10 / minimumBase10) < 10) {

      _updateTicksPixelsBase10(minimum, maximum);

    } else {
      int magnitude = maximumBase10.magnitude();
      while (_ticks.length < numTicks) {
        num power = pow(10, magnitude);
        for (int i = 0; i < prettyLogTicks.length; i++) {
          final double x = (prettyLogTicks[i] * power).toLog10();

          if (_ticks.isNotEmpty && (_ticks.last - x) / (maximum - minimum) > 0.05) {
            _ticks.add(x);
          }
          if (_ticks.isEmpty && x < maximum) {
            _ticks.add(x);
          }
        }
        magnitude--;
      }

    }
  }

  void _updateTicksPixelsBase10(double minimum, double maximum) {
    final power = ((maximum - minimum) / 1.5).magnitude();
    final order = pow(10, power).toDouble();
    final maxBase = (maximum / order).round();
    double x = maximum;
    int i = maxBase;
    while (_ticks.length < numTicks) {
      x = i * order;
      _ticks.add(x);
      i--;
    }
  }

  void _updateTicksPixelsFrom(List<double> ticksToAdd) {
    _ticks.addAll(ticksToAdd);
  }

  void _updateTicksPixelsNaive(double minimum, double maximum) {
    final n = numTicks + 1;
    final double stepSize = (maximum - minimum) / n;
    double x = minimum;
    for (int i = 1; i < n; i++) {
      x += stepSize;
      _ticks.add(x);
    }
  }


  @override
  bool operator ==(covariant Ticks other) => 
          listEquals(predefinedTicks, other.predefinedTicks) && 
          pretty == other.pretty && 
          fractionDigits == other.fractionDigits &&
          numTicks == other.numTicks &&
          unit == other.unit;

  @override
  int get hashCode => ticks.hashCode * pretty.hashCode * numTicks.hashCode;


}

