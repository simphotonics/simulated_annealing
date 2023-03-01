import 'dart:io';
import 'dart:math';

import 'package:list_operators/list_operators.dart';
import 'package:simulated_annealing/simulated_annealing.dart';

void main() async {
  final radius = 2;

// Defining a spherical search space consisting of all points on
// the surface of a sphere with radius 2.
  final space = SearchSpace.sphere(rMin: radius, rMax: radius);
  final position = [radius, 0.0, 0.0];
  final deltaPosition = [0, 0.2, pi];

  final sampleSize = 2000;
  final perturbationSampleSize = 600;

  final sample = space.sample(size: sampleSize).sphericalToCartesian;

  final perturbations = space.sampleVicinityOf(
    position,
    deltaPosition,
    size: perturbationSampleSize,
  );

  await File('example/data/spherical_search_space2D.dat').writeAsString(
    sample.export(label: '#Spherical Search Space: x, y, z'),
  );
  await File('example/data/spherical_search_space_perturbation.dat')
      .writeAsString(
    perturbations.export(label: '#Spherical Perturbations: r, theta, phi'),
  );
  await File('example/data/spherical_search_space2D_perturbation.dat')
      .writeAsString(
    perturbations.sphericalToCartesian
        .export(label: '#Spherical Perturbations: x, y, z'),
  );

  await File('example/data/spherical_search_space2D_test_point.dat')
      .writeAsString('''
    ${[
    position.sphericalToCartesian
  ].export(label: '#Perturbation Centrepoint: x, y, z')}''');

  // The search space can be visualized by navigating to the folder
  // 'example/gnuplot_scripts' and running the commands:
  // # gnuplot
  // gnuplot> load 'spherical_search_space2D.gp'
}
