import 'dart:math';

import 'package:minimal_test/minimal_test.dart';
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
final space = SearchSpace([x, y, z], dxMin: [1e-6, 1e-6, 1e-6]);

// Defining an energy function.
// The energy function has a minimum at xMin.
final xGlobalMin = [0.5, 0.7, 0.8];
final xLocalMin = [-1.0, -1.0, -0.5];
num energy(List<num> x) {
  return 4.0 -
      4.0 * exp(-4 * xGlobalMin.distance(x)) -
      0.3 * exp(-6 * xLocalMin.distance(x));
}

final energyField = EnergyField(
  energy,
  space,
);

final simulator = LoggingSimulator(
  energyField,
  exponentialSequence,
  perturbationSequence,
  iterations: 750,
  gammaStart: 0.7,
  gammaEnd: 0.05,
);

final simulatorWithPresets = LoggingSimulator(
  energyField,
  exponentialSequence,
  perturbationSequence,
  iterations: 750,
  gammaStart: 0.7,
  gammaEnd: 0.05,
  dEnergyStart: 0.5,
  dEnergyEnd: 1e-6,
  startPosition: [0, 0, 0],
);

void main() async {
  final kB = await simulator.kB;
  final tStart = await simulator.tStart;
  final dE = await simulator.dEnergyStart;
  final result = await simulator.anneal((num temperature) => 1);
  final dEnergyStart = await simulatorWithPresets.dEnergyStart;
  final dEnergyEnd = await simulatorWithPresets.dEnergyEnd;
  final temperatures = await simulator.temperatures;
  final perturbationMagnitudes = await simulator.perturbationMagnitudes;

  group('Simulator:', () {
    test('GammaStart', () {
      expect(exp(-dE / (kB * tStart)), simulator.gammaStart);
    });
    test('Convergence', () {
      expect(result, xGlobalMin, precision: 1e-6);
    });
    test('tEnd', () {
      expect(simulator.tEnd, 1e-3);
    });
    test('dEnergyStart', () {
      expect(dEnergyStart, 0.5);
    });
    test('dEnergyEnd', () {
      expect(dEnergyEnd, 1e-6);
    });
    test('temperatures', () {
      expect(temperatures.last, simulator.tEnd);
    });
    test('startPosition', () {
      expect(simulatorWithPresets.currentPosition, [0, 0, 0]);
      expect(
        simulatorWithPresets.currentEnergy,
        energyField.energy([0, 0, 0]),
      );
      expect(simulatorWithPresets.currentMinPosition, [0, 0, 0]);
      expect(
        simulatorWithPresets.currentMinEnergy,
        energyField.energy([0, 0, 0]),
      );
    });
    test('perturbationMagnitudes', () {
      expect(perturbationMagnitudes.first, space.dxMax);
      expect(perturbationMagnitudes.last, space.dxMin);
    });
  });
}
