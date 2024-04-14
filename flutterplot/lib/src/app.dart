
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutterplot/flutterplot.dart';
import 'package:flutterplot/src/plot_components/hittable_plot_object.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutterplot/src/plot_components/annotation.dart';
import 'package:flutterplot/src/rendering/custom_painters.dart';


enum Interaction {
  crosshair,
  graph,
  annotation
} 


class FlutterPlotApp extends StatefulWidget {

  const FlutterPlotApp({super.key, required this.plot});
  final Plot plot;

  @override
  State<StatefulWidget> createState() => FlutterPlotState();
  
}



class FlutterPlotState extends State<FlutterPlotApp> {

  //Public fields
  BoxConstraints windowConstraints = BoxConstraints();

  final Map<Offset, RenderPoint> pixelLUT = {};
  final Map<Graph, List<RenderPoint>> graphRenderPoints = {};
  final Map<double, String> xCrosshairLabels = {};
  final Map<double, String> yCrosshairLabels = {};
  
  Interaction currentInteraction = Interaction.crosshair;

  //Private fields
  Annotation? _activeAnnotation;
  Crosshair? _activeCrosshair;
  Graph? _activeGraph;

  final ValueNotifier<int> _crosshairState = ValueNotifier(0);
  int _decimate = 0;
  int _moveFreq = 0;

  bool _shiftDown = false;
  bool _controlDown = false;


  Offset _moveOffset = Offset.zero;

  final _xScaler = Scaler();
  final _yScaler = Scaler();


  late PlotConstraints _plotConstraints;
  late PlotConstraints _plotExtremes;


  final Map<String, double> _xTicks = {};
  final Map<String, double>  _yTicks = {};



  //Public getters
  double get sidePadding => widget.plot.padding + 40;
  double get overPadding => widget.plot.padding;


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

  //Private getters
  double get _xMovementScalar => (_plotConstraints.xMax - _plotConstraints.xMin).abs() / windowConstraints.maxWidth;
  double get _yMovementScalar => (_plotConstraints.yMax - _plotConstraints.yMin).abs() / windowConstraints.maxHeight;



  void debugLog(String message) {
    debugPrint('FlutterPlot: $message');
  }

  int _calculateDecimate() {
    final display = WidgetsBinding.instance.platformDispatcher.views.first.display;
    debugLog('Measured Refresh Rate was ${display.refreshRate} Hz');
    return display.refreshRate ~/ 10;
  }

  Offset _getPixelFromHittablePlotObject(HittablePlotObject object) {
    if (object is Annotation) {
      return _getPixelFromAnnotation(object);
    }
    if (object is Crosshair) {
      return _getPixelFromCrosshair(object);
    }
    throw FlutterPlotException('Object is neither Annotation or Crosshair');
  }

  Offset _getPixelFromAnnotation(Annotation object) {
    return getPixelFromValue(object.value!);
  }

  Offset _getPixelFromCrosshair(Crosshair object) {
    return Offset(
      _xScaler.scale(object.value!.dx),
      object.yPadding
    );
  }

  bool _hit(PointerDownEvent event, HittablePlotObject object) {

    final Offset eventPixel = event.localPosition;
    final Offset pixelPosition = _getPixelFromHittablePlotObject(object);

    final halfWidth = object.width / 2;
    final halfHeight = object.height / 2;

    if (eventPixel.dx >= pixelPosition.dx - halfWidth && eventPixel.dx <= pixelPosition.dx + halfWidth
      && eventPixel.dy >= pixelPosition.dy - halfHeight && eventPixel.dy <= pixelPosition.dx + halfHeight) {
        return true;
      }

    return false;
  }


  bool _checkAnnotationHit(PointerDownEvent event) {

    for (Graph graph in widget.plot.graphs) {

      if (graph.annotations == null) {
        continue;
      }
      for (Annotation annotation in graph.annotations!) {
        if (_hit(event, annotation)) {
          _activeAnnotation = annotation;
          return true;
        }
      }
    }
    return false;
  }


  bool _checkCrosshairHit(PointerDownEvent event) {

    for (Graph graph in widget.plot.graphs) {

      if (graph.crosshairs == null) {
        continue;
      }
      for (Crosshair crosshair in graph.crosshairs!) {
        if (_hit(event, crosshair)) {
          _activeCrosshair?.active = false;
          crosshair.active = true;
          _activeCrosshair = crosshair;
          _activeGraph = graph;
          return true;
        }
      } 
    }
    return false;
  }

  void _moveActiveAnnotation(PointerMoveEvent event) {

    _activeAnnotation?.value = getValueFromPixel(event.localPosition);

  }

