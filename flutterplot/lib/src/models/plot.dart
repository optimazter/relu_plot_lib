import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterplot/src/widgets/plot_view.dart';
import 'graph.dart';
import 'plot_constraints.dart';

/// A widget that displays a FlutterPlot Plot.
/// 
/// The plot will display the FlutterPlot Graph objects specified
/// 
/// This sample shows a simple graph:
/// 
/// {@tool snippet}
/// 
/// ```dart
/// Plot(
///   graphs: [
///     Graph(
///       x: [0, 1, 2, 3, 4, 5], 
///       y: [0, 1, 2, 3, 4, 5],
///       crosshairs: [
///         Crosshair(
///           label: 'Crosshair', 
///           active: true, 
///           yPadding: 10,
///         )],
///     )
/// ],)
///  ```
/// {@end-tool}


class Plot extends StatelessWidget {
   ///Creates a widget that displays a FlutterPlot Plot
  
  const Plot({
    super.key,
    required this.graphs,
    this.xUnit,
    this.yUnit, 
    this.xTicks,
    this.yTicks,
    this.numXTicks,
    this.numYTicks,
    this.constraints,
    this.decimate,
    this.onResize,
    this.xLog = false,
    this.yLog = false,
    this.strokeWidth = 1,
    this.padding = 0,
    this.ticksFractionDigits = 3,
    this.crosshairFractionDigits = 2,
  });


  /// The FlutterPlot graphs to paint.
  final List<Graph> graphs;
  
  /// The label which will annotate [xTicks].
  final String? xUnit;

  /// The label which will annotate [yTicks].
  final String? yUnit;

  /// The list of ticks for the x-axis.
  final List<double>? xTicks;

  /// The list of ticks for the y-axis.
  final List<double>? yTicks;

  /// Number of ticks for the x-axis.
  /// 
  /// Is only used for automatic generation of ticks,
  /// will not be used if [xTicks] is used.
  final int? numXTicks;

  /// Number of ticks for the y-axis.
  /// 
  /// Is only used for automatic generation of ticks,
  /// will not be used if [yTicks] is used.
  final int? numYTicks;

  /// Initial Plot constraints
  final PlotConstraints? constraints;

  /// Specifies the integer which will decimate the update frequency
  /// used by [onPointerMove] when the Plot is moved.
  /// If null, decimate will be calculated according to the screen refresh rate.
  final int? decimate;

  /// Function called every time the Plot is resized
  final Function(PlotConstraints constraints, PlotConstraints extremes)? onResize;

  /// Determines if the x-axis should be in the log10 space.
  final bool xLog;

  /// Determines if the y-axis should be in the log10 space.
  final bool yLog;

  /// The width of the graph lines
  final double strokeWidth;

  /// The padding to use around the plot borders
  final double padding;

  /// The number of digits to use for [xTicks] and [yTicks].
  final int ticksFractionDigits;

  /// The number of digits to use for FlutterPlot crosshair
  final int crosshairFractionDigits;

  @override
  Widget build(BuildContext context) => PlotView(plot: this);


  bool isEqualConfigTo(Plot other) =>
    listEquals(graphs, other.graphs) &&
    other.xUnit == xUnit &&
    other.yUnit == yUnit &&
    listEquals(xTicks, yTicks) &&
    other.numXTicks == numXTicks &&
    other.numYTicks == numYTicks &&
    other.constraints == constraints &&
    other.decimate == decimate &&
    other.xLog == xLog &&
    other.yLog == yLog &&
    other.strokeWidth == strokeWidth &&
    other.padding == padding &&
    other.ticksFractionDigits == ticksFractionDigits;

  }

    








    





