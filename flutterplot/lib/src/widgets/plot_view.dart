import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutterplot/flutterplot.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutterplot/src/models/camera.dart';
import 'package:flutterplot/src/models/draggable_plot_object.dart';
import 'package:flutterplot/src/rendering/annotation_layer.dart';
import 'package:flutterplot/src/rendering/crosshair_painter.dart';
import 'package:flutterplot/src/rendering/graph_painter.dart';
import 'package:flutterplot/src/rendering/ticks_painter.dart';
import 'package:flutterplot/src/utils/utils.dart';


enum Interaction {
  plotObject,
  graph,
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



  Interaction currentInteraction = Interaction.graph;

  DraggablePlotObject? _activePlotObject;
  Graph? _activeGraph;


  double get paddingL => plot.padding + 30; 
  double get paddingB => plot.padding + 30;
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
    _initPlotObjects(plot.graphs);
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


  bool _checkPlotObjectHit(PointerDownEvent event) {
    for (Graph graph in plot.graphs) {
      for (DraggablePlotObject obj in graph.plotObjects) {
        if (obj.isHit(event, camera.transform)) {
          _activePlotObject = obj;
          _activeGraph = graph;
          return true;
        }
      }
    }
    return false;
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



  void _initPlotObjects(List<Graph> graphs) {
    graphs.forEach((graph) {
      graph.plotObjects.forEach((plotObject) {
        if (plotObject.position == Offset.infinite) {
          final int index = graph.x.length ~/ 2;
          plotObject.position = Offset(graph.x[index], graph.y[index]);
          if (plotObject is Crosshair) {
            plotObject.prevIndex = index;
          }
        }
      });
    });
  }



  void _disposeValues() {
    graphPaths.clear();
    _activePlotObject = null;
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
        widget.scalePlot(scale, scale);    
      });
    }
  }
  

  void _handlePointerDown(PointerDownEvent event) {
    setState(() {
      if (widget._checkPlotObjectHit(event)) {
        widget.currentInteraction = Interaction.plotObject;
        widget._activePlotObject?.onDragStart?.call(widget._activePlotObject!);
      }
      else {
        widget.currentInteraction = Interaction.graph;
      }
    });
  }

  void _handlePointerUp(PointerUpEvent event) {
    switch(widget.currentInteraction) {
      case Interaction.plotObject:
        widget._activePlotObject?.onDragEnd?.call(widget._activePlotObject!);
        break;
      case Interaction.graph:
        break;
    }
    widget.currentInteraction = Interaction.graph;
  }
  

  void _handlePointerMove(PointerMoveEvent event) {

    event = event.transformed(Matrix4.inverted(widget.camera.transform));

    switch(widget.currentInteraction) {
      case Interaction.plotObject:
        setState(() {
          event = event.transformed(widget.camera.transformInverted);
          widget._activePlotObject?.onDrag(event);
          if (widget._activePlotObject is Crosshair) {
            final crosshair = widget._activePlotObject as Crosshair;
            crosshair.adjustPosition(event, widget._activeGraph!.x, widget._activeGraph!.y, widget.plotExtremes.xMin, widget.plotExtremes.xMax);
          }
        });
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
                      xUnit: widget.xTicks?.unit,
                      yUnit: widget.yTicks?.unit,
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
    

    

