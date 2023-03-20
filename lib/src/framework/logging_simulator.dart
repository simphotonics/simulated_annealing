import 'package:exception_templates/exception_templates.dart';
import 'package:list_operators/list_operators.dart';

import 'data_log.dart';
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
  /// * outerIterations: Number of iterations when cooling.
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
    int outerIterations = 750,
    int innerIterationsStart = 5,
    int innerIterationsEnd = 20,
    int sampleSize = 500,
  }) : super(
          field,
          gammaStart: gammaStart,
          gammaEnd: gammaEnd,
          outerIterations: outerIterations,
          sampleSize: sampleSize,
          innerIterationsStart: innerIterationsStart,
          innerIterationsEnd: innerIterationsEnd,
        );

  /// Stored the simulator data log. Works with the extensions `DataLog` and
  /// `Export`.
  final _dataLog = DataLog<num>();

  /// Exports all records.
  String export({
    int precision = 10,
    String delimiter = '   ',
  }) =>
      _dataLog.export(
        precision: precision,
        delimiter: delimiter,
      );

  /// Exports the first record.
  String exportFirst({
    int precision = 10,
    String delimiter = '   ',
  }) =>
      _dataLog.exportLast(
        precision: precision,
        delimiter: delimiter,
      );

  /// Exports the last record.
  String exportLast({
    int precision = 10,
    String delimiter = '   ',
  }) =>
      _dataLog.exportLast(
        precision: precision,
        delimiter: delimiter,
      );

  /// Returns a list of valid keys with length `field.dimensions`.
  List<String> _validpositionKeys() {
    final positionKeys = field.space.intervalNames;
    if (positionKeys.length != field.dimensions) {
      throw ErrorOf<LoggingSimulator>(
          message: 'Invalid keys detected.',
          invalidState: 'Keys: $positionKeys have '
              'length ${positionKeys.length}.',
          expectedState: 'A list of unique strings with '
              'length ${field.dimensions}.');
    }
    if (positionKeys.toSet().length != positionKeys.length) {
      throw ErrorOf<LoggingSimulator>(
          message: 'Invalid keys detected.',
          invalidState: 'Keys: $positionKeys are not unique.',
          expectedState: 'A list of unique strings.');
    }
    return positionKeys;
  }

  /// Returns a list of valid keys that can be used to store
  /// `field.dimensions` coordinates.
  /// The keys are the names of the [Interval]s used to define
  /// the [SearchSpace], see [EnergyField].
  late final positionKeys = _validpositionKeys();

  /// Returns a valid list of keys that can be used to store
  /// `field.dimensions` coordinates.
  late final deltaPositionKeys =
      List<String>.generate(positionKeys.length, (i) {
    final first = positionKeys[i][0].toUpperCase();
    final rest = positionKeys[i].substring(1);
    return 'd$first$rest';
  }).unmodifiable;

  /// Returns the current position log.
  List<List<num>> get currentPositionLog => _dataLog.getAll(positionKeys);

  /// Returns the current perturbation magnitude log.
  List<List<num>> get deltaPositionLog => _dataLog.getAll(deltaPositionKeys);

  /// Returns the current energy log.
  List<num> get currentEnergyLog => _dataLog.get('Energy');

  /// Returns the current min. energy log.
  List<num> get currentMinEnergyLog => _dataLog.get('Energy Min');

  /// Returns the current acceptance probability log.
  List<num> get acceptanceProbabilityLog => _dataLog.get('P(dE > 0)');

  /// Returns the current temperature log.
  List<num> get temperatureLog => _dataLog.get('Temperature');

  /// The number of times `recordLog()` was called.
  int _logCount = 0;

  /// Returns the number times `recordLog()` was called.
  int get logCount => _logCount;

  @override
  void prepareLog() {}

  @override
  void recordLog() {
    _dataLog.addAll(positionKeys, currentPosition);
    _dataLog.addAll(deltaPositionKeys, deltaPosition);
    _dataLog.add('Energy', currentEnergy);
    _dataLog.add('Energy Min', currentMinEnergy);
    _dataLog.add('P(dE > 0)', acceptanceProbability);
    _dataLog.add('Temperature', t);
    ++_logCount;
  }
}
