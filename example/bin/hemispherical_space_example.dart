import 'dart:io';
import 'dart:math';

import 'package:list_operators/list_operators.dart';
import 'package:simulated_annealing/simulated_annealing.dart';

// Define intervals.
final r = 2;
int hemisphere() => Random().nextFromList([-1, 1]);
var x = FixedInterval(-r, r);
final y = ParametricInterval(
  () => -sqrt(pow(r, 2) - pow(x.next(), 2)),
  () => sqrt(pow(r, 2) - pow(x.next(), 2)),
);

double zRange() => sqrt(pow(r, 2) - pow(y.next(), 2) - pow(x.next(), 2));
final z = ParametricInterval(() => zRange(), () => zRange());

// Defining a spherical search space.
// Intervals are listed in order of dependence.
final space = SearchSpace.sphere(
  rMin: r,
  rMax: r,
  thetaMin: 0,
  thetaMax: pi / 2,
);

void main() async {
  final position = [1.9, pi / 4, -pi / 2];
  final deltaPosition = [0.2, 0.4, 0.4];
  // final position = [0.8, 0.2, 1.8];
  // final deltaPosition = [0.6, 0.6, 0.6];

  final sample = space.sample(sampleSize: 2000).sphericalToCartesian;

  final perturbation = space
      .sampleCloseTo(position, deltaPosition, sampleSize: 400)
      .sphericalToCartesian;

  await File('example/data/hemisphere.dat').writeAsString(sample.export());
  await File(
    'example/data/hemisphere_perturbation.dat',
  ).writeAsString(perturbation.export());

  await File('example/data/hemisphere_test_point.dat').writeAsString('''
    # Test Point
    ${[position.sphericalToCartesian].export()}''');

  // The search space can be visualized by navigating to the folder
  // 'example/gnuplot_scripts' and running the commands:
  // # gnuplot
  // gnuplot> load 'hemispherical_search_space.gp'
}
