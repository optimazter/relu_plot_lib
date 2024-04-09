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
    return 2 * pow(x, 2) / 1000 + 2*x + 40;
  }

  double f2(num x) {
    return 2 * pow(x, 2)/ 1000 + 3 * x + 500;
  }


  @override
  Widget build(BuildContext context) {

    List<double> X = [];
    List<double> y1 = [];
    List<double> y2 = [];
    for (int i = -500000; i < 500000; i++) {
      X.add(i.toDouble());
      y1.add(f1(i));
      y2.add(f2(i));
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
              annotations: [Annotation(child: const SizedBox(
                width: 100,
                height: 80,
                child: Card.filled(
                color: Colors.blue,
                child: Text('Test'),
              )
              )
            )]
            ),
            // Graph(
            //   X: X, 
            //   Y: y2,
            //   color: Colors.amber,
            //   crosshair: Crosshair(label: 'Test2', active: true, yPadding: 20),
            //    annotations: [Annotation(child: const SizedBox(
            //     width: 100,
            //     height: 80,
            //     child: Card.filled(
            //     color: Colors.amber,
            //     child: Text('hei 2'),
            //   )
            //   )
            // )]
            //   )
            ],
        )
    )
    );
  }
}
