import 'dart:io';
import 'dart:math';

import 'package:simulated_annealing/simulated_annealing.dart';

void main() async {
  // Define intervals.
  final radius = 2;
  final x = FixedInterval(-radius, radius);
  final y = ParametricInterval(
    () => -sqrt(pow(radius, 2) - pow(x.next(), 2)),
    () => sqrt(pow(radius, 2) - pow(x.next(), 2)),
  );
  final z = ParametricInterval(
    () => -sqrt(pow(radius, 2) - pow(y.next(), 2) - pow(x.next(), 2)),
    () => sqrt(pow(radius, 2) - pow(y.next(), 2) - pow(x.next(), 2)),
  );

  // Defining a spherical search space.
  final space = SearchSpace([x, y, z]);

  print('Space sizes: ${space.size}.');

  final testPoint = [1.2, 1.0, 0.6];
  final magnitudes = [0.4, 0.4, 0.4];

  final sample = List<List<num>>.generate(2000, (_) => space.next());

  final perturbation = List<List<num>>.generate(
      500, (_) => space.perturb(testPoint, magnitudes));

  await File('../data/spherical_search_space.dat').writeAsString(
    sample.export(),
  );
  await File('../data/spherical_search_space_perturbation.dat').writeAsString(
    perturbation.export(),
  );

  await File('../data/spherical_search_space_center_point.dat').writeAsString('''
    # Perturbation Centerpoint
    ${[testPoint].export()}''');

  // The search space can be visualized by navigating to the folder
  // 'example/data' and running the commands:
  // # gnuplot
  // gnuplot> load 'spherical_search_space.gp'
}
