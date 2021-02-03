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
  /// * tEnd: The system temperature at the end of the annealing process.
  /// * gammaStart: Probability of solution acceptance if `dE == dEnergyStart`
  ///   and the temperature is the initial temperature of the annealing process.
  /// * gammaEnd: Probability of solution acceptance if `dE == dEnergyEnd`
  ///   and the temperature is the final temperatures of the annealing process.
  /// * iterations: Number of iterations when cooling
  ///   the system from the initial annealing
  ///   temperature to the final temperature `tEnd`.
  /// * xStart: Defaults to `field.minPosition`. Can be used to specify the
  ///   starting point of the simulated annealing process.
  /// * dEnergyStart: Defaults to `field.dEnergyStart`. Can be used for testing
  ///   purposes. It is an estimate of the typical variation of
  ///   the energy function when perturbing the current position randomly with
  ///   magnitude `dxMax`.
  /// * dEnergyEnd: Defaults to `field.dEnergyEnd`. Can be used for testing
  ///   purposes. It is an estimate of the typical variation of
  ///   the system energy function when perturbing the current position
  ///   randomly with magnitude `dxMin`.
  LoggingSimulator(
    EnergyField field,
    TemperatureSequence temperatureSequence,
    PertubationSequence perturbationSequence, {
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

  final rec = NumericalDataRecorder();

  @override
  void prepareLog() {}

  @override
  void recordLog() {
    rec.addVector('x', currentPosition);
    rec.addVector('dx', dx);
    rec.addScalar('Energy', currentEnergy);
    rec.addScalar('Energy Min', currentMinEnergy);
    rec.addScalar('P(dE > 0)', acceptanceProbability);
    rec.addScalar('Temperature', t);
  }
}
