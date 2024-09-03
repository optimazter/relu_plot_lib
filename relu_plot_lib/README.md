# About

*relu_plot_lib* is a simple graph tool for flutter desktop applications.

# Usage 
To use relu_plot_lib, simply add *relu_plot_lib* as a dependency in your *pubspec.yaml* file.

```yaml
dependencies:
  relu_plot_lib: ^1.0.1
```

![relu_plot_lib_demo](https://github.com/user-attachments/assets/430b330b-be1d-45cb-a55b-dec45110c839)


An example on how to implement the simple relu_plot_lib Plot in the video above is shown below.

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

