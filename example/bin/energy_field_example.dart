import 'dart:math';

import 'package:list_operators/list_operators.dart';
import 'package:simulated_annealing/simulated_annealing.dart';

// Defining a spherical space.
final radius = 2;
final x = FixedInterval(-radius, radius);
final y = ParametricInterval(
  () => -sqrt(pow(radius, 2) - pow(x.next(), 2)),
  () => sqrt(pow(radius, 2) - pow(x.next(), 2)),
);
final z = ParametricInterval(
  () => -sqrt(pow(radius, 2) - pow(y.next(), 2) - pow(x.next(), 2)),
  () => sqrt(pow(radius, 2) - pow(y.next(), 2) - pow(x.next(), 2)),
);
final dxMin = <num>[1e-6, 1e-6, 1e-6];
final space = SearchSpace(
  [x, y, z],
  dxMin: [1e-6, 1e-6, 1e-6],
  //dxMax: [1, 1, 1],
);

// Defining an energy function.
// The energy function has a minimum at xMin.
final xGlobalMin = [0.5, 0.7, 0.8];
final xLocalMin = [-1.0, -1.0, -0.5];
num energy(List<num> x) {
  return 4.0 -
      4.0 * exp(-4 * xGlobalMin.distance(x)) -
      2.0 * exp(-6 * xLocalMin.distance(x));
}

final field = EnergyField(
  energy,
  space,
);

void main(List<String> args) {
  print(field);

  field.info.then((info) => print(info));
}
