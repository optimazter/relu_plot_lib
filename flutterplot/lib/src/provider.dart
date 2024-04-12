
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutterplot/flutterplot.dart';
import 'package:flutterplot/src/hittable_plot_object.dart';



enum Interaction {
  crosshair,
  graph,
  annotation
} 


class PlotState  {
  PlotState({required this.plot}) {
    _init();
  }

  final Plot plot;

  final xScaler = Scaler();
  final yScaler = Scaler();

  BoxConstraints windowConstraints = BoxConstraints();
  late PlotConstraints plotConstraints;
  late final PlotConstraints plotExtremes;

  final Map<Offset, RenderPoint> pixelLUT = {};
  final Map<Graph, List<RenderPoint>> graphRenderPoints = {};
  final Map<String, double> _xTicks = {};
  final Map<String, double>  _yTicks = {};
  final Map<double, String> xCrosshairLabels = {};
  final Map<double, String> yCrosshairLabels = {};

  Annotation? activeAnnotation;
  Crosshair? activeCrosshair;
  Graph? activeGraph;

  double get sidePadding => plot.padding + 40;
  double get overPadding => plot.padding;


  double get xMovementScalar => (plotConstraints.xMax - plotConstraints.xMin).abs() / windowConstraints.maxWidth;
  double get yMovementScalar => (plotConstraints.yMax - plotConstraints.yMin).abs() / windowConstraints.maxHeight;

  ValueNotifier<int> crosshairState = ValueNotifier(0);

  int decimate = 0;


  void debugLog(String message) {
    debugPrint('FlutterPlot: $message');
  }



  Map<String, double> get xTicks {
    Map<String, double> filteredTicks = {};
    _xTicks.forEach((key, val) {
      if (val > 0 && val < windowConstraints.maxWidth) {
        filteredTicks[key] = val;
      }
    });
    return filteredTicks;
  }

  Map<String, double> get yTicks {
    Map<String, double> filteredTicks = {};
    _yTicks.forEach((key, val) {
      if (val > 0 && val < windowConstraints.maxHeight) {
        filteredTicks[key] = val;
      }
    });
    return filteredTicks;
  }

  Interaction currentInteraction = Interaction.crosshair;

  int calculateDecimate() {
    final display = WidgetsBinding.instance.platformDispatcher.views.first.display;
    debugLog('Measured Refresh Rate was ${display.refreshRate} Hz');
    return display.refreshRate ~/ 10;
  }


  Offset getPixelFromAnnotation(Annotation object) {
    return getPixelFromValue(object.value!);
  }

  Offset getPixelFromCrosshair(Crosshair object) {
    return Offset(
      xScaler.scale(object.value!.dx),
      object.yPadding
    );
  }

  bool hit(PointerDownEvent event, HittablePlotObject object) {

    final Offset eventPixel = event.localPosition;

    final Offset pixelPosition = object.getPixelFromValue!(object);

    final halfWidth = object.width / 2;
    final halfHeight = object.height / 2;

    if (eventPixel.dx >= pixelPosition.dx - halfWidth && eventPixel.dx <= pixelPosition.dx + halfWidth
      && eventPixel.dy >= pixelPosition.dy - halfHeight && eventPixel.dy <= pixelPosition.dx + halfHeight) {
        return true;
      }

    return false;
  }


  bool checkAnnotationHit(PointerDownEvent event) {

    for (Graph graph in plot.graphs) {

      if (graph.annotations == null) {
        continue;
      }
      for (Annotation annotation in graph.annotations!) {
        if (hit(event, annotation)) {
          activeAnnotation = annotation;
          return true;
        }
      }
    }
    return false;
  }


  bool checkCrosshairHit(PointerDownEvent event) {

    for (Graph graph in plot.graphs) {

      if (graph.crosshairs == null) {
        continue;
      }
      for (Crosshair crosshair in graph.crosshairs!) {
        if (hit(event, crosshair)) {
          activeCrosshair = crosshair;
          activeGraph = graph;
          return true;
        }
      } 
    }
    return false;
  }

