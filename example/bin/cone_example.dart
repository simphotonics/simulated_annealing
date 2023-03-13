import 'dart:io';
import 'dart:math';

import 'package:list_operators/list_operators.dart';
import 'package:simulated_annealing/simulated_annealing.dart';

/// To run the program navigate to the main project folder
/// and use the command:
/// ```Term
/// $ dart example/bin/cone_example.dart
/// ```
/// To visualize the search space navigate to `example/gnuplot_scripts`,
/// start the program `gnuplot` and use the command:
/// ```Term
/// gnuplot> load 'cone.gp'
/// ```
void main(List<String> args) async {
  /// Search space including all points on the surface of
  /// a cone (rho is const).
  final space = SearchSpace.cone()..levels = ([36, 36, 20]);

  final position = [0.5, -pi / 2, 0.5];
  final deltaPosition = [0.1, 0.2, 0.5];

  /// Generate samples:
  final sample = space.sample(sampleSize: 2000).cylindricalToCartesian;

  final perturbations = space
      .sampleCloseTo(
        position,
        deltaPosition,
        sampleSize: 100,
      )
      .cylindricalToCartesian;

  print(space);

  print('');
  print('Writing data ...');

  /// Write to file:
  await File('example/data/cone.dat').writeAsString(
    sample.export(label: '#Conical Search Space: x, y, z'),
  );
  await File('example/data/cone_perturbation.dat').writeAsString(
    perturbations.export(label: '#Conical Perturbations: x, y, z'),
  );

  await File('example/data/cone_test_point.dat').writeAsString('''
    ${[
    position.cylindricalToCartesian
  ].export(label: '#Perturbation Centrepoint: x, y, z')}''');

  print('Data written successfully. \nGood bye.');
}
