import 'data_recorder.dart';
import 'energy_field.dart';
import 'simulator.dart';

/// Annealing simulator capable of logging variables via an object of
/// type `DataRecorder`.
class LoggingSimulator extends Simulator {
  /// Constructs an object of type `LoggingSimulator`.
  /// * field: An object of type `EnergyField` encapsulating the
  ///   energy function (cost function)  and search space.
  /// ---
  /// &nbsp;&nbsp;&nbsp;&nbsp;  *Optional parameters*:
  /// * gammaStart: Probability of solution acceptance if `dE == dEnergyStart`
  ///   and the temperature is the initial temperature of the annealing process.
  /// * gammaEnd: Probability of solution acceptance if `dE == dEnergyEnd`
  ///   and the temperature is the final temperatures of the annealing process.
  /// * iterations: Number of iterations when cooling.
  ///  * innerIterationsStart: Number of iterations at constant temperature
  ///   at the start of the annealing process.
  /// * innerIterationsEnd: Number of iterations at constant temperature
  ///   at the end of the annealing process.
  /// * sampleSize: Size of sample used to estimate the start temperature
  ///   and the final temperature of the annealing process.
  LoggingSimulator(
    EnergyField field, {
    num gammaStart = 0.8,
    num gammaEnd = 0.1,
    int iterations = 750,
    int innerIterationsStart = 5,
    int innerIterationsEnd = 20,
    int sampleSize = 500,
  }) : super(
          field,
          gammaStart: gammaStart,
          gammaEnd: gammaEnd,
          iterations: iterations,
          sampleSize: sampleSize,
          innerIterationsStart: innerIterationsStart,
          innerIterationsEnd: innerIterationsEnd,
        );

  /// Records the simulator log.
  final _rec = NumericalDataRecorder();

  /// Exports all records.
  String export({
    int precision = 10,
    String delimiter = '   ',
  }) =>
      _rec.export(
        precision: precision,
        delimiter: delimiter,
      );

  /// Exports the first record.
  String exportFirst({
    int precision = 10,
    String delimiter = '   ',
  }) =>
      _rec.exportLast(
        precision: precision,
        delimiter: delimiter,
      );

  /// Exports the last record.
  String exportLast({
    int precision = 10,
    String delimiter = '   ',
  }) =>
      _rec.exportLast(
        precision: precision,
        delimiter: delimiter,
      );

  /// Returns the current position log.
  List<List<num>> get currentPositionLog => _rec.getVector('x');

  /// Returns the current perturbation magnitude log.
  List<List<num>> get deltaPositionLog => _rec.getVector('deltaPosition');

  /// Returns the current energy log.
  List<num> get currentEnergyLog => _rec.getScalar('Energy');

  /// Returns the current min. energy log.
  List<num> get currentMinEnergyLog => _rec.getScalar('Energy Min');

  /// Returns the current acceptance probability log.
  List<num> get acceptanceProbabilityLog => _rec.getScalar('P(dE > 0)');

  /// Returns the current temperature log.
  List<num> get temperatureLog => _rec.getScalar('Temperature');

  /// The number of times `recordLog()` was called.
  int _logCount = 0;

  /// Returns the number times `recordLog()` was called.
  int get logCount => _logCount;

  @override
  void prepareLog() {}

  @override
  void recordLog() {
    _rec.addVector('x', currentPosition);
    _rec.addVector('deltaPosition', deltaPosition);
    _rec.addScalar('Energy', currentEnergy);
    _rec.addScalar('Energy Min', currentMinEnergy);
    _rec.addScalar('P(dE > 0)', acceptanceProbability);
    _rec.addScalar('Temperature', t);
    ++_logCount;
  }
}