  void _moveActiveCrosshair(PointerMoveEvent event) {

    if (_activeCrosshair != null) {

      final int? i = _getXIndexFromPixel(_activeGraph!, event.localPosition.dx, event.localDelta.dx, _activeCrosshair!.prevIndex);
      
      if (i != null) {
        _activeCrosshair?.value =  Offset(_activeGraph!.X[i], _activeGraph!.Y[i]);
        _activeCrosshair?.prevIndex = i;  
      }
    }     

  }


  void _movePlot(Offset moveDelta) {

    final xMovement = moveDelta.dx * _xMovementScalar;
    final yMovement = moveDelta.dy * _yMovementScalar;

    _plotConstraints.xMin -= xMovement;
    _plotConstraints.xMax -= xMovement;
    _plotConstraints.yMin += yMovement;
    _plotConstraints.yMax += yMovement;

  }


  bool _setXConstraints(double scrollDelta) {

    final xMovement = scrollDelta * _xMovementScalar;

    final double newXMin = _plotConstraints.xMin += xMovement;
    final double newXMax = _plotConstraints.xMax -= xMovement;
    if (newXMin < newXMax && newXMax > _plotExtremes.xMin) {
      _plotConstraints.xMin = newXMin;
      _plotConstraints.xMax = newXMax;
      return true;
    }
    return false;
  }

  bool _setYConstraints(double scrollDelta) {

    final yMovement = scrollDelta * _yMovementScalar; 

    final double newYMin = _plotConstraints.yMin += yMovement;
    final double newYMax = _plotConstraints.yMax -= yMovement;

    if (newYMin < newYMax && newYMax > _plotExtremes.yMin) {
      _plotConstraints.yMin = newYMin;
      _plotConstraints.yMax = newYMax;
      return true;
    }
    return false;
  }


