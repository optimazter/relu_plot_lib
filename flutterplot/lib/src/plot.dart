import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterplot/flutterplot.dart';
import 'package:flutterplot/src/annotation.dart';
import 'package:flutterplot/src/custom_painters.dart';
import 'package:flutterplot/src/provider.dart';

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
  final Function(PlotConstraints)? onResize;

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
  Widget build(BuildContext context) => InteractivePlot(state: PlotState(plot: this));


}


class InteractivePlot extends StatefulWidget {

  const InteractivePlot({super.key, required this.state});

  final PlotState state;






  @override
  State<StatefulWidget> createState() => InteractivePlotState();

  
}




class InteractivePlotState extends State<InteractivePlot> {


  late final PanGestureRecognizer recognizer;
  final List<LogicalKeyboardKey> keys = [];
  bool shiftDown = false;
  bool controlDown = false;
  bool rightClick = false;
  bool annotationMovement = false;
  bool initialized = false;

  int moveFreq = 0;
  Offset moveOffset = Offset.zero;
  



  void _handleMouseScroll(double dy) {
    if (shiftDown) {
      final constrained = widget.state.setXConstraints(dy);
      if (constrained) {
        setState(() {
          widget.state.resizePlot(true, false);
        });
      }
    }
    else if (controlDown) {
      final constrained = widget.state.setYConstraints(dy);
      if (constrained) {
        setState(() {
          widget.state.resizePlot(false, true);
        });
      }
    }
    else {
      final xConstrained = widget.state.setXConstraints(dy);
      final yConstrained = widget.state.setYConstraints(dy);
      if (xConstrained && yConstrained) {
        setState(() {
          widget.state.resizePlot();        
        });

      }
      else if (xConstrained) {
        setState(() {
          widget.state.resizePlot(true, false);
        });
      }
      else if (yConstrained) {
        setState(() {
          widget.state.resizePlot(false, true);
        });
      }
    }
  }

  void _handlePointerDown(PointerDownEvent event) {

    setState(() {
      if (widget.state.checkAnnotationHit(event)) {
        widget.state.currentInteraction = Interaction.annotation;
      }
      else if (event.kind == PointerDeviceKind.mouse && event.buttons == kSecondaryMouseButton) {
        widget.state.currentInteraction = Interaction.graph;

      } else {
        widget.state.checkCrosshairHit(event);
        widget.state.currentInteraction = Interaction.crosshair;
      }
    });
  }
  

  void _handlePointerMove(PointerMoveEvent event) {
    switch(widget.state.currentInteraction) {
      case Interaction.annotation:
        setState(() {
            widget.state.moveActiveAnnotation(event);
        });
        break;
      case Interaction.crosshair:
          widget.state.moveActiveCrosshair(event);
          widget.state.crosshairState.value++;
        break;
      case Interaction.graph:
          moveFreq++;
          moveOffset += event.localDelta;
          if (moveFreq >= widget.state.decimate) {
            setState(() {
              widget.state.movePlot(moveOffset);
              widget.state.resizePlot();
              moveFreq = 0;
              moveOffset = Offset.zero;
            });

          }
        break;
    }
  }

  

  bool _handleKeyDownUp(KeyEvent event) {

    if (event.logicalKey == LogicalKeyboardKey.shift || event.logicalKey == LogicalKeyboardKey.shiftLeft) {
      shiftDown = event is KeyDownEvent;
    }
    if (event.logicalKey == LogicalKeyboardKey.control || event.logicalKey == LogicalKeyboardKey.controlLeft) {
      controlDown = event is KeyDownEvent;
    }
    return shiftDown || controlDown;
    
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
          left: widget.state.sidePadding, 
          bottom: widget.state.overPadding,
          right: widget.state.sidePadding + 40,
          top: widget.state.overPadding
        ),
        child: LayoutBuilder(

          builder: (context, windowConstraints) {   
            
            if (windowConstraints != widget.state.windowConstraints) {
              widget.state.resizeWindow(windowConstraints);
            }
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
                                  foregroundPainter: GraphPainter(state: widget.state),
                                  painter: BackgroundPainter(state: widget.state),
                                  )
                        ),
                        RepaintBoundary(
                          child: ValueListenableBuilder(
                            valueListenable: widget.state.crosshairState, 
                            builder: (context, value, child) {
                             return SizedBox(
                                  width: windowConstraints.maxWidth,
                                  height: windowConstraints.maxHeight,
                                  child: CustomPaint(
                                      painter: CrosshairPainter(state: widget.state),
                                  )
                                );
                            }),
                          ),
                        SizedBox(
                            width: windowConstraints.maxWidth,
                            height: windowConstraints.maxHeight,
                            child:  AnnotationLayer(state: widget.state, context: context),
                        ),
                      ],
                  )
              );
            }
        ),);
      }
    }



    





