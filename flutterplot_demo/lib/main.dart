import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutterplot/flutterplot.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flutterplot demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'flutterplot demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  double f1(num x) {
    return x * sin(pi / 5 * x);
  }

  double f2(num x) {
    return pow(x,2) + 7 * x - 2000;
  }


  @override
  Widget build(BuildContext context) {

    List<double> X = [];
    List<double> y1 = [];
    for (int i = 0; i < 1000; i++) {
      X.add(i.toDouble());
      y1.add(f1(i));
    }

    return Scaffold(
      appBar: AppBar(

        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Plot(
          padding: 30,
          xUnit: 'Hz',
          yUnit: 'dB',
          graphs: [
            Graph(
              X: X, 
              Y: y1,
              color: Colors.blue,
              crosshair: Crosshair(label: 'Test1', active: true, yPadding: 10),
              annotations: [Annotation(child: Text("Test"))]
            ),
            // Graph(
            //   X: X, 
            //   Y: Y2,
            //   color: Colors.red,
            //   crosshair: Crosshair(label: 'Test2', active: false, yPadding: 20),
            //   )
            ],
        )
    )
    );
  }
}
