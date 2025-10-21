import 'dart:io';
import 'dart:math';

import 'package:list_operators/list_operators.dart';
import 'package:simulated_annealing/simulated_annealing.dart';

double invCDF(num p, num xMin, num xMax) => xMin + (xMax - xMin) * sqrt(p);

/// To run the program navigate to main project folder and use the
/// command:
/// ```Terminal
/// $ dart example/bin/triangular_search_space_example.dart
/// ```

void main() async {
  final space = SearchSpace.triangle(xMin: 0, xMax: 6, yMin: -100, yMax: 150);

  print('Space size: ${space.size}.');

  final testPoint = [4.0, 25.0];
  final magnitudes = [2.5, 25.0];

  final sample = List<List<num>>.generate(2000, (_) => space.next());

  final perturbation = List<List<num>>.generate(
    900,
    (_) => space.perturb(testPoint, magnitudes),
  );

  await File(
    'example/data/triangular_search_space.dat',
  ).writeAsString(sample.export());
  await File(
    'example/data/triangular_search_space_perturbation.dat',
  ).writeAsString(perturbation.export());

  await File(
    'example/data/triangular_search_space_center_point.dat',
  ).writeAsString('''
    # Perturbation Centerpoint
    ${[testPoint].export()}''');

  // The search space can be visualized by navigating to the folder
  // 'example/data' and running the commands:
  // # gnuplot
  // gnuplot> load 'triangular_search_space.gp'
}
