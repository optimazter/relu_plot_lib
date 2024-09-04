import 'dart:math';
import 'package:flutter/material.dart';
import 'package:relu_plot_lib/relu_plot_lib.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:relu_plot_lib/src/models/camera.dart';
import 'package:relu_plot_lib/src/models/draggable_plot_object.dart';
import 'package:relu_plot_lib/src/rendering/annotation_layer.dart';
import 'package:relu_plot_lib/src/rendering/crosshair_painter.dart';
import 'package:relu_plot_lib/src/rendering/graph_painter.dart';
import 'package:relu_plot_lib/src/rendering/ticks_painter.dart';
import 'package:relu_plot_lib/src/utils/utils.dart';

enum Interaction {
  plotObject,
  graph,
}

// ignore: must_be_immutable
class PlotView extends StatefulWidget {
  PlotView({
    super.key,
    required this.plot,
    required double width,
    required double height,
  })  : _width = width,
        _height = height {
    init();
  }

  final Plot plot;
  final double _width;
  final double _height;

  final Map<Graph, Path> graphPaths = {};

  late final PlotConstraints plotExtremes;
  late final Camera camera;

  Interaction currentInteraction = Interaction.graph;

  DraggablePlotObject? _activePlotObject;
  Graph? _activeGraph;

  double get width => _width - (paddingL + paddingR);
  double get height => _height - (paddingB + paddingT);

  double get paddingL => plot.padding + 30;
  double get paddingB => plot.padding + 30;
  double get paddingR => plot.padding;
  double get paddingT => plot.padding;

  Ticks? get xTicks => plot.xTicks
    ?..update(camera.localConstraints.xMin, camera.localConstraints.xMax);
  Ticks? get yTicks => plot.yTicks
    ?..update(camera.localConstraints.yMin, camera.localConstraints.yMax);

  List<Crosshair> get crosshairs => plot.graphs
      .map((graph) => graph.crosshairs ?? [])
      .expand((crosshair) => crosshair)
      .toList();
  List<Annotation> get annotations => plot.graphs
      .map((graph) => graph.annotations ?? [])
      .expand((annotation) => annotation)
      .toList();

  void init() {
    debugLog('Initializing Plot');
    _disposeValues();
    _initLog(
        plot.xTicks?.logarithmic ?? false, plot.yTicks?.logarithmic ?? false);
    _initGraphPaths(plot.graphs);
    _initExtremes(plot.graphs);
    _initCamera(plotExtremes.xMax - plotExtremes.xMin,
        plotExtremes.yMax - plotExtremes.yMin, width, height);
    _initPlotObjects(plot.graphs);
  }

  void onDrag(PointerMoveEvent event) {
    event = event.transformed(camera.transformInverted);
    camera.move(event.localDelta.dx, event.localDelta.dy);
    plot.onConstraintsChanged?.call(camera.localConstraints, plotExtremes);
  }

