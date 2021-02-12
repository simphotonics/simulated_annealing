import 'dart:io';
import 'dart:math';

import 'package:list_operators/list_operators.dart';
import 'package:simulated_annealing/simulated_annealing.dart';

double inverseCdf(num p, num thetaMin, num thetaMax) {
  final cosThetaMin = cos(thetaMin);
  return acos(-p * (cosThetaMin - cos(thetaMax)) + cosThetaMin);
}

// Define intervals.
final radius = 2;
final theta = FixedInterval(0, pi);//, inverseCdf: inverseCdf);
final phi = FixedInterval(0, 2 * pi);

// Defining a spherical search space.
final space = SearchSpace([phi, theta], dxMin: [1e-6, 1e-6, 1e-6]);

void main() async {
  final testPointSC = [2*pi-0.5, pi/4];
  final magnitudesSC = [pi/8, pi/8];

  print(space.perturb(testPointSC, magnitudesSC));

  final testPointCC = [
    radius * sin(testPointSC[1]) * cos(testPointSC[0]),
    radius * sin(testPointSC[1]) * sin(testPointSC[0]),
    radius * cos(testPointSC[1]),
  ];

  final sampleSize = 2000;
  final perturbationSampelSize = 600;

  final sampleSC = List<List<num>>.generate(sampleSize, (_) => space.next());

  final sampleCC = List<List<num>>.generate(
    sampleSC.length,
    (i) => [
      radius * sin(sampleSC[i][1]) * cos(sampleSC[i][0]),
      radius * sin(sampleSC[i][1]) * sin(sampleSC[i][0]),
      radius * cos(sampleSC[i][1]),
    ],
  );

  final perturbationSC = List<List<num>>.generate(
      perturbationSampelSize, (_) => space.perturb(testPointSC, magnitudesSC));

  // Transform to Cartesian coordinates.
  final perturbationCC = List<List<num>>.generate(
    perturbationSC.length,
    (i) => [
      radius * sin(perturbationSC[i][1]) * cos(perturbationSC[i][0]),
      radius * sin(perturbationSC[i][1]) * sin(perturbationSC[i][0]),
      radius * cos(perturbationSC[i][1]),
    ],
  );

  // await File('../data/sphereSCperturbation.dat')
  //     .writeAsString(perturbationSC.export());
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
