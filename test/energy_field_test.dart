import 'dart:math';

import 'package:minimal_test/minimal_test.dart';
import 'package:list_operators/list_operators.dart';

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
final space = SearchSpace([x, y, z], dPositionMin: [1e-4, 1e-4, 1e-4]);
final field = EnergyField(energyFunction, space, sampleSize: 600);

void main(List<String> args) {
  // Testing class: Interval.
  group('Energy sample', () async {
    final fieldMax = await field.max;
    final fieldStdDev = await field.stdDev;
    final fieldMean = await field.mean;

    test('iterations', () {
      expect(field.sampleSize, 600);
    });

    test('min', () {
      expect(field.minValue, 2.0, precision: 2);
    });
    test('max', () {
      expect(fieldMax, 4.0, precision: 0.1);
    });
    test('mean', () {
      expect(fieldMean, 2.0, precision: 2);
    });
    test('stdDev', () {
      expect(fieldStdDev < fieldMean - field.minValue, true);
    });
  });
}
