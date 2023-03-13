// Defining a spherical space.
import 'dart:math';

import 'package:list_operators/list_operators.dart';
import 'package:simulated_annealing/simulated_annealing.dart';

final radius = 2;
final x = FixedInterval(-radius, radius);

num yLimit() => sqrt(pow(radius, 2) - pow(x.next(), 2));
final y = ParametricInterval(() => -yLimit(), yLimit);

num zLimit() => sqrt(pow(radius, 2) - pow(y.next(), 2) - pow(x.next(), 2));
final z = ParametricInterval(() => -zLimit(), zLimit);

final deltaPositionMin = <num>[1e-6, 1e-6, 1e-6];
final space = SearchSpace.parametric([x, y, z]);

// Defining an energy function.
// The energy function has a minimum at xMin.
final globalMin = [0.5, 0.7, 0.8];
final localMin = [-1.0, -1.0, -0.5];
num energy(List<num> position) {
  return 4.0 -
      4.0 * exp(-4 * globalMin.distance(position)) -
      0.3 * exp(-6 * localMin.distance(position));
}

final field = EnergyField(
  energy,
  space,
);
