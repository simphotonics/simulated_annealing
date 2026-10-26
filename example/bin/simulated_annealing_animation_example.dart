import '../../test/src/energy_field_instance.dart';
import '../../test/src/snapshot_logging_simulator.dart';

/// To run this program navigate to the package root folder
/// and use the command:
/// $ dart example/bin/simulated_annealing_animation_example.dart
///
/// Note: Create the output folder: example/data/animation/ if it does not
/// exist.
void main() {
  // Construct a simulator instance.
  final simulator = SnapshotLoggingSimulator(
    field,
    outputPath: 'example/data/animation/log_',
    nth: 50,
    outerIterations: 150,
    gammaStart: 0.8,
    gammaEnd: 0.05,
  );

  print(simulator);
  print('Start annealing process ...');

  final xSol = simulator.anneal(isRecursive: true, isVerbose: true);
  print('Annealing ended.');
  print('Solution: $xSol');
}
