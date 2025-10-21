import 'dart:io';
import 'dart:math';

import 'package:list_operators/list_operators.dart';
import 'package:simulated_annealing/simulated_annealing.dart';

void main() async {
  final radius = 2;

  // Defining a spherical search space consisting of all points on
  // the surface of a sphere with radius 2.
  final space = SearchSpace.sphere(rMin: 0, rMax: radius);
  final position = [1.9, pi / 4, -pi / 2];
  final deltaPosition = [0.4, 0.4, 0.4];

  final sampleSize = 2000;
  final perturbationSampleSize = 400;

  final sample = space.sample(sampleSize: sampleSize).sphericalToCartesian;

  final perturbations = space.sampleCloseTo(
    position,
    deltaPosition,
    sampleSize: perturbationSampleSize,
  );
  print(space);

  print('');
  print('Writing data ...');

  await File(
    'example/data/spherical_space.dat',
  ).writeAsString(sample.export(label: '#Spherical Search Space: x, y, z'));

  await File('example/data/spherical_space_perturbation.dat').writeAsString(
    perturbations.sphericalToCartesian.export(
      label: '#Spherical Perturbations: x, y, z',
    ),
  );

  await File('example/data/spherical_space_test_point.dat').writeAsString(
    '''
    ${[position.sphericalToCartesian].export(label: '#Perturbation Centrepoint: x, y, z')}''',
  );

  print('Data written successfully. \nGood bye.');

  // The search space can be visualized by navigating to the folder
  // 'example/gnuplot_scripts' and running the commands:
  // # gnuplot
  // gnuplot> load 'spherical_search_space.gp'
}