  void moveActiveAnnotation(PointerMoveEvent event) {

    activeAnnotation?.value = getValueFromPixel(event.localPosition);

  }

  void moveActiveCrosshair(PointerMoveEvent event) {

    if (activeCrosshair != null) {

      final int? i = _getXIndexFromPixel(activeGraph!, event.localPosition.dx, event.localDelta.dx, activeCrosshair!.prevIndex);
      
      if (i != null) {
        activeCrosshair?.value =  Offset(activeGraph!.X[i], activeGraph!.Y[i]);
        activeCrosshair?.prevIndex = i;  
      }
    }     

  }


  bool isWithinPlotPixels(Offset pixel) => pixel.dx >= 0 && pixel.dx <= windowConstraints.maxWidth && pixel.dy >= 0 && pixel.dy <= windowConstraints.minWidth;


  bool isWithinPlotValues(Offset value) => value.dx >= plotConstraints.xMin && value.dx <= plotConstraints.xMax && value.dy >= plotConstraints.yMin && value.dy <= plotConstraints.yMax;



  void movePlot(Offset moveDelta) {

    final xMovement = moveDelta.dx * xMovementScalar;
    final yMovement = moveDelta.dy * yMovementScalar;

    plotConstraints.xMin -= xMovement;
    plotConstraints.xMax -= xMovement;
    plotConstraints.yMin += yMovement;
    plotConstraints.yMax += yMovement;


  }


  bool setXConstraints(double scrollDelta) {

    final xMovement = scrollDelta * xMovementScalar;

    final double newXMin = plotConstraints.xMin += xMovement;
    final double newXMax = plotConstraints.xMax -= xMovement;
    if (newXMin < newXMax && newXMax > plotExtremes.xMin) {
      plotConstraints.xMin = newXMin;
      plotConstraints.xMax = newXMax;
      return true;
    }
    return false;
  }

  bool setYConstraints(double scrollDelta) {

    final yMovement = scrollDelta * yMovementScalar; 

    final double newYMin = plotConstraints.yMin += yMovement;
    final double newYMax = plotConstraints.yMax -= yMovement;

    if (newYMin < newYMax && newYMax > plotExtremes.yMin) {
      plotConstraints.yMin = newYMin;
      plotConstraints.yMax = newYMax;
      return true;
    }
    return false;
  }


  int? _getXIndexFromPixel(Graph graph, double pxX,  double dx, int prevIndex) {
    double x = xScaler.inverse(pxX);
    if (x <= plotExtremes.xMin) {
      return 0;
    }
    if (x >= plotExtremes.xMax) {
      return graph.X.length - 1;
    }
    if (dx < 0) {
      for (int i = prevIndex - 1; i > 0; i --) {
        if (graph.X[i - 1] <= x && x <= graph.X[i + 1]) {
          return i;
        }
      }
    }
    for (int i = prevIndex + 1; i < graph.X.length - 1; i ++) {

      if (graph.X[i - 1] <= x && x <= graph.X[i + 1]) {
        return i;
      }
    } 
    return null;

  }


  void initXTicks() {
    _xTicks.clear();
    final ticks = plot.xTicks ?? _getXTicks();
    bool toLog = plot.xTicks != null;
    _initTicks(ticks, _xTicks, xScaler, plot.xUnit ?? '', plot.xLog, toLog, false);
  }

  void initYTicks() {
    _yTicks.clear();
    final ticks = plot.yTicks ?? _getYTicks();
    bool toLog = plot.yTicks != null;
    _initTicks(ticks, _yTicks, yScaler, plot.yUnit ?? '', plot.yLog, toLog, true);

  }

