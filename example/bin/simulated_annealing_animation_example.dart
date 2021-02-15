
import 'package:simulated_annealing/simulated_annealing.dart';

import 'energy_field_example.dart';
import 'snapshot_logging_simulator.dart';

void main() async {
  // Construct a simulator instance.
  final simulator = SnapshotLoggingSimulator(
      field, exponentialSequence, perturbationSequence,
      '../data/animation/log_',
      nth:1,
      iterations: 750, gammaStart: 0.7, gammaEnd: 0.05);

  print(await simulator.info);

  final xSol = await simulator.anneal((_) => 1, isRecursive: true);

  print('Solution: $xSol');
}
