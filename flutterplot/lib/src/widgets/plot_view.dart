
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutterplot/flutterplot.dart';
import 'package:flutterplot/src/models/scaler.dart';
import 'package:flutterplot/src/painters/background_painter.dart';
import 'package:flutterplot/src/painters/crosshair_painter.dart';
import 'package:flutterplot/src/painters/graph_painter.dart';
import 'package:flutterplot/src/models/hittable_plot_object.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutterplot/src/painters/render_point.dart';
import 'package:flutterplot/src/utils.dart';
import 'package:flutterplot/src/widgets/annotation_layer.dart';


enum Interaction {
  crosshair,
  graph,
  annotation,
} 


// ignore: must_be_immutable
class PlotView extends StatefulWidget {

  PlotView({super.key, required this.plot});
  final Plot plot;

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
  final ValueNotifier<int> _annotationState = ValueNotifier(0);
  
  int _decimate = 0;

  final _xScaler = Scaler();
  final _yScaler = Scaler();


  late PlotConstraints _plotConstraints;
  late PlotConstraints _plotExtremes;


  final Map<String, double> _xTicks = {};
  final Map<String, double>  _yTicks = {};



  //Public getters
  double get sidePadding => plot.padding + 40;
  double get overPadding => plot.padding;


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
    return getPixelFromValue(object.coordinate!);
  }

  Offset _getPixelFromCrosshair(Crosshair object) {
    return Offset(
      _xScaler.scale(object.coordinate!.dx),
      object.yPadding
    );
  }

  bool _hit(PointerDownEvent event, HittablePlotObject object) {

    final Offset eventPixel = event.localPosition;
    final Offset pixelPosition = _getPixelFromHittablePlotObject(object);

    final halfWidth = object.width / 2;
    final halfHeight = object.height / 2;

    if (eventPixel.dx >= pixelPosition.dx - halfWidth && eventPixel.dx <= pixelPosition.dx + halfWidth
      && eventPixel.dy >= pixelPosition.dy - halfHeight && eventPixel.dy <= pixelPosition.dy + halfHeight) {
        return true;
      }

    return false;
  }


  bool _checkAnnotationHit(PointerDownEvent event) {

    for (Graph graph in plot.graphs) {

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

    for (Graph graph in plot.graphs) {

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

    _activeAnnotation?.coordinate = getValueFromPixel(event.localPosition);

  }

  void _moveActiveCrosshair(PointerMoveEvent event) {

    if (_activeCrosshair != null) {

      final int? i = _getXIndexFromPixel(_activeGraph!, event.localPosition.dx, event.localDelta.dx, _activeCrosshair!.prevIndex);
      
      if (i != null) {
        _activeCrosshair?.coordinate =  Offset(_activeGraph!.X[i], _activeGraph!.Y[i]);
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
    final ticks = plot.xTicks ?? _getXTicks();
    bool toLog = plot.xTicks != null;
    _initTicks(ticks, _xTicks, _xScaler, plot.xUnit ?? '', plot.xLog, toLog, false);
  }

  void _initYTicks() {
    _yTicks.clear();
    final ticks = plot.yTicks ?? _getYTicks();
    bool toLog = plot.yTicks != null;
    _initTicks(ticks, _yTicks, _yScaler, plot.yUnit ?? '', plot.yLog, toLog, true);

  }

  String _toLogarithmicLabel(num valPow, String unit) {
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
        label = _toLogarithmicLabel(valPow, unit);
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
      double x = _plotConstraints.xMin + (i) * (_plotConstraints.xMax - _plotConstraints.xMin) / n;
      xTicks.add(x);
    }
    return xTicks;
  }

  List<double> _getYTicks() {
    int n = plot.numYTicks ?? 10;
    n += 1;
    final List<double> yTicks = [];
    for (int i = 1; i < n; i++) {
      double y = _plotConstraints.yMin + (i) * (_plotConstraints.yMax - _plotConstraints.yMin) / n;
      yTicks.add(y);
    }
    return yTicks;
  }

  Offset getValueFromPixel(Offset pixel) => Offset(_xScaler.inverse(pixel.dx), _yScaler.inverse(windowConstraints.maxHeight - pixel.dy));

  Offset getPixelFromValue(Offset coordinate) => Offset(_xScaler.scale(coordinate.dx), windowConstraints.maxHeight - _yScaler.scale(coordinate.dy));



  void _resizePlot( [bool xOnly = false, bool yOnly = false]) {

    debugLog('Resizing Plot');

    if (!yOnly) {
     _xScaler.setScaling(_plotConstraints.xMin, _plotConstraints.xMax, 0, windowConstraints.maxWidth);
    }
    if (!xOnly) {
     _yScaler.setScaling(_plotConstraints.yMin, _plotConstraints.yMax, 0, windowConstraints.maxHeight);
    }


    pixelLUT.forEach((coordinate, point) {

      point.pixel = Offset(_xScaler.scale(coordinate.dx), windowConstraints.maxHeight - _yScaler.scale(coordinate.dy));

    });

    graphRenderPoints.forEach((graph, points) {
    
      points = points.where((pt) => pt.pixel.dx >= 0 &&
                                                  pt.pixel.dx <= windowConstraints.maxWidth)
                                                  .toList();
    });

    _initXTicks();
    _initYTicks();

    plot.onResize?.call(_plotConstraints);


  }

  void _initCrosshairLabels(Map<double, String> labels, List<double> vals, bool toLog) {
    for (int i = 0; i < vals.length; i++) {
      double val = vals[i];
      if (toLog) {
        labels[val] = pow(e, val * ln10).toStringAsFixed(plot.crosshairFractionDigits);
      } else {
        labels[val] = val.toStringAsFixed(plot.crosshairFractionDigits);
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

    _decimate = plot.decimate ?? _calculateDecimate();

    double xMin = double.infinity;
    double xMax = double.negativeInfinity;
    double yMin = double.infinity;
    double yMax = double.negativeInfinity;

    for (Graph graph in plot.graphs) {

      graph.init(xLog: plot.xLog, yLog: plot.yLog);

      _initCrosshairLabels(xCrosshairLabels, graph.X, plot.xLog);
      _initCrosshairLabels(yCrosshairLabels, graph.Y, plot.yLog);

      xMin = min(xMin, graph.X.reduce(min));
      xMax = max(xMax, graph.X.reduce(max));

      yMin = min(yMin, graph.Y.reduce(min));
      yMax = max(yMax, graph.Y.reduce(max));

    }

    _xScaler.setScaling(xMin, xMax, 0, 1);
    _yScaler.setScaling(yMin, yMax, 0, 1);

    _plotExtremes = PlotConstraints(xMin: xMin, xMax: xMax, yMin: yMin, yMax: yMax);

    plot.onInit?.call(_plotExtremes);

    _plotConstraints = plot.constraints ?? PlotConstraints(xMin: xMin, xMax: xMax, yMin: yMin, yMax: yMax);



    _initXTicks();
    _initYTicks();

    for (int j = 0; j < plot.graphs.length; j++) {

      final graph = plot.graphs[j];
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
          if (annotation.coordinate == null) {
            int index = graph.X.length ~/ 2;
            annotation.coordinate = Offset(graph.X[index], graph.Y[index]);
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

          if (crosshair.coordinate == null) {
            int index = graph.X.length ~/ 2;
            crosshair.prevIndex = index;
            crosshair.coordinate = Offset(graph.X[index], graph.Y[index]);
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

  @override
  State<StatefulWidget> createState() => FlutterPlotState();

}


class FlutterPlotState extends State<PlotView> {
  
  int _moveFreq = 0;

  bool _shiftDown = false;
  bool _controlDown = false;


  Offset _moveOffset = Offset.zero;



  void _handleMouseScroll(double dy) {
    if (_shiftDown) {
      final constrained = widget._setXConstraints(dy);
      if (constrained) {
        setState(() {
          widget._resizePlot(true, false);
        });
      }
    }
    else if (_controlDown) {
      final constrained = widget._setYConstraints(dy);
      if (constrained) {
        setState(() {
          widget._resizePlot(false, true);
        });
      }
    }
    else {
      final xConstrained = widget._setXConstraints(dy);
      final yConstrained = widget._setYConstraints(dy);
      if (xConstrained && yConstrained) {
        setState(() {
          widget._resizePlot();        
        });

      }
      else if (xConstrained) {
        setState(() {
          widget._resizePlot(true, false);
        });
      }
      else if (yConstrained) {
        setState(() {
          widget._resizePlot(false, true);
        });
      }
    }
  }

  void _handlePointerDown(PointerDownEvent event) {
    setState(() {
      if (widget._checkAnnotationHit(event)) {
        widget.currentInteraction = Interaction.annotation;
        widget._activeAnnotation?.onDragStarted?.call(widget._activeAnnotation!.coordinate!);
      }
      else if (widget._checkCrosshairHit(event)) {      
        widget.currentInteraction = Interaction.crosshair;
        widget._activeCrosshair?.onDragStarted?.call(widget._activeCrosshair!.coordinate!);
      } 
      else {
        widget.currentInteraction = Interaction.graph;
      }
    });
  }

  void _handlePointerUp(PointerUpEvent event) {
    switch(widget.currentInteraction) {
      case Interaction.annotation:
        widget._activeAnnotation?.onDragEnd?.call(widget._activeAnnotation!.coordinate!);
        break;
      case Interaction.crosshair:
        widget._activeCrosshair?.onDragEnd?.call(widget._activeCrosshair!.coordinate!);
      case Interaction.graph:
        break;
    }
    widget.currentInteraction = Interaction.graph;
  }
  

  void _handlePointerMove(PointerMoveEvent event) {
    switch(widget.currentInteraction) {
      case Interaction.annotation:
          widget._moveActiveAnnotation(event);
          widget._annotationState.value++;
        break;
      case Interaction.crosshair:
          widget._moveActiveCrosshair(event);
          widget._crosshairState.value++;
        break;
      case Interaction.graph:
          _moveFreq++;
          _moveOffset += event.localDelta;
          if (_moveFreq >= widget._decimate) {
            setState(() {
              widget._movePlot(_moveOffset);
              widget._resizePlot();
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
  void didUpdateWidget(covariant PlotView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.plot != widget.plot) {
      widget._init();
    }
  }


  @override
  void initState() {
    super.initState();
    widget._init();
    HardwareKeyboard.instance.addHandler(_handleKeyDownUp);
  }


  @override
  Widget build(BuildContext context) {   
      return Padding(
        padding: EdgeInsets.only(
          left: widget.sidePadding, 
          bottom: widget.overPadding,
          right: widget.sidePadding + 40,
          top: widget.overPadding
        ),
        child: LayoutBuilder(

          builder: (context, windowConstraints) {   
            
            widget._resizeWindow(windowConstraints);

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
                  onPointerUp: (event) {
                    _handlePointerUp(event);
                  },

                  child: Stack(
                      children: [
                        SizedBox(
                              width: windowConstraints.maxWidth,
                              height: windowConstraints.maxHeight,
                              child: CustomPaint(
                                  foregroundPainter: GraphPainter(
                                    graphRenderPoints: widget.graphRenderPoints, 
                                    width: widget.windowConstraints.maxWidth,
                                    height: widget.windowConstraints.maxHeight),
                                  painter: BackgroundPainter(
                                    xTicks: widget._xTicks,
                                    yTicks: widget._yTicks,
                                    width: widget.windowConstraints.maxWidth,
                                    height: widget.windowConstraints.maxHeight,
                                    padding: widget.sidePadding
                                    ),
                                  )
                        ),
                        RepaintBoundary(
                          child: ValueListenableBuilder(
                            valueListenable: widget._crosshairState, 
                            builder: (context, coordinate, child) {
                             return SizedBox(
                                  width: windowConstraints.maxWidth,
                                  height: windowConstraints.maxHeight,
                                  child: CustomPaint(
                                      painter: CrosshairPainter(
                                        pixelLUT: widget.pixelLUT,
                                        xCrosshairLabels: widget.xCrosshairLabels,
                                        yCrosshairLabels: widget.yCrosshairLabels,
                                        graphs: widget.plot.graphs,
                                        width: windowConstraints.maxWidth,
                                        height: windowConstraints.maxHeight,
                                        padding: widget.sidePadding,
                                        ),
                                  )
                                );
                            }),
                          ),
                        RepaintBoundary(
                          child: ValueListenableBuilder(
                            valueListenable: widget._annotationState,
                            builder: (context, coordinate, child) {
                              return SizedBox(
                                width: windowConstraints.maxWidth,
                                height: windowConstraints.maxHeight,
                                child:  AnnotationLayer(graphs: widget.plot.graphs, getPixelFromValue: widget.getPixelFromValue,),
                            );
                          }
                        )
                      )
                    ],
                  )
              );
            }
        ),);
      }
    }

    

