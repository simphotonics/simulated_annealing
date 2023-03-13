import 'energy_field_example.dart';
import '../../test/src/snapshot_logging_simulator.dart';

/// To run this program please navigate to the package root folder
/// and use the command:
/// $ dart example/bin/simulated_annealing_animation_example.dart
void main() async {
  // Construct a simulator instance.
  final simulator = SnapshotLoggingSimulator(
    field,
    outputPath: 'example/data/animation/log_',
    nth: 50,
    outerIterations: 150,
    gammaStart: 0.8,
    gammaEnd: 0.05,
  );

  simulator.gridStart = [];
  simulator.gridEnd = [];

  print(await simulator.info);
  print('Start annealing process ...');

  final xSol = await simulator.anneal(
    isRecursive: true,
    isVerbose: true,
  );
  print('Annealing ended.');
  print('Solution: $xSol');
}
