import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutterplot/flutterplot.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutterplot/src/models/camera.dart';
import 'package:flutterplot/src/painters/annotation_painter.dart';
import 'package:flutterplot/src/painters/crosshair_painter.dart';
import 'package:flutterplot/src/painters/graph_painter.dart';
import 'package:flutterplot/src/painters/ticks_painter.dart';
import 'package:flutterplot/src/utils/utils.dart';


enum Interaction {
  crosshair,
  graph,
  annotation,
} 


// ignore: must_be_immutable
class PlotView extends StatefulWidget {

  PlotView({
    super.key, 
    required this.plot, 
    required this.width,
    required this.height,
  })
  {
    init();
  }


  final Plot plot;
  final double width;
  final double height;

  final Map<Graph, Path> graphPaths = {};

  late final PlotConstraints plotExtremes;
  late final Camera camera;


  Interaction currentInteraction = Interaction.crosshair;


  Annotation? _activeAnnotation;
  Crosshair? _activeCrosshair;
  Graph? _activeGraph;

  int _decimate = 0;


  double get paddingL => plot.padding; 
  double get paddingB => plot.padding + 20;
  double get paddingR => plot.padding;
  double get paddingT => plot.padding;


  Ticks? get xTicks => plot.xTicks?..update(camera.localConstraints.xMin, camera.localConstraints.xMax);
  Ticks? get yTicks => plot.yTicks?..update(camera.localConstraints.yMin, camera.localConstraints.yMax);

  List<Crosshair> get crosshairs => plot.graphs.map((graph) => graph.crosshairs ?? []).expand((crosshair) => crosshair).toList();

  List<Annotation> get annotations => plot.graphs.map((graph) => graph.annotations ?? []).expand((annotation) => annotation).toList();


  void init() {
    debugLog('Initializing Plot');
    _disposeValues();
    _initLog(plot.xTicks?.logarithmic ?? false, plot.yTicks?.logarithmic ?? false);
    _initGraphPaths(plot.graphs);
    _initExtremes(plot.graphs);
    _initCamera(plotExtremes.xMax - plotExtremes.xMin, plotExtremes.yMax - plotExtremes.yMin, width, height);
    _initAnnotations(plot.graphs);
    _initCrosshairs(plot.graphs);
    _initDecimate();
  }





  bool _checkAnnotationHit(PointerDownEvent event) {
    for (Graph graph in plot.graphs) {
      if (graph.annotations == null) {
        continue;
      }
      for (Annotation annotation in graph.annotations!) {
        final Offset globalPosition = camera.transform.transformOffset(annotation.position);
        if (event.localPosition.dx >= globalPosition.dx - annotation.halfWidth && event.localPosition.dx <= globalPosition.dx + annotation.halfWidth
           && event.localPosition.dy >= globalPosition.dy - annotation.halfHeight && event.localPosition.dy <= globalPosition.dy + annotation.halfHeight) {
          _activeAnnotation = annotation;
          _activeGraph = graph;
          return true;
        }
      }
    }
    return false;
  }


  bool _checkCrosshairHit(PointerDownEvent event) {

    final Offset eventPixel = event.localPosition;

    for (Graph graph in plot.graphs) {
      if (graph.crosshairs == null) {
        continue;
      }
      for (Crosshair crosshair in graph.crosshairs!) {
        final double globalX = camera.transform.transformX(crosshair.position.dx);
        if (eventPixel.dx >= globalX - crosshair.halfWidth && eventPixel.dx <= globalX + crosshair.halfWidth
            && eventPixel.dy >= crosshair.yPadding && eventPixel.dy <= crosshair.yPadding + crosshair.height) {
          _activeCrosshair = crosshair;
          _activeGraph = graph;
          return true;
        }
      } 
    }
    return false;
  }

  void _moveActiveAnnotation(PointerMoveEvent event) {
    if (_activeAnnotation != null) {
      event = event.transformed(camera.transformInverted);
      _activeAnnotation!.position += event.localDelta;
    }
  }

