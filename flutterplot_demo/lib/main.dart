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

    final x = List<double>.generate(10000, (i) => i + 1.0);
    final List<double> y = List.from(x);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Plot(
            xTicks: Ticks(
              pretty: true, 
              logarithmic: true
              ),
            yTicks: Ticks(
              pretty: true, 
              logarithmic: false
              ),
            graphs: [
              Graph(
                x: x, 
                y: y,
                color: Colors.blue,
                crosshairs: [
                  Crosshair(
                    label: 'Crosshair', 
                    yPadding: 20, 
                    color: Colors.red
                  )
                ],
                annotations: [
                  Annotation(
                    width: 100,
                    height: 100,
                    child: Card.filled(
                      child: SizedBox(
                        width: 100,
                        height: 70,
                        child: Center(
                          child: Text(
                            'This is an annotation!', 
                            textAlign: TextAlign.center,
                          )
                        ),
                      ),
                      color: Colors.red
                    ),
                  ),
                ]
              ),
            ],
        )
        )
      ),
    );
  }
}

