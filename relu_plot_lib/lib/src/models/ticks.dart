import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:relu_plot_lib/src/utils/utils.dart';




const Map<int, String> SIPrefix = {
  -12:'p', -9:'n', -6:'µ', -3:'m', 0:'', 3: 'k', 6:'M', 9:'G', 12: 'T'
};

const prettyLogTicks = <double>[1, 2, 3, 5];

const prettySteps = <double>[1, 2, 5, 10];



/// The ticks to annotate an axis of the [plot].
class Ticks {


  Ticks({
    this.predefinedTicks = const [],
    this.logarithmic = false,
    this.pretty = false,
    this.fractionDigits = 3,
    this.maxNumTicks = 15,
    this.minNumTicks = 11,
    this.unit,
  }): assert(!(predefinedTicks.isNotEmpty && pretty == true), '[pretty] can not be true if [ticks] is specified.');


  /// Predefine a list of ticks.
  final List<double> predefinedTicks;

  /// Determines if the ticks should be generated using the flutterplot "pretty" strategy. The "naive" strategy is default.
  final bool pretty;

  /// Number of fraction digits to display at each tick.
  final int fractionDigits;

  /// Number of ticks to display. 
  final int minNumTicks;

  /// Number of ticks to display. 
  final int maxNumTicks;

  /// The unit to denote the ticks.
  final String? unit;

  /// Determines if the axis should be logarithmic or not. 
  final bool logarithmic;


  final List<double> _ticks = [];
  final List<String> _labels = [];

  bool get empty => predefinedTicks.isEmpty && !pretty && maxNumTicks == 0;

  List<double> get ticks => _ticks;

  List<String> get labels => _labels;
  

  void update(double minimum, double maximum) {
    if (minimum.isInfinite || maximum.isInfinite) {
      return;
    }
    if (empty) {
      return;
    }
    _ticks.clear();
    _labels.clear();

    if (pretty) {
      if (logarithmic) {
        _updatePrettyTicksLog(minimum, maximum);
      } else {
        _updatePrettyTicks(minimum, maximum);
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


  String _toLabel(double number) {
    if (!number.isFinite) {
      return '';
    }
    int magnitude = number.magnitude();
    while (magnitude > SIPrefix.keys.first && magnitude < SIPrefix.keys.last) {
      if (SIPrefix.keys.contains(magnitude)) {
        return '${(number/pow(10, magnitude)).toStringAsFixed(fractionDigits)} ${SIPrefix[magnitude]}';
      } 
      magnitude--;
    }
    return '$number';
  }
    


  void _updatePrettyTicksLog(double minimum, double maximum) {
    
    final double minimumBase10 = pow(10, minimum).toDouble();
    final double maximumBase10 = pow(10, maximum).toDouble();

    if (minimumBase10.isInfinite || maximumBase10.isInfinite) {
      return;
    }
  
    if ((maximumBase10 / minimumBase10) < 10) {

      _updatePrettyTicks(minimum, maximum);

    } else {
      int magnitude = minimumBase10.magnitude();
      double tick = minimum;
      while (tick < maximum) {
        num power = pow(10, magnitude);
        for (int i = 0; i < prettyLogTicks.length; i++) {
          tick = (prettyLogTicks[i] * power).toLog10();
          _ticks.add(tick);
        }
        magnitude++;
      }
    }
  }


  void _updateTicksPixelsFrom(List<double> ticksToAdd) {
    _ticks.addAll(ticksToAdd);
  }

  void _updateTicksPixelsNaive(double minimum, double maximum) {
    final n = maxNumTicks + 1;
    final double stepSize = (maximum - minimum) / n;
    double x = minimum;
    for (int i = 1; i < n; i++) {
      x += stepSize;
      _ticks.add(x);
    }
  }

  void _updatePrettyTicks(double minimum, double maximum) {
    if (_ticks.isEmpty || minimum < _ticks.first || maximum > _ticks.last || _getNumTicksInRange(minimum, maximum) < minNumTicks) {
      _ticks.clear();
      final stepSize = _getPrettyStepSize(minimum, maximum);
      final startTick = (minimum / stepSize).floor() * stepSize;
      double tick = startTick;
      while (tick < maximum) {
        _ticks.add(tick);
        tick += stepSize;
      }
    } 
  }

  double _getPrettyStepSize(double minimum, double maximum) {
    final range = maximum - minimum;
    final roughStep = range / maxNumTicks;
    final magnitude = roughStep.magnitude();
    final power = pow(10, magnitude);

    for (double step in prettySteps) {
      final double prettyStep = step * power;
      if (roughStep <= prettyStep) {
        return prettyStep;
      }
    }
    return 10.0 * magnitude;
  }


  int _getNumTicksInRange(double minimum, double maximum) {
    final startIndex = _ticks.firstIndexWhereOrNull((x) => x < minimum) ?? 0;
    final stopIndex = _ticks.firstIndexWhereOrNull((x) => x > maximum) ?? 0;
    return stopIndex - startIndex;
  }


  @override
  bool operator ==(covariant Ticks other) => 
          listEquals(predefinedTicks, other.predefinedTicks) && 
          pretty == other.pretty && 
          fractionDigits == other.fractionDigits &&
          minNumTicks == other.minNumTicks &&
          maxNumTicks == other.maxNumTicks &&
          unit == other.unit;

  @override
  int get hashCode => ticks.hashCode * pretty.hashCode;


}

