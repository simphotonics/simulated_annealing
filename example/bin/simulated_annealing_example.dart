import 'dart:io';

import 'package:simulated_annealing/simulated_annealing.dart';

import 'energy_field_example.dart';

/// To run this program navigate to the root folder in your local
/// copy of the package `simulated_annealing` and use the command:
/// $ dart example/bin/simulated_annealing_example.dart
void main() async {
  // Construct a simulator instance.
  final simulator = LoggingSimulator(
    field,
    gammaStart: 0.5,
    gammaEnd: 0.1,
  );

  print(simulator);
  print(await simulator.info);

  final xSol = await simulator.anneal((_) => 1, isRecursive: true, ratio: 0.5);
  await File('example/data/log.dat').writeAsString(simulator.export());

  print('Solution: $xSol');
}
