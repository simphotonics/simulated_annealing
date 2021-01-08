import 'dart:math';

import 'package:minimal_test/minimal_test.dart';
import 'package:simulated_annealing/simulated_annealing.dart';

class LoggingSimulator extends Simulator {
  LoggingSimulator(
    Energy system,
    AnnealingSchedule schedule, {
    num gamma = 0.8,
    num? dE0,
    List<num>? xMin0,
  }) : super(
          system,
          schedule,
          gamma: gamma,
          dE0: dE0,
          xMin0: xMin0,
        );

  final rec = DataRecorder();

  @override
  void prepareLog() {
    rec.prepareVector('x', 3);
    rec.prepareScalar('Energy');
    rec.prepareScalar('Energy Min');
    rec.prepareScalar('P(dE)');
    rec.prepareScalar('Temperature');
    rec.prepareVector('dx', 3);
  }

  @override
  void recordLog() {
    rec.addVector('x', x);
    rec.addVector('dx', dx);
    rec.addScalar('Energy', eCurrent);
    rec.addScalar('Energy Min', eMin);
    rec.addScalar('P(dE)',
        (eCurrent - eMin) < 0 ? 1 : exp(-(eCurrent - eMin) / (kB * t)));
    rec.addScalar('Temperature', t);
  }
}

// Defining a spherical space.
final radius = 2;
final x0 = FixedInterval(-radius, radius);
final x1 = ParametricInterval(
  () => -sqrt(pow(radius, 2) - pow(x0.next(), 2)),
  () => sqrt(pow(radius, 2) - pow(x0.next(), 2)),
);
final x3 = ParametricInterval(
  () => -sqrt(pow(radius, 2) - pow(x1.next(), 2) - pow(x0.next(), 2)),
  () => sqrt(pow(radius, 2) - pow(x1.next(), 2) - pow(x0.next(), 2)),
);
final space = SearchSpace([x0, x1, x3]);

// Defining an annealing schedule.
final schedule = AnnealingSchedule(
  exponentialSequence(100, 1e-8, n: 750),
  space.size,
  [1e-6, 1e-6, 1e-6],
);

// Defining an energy function.
// The energy function has a local minimum at xLocalMin
// and a global minimum at xGlobalMin.
final xGlobalMin = <num>[0.5, 0.7, 0.8];
final xLocalMin = <num>[-1.0, -1.0, -0.5];
num energyFunction(List<num> x) {
  return 4.0 -
      4.0 * exp(-4 * xGlobalMin.distance(x)) -
      2.0 * exp(-6 * xLocalMin.distance(x));
}

// ignore: unused_element
int markov(num temperature) {
  return min(1 + 1 ~/ (100 * temperature), 25);
}

final energy = Energy(energyFunction, space);

// Construct a simulator instance.
final simulator = LoggingSimulator(
  energy,
  schedule,
  gamma: 0.8,
  dE0: energy.stdDev + 0.1,
);

void main() {
  group('Simulator:', () {
    test('Gamma', () {
      expect(exp(-simulator.dE0 / (simulator.kB * simulator.schedule.tStart)),
          simulator.gamma);
    });
    test('Convergence', () {
      final result = simulator.anneal((num temperature) => 5);
      expect(result, xGlobalMin, precision: 1e-4);
    });
  });
}
