import 'dart:io';

import 'package:simulated_annealing/simulated_annealing.dart';

import 'energy_field_example.dart';
/// To run this program navigate to the folder `example/bin` in your local
/// copy of the package `simulated_annealing` and use the command:
/// $ dart simulated_annealing_example.dart
void main() async {
  // Construct a simulator instance.
  final simulator = LoggingSimulator(field, exponentialSequence,
      perturbationSequence,
      iterations: 750, gammaStart: 0.7, gammaEnd: 0.05);

  print(await simulator.info);

  final xSol = await simulator.anneal((_) => 1, isRecursive: true);
  await File('../data/log.dat').writeAsString(simulator.export());

  print('Solution: $xSol');
}
