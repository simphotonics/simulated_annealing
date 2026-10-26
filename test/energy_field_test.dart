import 'package:list_operators/list_operators.dart';
import 'package:test/test.dart';

import 'src/energy_field_instance.dart';

void main() {
  // Testing class: Interval.
  group('Sampling:', () {
    test('sampleField', () {
      final sample = field.sampleEnergy();
      expect(sample.length, 100);
    });
    test('sampleEnergyCloseTo', () {
      final sample = field.sampleEnergyCloseTo(
        globalMin,
        deltaPositionMin,
        selectUphillMoves: true,
      );
      expect(sample.length, 100);
      expect(field.energy(globalMin), lessThanOrEqualTo(sample.min()));
    });
  });
  group('tStart:', () {
    test('gamma = 1.0', () {
      final t = field.tStart(0.99, deltaPosition: field.size);
      expect(t, isNonNegative);
      expect(t, isNotNaN);
    });
    test('gamma = 0.8', () {
      final t = field.tStart(0.8, deltaPosition: field.size);
      expect(t, isNonNegative, reason: '$t');
      expect(t, isNotNaN);
    });
    test('gamma = 0.1', () {
      final t = field.tStart(0.1, deltaPosition: field.size);
      expect(t, isNonNegative, reason: '$t');
      expect(t, isNotNaN);
    });
    test('t(gamma = 0.1) < t(gamma = 0.99)', () {
      final t01 = field.tStart(0.1, deltaPosition: field.size, sampleSize: 600);
      final t099 = field.tStart(
        0.99,
        deltaPosition: field.size,
        sampleSize: 600,
      );
      expect(t01, lessThan(t099));
    });
  });
  group('tEnd:', () {
    final deltaPosition = [1e-6, 1e-6, 1e-6];
    test('gamma = 0.99', () {
      final t = field.tEnd(0.99, deltaPosition: deltaPosition);
      expect(t, isNonNegative);
      expect(t, isNotNaN);
    });
    test('gamma = 0.8', () {
      final t = field.tEnd(0.8, deltaPosition: deltaPosition);
      expect(t, isNonNegative);
      expect(t, isNotNaN);
    });
    test('gamma = 0.1', () {
      final t = field.tEnd(0.1, deltaPosition: deltaPosition);
      expect(t, isNonNegative);
      expect(t, isNotNaN);
    });
    test('t(gamma = 0.1) < t(gamma = 0.8)', () {
      final t01 = field.tEnd(0.1, deltaPosition: deltaPosition);
      final t08 = field.tEnd(0.8, deltaPosition: deltaPosition);
      expect(t01, lessThan(t08));
    });
  });
}
