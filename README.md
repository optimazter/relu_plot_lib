# FlutterPlot
# (NOTE: UNDER DEVELOPMENT)

<a href=”https://github.com/optimazter/flutterplot/actions"><img src=”https://github.com/optimazter/flutterplot/workflows/tests/badge.svg" alt=”Build Status”></a>

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
  graphs: [
    Graph(
      x: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10], 
      y: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
      color: Colors.blue,
      crosshairs: [
        Crosshair(
          label: 'Crosshair 1', 
          active: true, 
          yPadding: 10, 
          color: Colors.blue
          ),],
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
   ]),
]);
```

Note that the FlutterPlot package is created with large datasets in mind, with few points as shown in the example above, 
the Crosshairs movement will be weird as when it will search for the nearest value the nearest values are far from each other.
