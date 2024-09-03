# About

FlutterPlot is a simple graph tool for flutter desktop applications.

# Usage 
To use FlutterPlot, simply add [flutterplot] as a dependency in your *pubspec.yaml* file.

```yaml
dependencies:
    flutterplot: ^1.0.1
```

https://github.com/user-attachments/assets/a8744c57-70a8-48db-9ebc-835a002256c1


An example on how to implement the simple FlutterPlot Plot in the video above is shown below.

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