  void _moveActiveCrosshair(PointerMoveEvent event) {
    if (_activeCrosshair != null) {
      final int? i = _getXIndexFromPixel(_activeGraph!, event.localPosition.dx, event.localDelta.dx, _activeCrosshair!.prevIndex);
      if (i != null) {
        _activeCrosshair!.position = Offset(_activeGraph!.x[i], _activeGraph!.y[i]);
        _activeCrosshair!.prevIndex = i;  
      }
    }     

  }


  int? _getXIndexFromPixel(Graph graph, double pxX,  double dx, int prevIndex) {
    double x = pxX;
    if (x <= plotExtremes.xMin) {
      return 0;
    }
    if (x >= plotExtremes.xMax) {
      return graph.x.length - 1;
    }
    if (dx < 0) {
      for (int i = prevIndex - 1; i > 0; i --) {
        if (graph.x[i - 1] <= x && x <= graph.x[i + 1]) {
          return i;
        }
      }
    }
    for (int i = prevIndex + 1; i < graph.x.length - 1; i ++) {
      if (graph.x[i - 1] <= x && x <= graph.x[i + 1]) {
        return i;
      }
    } 
    return null;

  }


  void _initLog(bool xLog, bool yLog) {
    plot.toLog(xLog, yLog);
  }


  void _initCamera(double localWidth, double localHeight, double canvasWidth, double canvasHeight) {
    camera = Camera(
      canvasWidth: canvasWidth, 
      canvasHeight: canvasHeight,
      localConstraints: plotExtremes
    );

  }


  void _initDecimate() {
    if (plot.decimate != null) {
      _decimate = plot.decimate!;
    } else {
      final display = WidgetsBinding.instance.platformDispatcher.views.first.display;
      debugLog('Measured Refresh Rate was ${display.refreshRate} Hz');
      _decimate = display.refreshRate ~/ 10;
    }
  }

  
  void _initGraphPaths(List<Graph> graphs) {
    graphs.forEach((graph) {
      final Path path = Path();
      path.moveTo(graph.x[0], graph.y[0]);
      for (int i = 1; i < graph.x.length; i++) {
        path.lineTo(graph.x[i], graph.y[i]);
      }
      graphPaths[graph] = path;
    });
  }


  void _initExtremes(List<Graph> graphs) {
    final double xMin = graphs.map((graph) => graph.x.reduce(min)).reduce(min);
    final double xMax = graphs.map((graph) => graph.x.reduce(max)).reduce(max);
    final double yMin = graphs.map((graph) => graph.y.reduce(min)).reduce(min);
    final double yMax = graphs.map((graph) => graph.y.reduce(max)).reduce(max);
    plotExtremes = PlotConstraints(xMin: xMin, xMax: xMax, yMin: yMin, yMax: yMax);
  
  }



  void _initAnnotations(List<Graph> graphs) {
    graphs.forEach((graph) {
    if (graph.annotations != null) {
      for (var annotation in graph.annotations!) {
        if (annotation.position == Offset.zero) {
          final int index = graph.x.length ~/ 2;
          annotation.position = Offset(graph.x[index], graph.y[index]);
        }
      }
    }
    });
  }


  void _initCrosshairs(List<Graph> graphs) {

    graphs.forEach((graph) {
      if (graph.crosshairs != null) {
        for (var crosshair in graph.crosshairs!) {
          if (crosshair.position == Offset.infinite) {
            final int index = graph.x.length ~/ 2;
            crosshair.prevIndex = index;
            crosshair.position = Offset(graph.x[index], graph.y[index]);
          }
        }
      }
    });
  }


  void _disposeValues() {
    _activeAnnotation = null;
    _activeCrosshair = null;
    _activeGraph = null;
  }

  @override
  State<StatefulWidget> createState() => FlutterPlotState();
  


}


class FlutterPlotState extends State<PlotView> {
  
  int _moveFreq = 0;
  bool _shiftDown = false;
  bool _controlDown = false;
  Offset _moveOffset = Offset.zero;


  void _handleMouseScroll(PointerEvent event) {
    double scale = 0;
    if (event is PointerPanZoomUpdateEvent) {
      scale = event.localPanDelta.dy.sign;
    } else if (event is PointerScrollEvent) {
      scale = event.scrollDelta.dy.sign;
    }
    scale = scale > 0 ? 0.9 : 1.1;
    if (_shiftDown) {
      setState(() {
        widget.camera.zoom(scale, 1.0);
      });
    }
    else if (_controlDown) {
      setState(() {
        widget.camera.zoom(1.0, scale);
      });
    }
    else {
      setState(() {
        widget.camera.zoom(scale, scale);    
      });
    }
  }
  

