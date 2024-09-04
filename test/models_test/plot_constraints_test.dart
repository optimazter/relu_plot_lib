import 'package:relu_plot_lib/src/models/plot_constraints.dart';
import 'package:test/test.dart';

void main() {
  test('is finite', () {
    final finiteConstraints =
        PlotConstraints(xMin: 0, xMax: 100, yMin: 0, yMax: 100);
    expect(finiteConstraints.isFinite, true);
  });

  test('is infinite', () {
    final infiniteConstraints =
        PlotConstraints(xMin: 0, xMax: double.infinity, yMin: 0, yMax: 100);
    expect(infiniteConstraints.isFinite, false);
  });

  test('equal', () {
    final constraints1 =
        PlotConstraints(xMin: 0, xMax: 100, yMin: 0, yMax: 100);
    final constraints2 =
        PlotConstraints(xMin: 0, xMax: 100, yMin: 0, yMax: 100);
    expect(constraints1 == constraints2, true);
  });

  test('unequal', () {
    final constraints1 =
        PlotConstraints(xMin: 0, xMax: 100, yMin: 0, yMax: 100);
    final constraints2 = PlotConstraints(xMin: 0, xMax: 50, yMin: 0, yMax: 50);
    expect(constraints1 == constraints2, false);
  });
}
