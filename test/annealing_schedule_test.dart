import 'package:minimal_test/minimal_test.dart';
import 'package:simulated_annealing/simulated_annealing.dart';

void main(List<String> args) {
  // Testing class: Interval.
  group('Initial temperature', () {
    final tStart = 100.0;
    final tEnd = 1e-3;
    test('linear', () {
      expect(linearSequence(tStart, tEnd, iterations: 50).first, tStart);
    });
    test('exponential', () {
      expect(exponentialSequence(tStart, tEnd, iterations: 50).first, tStart);
    });
    test('normal', () {
      expect(normalSequence(tStart, tEnd, iterations: 50).first, tStart);
    });
    test('geometric', () {
      expect(geometricSequence(tStart, tEnd, iterations: 50).first, tStart);
    });
    test('lundy', () {
      expect(lundySequence(tStart, tEnd, iterations: 100).last, tEnd);
    });
  });
  group('Final temperature', () {
    final tStart = 100.0;
    final tEnd = 1e-3;
    test('linear', () {
      expect(linearSequence(tStart, tEnd, iterations: 50).last, tEnd);
    });
    test('exponential', () {
      expect(exponentialSequence(tStart, 1e-3, iterations: 50).last, tEnd);
    });
    test('normal', () {
      expect(normalSequence(tStart, 1e-3, iterations: 50).last, tEnd);
    });
    test('geometric', () {
      expect(geometricSequence(tStart, tEnd, iterations: 50).last, tEnd);
    });
    test('lundy', () {
      expect(lundySequence(tStart, tEnd, iterations: 100).last, tEnd);
    });
  });

  group('Perturbation magnitudes', () {
    final dPositionMax = [10.0, 10.0];
    final dPositionMin = [1e-4, 1e-4];
    final tStart = 1000.0;
    final tEnd = 1e-2;
    final temperaturesLinear = linearSequence(tStart, tEnd, iterations: 100);

    test('linearSchedule', () {
      final dPositionLinear =
          perturbationSequence(temperaturesLinear, dPositionMax, dPositionMin);
      expect(dPositionLinear[0], dPositionMax);
      expect(dPositionLinear[99], dPositionMin);
    });
    test('exponentialSchedule', () {
      final dPositionExponential =
          perturbationSequence(temperaturesLinear, dPositionMax, dPositionMin);
      expect(dPositionExponential[0], dPositionMax);
      expect(dPositionExponential[99], dPositionMin);
    });
  });
  group('Markov Chain length', () {
    final tStart = 1000.0;
    final tEnd = 1e-2;
    test('Initial value', () {
      expect(markovChainLength(tStart, tStart: tStart, tEnd: tEnd), 5);
    });
    test('Final value', () {
      expect(markovChainLength(tEnd, tStart: tStart, tEnd: tEnd), 20);
    });
    test('Interpolated value', () {
      expect(markovChainLength((tStart - tEnd) / 2, tStart: tStart, tEnd: tEnd),
          13);
    });
  });
}
