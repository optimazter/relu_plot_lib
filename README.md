# About

*relu_plot_lib* is a simple graph tool for flutter desktop applications.

Add multiple graphs and annotate them with widgets of your choosing, navigate around the plot and scale it using your mouse, and read and compare graph values with crosshairs.

# Usage 
To use relu_plot_lib, simply add *relu_plot_lib* as a dependency in your *pubspec.yaml* file.

```yaml
dependencies:
  relu_plot_lib: ^1.0.3
```

![output](https://github.com/user-attachments/assets/9ab75fa4-d451-4d35-9975-7116090b87ad)



An example on how to implement the simple relu_plot_lib Plot in the video above is shown below. This code is available in the *examples* folder as well.

```dart
Plot(
  xTicks: Ticks(
    pretty: true, 
    logarithmic: true,
    unit: 'Hz',
    fractionDigits: 1,
    ),
  yTicks: Ticks(
    pretty: true, 
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
          child: const Card.filled(
            color: Colors.red,
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
          ),
        ),
      ]
    ),
  ],
)
```

