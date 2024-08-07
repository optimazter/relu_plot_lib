import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutterplot/src/rendering/annotation_layout.dart';



class AnnotationParentData extends MultiChildLayoutParentData with ContainerParentDataMixin<RenderBox> {
  Matrix4 modelView = Matrix4.identity();
  Offset position = Offset.zero;
} 


// ignore: must_be_immutable
class Annotation extends ParentDataWidget<AnnotationParentData> {
  
   Annotation({
    super.key, 
    this.position = Offset.zero,
    this.onDragEnd,
    required double width,
    required double height,
    required Widget child,

  }) 
  : 
  halfWidth = width / 2,
  halfHeight = height / 2,
  super(child: Center(child: child));

  Offset position;
  final Matrix4 modelView = Matrix4.identity();
  final double halfWidth;
  final double halfHeight;


  /// Function called every time the Annotation has been moved
  final Function(Offset position)? onDragEnd;


  @override
  void applyParentData(RenderObject renderObject) {
    
    assert(renderObject.parentData is AnnotationParentData);
    final AnnotationParentData parentData = renderObject.parentData! as AnnotationParentData;
    bool needsLayout = false;

    if (parentData.position != position) {
      parentData.position = position;
      needsLayout = true;
    }
    if (parentData.modelView != modelView) {
      parentData.modelView = modelView;
      needsLayout = true;
    }
    if (needsLayout) {
      final RenderObject? targetParent = renderObject.parent;
      if (targetParent is RenderObject) {
        targetParent.markNeedsLayout();
      }
    }

  }

  
  @override
  Type get debugTypicalAncestorWidgetClass => AnnotationRenderObject;


}
