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
    outerIterations: 150,
    innerIterationsStart: 5,
    innerIterationsEnd: 10,
  );

  simulator.gridStart = [];
  simulator.gridEnd = [];
  simulator.deltaPositionEnd = [1e-7, 1e-7, 1e-7];

  print(await simulator.info);

  print('Start annealing process ...');
  final xSol = await simulator.anneal(
    isRecursive: true,
  );
  print('Annealing ended.');
  print('Writing log to file: example/data/log.dat');
  await File('example/data/log.dat').writeAsString(simulator.export());
  print('Finished writing. ');

  print('Solution: $xSol');
  print('xSol - globalMin: ${xSol - globalMin}.');
}
