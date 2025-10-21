import 'dart:io';
import 'dart:math';

import 'package:list_operators/list_operators.dart';
import 'package:simulated_annealing/simulated_annealing.dart';

// Defining a spherical space.
final space = SearchSpace.sphere(rMin: 0, rMax: 2);

// Defining an energy function.
final globalMin = [0.5, 0.7, 0.8];
final localMin = [-1.0, -1.0, -0.5];
num energy(List<num> position) {
  position = position.sphericalToCartesian;
  return 4.0 -
      4.0 * exp(-4 * globalMin.distance(position)) -
      0.3 * exp(-4 * localMin.distance(position));
}

final field = EnergyField(energy, space);

void main(List<String> args) async {
  print(field);

  print('');
  print('Writing data ...');

  final sample = await field.sample(sampleSize: 2000);

  await File('example/data/energy.dat').writeAsString(
    sample.export(label: '#Energy Spherical Search Space: x, y, z, Energy'),
  );

  print('Data written successfully. \nGood bye.');
}
