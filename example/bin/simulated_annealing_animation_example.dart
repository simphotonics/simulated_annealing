import 'energy_field_example.dart';
import 'snapshot_logging_simulator.dart';

/// To run this program please navigate to the package root folder
/// and use the command:
/// $ dart example/bin/simulated_annealing_animation_example.dart
void main() async {
  // Construct a simulator instance.
  final simulator = SnapshotLoggingSimulator(
    field,
    outputPath: 'example/data/animation/log_',
    nth: 50,
    iterations: 750,
    gammaStart: 0.7,
    gammaEnd: 0.05,
  );

  simulator.gridEnd = [10, 10, 10];

  print(await simulator.info);

  final xSol = await simulator.anneal(
    (num temperature) => 1,
    isRecursive: true,
    scaleMarkovChain: true,
    isVerbose: true,
  );

  print('Solution: $xSol');
}
