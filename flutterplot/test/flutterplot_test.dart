import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutterplot/flutterplot.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: Center(
          child: Text(message),
        ),
      ),
    );
  }
}


void main() {
  testWidgets('Render a simple line', (tester) async {

    Graph simpleLine = Graph(X: [0, 1, 2, 3, 4, 5], Y: [4, 5, 6, 7, 8, 9]);

    await tester.pumpWidget(
      Plot(
        graph: [simpleLine])
        );
    
});

testWidgets('test', (tester) async {

  await tester.pumpWidget(const MyWidget(title: 'test', message: 'Hei'));

});

}
