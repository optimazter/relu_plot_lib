import 'package:flutter/material.dart';
import 'package:relu_plot_lib/relu_plot_lib.dart';



void main() {
  runApp(const MyApp());
}

/// This is an example app showing a simple example on how FlutterPlot can be used.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
    

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Plot(
            xTicks: Ticks(
              pretty: true, 
              logarithmic: true,
              unit: 'Hz',
              fractionDigits: 1,
              ),
            yTicks: Ticks(
              pretty: true, 
              logarithmic: false,
              unit: 'dB'
              ),
            graphs: [
              Graph(
                x: List<double>.generate(10000, (i) => i + 1.0), 
                y: List<double>.generate(10000, (i) => i + 1.0),
                color: Colors.blue,
                crosshairs: [
                  Crosshair(
                    width: 120,
                    label: 'Crosshair', 
                    yPadding: 20, 
                    color: Colors.red,
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

