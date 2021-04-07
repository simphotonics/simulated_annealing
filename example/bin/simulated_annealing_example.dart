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
    field,
    gammaStart: 0.7,
    gammaEnd: 0.05,
    iterations: 30,
  );

  simulator.gridEnd = [20, 20, 20];
  simulator.deltaPositionEnd = [1e-12, 1e-12, 1e-12];

  print(simulator);
  print(await simulator.info);

  final tStart = await simulator.tStart;
  final tEnd = await simulator.tEnd;

  final xSol = await simulator.anneal(
    (num temperature, List<int> grid) => markovChainLength(
      temperature,
      grid,
      tStart: tStart,
      tEnd: tEnd,
      chainLengthStart: 2,
      chainLengthEnd: 10,
    ),
    isRecursive: true,
    ratio: 0.5,
  );
  await File('example/data/log.dat').writeAsString(simulator.export());

  print('Solution: $xSol');
  print(xSol - xGlobalMin);
  print((xSol - xGlobalMin).abs() < simulator.deltaPositionEnd);
}
