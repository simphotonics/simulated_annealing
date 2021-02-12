
import 'package:simulated_annealing/simulated_annealing.dart';

import 'energy_field_example.dart';
import 'snapshot_logging_simulator.dart';



void main() async {
  // Construct a simulator instance.
  final simulator = SnapshotLoggingSimulator(
      energyField, exponentialSequence, perturbationSequence,
      '../data/animation/log_',
      nth:1,
      iterations: 750, gammaStart: 0.7, gammaEnd: 0.05);

  print(await simulator.info);

  final xSol = await simulator.anneal((_) => 1, isRecursive: true);

  // final eMin = simulator.currentMinEnergyLog;

  // //print(eMin);

  // final eMin_reduced = LinkedHashSet<num>.from(eMin).toList();

  // final log = simulator.currentPositionLog;
  // log.add(eMin);
  // log.add(simulator.temperatureLog);

  // //print(log);

  // final log_reduced = <List<num>>[[], [], [], [], []];

  // for (var i = 0; i < 5; i++) {
  //   log_reduced[i].add(log[i][0]);
  // }

  // var prevEnergy = log[3][0];

  // var frames = 0;

  // await File('../data/animation/log_${frames++}.dat').writeAsString(log_reduced
  //     .export(label: 'x0    x1     x2    eMin      temperature', flip: true));

  // for (var j = 0; j < log[3].length; j++) {
  //   if (prevEnergy != log[3][j]) {
  //     // Add row
  //     for (var i = 0; i < 5; i++) {
  //       log_reduced[i].add(log[i][j]);
  //     }
  //     prevEnergy = log[3][j];
  //     await File('../data/animation/log_${frames++}.dat').writeAsString(
  //         log_reduced.export(
  //             label: 'x0    x1     x2    eMin    temperature', flip: true));
  //   } else {
  //     continue;
  //   }
  // }

  print('Solution: $xSol');
}