  String toLogarithmicLabel(num valPow, String unit) {
    switch (valPow) {
      case >= 1e12:
        return '${(valPow / 1e12).toStringAsFixed(plot.ticksFractionDigits)} T$unit';
      case >= 1e9:
        return '${(valPow / 1e9).toStringAsFixed(plot.ticksFractionDigits)} G$unit';
      case >= 1e6:
        return '${(valPow / 1e6).toStringAsFixed(plot.ticksFractionDigits)} M$unit';
      case >= 1e3:
        return '${(valPow / 1e3).toStringAsFixed(plot.ticksFractionDigits)} K$unit';
      default:
        return '${valPow.toStringAsFixed(plot.ticksFractionDigits)} $unit';
    }

  }

  void _initTicks(List<double> ticks, Map<String, double> labels, Scaler scaler, String unit, bool isLog, bool toLog, bool y) {
    for (int i = 0; i < ticks.length; i++) {
      String label;
      double val = ticks[i];
      if (isLog) {
        num valPow;
        if (toLog) {
          valPow = val;
          val = log(val) / ln10;
        } else {
          valPow = pow(e, val*ln10);
        }
        label = toLogarithmicLabel(valPow, unit);
      } else {
        label = '${val.toStringAsFixed(plot.ticksFractionDigits)} $unit';
      }
      if (y) {
        labels[label] = windowConstraints.maxHeight - scaler.scale(val);
      } else {
        labels[label] = scaler.scale(val);
      }
    }
  }


  List<double> _getXTicks() {
    int n = plot.numXTicks ?? 10;
    n += 1;
    final List<double> xTicks = [];
    for (int i = 1; i < n; i++) {
      double x = plotConstraints.xMin + (i) * (plotConstraints.xMax - plotConstraints.xMin) / n;
      xTicks.add(x);
    }
    return xTicks;
  }

  List<double> _getYTicks() {
    int n = plot.numYTicks ?? 10;
    n += 1;
    final List<double> yTicks = [];
    for (int i = 1; i < n; i++) {
      double y = plotConstraints.yMin + (i) * (plotConstraints.yMax - plotConstraints.yMin) / n;
      yTicks.add(y);
    }
    return yTicks;
  }

  Offset getValueFromPixel(Offset pixel) => Offset(xScaler.inverse(pixel.dx), yScaler.inverse(windowConstraints.maxHeight - pixel.dy));

  Offset getPixelFromValue(Offset value) => Offset(xScaler.scale(value.dx), windowConstraints.maxHeight - yScaler.scale(value.dy));



  void resizePlot( [bool xOnly = false, bool yOnly = false]) {

    debugLog('Resizing Plot');

    if (!yOnly) {
     xScaler.setScaling(plotConstraints.xMin, plotConstraints.xMax, 0, windowConstraints.maxWidth);
    }
    if (!xOnly) {
     yScaler.setScaling(plotConstraints.yMin, plotConstraints.yMax, 0, windowConstraints.maxHeight);
    }


    pixelLUT.forEach((value, point) {

      point.pixel = Offset(xScaler.scale(value.dx), windowConstraints.maxHeight - yScaler.scale(value.dy));

    });

    graphRenderPoints.forEach((graph, points) {
    
      points = points.where((pt) => pt.pixel.dx >= 0 &&
                                                  pt.pixel.dx <= windowConstraints.maxWidth)
                                                  .toList();
    });

    initXTicks();
    initYTicks();

    if (plot.onResize != null) {
      plot.onResize!(plotConstraints);
    }


  }

  void initCrosshairLabels(Map<double, String> labels, List<double> vals, bool toLog) {
    for (int i = 0; i < vals.length; i++) {
      double val = vals[i];
      if (toLog) {
        labels[val] = pow(e, val * ln10).toStringAsFixed(plot.crosshairFractionDigits);
      } else {
        labels[val] = val.toStringAsFixed(plot.crosshairFractionDigits);
      }
    }
  }

  void resizeWindow(BoxConstraints windowConstraints) {

    debugLog('Resizing Window');

    this.windowConstraints = windowConstraints;
    resizePlot();
    
  }



