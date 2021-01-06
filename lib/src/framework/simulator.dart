import 'dart:math' as math;
import 'annealing_schedule.dart';
import 'energy.dart';
import 'search_space.dart';

typedef MarkovChainLength = int Function(num temperature);

/// Annealing simulator
abstract class Simulator {
  /// Simulator constructor.
  /// * system: Annealing system (energy function and search region).
  /// * schedule: Annealing schedule.
  /// * precision: Minimum neighbourhood step size.
  /// * gamma: Probability of solution acceptance if `dE == dE0`
  ///   and the system is at the highest (initial) temperature.
  /// * dE0: Defaults to `system.dE0`. Can be used for testing
  ///   purposes. It is an estimate of the typical variation of
  ///   the system energy function.
  ///
  /// * xMin0: Defaults to `system.xMin0`. Can be used to specify the
  ///   starting point of the simulated annealing process.
  Simulator(
    this.system,
    this.schedule, {
    this.gamma = 0.8,
    num? dE0,
    List<num>? xMin0,
  }) {
    this.dE0 = (dE0 == null) ? system.dE0 : dE0;
    _xMin = (xMin0 == null) ? system.xMin : xMin0;
    _xMinGlobal = _xMin;
    _eMin = system.energyFunction(_xMin);
    _eMinGlobal = _eMin;
    kB = -this.dE0 / (schedule.tStart * math.log(gamma));
    _e = _eMin;
    _t = schedule.tStart;
    _dx = schedule.dx(_t);
    _x = _xMin;
  }

  /// Probability of solution acceptance if `dE == dE0`.
  final num gamma;

  /// System Boltzmann constant, initialized such that:
  /// * `exp(-dE0/(kB * t0)) == gamma`
  late final num kB;

  /// Annealing system consisting of an energy function and a search region.
  final Energy system;

  /// A typical energy difference encountered when evaluating `system.energy`
  /// at random points.
  ///
  /// If no value is specified in the constructor it is initialized as
  /// `system.eStdDev`, the standard deviation of a sample
  /// obtained by evaluating `system.energy` at random
  /// points in the search space.
  late final dE0;

  /// Current energy minimizing solution.
  /// @nodoc
  late List<num> _xMin;

  /// Current energy minimizing solution. If the argument `xMin0` is not
  /// specified in the constructor it is initialized as `system.xMin`.
  List<num> get xMin => _xMin;

  /// Global energy minimizing solution.
  late List<num> _xMinGlobal;

  /// Global energy minimizing solution.
  List<num> get xMinGlobal => _xMinGlobal;

  /// Current energy minimum.
  num get eMin => _eMin;

  /// Current energy minimum.
  /// @nodoc
  late num _eMin;

  /// Global energy minimum.
  /// @nodoc
  late num _eMinGlobal;

  /// Global energy minimum.
  num get eMinGlobal => _eMinGlobal;

  /// Current temperature;
  /// @nodoc
  late num _t;

  /// Current temperature.
  num get t => _t;

  /// Current energy.
  /// @nodoc
  late num _e;

  /// Current energy.
  num get eCurrent => _e;

  /// Current perturbation magnitude.
  /// @nodoc
  late List<num> _dx;

  /// Current perturbation magnitude.
  List<num> get dx => _dx;

  /// Current position.
  /// @nodoc
  late List<num> _x;

  /// Current position
  List<num> get x => _x;

  /// Annealing schedule defined by a sequence of temperatures.
  final AnnealingSchedule schedule;

  /// Method called once from within `anneal` before any iterations.
  ///
  /// Can be used to setup a log.
  void prepareLog();

  /// Method called during each (inner) iteration.
  ///
  /// Can be used to add entries to the log.
  void recordLog();

  List<num> anneal(MarkovChainLength markov) {
    //innerIterations = innerIterations.abs();
    num dE = 0;

    prepareLog();
    recordLog();

    final temperatures = schedule.temperatures;

    for (var i = 0; i < temperatures.length; i++) {
      _t = temperatures[i];

      for (var j = 0; j < markov(_t); j++) {
        /// Calculate perturbation magnitudes
        _dx = schedule.dx(_t);
        _x = system.perturb(_xMin, _dx);

        /// Calculate energy
        _e = system.energyFunction(_x);
        dE = _e - _eMin;

        if (dE < 0) {
          _eMin = _e;
          _xMin = _x;
          if (_eMinGlobal > _eMin) {
            _eMinGlobal = _eMin;
            _xMinGlobal = _xMin;
          }
          //log.addScalar('Prob', 1);
        } else if (math.exp(-dE / (kB * _t)) > Interval.random.nextDouble()) {
          _eMin = _e;
          //log.addScalar('Prob', math.exp(-dE / (kB * t)));
          _xMin = _x;
        } else {
          //log.addScalar('Prob', 0);
        }
        recordLog();
      }
    }
    if (_eMinGlobal < _eMin) {
      print('Warning: E($_xMinGlobal) = $_eMinGlobal < E($_xMin) = $_eMin!');
    }
    return _xMin;
  }

  @override
  String toString() {
    final b = StringBuffer();
    b.writeln('Simulator: ');
    b.writeln('  gamma: $gamma');
    b.writeln('  P(dE0): ${math.exp(-dE0 / (kB * schedule.tStart))}');
    b.writeln('  kB: $kB');
    b.writeln('  t0: ${schedule.tStart}');
    b.writeln('  t${schedule.temperatures.length}: '
        '${schedule.temperatures.last}');
    b.writeln('  search region size: ${system.size}');
    b.writeln('  dx: ${schedule.dx(schedule.tStart)}');
    b.writeln('  precision: ${schedule.dx(schedule.tEnd)}');
    b.writeln('');
    b.writeln('  $system');
    return b.toString();
  }
}
