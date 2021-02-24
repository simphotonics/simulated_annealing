import 'dart:io';

import 'package:simulated_annealing/simulated_annealing.dart';

/// Annealing simulator class that writes intermediate snapshots of the
/// log to a file.
class SnapshotLoggingSimulator extends LoggingSimulator {
  /// Constructs an object of type `SnapshotLoggingSimulator`.
  /// * field: An object of type `EnergyField` encapsulating the
  ///   energy function (cost function)  and search space.
  /// * temperatureSequence: A function with typedef `TemperatureSequence`. It
  ///   specifies the annealing temperature schedule.
  /// * perturbationSequence: A function with typedef `PerturbationSequence`.
  ///   It specifies the perturbation magnitudes for each annealing temperature.
  /// * `outputPath`: Output path including file name base.
  /// ----
  /// Optional parameters:
  /// * `nth`: Write every n-th frame to file.
  /// * gammaStart: Probability of solution acceptance if `dE == dEnergyStart`
  ///   and the temperature is the initial temperature of the annealing process.
  /// * gammaEnd: Probability of solution acceptance if `dE == dEnergyEnd`
  ///   and the temperature is the final temperatures of the annealing process.
  /// * iterations: Number of iterations when cooling
  ///   the system from the initial annealing
  ///   temperature to the final temperature `tEnd`.
  /// * startPosition: Defaults to `field.minPosition`. Can be used to specify the
  ///   starting point of the simulated annealing process.
  /// * dEnergyStart: Defaults to `field.dEnergyStart`. Can be used for testing
  ///   purposes. It is an estimate of the typical variation of
  ///   the energy function when perturbing the current position randomly with
  ///   magnitude `dPositionMax`.
  /// * dEnergyEnd: Defaults to `field.dEnergyEnd`. Can be used for testing
  ///   purposes. It is an estimate of the typical variation of
  ///   the system energy function when perturbing the current position
  ///   randomly with magnitude `dPositionMin`.
  /// Not included with the framework because the class uses dart:io.
  ///
  SnapshotLoggingSimulator(
    EnergyField field,
    TemperatureSequence temperatureSequence,
    PertubationSequence perturbationSequence,
    this.outputPath, {
    this.nth = 1,
    num gammaStart = 0.8,
    num gammaEnd = 0.1,
    int iterations = 750,
    List<num>? startPosition,
    num? dEnergyStart,
    num? dEnergyEnd,
  }) : super(
          field,
          temperatureSequence,
          perturbationSequence,
          gammaStart: gammaStart,
          gammaEnd: gammaEnd,
          iterations: iterations,
          startPosition: startPosition,
          dEnergyStart: dEnergyStart,
          dEnergyEnd: dEnergyEnd,
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
