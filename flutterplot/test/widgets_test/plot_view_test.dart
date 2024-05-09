
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterplot/flutterplot.dart';



void main() {

  testWidgets(' ', (WidgetTester tester) async {
    await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: Plot(
                    graphs: [
                      Graph(
                        x: [0, 1000], 
                        y: [0, 1000],
                        annotations: [
                          Annotation(
                            child: const Text('test'),
                            coordinate: const Offset(500, 500)),

                        ]
                    )],
                  )
                )),
            )
        );
      });

    
    
}