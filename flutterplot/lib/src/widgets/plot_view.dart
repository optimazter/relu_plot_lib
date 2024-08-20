import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutterplot/flutterplot.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutterplot/src/models/camera.dart';
import 'package:flutterplot/src/rendering/annotation_layer.dart';
import 'package:flutterplot/src/rendering/crosshair_painter.dart';
import 'package:flutterplot/src/rendering/graph_painter.dart';
import 'package:flutterplot/src/rendering/ticks_painter.dart';
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

  late final int decimate;



  Interaction currentInteraction = Interaction.crosshair;

  Annotation? _activeAnnotation;
  Crosshair? _activeCrosshair;
  Graph? _activeGraph;


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


  void movePlot(Offset moveOffset) {
    camera.move(moveOffset.dx, moveOffset.dy);
    plot.onConstraintsChanged?.call(camera.localConstraints, plotExtremes);
  }

  void scalePlot(double scaleX, double scaleY) {
    camera.scale(scaleX, scaleY);
    plot.onConstraintsChanged?.call(camera.localConstraints, plotExtremes);
  }


  bool _checkAnnotationHit(PointerDownEvent event) {
    for (Graph graph in plot.graphs) {
      if (graph.annotations == null) {
        continue;
      }
      for (Annotation annotation in graph.annotations!) {
        final Offset globalPosition = camera.transform.transformOffset(annotation.position);
        if (event.localPosition.dx >= globalPosition.dx && event.localPosition.dx <= globalPosition.dx + annotation.width
           && event.localPosition.dy >= globalPosition.dy && event.localPosition.dy <= globalPosition.dy + annotation.height) {
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
      event = event.transformed(camera.transformInverted);
      final Offset localPosition = _activeCrosshair!.position + event.localDelta;
      final int? i = _getXIndexFromPixel(_activeGraph!, localPosition.dx, event.localDelta.dx, _activeCrosshair!.prevIndex);
      if (i != null) {
        _activeCrosshair!.position = Offset(_activeGraph!.x[i], _activeGraph!.y[i]);
        _activeCrosshair!.prevIndex = i;  
      }
    
    }     
  }


  int? _getXIndexFromPixel(Graph graph, double x, double dx, int prevIndex) {

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
      localConstraints: plot.constraints ?? plotExtremes,
      minimumScale: plot.minimumScale,
      maximumScale: plot.maximumScale,

    );

  }


  void _initDecimate() {
    if (plot.decimate != null) {
      decimate = plot.decimate!;
    } else {
      final display = WidgetsBinding.instance.platformDispatcher.views.first.display;
      debugLog('Measured Refresh Rate was ${display.refreshRate} Hz');
      decimate = display.refreshRate ~/ 10;
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
    plot.onConstraintsChanged?.call(plot.constraints ?? plotExtremes, plotExtremes);
  }



  void _initAnnotations(List<Graph> graphs) {
    graphs.forEach((graph) {
    if (graph.annotations != null) {
      for (var annotation in graph.annotations!) {
        if (annotation.position == Offset.infinite) {
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
    graphPaths.clear();
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
        widget.scalePlot(scale, 1.0);
      });
    }
    else if (_controlDown) {
      setState(() {
        widget.scalePlot(1.0, scale);
      });
    }
    else {
      setState(() {
        widget.camera.scale(scale, scale);    
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
      } 
      else {
        widget.currentInteraction = Interaction.graph;
      }
    });
  }

  void _handlePointerUp(PointerUpEvent event) {
    switch(widget.currentInteraction) {
      case Interaction.annotation:
        widget._activeAnnotation?.onDragEnd?.call(widget._activeAnnotation!.position);
        break;
      case Interaction.crosshair:
        widget._activeCrosshair?.onDragEnd?.call(widget._activeCrosshair!.position);
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
          if (_moveFreq >= widget.decimate) {
            setState(() {
              widget.movePlot(_moveOffset);
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
                  child:  AnnotationLayer(
                    annotations: widget.annotations,
                    transform: widget.camera.transform,
                  ),
                )
            ],
          )
      ));
    }
}
    

    

