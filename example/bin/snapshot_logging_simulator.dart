import 'dart:io';

import 'package:simulated_annealing/simulated_annealing.dart';

/// Annealing simulator class that writes intermediate snapshots of the
/// log to a file.
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
  /// * iterations: Number of iterations when cooling
  /// Not included with the framework because the class uses dart:io.
  SnapshotLoggingSimulator(
    EnergyField field, {
    required this.outputPath,
    this.nth = 1,
    num gammaStart = 0.8,
    num gammaEnd = 0.1,
    int iterations = 750,
  }) : super(
          field,
          gammaStart: gammaStart,
          gammaEnd: gammaEnd,
          iterations: iterations,
        );

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
