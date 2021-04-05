import 'package:matcher/matcher.dart';
import 'package:test/test.dart';
import 'package:list_operators/list_operators.dart';

import 'src/energy_field_instance.dart';

void main() async {
  // Testing class: Interval.
  group('Sampling:', () {
    test('sampleField', () async {
      final sample = await field.sample();
      expect(sample.length, 100);
    });
    test('sampleNeighbourhood', () async {
      final sample = await field.sampleNeighbourhood(
          globalMin, deltaPositionMin,
          grid: [40, 40, 40], selectUphillMoves: true);
      expect(sample.length, 100);
      expect(field.energy(globalMin), lessThanOrEqualTo(sample.min()));
    });
  });
  group('tStart', () {
    final grid = [40, 40, 40];
    test('gamma = 1.0', () async {
      final t = await field.tStart(0.99, grid: grid, deltaPosition: field.size);
      expect(t, isNonNegative);
      expect(t, isNotNaN);
    });
    test('gamma = 0.8', () async {
      final t = await field.tStart(0.8, grid: grid, deltaPosition: field.size);
      expect(t, isNonNegative, reason: '$t');
      expect(t, isNotNaN);
    });
    test('gamma = 0.1', () async {
      final t = await field.tStart(0.1, grid: grid, deltaPosition: field.size);
      expect(t, isNonNegative, reason: '$t');
      expect(t, isNotNaN);
    });
    test('t(gamma = 0.1) < t(gamma = 0.99)', () async {
      final t01 = await field.tStart(
        0.1,
        grid: grid,
        deltaPosition: field.size,
        sampleSize: 600,
      );
      final t099 = await field.tStart(
        0.99,
        grid: grid,
        deltaPosition: field.size,
        sampleSize: 600,
      );
      expect(t01, lessThan(t099));
    });
  });
  group('tEnd', () {
    final grid = [40, 40, 40];
    final deltaPosition = [1e-6, 1e-6, 1e-6];
    test('gamma = 0.99', () async {
      final t =
          await field.tEnd(0.99, grid: grid, deltaPosition: deltaPosition);
      expect(t, isNonNegative);
      expect(t, isNotNaN);
    });
    test('gamma = 0.8', () async {
      final t = await field.tEnd(0.8, grid: grid, deltaPosition: deltaPosition);
      expect(t, isNonNegative);
      expect(t, isNotNaN);
    });
    test('gamma = 0.1', () async {
      final t = await field.tEnd(0.1, grid: grid, deltaPosition: deltaPosition);
      expect(t, isNonNegative);
      expect(t, isNotNaN);
    });
    test('t(gamma = 0.1) < t(gamma = 0.8)', () async {
      final t01 = await field.tEnd(
        0.1,
        grid: grid,
        deltaPosition: deltaPosition,
      );
      final t08 = await field.tEnd(
        0.8,
        grid: grid,
        deltaPosition: deltaPosition,
      );
      expect(t01, lessThan(t08));
    });
  });
}
