import 'package:list_operators/list_operators.dart';
import 'package:test/test.dart';
import 'package:simulated_annealing/simulated_annealing.dart';

void main() {
  // Testing class: Interval.
  group('Initial temperature:', () {
    final tStart = 100.0;
    final tEnd = 1e-3;
    final delta = 1e-12;
    test('linear', () {
      expect(
        linearSequence(tStart, tEnd, iterations: 50).first,
        closeTo(tStart, delta),
      );
    });
    test('exponential', () {
      expect(
        exponentialSequence(tStart, tEnd, iterations: 50).first,
        closeTo(tStart, delta),
      );
    });
    test('normal', () {
      expect(
        normalSequence(tStart, tEnd, iterations: 50).first,
        closeTo(tStart, delta),
      );
    });
    test('geometric', () {
      expect(
        geometricSequence(tStart, tEnd, iterations: 50).first,
        closeTo(tStart, delta),
      );
    });
    test('lundy', () {
      expect(
        lundySequence(tStart, tEnd, iterations: 100).last,
        closeTo(tEnd, delta),
      );
    });
  });
  group('Final temperature:', () {
    final tStart = 100.0;
    final tEnd = 1e-3;
    final delta = 1e-12;
    test('linear', () {
      expect(
        linearSequence(tStart, tEnd, iterations: 50).last,
        closeTo(tEnd, delta),
      );
    });
    test('exponential', () {
      expect(
        exponentialSequence(tStart, 1e-3, iterations: 50).last,
        closeTo(tEnd, delta),
      );
    });
    test('normal', () {
      expect(
        normalSequence(tStart, 1e-3, iterations: 50).last,
        closeTo(tEnd, delta),
      );
    });
    test('geometric', () {
      expect(
        geometricSequence(tStart, tEnd, iterations: 50).last,
        closeTo(tEnd, delta),
      );
    });
    test('lundy', () {
      expect(
        lundySequence(tStart, tEnd, iterations: 100).last,
        closeTo(tEnd, delta),
      );
    });
  });

  group('Perturbation magnitudes:', () {
    final deltaPositionMax = [10.0, 10.0];
    final deltaPositionMin = [1e-4, 1e-4];
    final tStart = 1000.0;
    final tEnd = 1e-2;
    final temperaturesLinear = linearSequence(tStart, tEnd, iterations: 100);
    final delta = 1e-12;

    test('linearSchedule', () {
      final deltaPositionLinear = defaultPerturbationSequence(
          temperaturesLinear, deltaPositionMax, deltaPositionMin);
      expect(
        deltaPositionLinear[0],
        closeToList(deltaPositionMax, delta),
      );
      expect(
        deltaPositionLinear[99],
        closeToList(deltaPositionMin, delta),
      );
    });
    test('exponentialSchedule', () {
      final deltaPositionExponential = defaultPerturbationSequence(
          temperaturesLinear, deltaPositionMax, deltaPositionMin);
      expect(
        deltaPositionExponential[0],
        closeToList(deltaPositionMax, delta),
      );
      expect(
        deltaPositionExponential[99],
        closeToList(deltaPositionMin, delta),
      );
    });
  });
  group('Markov Chain Length:', () {
    final tStart = 1000.0;
    final tEnd = 1e-2;
    test('Initial value', () {
      expect(markovChainLength(tStart, tStart: tStart, tEnd: tEnd), 5);
    });
    test('Final value', () {
      expect(markovChainLength(tEnd, tStart: tStart, tEnd: tEnd), 20);
    });
    test('Interpolated value', () {
      expect(
          markovChainLength(
            (tStart - tEnd) / 2,
            tStart: tStart,
            tEnd: tEnd,
          ),
          12);
    });
  });
}
