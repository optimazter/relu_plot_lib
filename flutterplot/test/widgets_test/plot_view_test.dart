
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterplot/flutterplot.dart';
import 'package:flutterplot/src/widgets/plot_view.dart';





void main() {

  testWidgets(' ', (WidgetTester tester) async {
    await tester.pumpWidget(
      PlotView(plot: 
        Plot(
          xTicks: const [1, 2],
          yTicks: const [1, 2],
          ticksFractionDigits: 0,
          graphs: [
            Graph(
              x: [1, 2, 3, 4, 5], 
              y: [1, 2, 3, 4, 5]
          )],
        )
      )
    );
  });
}