  void _handlePointerDown(PointerDownEvent event) {
    setState(() {
      if (widget._checkAnnotationHit(event)) {
        widget.currentInteraction = Interaction.annotation;
      }
      else if (widget._checkCrosshairHit(event)) {     
        widget.currentInteraction = Interaction.crosshair;
        widget._activeCrosshair?.onDragStarted?.call(widget._activeCrosshair!);
      } 
      else {
        widget.currentInteraction = Interaction.graph;
      }
    });
  }

  void _handlePointerUp(PointerUpEvent event) {
    switch(widget.currentInteraction) {
      case Interaction.annotation:
        break;
      case Interaction.crosshair:
        widget._activeCrosshair?.onDragEnd?.call(widget._activeCrosshair!);
      case Interaction.graph:
        break;
    }
    widget.currentInteraction = Interaction.graph;
  }
  

  void _handlePointerMove(PointerMoveEvent event) {

    event = event.transformed(Matrix4.inverted(widget.camera.transform));

    switch(widget.currentInteraction) {
      case Interaction.annotation:
        setState(() {
          widget._moveActiveAnnotation(event);
        });
        break;
      case Interaction.crosshair:
        setState(() {
          widget._moveActiveCrosshair(event);
        });
        break;
      case Interaction.graph:
          _moveFreq++;
          _moveOffset += event.localDelta;
          if (_moveFreq >= widget._decimate) {
            setState(() {
              widget.camera.move(_moveOffset.dx, _moveOffset.dy);
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
  }


  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleKeyDownUp);
  }


  @override
  Widget build(BuildContext context) {   
      return Padding(
        padding: EdgeInsets.only(
          right: widget.paddingR, 
          bottom: widget.paddingB,
          left: widget.paddingL,
          top: widget.paddingT,
        ),
        child: Listener(
          onPointerDown: (event) {
            _handlePointerDown(event);   
          },
          onPointerMove: (event) {
            _handlePointerMove(event);
          },
          onPointerSignal: (event) {
            if (event is PointerScrollEvent) { 
              _handleMouseScroll(event);
            }
          },
          onPointerPanZoomUpdate: (PointerPanZoomUpdateEvent event) {
            _handleMouseScroll(event);
          },
          onPointerUp: (event) {
            _handlePointerUp(event);
          },
          child: Stack(
              children: [
                SizedBox(
                  width: widget.width,
                  height: widget.height,
                  child: CustomPaint(
                    foregroundPainter: TicksPainter(
                      xTicks: widget.xTicks?.ticks,
                      yTicks: widget.yTicks?.ticks,
                      xLabels: widget.xTicks?.labels,
                      yLabels: widget.yTicks?.labels,
                      bottomPadding: widget.paddingB,
                      leftPadding: widget.paddingL,
                      transform: widget.camera.transform,
                    ),
                    painter: GraphPainter(
                      graphPaths: widget.graphPaths,
                      transform: widget.camera.transform,
                    ),
                  )
                ),
                SizedBox(
                  width: widget.width,
                  height: widget.height,
                  child: CustomPaint(
                      painter: CrosshairPainter(
                        crosshairs: widget.crosshairs,
                        fractionDigits: widget.plot.crosshairFractionDigits,
                        xUnit: widget.plot.xTicks?.unit,
                        yUnit: widget.plot.yTicks?.unit, 
                        logarithmicXLabel: widget.plot.xTicks?.logarithmic ?? false,
                        logarithmicYLabel: widget.plot.yTicks?.logarithmic ?? false,
                        transform: widget.camera.transform,
                      ),
                  )
                ),
                SizedBox(
                  width: widget.width,
                  height: widget.height,
                  child:  AnnotationLayout(
                    annotations: widget.annotations,
                    transform: widget.camera.transform,
                  ),
                )
            ],
          )
      ));
    }
}
    

    

