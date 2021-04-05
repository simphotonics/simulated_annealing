import 'dart:io';
import 'dart:math';

import 'package:list_operators/list_operators.dart';
import 'package:simulated_annealing/simulated_annealing.dart';

// Define intervals.
final radius = 2.0;
var x = FixedInterval(-radius, radius);

num yBoundary() {
  if (x.next() >= radius) {
    print('yBoundary: $x');
  }
  return sqrt(pow(radius, 2.0) - pow(x.next(), 2));
}

num zBoundary() {
  if (pow(x.next(), 2) + pow(y.next(), 2) > pow(radius, 2)) {
    print('x = $x;');
    print('y = $y');
    print('z^2 = ${pow(radius, 2.0) - pow(x.next(), 2) - pow(y.next(), 2)}');
  }
  return sqrt(pow(radius, 2.0) - pow(x.next(), 2) - pow(y.next(), 2));
}

final y = ParametricInterval(
  () => -yBoundary(),
  () => yBoundary(),
);

final z = ParametricInterval(
  () => -zBoundary(),
  () => zBoundary(),
);

// Defining a spherical search space.
// Intervals are listed in order of dependence.
final space = SearchSpace([x, y, z]);

void main() async {
  for (var i = 0; i < 10; i++) {
    print(space.estimateSize());
  }

  final xTest = [1.2, 1.0, 0.6];
  final deltaPosition = [0.6, 0.6, 0.6];

  final sample =
      List<List<num>>.generate(2000, (_) => space.next(nGrid: [10, 10, 10]));

  final perturbation = List<List<num>>.generate(
      500, (_) => space.perturb(xTest, deltaPosition, nGrid: [50, 50, 50]));

  await File('../data/spherical_search_space.dat').writeAsString(
    sample.export(),
  );
  await File('../data/spherical_search_space_perturbation.dat').writeAsString(
    perturbation.export(),
  );

  await File('../data/spherical_search_space_center_point.dat')
      .writeAsString('''
    # Perturbation Centerpoint
    ${[xTest].export()}''');

  // The search space can be visualized by navigating to the folder
  // 'example/gnuplot_scripts' and running the commands:
  // # gnuplot
  // gnuplot> load 'spherical_search_space.gp'
}
