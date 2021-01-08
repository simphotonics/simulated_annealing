import 'dart:io';

import 'package:simulated_annealing/simulated_annealing.dart';

void main() async {
  // Define intervals.
  final yMax = 6;
  final yMin = -2;
  final x = FixedInterval((yMax - yMin)/30, 10);
  final y = ParametricInterval(
      () => yMax - 15 * x.next(), () => yMin + 15 * x.next());

  // Defining a spherical search space.
  final space = SearchSpace([x, y]);

  print('Space sizes: ${space.size}.');

  final testPoint = [3.0, 25.0];
  final magnitudes = [0.5, 25.0];

  final sample = List<List<num>>.generate(2000, (_) => space.next());

  final perturbation = List<List<num>>.generate(
      500, (_) => space.perturb(testPoint, magnitudes));

  await File('../data/triangular_search_space.dat').writeAsString(
    sample.export(),
  );
  await File('../data/triangular_search_space_perturbation.dat').writeAsString(
    perturbation.export(),
  );

  await File('../data/triangular_search_space_center_point.dat').writeAsString('''
    # Perturbation Centerpoint
    ${[testPoint].export()}''');

  // The search space can be visualized by navigating to the folder
  // 'example/data' and running the commands:
  // # gnuplot
  // gnuplot> load 'triangular_search_space.gp'
}
