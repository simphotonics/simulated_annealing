import 'dart:io';
import 'dart:math';

import 'package:list_operators/list_operators.dart';
import 'package:simulated_annealing/simulated_annealing.dart';

// Define intervals.
final radius = 2;
final theta = FixedInterval(0, pi);
final phi = FixedInterval(0, 2 * pi);

// Defining a spherical search space.
final space = SearchSpace([theta, phi], dxMin: [1e-6, 1e-6, 1e-6]);

void main() async {
  final testPointSC = [0.7, 1.9 * pi];
  final magnitudesSC = [pi / 10, pi / 10];

  final testPointCC = [
    radius * sin(testPointSC[0]) * cos(testPointSC[1]),
    radius * sin(testPointSC[0]) * sin(testPointSC[1]),
    radius * cos(testPointSC[0]),
  ];

  var sampleSize = 900;

  final sampleSC = List<List<num>>.generate(sampleSize, (_) => space.next());

  // final sampleSC = <List<num>>[];

  // final n = 30;

  // for (var i = 0; i < n; i++) {
  //   for (var j = 0; j < n; j++) {
  //     sampleSC.add([0 + i / (n - 1) * pi, 0 + j / (n - 1) * 2 * pi]);

  //   }
  // }


  final sampleCC = List<List<num>>.generate(
    sampleSC.length,
    (i) => [
      radius * sin(sampleSC[i][0]) * cos(sampleSC[i][1]),
      radius * sin(sampleSC[i][0]) * sin(sampleSC[i][1]),
      radius * cos(sampleSC[i][0]),
    ],
  );

  final perturbationSC = List<List<num>>.generate(
      200, (_) => space.perturb(testPointSC, magnitudesSC));

  final perturbationCC = List<List<num>>.generate(
    200,
    (i) => [
      radius * sin(perturbationSC[i][0]) * cos(perturbationSC[i][1]),
      radius * sin(perturbationSC[i][0]) * sin(perturbationSC[i][1]),
      radius * cos(perturbationSC[i][0]),
    ],
  );

  await File('../data/spherical_search_space2D.dat').writeAsString(
    sampleCC.export(),
  );
  await File('../data/spherical_search_space2D_perturbation.dat').writeAsString(
    perturbationCC.export(),
  );

  await File('../data/spherical_search_space2D_test_point.dat')
      .writeAsString('''
    # Perturbation Centerpoint
    ${[testPointCC].export()}''');

  // The search space can be visualized by navigating to the folder
  // 'example/gnuplot_scripts' and running the commands:
  // # gnuplot
  // gnuplot> load 'spherical_search_space2D.gp'
}
