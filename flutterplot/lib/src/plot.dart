import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterplot/flutterplot.dart';
import 'package:flutterplot/src/annotation.dart';
import 'package:flutterplot/src/custom_painters.dart';
import 'package:flutterplot/src/provider.dart';


class Plot extends StatelessWidget {   
  
  const Plot({
    Key? key,
    required this.graphs,
    this.xUnit,
    this.yUnit, 
    this.xTicks,
    this.yTicks,
    this.numXTicks,
    this.numYTicks,
    this.showGrid = true,
    this.strokeWidth = 1,
    this.padding = 0,
    this.fractionDigits = 0,
  }) : super(key: key);


  final List<Graph> graphs;
  
  final String? xUnit;
  final String? yUnit;

  final List<double>? xTicks;
  final List<double>? yTicks;

  final int? numXTicks;
  final int? numYTicks;

  final bool showGrid;

  final double strokeWidth;
  final double padding;
  final int fractionDigits;
  
  @override
  Widget build(BuildContext context) => ProviderScope(
    child: InteractivePlot(state: PlotStateManager(plot: this)),
  );

  
}

class InteractivePlot extends StatefulWidget { 

  InteractivePlot({required this.state});

  final PlotStateManager state;

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

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleKeyDownUp);
  }

  void _handleMouseScroll(double dy, WidgetRef ref) {
 
    if (shiftDown) {
      var constrained = widget.state.setXConstraints(dy);
      if (constrained) {
        widget.state.resize(true, false);
        widget.state.repaintPlot(ref);

      }

    }
    else if (controlDown) {
      var constrained = widget.state.setYConstraints(dy);
      if (constrained) {
        widget.state.resize(false, true);
        widget.state.repaintPlot(ref);

      }
    }
    else {
      var xConstrained = widget.state.setXConstraints(dy);
      var yConstrained = widget.state.setYConstraints(dy);
      if (xConstrained && yConstrained) {
        widget.state.resize();
        widget.state.repaintPlot(ref);

      }
      else if (xConstrained) {
        widget.state.resize(true, false);
        widget.state.repaintPlot(ref);

      }
      else if (yConstrained) {
        widget.state.resize(false, true);
        widget.state.repaintPlot(ref);

      }
    }

  }

  void _handlePointerDown(PointerDownEvent event, WidgetRef ref) {
    if (widget.state.currentInteraction != Interaction.annotation) {
      if (event.kind == PointerDeviceKind.mouse && event.buttons == kSecondaryMouseButton) {
        widget.state.currentInteraction = Interaction.graph;
      } else {
        widget.state.currentInteraction = Interaction.crosshair;
      }
    }
  }
  



  void _handlePointerMove(PointerMoveEvent event, WidgetRef ref) {
    switch(widget.state.currentInteraction) {
      case Interaction.annotation:
        break;
      case Interaction.crosshair:
        widget.state.moveActiveCrosshairs(event);
        widget.state.repaintCrosshairs(ref);
        break;
      case Interaction.graph:
        widget.state.movePlot(event.delta);
        widget.state.resize();
        widget.state.repaintPlot(ref);
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
  Widget build(BuildContext context) {

    return Padding(
      padding: EdgeInsets.only(
        left: widget.state.sidePadding, 
        bottom: widget.state.overPadding,
        right: widget.state.sidePadding,
        top: widget.state.overPadding
        ),
      child: LayoutBuilder(

        builder: (_, windowConstraints) {

          widget.state.init(windowConstraints);

          return Consumer(builder: (context, ref, child) {

            ref.watch(plotRepainter);

            return Listener(
                onPointerDown: (event) {
                  _handlePointerDown(event, ref);
                },
                onPointerMove: (event) {
                  _handlePointerMove(event, ref);
                },
                onPointerSignal: (event) {
                  if (event is PointerScrollEvent) { 
                    _handleMouseScroll(event.scrollDelta.dy, ref);
                  }
                },
                onPointerPanZoomUpdate: (PointerPanZoomUpdateEvent event) {
                  _handleMouseScroll(event.panDelta.dy, ref);
                },
                child: Stack(
                    children: [
                      SizedBox(
                        width: windowConstraints.maxWidth,
                        height: windowConstraints.maxHeight,
                        child: RepaintBoundary(
                          child: CustomPaint(
                            painter: BackgroundPainter(state: widget.state),
                            )
                          ),
                      ),
                      SizedBox(
                          width: windowConstraints.maxWidth,
                          height: windowConstraints.maxHeight,
                          child: RepaintBoundary(
                            child: CustomPaint(
                              painter: GraphPainter(state: widget.state),
                              )
                            ),
                      ),
                      Consumer(builder: (context, crosshairRef, child) {
                        crosshairRef.watch(crosshairRepainter);
                        return SizedBox(
                          width: windowConstraints.maxWidth,
                          height: windowConstraints.maxHeight,
                          child: RepaintBoundary(
                            child: CustomPaint(
                              painter: CrosshairPainter(state: widget.state),
                              )
                            ),
                        );
                      }),
                      // Consumer(builder: (context, annotationRef, child) {
                      //   annotationRef.watch(annotationsRepainter);
                      //   return SizedBox(
                      //     width: windowConstraints.maxWidth,
                      //     height: windowConstraints.maxHeight,
                      //     child: RepaintBoundary(
                      //       child: CustomPaint(
                      //         painter: AnnotationPainter(state: widget.state),
                      //       )
                      //     ),
                      //   );
                        
                      // },),
                      SizedBox(
                          width: windowConstraints.maxWidth,
                          height: windowConstraints.maxHeight,
                          child:  AnnotationLayer(state: widget.state,),
                      ),
                    ]
                )
              );  
            });
          }
        )
      );
    }
  }



    





