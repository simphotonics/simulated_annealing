import 'dart:io';

import 'package:simulated_annealing/simulated_annealing.dart';


/// Annealing simulator class that writes intermediate snapshots of the
/// log to a file.
///
/// Not included with the framework because the class uses dart:io.
class SnapshotLoggingSimulator extends LoggingSimulator {
  SnapshotLoggingSimulator(
    EnergyField field,
    TemperatureSequence temperatureSequence,
    PertubationSequence perturbationSequence,
    this.outputPath, {
    this.nth = 1,
    tEnd = 1e-3,
    gammaStart = 0.8,
    gammaEnd = 0.1,
    iterations = 750,
    List<num>? startPosition,
    num? dEnergyStart,
    num? dEnergyEnd,
  }) : super(
          field,
          temperatureSequence,
          perturbationSequence,
          tEnd: tEnd,
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
