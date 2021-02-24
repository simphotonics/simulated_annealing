import 'annealing_schedule.dart';
import 'data_recorder.dart';
import 'energy_field.dart';
import 'simulator.dart';

/// Annealing simulator capable of logging variables via an object of
/// type `DataRecorder`.
class LoggingSimulator extends Simulator {
  /// Constructs an object of type `LoggingSimulator`.
  /// * field: An object of type `EnergyField` encapsulating the
  ///   energy function (cost function)  and search space.
  /// * temperatureSequence: A function with typedef `TemperatureSequence`. It
  ///   specifies the annealing temperature schedule.
  /// * perturbationSequence: A function with typedef `PerturbationSequence`.
  ///   It specifies the perturbation magnitudes for each annealing temperature.
  /// ----
  /// Optional parameters:
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
  LoggingSimulator(
    EnergyField field,
    TemperatureSequence temperatureSequence,
    PertubationSequence perturbationSequence, {
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

  /// Records the simulator log.
  final _rec = NumericalDataRecorder();

  String export({
    int precision = 10,
    String delimiter = '   ',
  }) =>
      _rec.export(
        precision: precision,
        delimiter: delimiter,
      );

  String exportLast({
    int precision = 10,
    String delimiter = '   ',
  }) =>
      _rec.exportLast(
        precision: precision,
        delimiter: delimiter,
      );

  String exportFirst({
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
  List<List<num>> get dPositionLog => _rec.getVector('dPosition');

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
    _rec.addVector('dPosition', dPosition);
    _rec.addScalar('Energy', currentEnergy);
    _rec.addScalar('Energy Min', currentMinEnergy);
    _rec.addScalar('P(dE > 0)', acceptanceProbability);
    _rec.addScalar('Temperature', t);
    ++_logCount;
  }
}
