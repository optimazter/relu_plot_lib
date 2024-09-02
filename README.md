![workflow](https://github.com/optimazter/flutterplot/workflows/tests/badge.svg)

# FlutterPlot

FlutterPlot is a simple graph tool for flutter desktop applications. 


To download, simply add the following code to your **pubspec.yaml**:

```yaml
flutterplot: 
  git:
    url: https://github.com/optimazter/flutterplot
    path: flutterplot
```
An example on how to implement a simple FlutterPlot Plot is shown below. For further information, please see the provided **flutterplot_demo**.

```dart
Plot(
  xTicks: Ticks(
    pretty: true, 
    logarithmic: true,
    unit: 'Hz',
    ),
  yTicks: Ticks(
    pretty: true, 
    unit: 'dBSPL'
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
);
```

Note that the FlutterPlot package is created with large datasets in mind, with few points, 
the Crosshairs movement will be weird as when it will search for the nearest value the nearest values are far from each other.
