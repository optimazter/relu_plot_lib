
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterplot/flutterplot.dart';
import 'package:flutterplot/src/annotation.dart';


final crosshairRepainter = StateProvider<int>((ref) => 0);
final plotRepainter = StateProvider<int>((ref) => 0);


enum Interaction {
  crosshair,
  graph,
  annotation
} 

class PlotStateManager {

  PlotStateManager({
    required this.plot
  });

  final Plot plot;

  final xScaler = Scaler();
  final yScaler = Scaler();

  BoxConstraints? windowConstraints;
  PlotConstraints? plotConstraints;
  PlotConstraints? plotExtremes;


  final Map<Offset, RenderPoint> pixelLUT = {};
  final Map<String, double> xTicks = {};
  final Map<String, double>  yTicks = {};

  List<Annotation> annotations = [];

  List<RenderPoint> renderPoints = [];

  double get sidePadding => plot.padding + 40;
  double get overPadding => plot.padding;

  Interaction currentInteraction = Interaction.crosshair;



  void moveActiveCrosshairs(PointerMoveEvent event) {
    
    for (Graph graph in plot.graphs) {

      if (graph.crosshair == null) {
        continue;
      }
      if (!graph.crosshair!.active) { 
        continue;
      }
      
      int? i = _getXIndexFromPixel(graph, event.position.dx, event.delta.dx, graph.crosshair!.prevIndex);
      
      if (i != null) {

        graph.crosshair!.value =  Offset(graph.X[i], graph.Y[i]);
        graph.crosshair!.prevIndex = i;  

      }
    }
  }



  bool isWithinPlotPixels(Offset pixel) => pixel.dx >= 0 && pixel.dx <= windowConstraints!.maxWidth && pixel.dy >= 0 && pixel.dy <= windowConstraints!.minWidth;


  bool isWithinPlotValues(Offset value) => value.dx >= plotConstraints!.xMin && value.dx <= plotConstraints!.xMax && value.dy >= plotConstraints!.yMin && value.dy <= plotConstraints!.yMax;



  void movePlot(Offset moveDelta) {

    plotConstraints!.xMin -= moveDelta.dx;
    plotConstraints!.xMax -= moveDelta.dx;
    plotConstraints!.yMin += moveDelta.dy;
    plotConstraints!.yMax += moveDelta.dy;

  }


  bool setXConstraints(double scrollDelta) {

    final double newXMin = plotConstraints!.xMin += scrollDelta;
    final double newXMax = plotConstraints!.xMax -= scrollDelta;
    if (newXMin < newXMax && newXMax > plotExtremes!.xMin) {
      plotConstraints!.xMin = newXMin;
      plotConstraints!.xMax = newXMax;
      return true;
    }
    return false;
  }

  bool setYConstraints(double scrollDelta) {

    final double newYMin = plotConstraints!.yMin -= scrollDelta;
    final double newYMax = plotConstraints!.yMax += scrollDelta;

    if (newYMin < newYMax && newYMax > plotExtremes!.yMin) {
      plotConstraints!.yMin = newYMin;
      plotConstraints!.yMax = newYMax;
      return true;
    }
    return false;
  }

