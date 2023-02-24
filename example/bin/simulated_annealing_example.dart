import 'dart:io';

import 'package:list_operators/list_operators.dart';
import 'package:simulated_annealing/simulated_annealing.dart';

import 'energy_field_example.dart';

/// To run this program navigate to the root folder in your local
/// copy of the package `simulated_annealing` and use the command:
/// $ dart example/bin/simulated_annealing_example.dart
void main() async {
  // Construct a simulator instance.
  final simulator = LoggingSimulator(
    field, // Defined in file `energy_field_example.dart'
    gammaStart: 0.8,
    gammaEnd: 0.05,
    iterations: 50,
  );

  simulator.gridStart = [];
  simulator.gridEnd = [];
  simulator.deltaPositionEnd = [1e-12, 1e-12, 1e-12];

  print(simulator);
  print(await simulator.info);

  final xSol = await simulator.anneal(
    isRecursive: true,
  );
  await File('example/data/log.dat').writeAsString(simulator.export());

  print('Solution: $xSol');
  print(xSol - xGlobalMin);
  print((xSol - xGlobalMin).abs() < simulator.deltaPositionEnd);
}