  int? _getXIndexFromPixel(Graph graph, double pxX,  double dx, int prevIndex) {
    double x = _xScaler.inverse(pxX);
    if (x <= _plotExtremes.xMin) {
      return 0;
    }
    if (x >= _plotExtremes.xMax) {
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


  void _initXTicks() {
    _xTicks.clear();
    final ticks = widget.plot.xTicks ?? _getXTicks();
    bool toLog = widget.plot.xTicks != null;
    _initTicks(ticks, _xTicks, _xScaler, widget.plot.xUnit ?? '', widget.plot.xLog, toLog, false);
  }

  void _initYTicks() {
    _yTicks.clear();
    final ticks = widget.plot.yTicks ?? _getYTicks();
    bool toLog = widget.plot.yTicks != null;
    _initTicks(ticks, _yTicks, _yScaler, widget.plot.yUnit ?? '', widget.plot.yLog, toLog, true);

  }

  String _toLogarithmicLabel(num valPow, String unit) {
    switch (valPow) {
      case >= 1e12:
        return '${(valPow / 1e12).toStringAsFixed(widget.plot.ticksFractionDigits)} T$unit';
      case >= 1e9:
        return '${(valPow / 1e9).toStringAsFixed(widget.plot.ticksFractionDigits)} G$unit';
      case >= 1e6:
        return '${(valPow / 1e6).toStringAsFixed(widget.plot.ticksFractionDigits)} M$unit';
      case >= 1e3:
        return '${(valPow / 1e3).toStringAsFixed(widget.plot.ticksFractionDigits)} K$unit';
      default:
        return '${valPow.toStringAsFixed(widget.plot.ticksFractionDigits)} $unit';
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
        label = _toLogarithmicLabel(valPow, unit);
      } else {
        label = '${val.toStringAsFixed(widget.plot.ticksFractionDigits)} $unit';
      }
      if (y) {
        labels[label] = windowConstraints.maxHeight - scaler.scale(val);
      } else {
        labels[label] = scaler.scale(val);
      }
    }
  }


  List<double> _getXTicks() {
    int n = widget.plot.numXTicks ?? 10;
    n += 1;
    final List<double> xTicks = [];
    for (int i = 1; i < n; i++) {
      double x = _plotConstraints.xMin + (i) * (_plotConstraints.xMax - _plotConstraints.xMin) / n;
      xTicks.add(x);
    }
    return xTicks;
  }

  List<double> _getYTicks() {
    int n = widget.plot.numYTicks ?? 10;
    n += 1;
    final List<double> yTicks = [];
    for (int i = 1; i < n; i++) {
      double y = _plotConstraints.yMin + (i) * (_plotConstraints.yMax - _plotConstraints.yMin) / n;
      yTicks.add(y);
    }
    return yTicks;
  }

  Offset getValueFromPixel(Offset pixel) => Offset(_xScaler.inverse(pixel.dx), _yScaler.inverse(windowConstraints.maxHeight - pixel.dy));

  Offset getPixelFromValue(Offset value) => Offset(_xScaler.scale(value.dx), windowConstraints.maxHeight - _yScaler.scale(value.dy));



  void _resizePlot( [bool xOnly = false, bool yOnly = false]) {

    debugLog('Resizing Plot');

    if (!yOnly) {
     _xScaler.setScaling(_plotConstraints.xMin, _plotConstraints.xMax, 0, windowConstraints.maxWidth);
    }
    if (!xOnly) {
     _yScaler.setScaling(_plotConstraints.yMin, _plotConstraints.yMax, 0, windowConstraints.maxHeight);
    }


    pixelLUT.forEach((value, point) {

      point.pixel = Offset(_xScaler.scale(value.dx), windowConstraints.maxHeight - _yScaler.scale(value.dy));

    });

    graphRenderPoints.forEach((graph, points) {
    
      points = points.where((pt) => pt.pixel.dx >= 0 &&
                                                  pt.pixel.dx <= windowConstraints.maxWidth)
                                                  .toList();
    });

    _initXTicks();
    _initYTicks();

    if (widget.plot.onResize != null) {
      widget.plot.onResize!(_plotConstraints);
    }


  }

  void _initCrosshairLabels(Map<double, String> labels, List<double> vals, bool toLog) {
    for (int i = 0; i < vals.length; i++) {
      double val = vals[i];
      if (toLog) {
        labels[val] = pow(e, val * ln10).toStringAsFixed(widget.plot.crosshairFractionDigits);
      } else {
        labels[val] = val.toStringAsFixed(widget.plot.crosshairFractionDigits);
      }
    }
  }

  void _resizeWindow(BoxConstraints windowConstraints) {

    debugLog('Resizing Window');

    this.windowConstraints = windowConstraints;
    _resizePlot();
    
  }



  void _init() {

    debugLog('Initializing Plot');
    disposeValues();

    _decimate = widget.plot.decimate ?? _calculateDecimate();

    double xMin = double.infinity;
    double xMax = double.negativeInfinity;
    double yMin = double.infinity;
    double yMax = double.negativeInfinity;

    for (Graph graph in widget.plot.graphs) {

      graph.init(xLog: widget.plot.xLog, yLog: widget.plot.yLog);

      _initCrosshairLabels(xCrosshairLabels, graph.X, widget.plot.xLog);
      _initCrosshairLabels(yCrosshairLabels, graph.Y, widget.plot.yLog);

      xMin = min(xMin, graph.X.reduce(min));
      xMax = max(xMax, graph.X.reduce(max));

      yMin = min(yMin, graph.Y.reduce(min));
      yMax = max(yMax, graph.Y.reduce(max));

    }

    _xScaler.setScaling(xMin, xMax, 0, 1);
    _yScaler.setScaling(yMin, yMax, 0, 1);

    _plotExtremes = PlotConstraints(xMin: xMin, xMax: xMax, yMin: yMin, yMax: yMax);


    _plotConstraints = widget.plot.constraints ?? PlotConstraints(xMin: xMin, xMax: xMax, yMin: yMin, yMax: yMax);



    _initXTicks();
    _initYTicks();

    for (int j = 0; j < widget.plot.graphs.length; j++) {

      final graph = widget.plot.graphs[j];
      final graphPaint = Paint()..color = graph.color ?? Colors.black..strokeWidth = graph.linethickness ?? 1;

      graphRenderPoints[graph] = [];

      if (graph.X.length != graph.Y.length) {
        throw FlutterPlotException('Graph [x] and [y] must be of equal length, but found ${graph.X.length} x-values and ${graph.Y.length} y-values for $graph.');
      }

      for (int i = 0; i < graph.X.length; i++) {

        double pxX = _xScaler.scale(graph.X[i]);
        double pxY = _yScaler.scale(graph.Y[i]);

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
        }
      }

      if (graph.crosshairs != null) {

        for (int i = 0; i < graph.crosshairs!.length; i++) {

          Crosshair crosshair = graph.crosshairs![i];

          if (crosshair.active && _activeCrosshair != null) {
            throw FlutterPlotException('Only one crosshair should be [active]. Otherwise, weird Plot interactions will happen!');
          }

          if (crosshair.active) {
            _activeCrosshair = crosshair;
            _activeGraph = graph;
          }

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
    _activeAnnotation = null;
    _activeCrosshair = null;
    _activeGraph = null;
    _xTicks.clear();
    _yTicks.clear();
    xCrosshairLabels.clear();
    yCrosshairLabels.clear();
  }



  void _handleMouseScroll(double dy) {
    if (_shiftDown) {
      final constrained = _setXConstraints(dy);
      if (constrained) {
        setState(() {
          _resizePlot(true, false);
        });
      }
    }
    else if (_controlDown) {
      final constrained = _setYConstraints(dy);
      if (constrained) {
        setState(() {
          _resizePlot(false, true);
        });
      }
    }
    else {
      final xConstrained = _setXConstraints(dy);
      final yConstrained = _setYConstraints(dy);
      if (xConstrained && yConstrained) {
        setState(() {
          _resizePlot();        
        });

      }
      else if (xConstrained) {
        setState(() {
          _resizePlot(true, false);
        });
      }
      else if (yConstrained) {
        setState(() {
          _resizePlot(false, true);
        });
      }
    }
  }

  void _handlePointerDown(PointerDownEvent event) {

    setState(() {
      if (_checkAnnotationHit(event)) {
        currentInteraction = Interaction.annotation;
      }
      else if (event.kind == PointerDeviceKind.mouse && event.buttons == kSecondaryMouseButton) {
        currentInteraction = Interaction.graph;

      } else {
        _checkCrosshairHit(event);
        currentInteraction = Interaction.crosshair;
      }
    });
  }
  

  void _handlePointerMove(PointerMoveEvent event) {
    switch(currentInteraction) {
      case Interaction.annotation:
        setState(() {
            _moveActiveAnnotation(event);
        });
        break;
      case Interaction.crosshair:
          _moveActiveCrosshair(event);
          _crosshairState.value++;
        break;
      case Interaction.graph:
          _moveFreq++;
          _moveOffset += event.localDelta;
          if (_moveFreq >= _decimate) {
            setState(() {
              _movePlot(_moveOffset);
              _resizePlot();
              _moveFreq = 0;
              _moveOffset = Offset.zero;
            });

          }
        break;
    }
  }

  

  bool _handleKeyDownUp(KeyEvent event) {

    if (event.logicalKey == LogicalKeyboardKey.shift || event.logicalKey == LogicalKeyboardKey.shiftLeft) {
      _shiftDown = event is KeyDownEvent;
    }
    if (event.logicalKey == LogicalKeyboardKey.control || event.logicalKey == LogicalKeyboardKey.controlLeft) {
      _controlDown = event is KeyDownEvent;
    }
    return _shiftDown || _controlDown;
    
  }



  @override
  void didUpdateWidget(covariant FlutterPlotApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    _init();
  }


  @override
  void initState() {
    super.initState();
    _init();
    HardwareKeyboard.instance.addHandler(_handleKeyDownUp);
  }


  @override
  Widget build(BuildContext context) {   
      return Padding(
        padding: EdgeInsets.only(
          left: sidePadding, 
          bottom: overPadding,
          right: sidePadding + 40,
          top: overPadding
        ),
        child: LayoutBuilder(

          builder: (context, windowConstraints) {   
            
            _resizeWindow(windowConstraints);

            return Listener(
                  onPointerDown: (event) {
                    _handlePointerDown(event);   
                  },
                  onPointerMove: (event) {
                    _handlePointerMove(event);
                  },
                  onPointerSignal: (event) {
                    if (event is PointerScrollEvent) { 
                      _handleMouseScroll(event.scrollDelta.dy);
                    }
                  },
                  onPointerPanZoomUpdate: (PointerPanZoomUpdateEvent event) {
                    _handleMouseScroll(event.panDelta.dy);
                  },

                  child: Stack(
                      children: [
                        SizedBox(
                              width: windowConstraints.maxWidth,
                              height: windowConstraints.maxHeight,
                              child: CustomPaint(
                                  foregroundPainter: GraphPainter(state: this),
                                  painter: BackgroundPainter(state: this),
                                  )
                        ),
                        RepaintBoundary(
                          child: ValueListenableBuilder(
                            valueListenable: _crosshairState, 
                            builder: (context, value, child) {
                             return SizedBox(
                                  width: windowConstraints.maxWidth,
                                  height: windowConstraints.maxHeight,
                                  child: CustomPaint(
                                      painter: CrosshairPainter(state: this),
                                  )
                                );
                            }),
                          ),
                        SizedBox(
                            width: windowConstraints.maxWidth,
                            height: windowConstraints.maxHeight,
                            child:  AnnotationLayer(state: this, context: context),
                        ),
                      ],
                  )
              );
            }
        ),);
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
