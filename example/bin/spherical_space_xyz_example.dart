import 'dart:io';

import 'package:list_operators/list_operators.dart';
import 'package:simulated_annealing/simulated_annealing.dart';

void main() async {
  final radius = 1.0;

// Defining a spherical search space consisting of all points on
// the surface of a sphere with radius 2.
  final space = SearchSpace.sphereCartesian(
    radius: radius,
    //centre: [1, 1, 1],
  );

  final position = [0.5, 1.0, 1.5].sphericalToCartesian;
  final deltaPosition = [0.2, 0.2, 0.2];

  final sampleSize = 6000;
  final perturbationSampleSize = 600;

  final sample = space.sample(sampleSize: sampleSize);

  final perturbations = space.sampleCloseTo(
    position,
    deltaPosition,
    sampleSize: perturbationSampleSize,
  );
  print(space);

  print('');
  print('Writing data ...');

  await File('example/data/spherical_space.dat').writeAsString(
    sample.export(label: '#Spherical Search Space: x, y, z'),
  );

  await File('example/data/spherical_space_perturbation.dat').writeAsString(
    perturbations.export(label: '#Spherical Perturbations: x, y, z'),
  );

  await File('example/data/spherical_space_test_point.dat').writeAsString('''
    ${[position].export(label: '#Perturbation Centrepoint: x, y, z')}''');

  print('Data written successfully. \nGood bye.');

  // The search space can be visualized by navigating to the folder
  // 'example/gnuplot_scripts' and running the commands:
  // # gnuplot
  // gnuplot> load 'spherical_search_space2D.gp'
}
