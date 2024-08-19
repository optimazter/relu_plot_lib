import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterplot/src/models/ticks.dart';
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
/// 
/// Navigate around the plot by using a mouse or toch pad.
/// The Plot can be scaled with scrolling/panning a mouse or touchpad.
/// The Plot can be scaled on x-axis only by pressing shift + scroll/panning.
/// The Plot can be scaled on y-axis only by pressing ctrl + scroll/panning.


class Plot extends StatelessWidget {

   ///Creates a widget that displays a FlutterPlot Plot
  
  const Plot({
    super.key,
    required this.graphs,
    this.xTicks,
    this.yTicks,
    this.constraints,
    this.decimate,
    this.onConstraintsChanged,
    this.strokeWidth = 1,
    this.padding = 0,
    this.crosshairFractionDigits = 2,
    this.minimumScale = 0.25,
    this.maximumScale = 50,
  });



  /// The FlutterPlot graphs to paint.
  final List<Graph> graphs;

  /// The ticks which will annotate the x-axis.
  final Ticks? xTicks;

  /// The ticks which will annotate the y-axis.
  final Ticks? yTicks;

  /// Initial Plot constraints. 
  /// If xTicks or yTicks is logarithmic, it is expected that the constraints are in the log10 space.
  final PlotConstraints? constraints;

  /// Specifies the integer which will decimate the update frequency
  /// used by [onPointerMove] when the Plot is moved.
  /// If null, decimate will be calculated according to the screen refresh rate.
  final int? decimate;

  /// Function called every time the PlotConstraints changes. 
  /// To optimize performance, do not use this feature!
  /// If xTicks or yTicks is logarithmic, the constraints and extremes are in the log10 space.
  final Function(PlotConstraints constraints, PlotConstraints extremes)? onConstraintsChanged;

  /// The width of the graph lines
  final double strokeWidth;

  /// The padding to use around the plot borders
  final double padding;

  /// The number of digits to use for FlutterPlot crosshair
  final int crosshairFractionDigits;

  /// The minimum scale factor possible for scaling the plot. 
  final double minimumScale;

  /// The maximum scale factor possible for scaling the plot.
  final double maximumScale;



  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => PlotView(
      plot: this, 
      width: constraints.maxWidth,
      height: constraints.maxHeight,
    )
  );



  bool isEqualConfigTo(Plot other) =>
    listEquals(graphs, other.graphs) &&
    other.xTicks == xTicks &&
    other.yTicks == yTicks &&
    other.constraints == constraints &&
    other.decimate == decimate &&
    other.strokeWidth == strokeWidth &&
    other.padding == padding &&
    other.crosshairFractionDigits == crosshairFractionDigits &&
    other.minimumScale == minimumScale &&
    other.maximumScale == maximumScale;



  void toLog(bool xLog, bool yLog) {
    graphs.forEach((graph) => graph.toLog(xLog, yLog));
  }


  }

    








    