  int? _getXIndexFromPixel(Graph graph, double pxX,  double dx, int prevIndex) {
    double x = xScaler.inverse(pxX);
    if (pxX <= 0) {
      return 0;
    }
    if (pxX >= windowConstraints!.maxWidth) {
      return graph.X.length - 1;
    }
    if (dx < 0) {
      for (int i = prevIndex - 1; i > 1; i --) {
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
    final ticks = plot.xTicks ?? _getXTicks();
    ticks.forEach((x) {
        xTicks['${x.toStringAsFixed(plot.fractionDigits)} ${plot.xUnit ?? ''}'] = xScaler.scale(x);
      });
  }

  void initYTicks() {
    final ticks = plot.yTicks ?? _getYTicks();
    ticks.forEach((y) {
        yTicks['${y.toStringAsFixed(plot.fractionDigits)} ${plot.yUnit ?? ''}'] = yScaler.scale(y);
      });
  }

  List<double> _getXTicks() {
    int n = plot.numXTicks ?? 10;
    n += 1;
    final List<double> x = [];
    for (int i = 1; i < n; i++) {

      x.add(plotConstraints!.xMin + (i) * (plotConstraints!.xMax - plotConstraints!.xMin) / n);

    }
    return x;

  }

  List<double> _getYTicks() {
    int n = plot.numYTicks ?? 10;
    n += 1;
    final List<double> y = [];
    for (int i = 1; i < n; i++) {
      y.add(plotConstraints!.yMin + (i) * (plotConstraints!.yMax - plotConstraints!.yMin) / n);
    }
    return y;
  }

  Offset getValueFromPixel(Offset pixel) => Offset(xScaler.inverse(pixel.dx), yScaler.inverse(windowConstraints!.maxHeight - pixel.dy));

  Offset getPixelFromValue(Offset value) => Offset(xScaler.scale(value.dx), windowConstraints!.maxHeight - yScaler.scale(value.dy));


  void repaintCrosshairs(WidgetRef ref) {
    ref.read(crosshairRepainter.notifier).state++;
  }

  void repaintPlot(WidgetRef ref) {
    ref.read(plotRepainter.notifier).state++;
  }

  void resize([bool xOnly = false, bool yOnly = false]) {

    debugPrint('Resize');

    if (!yOnly) {
     xScaler.setScaling(plotConstraints!.xMin, plotConstraints!.xMax, 0, windowConstraints!.maxWidth);
    }
    if (!xOnly) {
     yScaler.setScaling(plotConstraints!.yMin, plotConstraints!.yMax, 0, windowConstraints!.maxHeight);
    }

    pixelLUT.forEach((value, point) {

      point.pixel = Offset(xScaler.scale(value.dx), windowConstraints!.maxHeight - yScaler.scale(value.dy));

    });

    renderPoints = pixelLUT.values.where((pt) => pt.pixel.dx >= 0 &&
                                                  pt.pixel.dx <= windowConstraints!.maxWidth)
                                                  .toList();
    if (plot.xTicks == null) {
      xTicks.clear();
      initXTicks();
    }
    if (plot.yTicks == null) {
      yTicks.clear();
      initYTicks();
    }

  }



  void init(BoxConstraints windowConstraints) {

    debugPrint('Initializing');

    this.windowConstraints = windowConstraints;

    double xMin = double.infinity;
    double xMax = double.negativeInfinity;
    double yMin = double.infinity;
    double yMax = double.negativeInfinity;

    for (Graph graph in plot.graphs) {

      xMin = min(xMin, graph.X.reduce(min));
      xMax = max(xMax, graph.X.reduce(max));

      yMin = min(yMin, graph.Y.reduce(min));
      yMax = max(yMax, graph.Y.reduce(max));

    }

    xScaler.setScaling(xMin, xMax, 0, windowConstraints.maxWidth);
    yScaler.setScaling(yMin, yMax, 0, windowConstraints.maxHeight);


    for (int j = 0; j < plot.graphs.length; j++) {

      var graph = plot.graphs[j];

      var graphPaint = Paint()..color = graph.color ?? Colors.black..strokeWidth = graph.linethickness ?? 1;

      for (int i = 0; i < graph.X.length; i++) {

        double pxX = xScaler.scale(graph.X[i]);
        double pxY = yScaler.scale(graph.Y[i]);

        pixelLUT[Offset(graph.X[i], graph.Y[i])] = RenderPoint(
                                  pixel: Offset(pxX, windowConstraints.maxHeight - pxY),
                                  paint: graphPaint,
                                  id: i * j
          );
      }
      renderPoints = pixelLUT.values.toList();
      plotExtremes = PlotConstraints(xMin: xMin, xMax: xMax, yMin: yMin, yMax: yMax);
      plotConstraints = PlotConstraints(xMin: xMin, xMax: xMax, yMin: yMin, yMax: yMax);
      initXTicks();
      initYTicks();
      
      if (graph.annotations != null) {
        graph.annotations!.forEach((annotation) {
          if (annotation.value == null) {
            annotation.value = Offset(xMax / 2, xMin / 2);
          }
          annotations.add(annotation);
        });
      }

      if (graph.crosshair != null) {

        int index = graph.X.length ~/ 2;
        graph.crosshair?.prevIndex = index;
        graph.crosshair?.value = Offset(graph.X[index], graph.Y[index]);
        

      }

  }

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
    return RenderPoint(pixel: Offset(0, 0), paint: Paint(), id: -1);
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




}
