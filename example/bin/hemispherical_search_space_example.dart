import 'dart:io';
import 'dart:math';

import 'package:list_operators/list_operators.dart';
import 'package:simulated_annealing/simulated_annealing.dart';

// Define intervals.
final r = 2;
int hemisphere() => Random().nextIntFromList([-1, 1]);
var x = FixedInterval(-r, r);
final y = ParametricInterval(
  () => -sqrt(pow(r, 2) - pow(x.next(), 2)),
  () => sqrt(pow(r, 2) - pow(x.next(), 2)),
);

double zRange() => sqrt(pow(r, 2) - pow(y.next(), 2) - pow(x.next(), 2));
final z = ParametricInterval(
  () => zRange(),
  () => zRange(),
);

// Defining a spherical search space.
// Intervals are listed in order of dependence.
final space = SearchSpace([x, y, z]);

void main() async {
  for (var i = 0; i < 10; i++) {
    print(space.estimateSize());
  }

  final xTest = [0.8, 0.2, 1.8];
  final deltaPosition = [0.6, 0.6, 0.6];

  final sample =
      List<List<num>>.generate(1200, (_) => space.next(nGrid: [120, 120, 120]));

  final perturbation =
      List<List<num>>.generate(400, (_) => space.perturb(xTest, deltaPosition));

  await File('../data/hemisphere.dat').writeAsString(
    sample.export(),
  );
  await File('../data/hemisphere_perturbation.dat').writeAsString(
    perturbation.export(),
  );

  await File('../data/hemisphere_test_point.dat').writeAsString('''
    # Test Point
    ${[xTest].export()}''');

  // The search space can be visualized by navigating to the folder
  // 'example/gnuplot_scripts' and running the commands:
  // # gnuplot
  // gnuplot> load 'hemispherical_search_space.gp'
}
