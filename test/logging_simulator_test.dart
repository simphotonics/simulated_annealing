import 'package:list_operators/list_operators.dart';
import 'package:simulated_annealing/simulated_annealing.dart';
import 'package:test/test.dart';

import 'src/energy_field_instance.dart';

final simulator = LoggingSimulator(
  field,
  outerIterations: 1200,
  gammaStart: 0.7,
  gammaEnd: 0.05,
);

final simulatorWithPresets = LoggingSimulator(
  field,
  outerIterations: 750,
  gammaStart: 0.7,
  gammaEnd: 0.05,
)..startPosition = [0, 0, 0];

void main() async {
  final tStart = await simulator.tStart;
  final tEnd = await simulator.tEnd;

  final result = await simulator.anneal();
  final temperatures = exponentialSequence(tStart, tEnd);
  final perturbationMagnitudes = defaultPerturbationSequence(
    temperatures,
    simulator.deltaPositionStart,
    simulator.deltaPositionEnd,
  );

  group('Parameters:', () {
    test('deltaPositionStart', () {
      expect(simulator.deltaPositionStart, closeToList(field.size, 0.25));
    });
    test('deltaPositionEnd', () {
      expect(simulator.deltaPositionEnd, [1e-6, 1e-6, 1e-6]);
    });
    test('startPosition', () {
      expect(simulatorWithPresets.startPosition, [0, 0, 0]);
    });
    test('tStart', () async {
      expect(await simulator.tStart, isNotNaN);
    });
    test('tEnd', () async {
      expect(await simulator.tEnd, isNotNaN);
    });
  });

  group('Simulator:', () {
    test('Convergence', () {
      expect(result, CloseToList(globalMin, deltaPositionMin.mean() * 10));
    });
  });
  group('Perturbation Magnitudes:', () {
    test('start', () {
      expect(
        perturbationMagnitudes.first,
        closeToList(simulator.deltaPositionStart, 1e-12),
      );
    });
    test('end', () {
      expect(
        perturbationMagnitudes.last,
        closeToList(simulator.deltaPositionEnd, 1e-12),
      );
    });
  });
  group('Simulator With Presets', () {
    test('startPosition', () {
      expect(simulatorWithPresets.currentPosition, [0, 0, 0]);
    });
    test('start energy', () {
      expect(simulatorWithPresets.currentEnergy, field.energy([0, 0, 0]));
    });
  });
}
