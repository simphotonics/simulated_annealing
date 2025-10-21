import 'dart:io';
import 'dart:math';

import 'package:list_operators/list_operators.dart';
import 'package:simulated_annealing/simulated_annealing.dart';

/// To run the program navigate to the main project folder
/// and use the command:
/// ```Term
/// $ dart example/bin/cylindrical_space_example.dart
/// ```
/// To visualize the search space navigate to `example/gnuplot_scripts`,
/// start the program `gnuplot` and use the command:
/// ```Term
/// gnuplot> load 'cylindrical_space.gp'
/// ```
void main(List<String> args) async {
  final rho = 2.0;

  /// Search space including all points on the surface of
  /// a cylinder (rho is const).
  final space = SearchSpace.cylinder(
    rhoMin: rho,
    rhoMax: rho,
    zMin: -1,
    zMax: 1,
  );

  final position = [rho, -pi / 2, 0.5];
  final deltaPosition = [0.5, 0.2, 0.5];

  /// Generate samples:
  final sample = space.sample(sampleSize: 3000).cylindricalToCartesian;

  final perturbations = space
      .sampleCloseTo(position, deltaPosition, sampleSize: 600)
      .cylindricalToCartesian;
  print(space);

  print('');
  print('Writing data ...');

  /// Write to file:
  await File(
    'example/data/cylindrical_space.dat',
  ).writeAsString(sample.export(label: '#Cylindrical Search Space: x, y, z'));
  await File('example/data/cylindrical_space_perturbation.dat').writeAsString(
    perturbations.export(label: '#Cylindrical Perturbations: x, y, z'),
  );

  await File('example/data/cylindrical_space_test_point.dat').writeAsString(
    '''
    ${[position.cylindricalToCartesian].export(label: '#Perturbation Centrepoint: x, y, z')}''',
  );

  print('Data written successfully. \nGood bye.');
  // The search space can be visualized by navigating to the folder
  // 'example/gnuplot_scripts' and running the commands:
  // # gnuplot
  // gnuplot> load 'cylindrical_search_space.gp'
}
