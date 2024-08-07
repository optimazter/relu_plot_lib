import 'package:flutter/material.dart';
import 'package:flutterplot/src/models/annotation.dart';


/// The Annotation Render Element 
class AnnotationRenderElement extends MultiChildRenderObjectElement {
  AnnotationRenderElement(super.widget);


  @override
  void update(covariant MultiChildRenderObjectWidget newWidget) {
    super.update(newWidget);
    visitChildren((element) {
      final parentDataElement = element as ParentDataElement<AnnotationParentData>;
      final annotation = parentDataElement.widget as Annotation;
      if (parentDataElement.renderObject != null) {
        annotation.applyParentData(parentDataElement.renderObject!);
      }
    });
  }

  
}