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



  @override
  Widget build(BuildContext context) {

    final x1 = List<double>.generate(10000, (i) => i + 1);
    final y1 = x1.map((x) => 2 * x + 3).toList();

    final x2 = List<double>.generate(10000, (i) => i + 1);
    final y2 = x2.map((x) => x + 2).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Plot(
            padding: 30,
            xUnit: 'Hz',
            yUnit: 'dB',
            xLog: true,
            ticksFractionDigits: 0,
            numYTicks: 5,
            graphs: [
              Graph(
                x: x1, 
                y: y1,
                color: Colors.blue,
                crosshairs: [
                  Crosshair(
                    label: 'Crosshair 1', 
                    active: true, 
                    yPadding: 10, 
                    color: Colors.blue
                    ),
                    ],
                annotations: [
                  Annotation(
                    width: 120,
                    height: 100,
                    child: const Card.filled(
                    color: Colors.blue,
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(
                      'This is an annotation.'
                    ),
                  )
                )
                )
                ]
              ),
              Graph(
                x: x2,
                y: y2,
                color: Colors.red,
                crosshairs: [
                  Crosshair(
                      label: 'Crosshair 2',
                      active: false,
                      yPadding: 100,
                      color: Colors.red,
                  )
                ]
              )
              ],
        )
       )
      ),
    );
  }
}
