import 'dart:io';

import 'package:simulated_annealing/simulated_annealing.dart';

/// Annealing simulator class that writes intermediate snapshots of the
/// log to a sequence of files.
class SnapshotLoggingSimulator extends LoggingSimulator {
  /// Constructs an object of type `SnapshotLoggingSimulator`.
  /// * field: An object of type `EnergyField` encapsulating the
  ///   energy function (cost function)  and search space.
  /// * `outputPath`: Output path including file name base.
  /// ----
  /// Optional parameters:
  /// * `nth`: Write every n-th frame to file.
  /// * gammaStart: Probability of solution acceptance if `dE == dEnergyStart`
  ///   and the temperature is the initial temperature of the annealing process.
  /// * gammaEnd: Probability of solution acceptance if `dE == dEnergyEnd`
  ///   and the temperature is the final temperatures of the annealing process.
  /// * outerIterations: Number of iterations when cooling.
  /// * innerIterationsStart: Number of iterations at constant temperature
  ///   at the start of the annealing process.
  /// * innerIterationsEnd: Number of iterations at constant temperature
  ///   at the end of the annealing process.
  /// * sampleSize: Size of sample used to estimate the start temperature
  ///   and the final temperature of the annealing process.
  /// Not included with the framework because the class uses dart:io.
  SnapshotLoggingSimulator(
    super.field, {
    required this.outputPath,
    this.nth = 1,
    super.gammaStart,
    super.gammaEnd,
    super.outerIterations,
    super.innerIterationsStart,
    super.innerIterationsEnd,
    super.sampleSize,
  });

  int _frameCounter = -1;

  /// Writing every nth frame to file.
  final int nth;

  /// Output path including file name base.
  /// * The path must be accessible.
  /// * An integer frame number will be appended to the file name.
  final String outputPath;

  /// Records the current simulator log.
  /// Writes the log to file.
  @override
  void recordLog() {
    super.recordLog();
    if (logCount % nth == 0) {
      ++_frameCounter;
      File('$outputPath$_frameCounter').writeAsString(export());
    }
  }
}