  void _init() {

    debugLog('Initializing Plot');
    disposeValues();

    decimate = plot.decimate ?? calculateDecimate();

    double xMin = double.infinity;
    double xMax = double.negativeInfinity;
    double yMin = double.infinity;
    double yMax = double.negativeInfinity;

    for (Graph graph in plot.graphs) {

      graph.init(xLog: plot.xLog, yLog: plot.yLog);

      initCrosshairLabels(xCrosshairLabels, graph.X, plot.xLog);
      initCrosshairLabels(yCrosshairLabels, graph.Y, plot.yLog);

      xMin = min(xMin, graph.X.reduce(min));
      xMax = max(xMax, graph.X.reduce(max));

      yMin = min(yMin, graph.Y.reduce(min));
      yMax = max(yMax, graph.Y.reduce(max));

    }

    xScaler.setScaling(xMin, xMax, 0, 1);
    yScaler.setScaling(yMin, yMax, 0, 1);

    plotExtremes = PlotConstraints(xMin: xMin, xMax: xMax, yMin: yMin, yMax: yMax);


    plotConstraints = plot.constraints ?? PlotConstraints(xMin: xMin, xMax: xMax, yMin: yMin, yMax: yMax);



    initXTicks();
    initYTicks();

    for (int j = 0; j < plot.graphs.length; j++) {

      final graph = plot.graphs[j];
      final graphPaint = Paint()..color = graph.color ?? Colors.black..strokeWidth = graph.linethickness ?? 1;

      graphRenderPoints[graph] = [];

      if (graph.X.length != graph.Y.length) {
        throw FlutterPlotException('Graph [x] and [y] must be of equal length, but found ${graph.X.length} x-values and ${graph.Y.length} y-values for $graph.');
      }

      for (int i = 0; i < graph.X.length; i++) {

        double pxX = xScaler.scale(graph.X[i]);
        double pxY = yScaler.scale(graph.Y[i]);

        final renderPoint = RenderPoint(
                                  pixel: Offset(pxX, windowConstraints.maxHeight - pxY),
                                  paint: graphPaint,
                                  id: i * j
          );

        pixelLUT[Offset(graph.X[i], graph.Y[i])] = renderPoint;
        graphRenderPoints[graph]!.add(renderPoint);
      }
      
      
      if (graph.annotations != null) {
        for (var annotation in graph.annotations!) {
          if (annotation.value == null) {
            int index = graph.X.length ~/ 2;
            annotation.value = Offset(graph.X[index], graph.Y[index]);
          }
          annotation.getPixelFromValue = getPixelFromAnnotation;
        }
      }

      if (graph.crosshairs != null) {

        for (int i = 0; i < graph.crosshairs!.length; i++) {

          Crosshair crosshair = graph.crosshairs![i];

          if (crosshair.active && activeCrosshair != null) {
            throw FlutterPlotException('Only one crosshair should be [active]. Otherwise, weird Plot interactions will happen!');
          }

          if (crosshair.active) {
            activeCrosshair = crosshair;
            activeGraph = graph;
          }

          crosshair.getPixelFromValue = getPixelFromCrosshair;

          if (crosshair.value == null) {
            int index = graph.X.length ~/ 2;
            crosshair.prevIndex = index;
            crosshair.value = Offset(graph.X[index], graph.Y[index]);
          }

         }
      }
    }

  }

  void disposeValues() {
    pixelLUT.clear();
    graphRenderPoints.clear();
    _xTicks.clear();
    _yTicks.clear();
    xCrosshairLabels.clear();
    yCrosshairLabels.clear();
  }



}

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

class PlotConstraints {

  PlotConstraints({
      required this.xMin,
      required this.xMax,
      required this.yMin,
      required this.yMax,
  });

  double xMin;
  double xMax;
  double yMin;
  double yMax;

  bool get isFinite => xMin.isFinite && xMax.isFinite && yMin.isFinite && yMax.isFinite;


  @override
  bool operator ==(covariant PlotConstraints other) {
    return other.xMin == xMin && other.xMax == xMax && other.yMin == yMin && other.yMax == yMax;
  }

  @override
  int get hashCode => xMin.hashCode;

}


class FlutterPlotException implements Exception {
  String cause;
  FlutterPlotException(this.cause);
}
