import 'dart:math';

import 'package:minimal_test/minimal_test.dart';
import 'package:simulated_annealing/simulated_annealing.dart';

final xGlobalMin = [0.5, 0.7, 0.8];
final xLocalMin = [-1.0, -1.0, -0.5];
num energyFunction(List<num> x) {
  return 4.0 -
      4.0 * exp(-4 * xGlobalMin.distance(x)) -
      2.0 * exp(-6 * xLocalMin.distance(x));
}

// ignore: unused_element
int markov(num temperature) {
  return min(1 + 1 ~/ (100 * temperature), 25);
}

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
final space = SearchSpace([x, y, z]);

final energy = Energy(energyFunction, space);

void main(List<String> args) {
  // Testing class: Interval.
  group('Energy sample', () {
    test('size', () {
      expect(energy.sample.length, energy.sampleSize);
    });
    test('min', () {
      expect(energy.sampleMin, 2.0, precision: 2);
    });
    test('max', () {
      expect(energy.sampleMax, 4.0, precision: 0.1);
    });
    test('mean', () {
      expect(energy.mean, 2.0, precision: 2);
    });
    test('stdDev', () {
      expect(energy.stdDev, 0.2, precision: 0.1);
    });
  });
}