  void onScale(PointerEvent event, double scaleX, double scaleY) {
    final scalePosition =
        camera.transformInverted?.transformOffset(event.localPosition);
    if (scalePosition != null) {
      camera.scale(scalePosition.dx, scalePosition.dy, scaleX, scaleY);
      plot.onConstraintsChanged?.call(camera.localConstraints, plotExtremes);
    }
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

  void _initCamera(double localWidth, double localHeight, double canvasWidth,
      double canvasHeight) {
    camera = Camera(
      canvasWidth: canvasWidth,
      canvasHeight: canvasHeight,
      localConstraints: plot.constraints ?? plotExtremes,
      minimumScale: plot.minimumScale,
      maximumScale: plot.maximumScale,
    );
  }

  void _initGraphPaths(List<Graph> graphs) {
    for (var graph in graphs) {
      final Path path = Path();
      path.moveTo(graph.x[0], graph.y[0]);
      for (int i = 1; i < graph.x.length; i++) {
        path.lineTo(graph.x[i], graph.y[i]);
      }
      graphPaths[graph] = path;
    }
  }

  void _initExtremes(List<Graph> graphs) {
    final double xMin = graphs.map((graph) => graph.x.reduce(min)).reduce(min);
    final double xMax = graphs.map((graph) => graph.x.reduce(max)).reduce(max);
    final double yMin = graphs.map((graph) => graph.y.reduce(min)).reduce(min);
    final double yMax = graphs.map((graph) => graph.y.reduce(max)).reduce(max);
    plotExtremes =
        PlotConstraints(xMin: xMin, xMax: xMax, yMin: yMin, yMax: yMax);
    plot.onConstraintsChanged
        ?.call(plot.constraints ?? plotExtremes, plotExtremes);
  }

  void _initPlotObjects(List<Graph> graphs) {
    for (var graph in graphs) {
      for (var plotObject in graph.plotObjects) {
        if (plotObject.position == Offset.infinite) {
          final int index = graph.x.length ~/ 2;
          plotObject.position = Offset(graph.x[index], graph.y[index]);
          if (plotObject is Crosshair) {
            plotObject.prevIndex = index;
          }
        }
      }
    }
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
  bool _shiftDown = false;
  bool _controlDown = false;

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
        widget.onScale(event, scale, 1.0);
      });
    } else if (_controlDown) {
      setState(() {
        widget.onScale(event, 1.0, scale);
      });
    } else {
      setState(() {
        widget.onScale(event, scale, scale);
      });
    }
  }

  void _handlePointerDown(PointerDownEvent event) {
    setState(() {
      if (widget._checkPlotObjectHit(event)) {
        widget.currentInteraction = Interaction.plotObject;
        widget._activePlotObject?.onDragStart?.call(widget._activePlotObject!);
      } else {
        widget.currentInteraction = Interaction.graph;
      }
    });
  }

  void _handlePointerUp(PointerUpEvent event) {
    switch (widget.currentInteraction) {
      case Interaction.plotObject:
        widget._activePlotObject?.onDragEnd?.call(widget._activePlotObject!);
        break;
      case Interaction.graph:
        break;
    }
    widget.currentInteraction = Interaction.graph;
  }

  void _handlePointerMove(PointerMoveEvent event) {
    switch (widget.currentInteraction) {
      case Interaction.plotObject:
        setState(() {
          widget._activePlotObject
              ?.onDrag(event, widget.camera.transformInverted!);
          if (widget._activePlotObject is Crosshair) {
            final crosshair = widget._activePlotObject as Crosshair;
            crosshair.adjustPosition(
                event,
                widget.camera.transformInverted!,
                widget._activeGraph!.x,
                widget._activeGraph!.y,
                widget.plotExtremes.xMin,
                widget.plotExtremes.xMax,
                widget.xTicks?.logarithmic ?? false,
                widget.yTicks?.logarithmic ?? false);
          }
        });
      case Interaction.graph:
        setState(() {
          widget.onDrag(event);
        });
        break;
    }
  }

  bool _handleKeyDownUp(KeyEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.shift ||
        event.logicalKey == LogicalKeyboardKey.shiftLeft) {
      _shiftDown = event is KeyDownEvent;
    }
    if (event.logicalKey == LogicalKeyboardKey.control ||
        event.logicalKey == LogicalKeyboardKey.controlLeft) {
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
                    )),
                SizedBox(
                    width: widget.width,
                    height: widget.height,
                    child: CustomPaint(
                      painter: CrosshairPainter(
                        crosshairs: widget.crosshairs,
                        xUnit: widget.plot.xTicks?.unit,
                        yUnit: widget.plot.yTicks?.unit,
                        logarithmicXLabel:
                            widget.plot.xTicks?.logarithmic ?? false,
                        logarithmicYLabel:
                            widget.plot.yTicks?.logarithmic ?? false,
                        transform: widget.camera.transform,
                      ),
                    )),
                SizedBox(
                  width: widget.width,
                  height: widget.height,
                  child: AnnotationLayer(
                    annotations: widget.annotations,
                    transform: widget.camera.transform,
                  ),
                )
              ],
            )));
  }
}
