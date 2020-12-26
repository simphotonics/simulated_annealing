##  Simulated Annealing - Example

Simulated annealing (SA) is typically used to solve discrete optimisation problems. But the algorithm can be adapted to minimize continuous functions. The example below demonstrates how
to find the global minimum of the function:

E(**x**) = 4.0 - 4.0&middot;e<sup>-4&middot;|**x** - **x**<sub>glob</sub>|</sup> - 2.0&middot; e<sup>-6*&middot;|**x** - **x**<sub>loc</sub>|</sup>

defined for a spherical search space centred around the origin.
Hereby, |**x** - **y**| = &#8730; ( &sum;<sub> i</sub><sup>3</sup> (x<sub>i</sub> - y<sub>i</sub>)<sup>2</sup> ) is the distance between the vectors **x** and **y**.

![Energy Function](https://raw.githubusercontent.com/simphotonics/simulated_annealing/main/example/plots/energy2d.svg?sanitize=true)


The figure above shows a projection of E onto the x-y plane. The global minimum of E(**x**)
is situated at **x**<sub>glob</sub> = \[0.5, 0.7, 0.8\]. The function has a local minimum
at **x**<sub>loc</sub>&nbsp;= \[-1, -1, -0.5\].

After defining a [search space], an [annealing schedule], and an annealing system (see source code below), we create
an instance of [`Simulator`][SimulatorClass]. The annealing process is started by calling the method `anneal`.

<details><summary> Click to show source code.</summary>

```Dart
import 'dart:io';
import 'dart:math';

import 'package:simulated_annealing/simulated_annealing.dart';

class LoggingSimulator extends Simulator {
  LoggingSimulator(
    AnnealingSystem system,
    AnnealingSchedule schedule, {
    num gamma = 0.8,
    num? dE0,
    List<num>? xMin0,
  }) : super(
          system,
          schedule,
          gamma: gamma,
          dE0: dE0,
          xMin0: xMin0,
        );

  final rec = DataRecorder();

  @override
  void prepareLog() {
    rec.prepareVector('x', 3);
    rec.prepareScalar('Energy');
    rec.prepareScalar('Energy Min');
    rec.prepareScalar('P(dE)');
    rec.prepareScalar('Temperature');
    rec.prepareVector('dx', 3);
  }

  @override
  void recordLog() {
    rec.addVector('x', x);
    rec.addVector('dx', dx);
    rec.addScalar('Energy', eCurrent);
    rec.addScalar('Energy Min', eMin);
    rec.addScalar('P(dE)',
        (eCurrent - eMin) < 0 ? 1 : exp(-(eCurrent - eMin) / (kB * t)));
    rec.addScalar('Temperature', t);
  }
}

void main() async {
  // Defining a spherical space.
  final radius = 2;
  final x = FixedInterval(-radius, radius);
  final y = ParametricInterval(
    () => -sqrt(pow(radius, 2) - pow(x.next(), 2)),
    () => sqrt(pow(radius, 2) - pow(x.next(), 2)),
  );
  final z = ParametricInterval(
    () => -sqrt(pow(radius, 2) - pow(y.next(), 2) - pow(x.next(), 2)),
    () => sqrt(pow(radius, 2) - pow(y.next(), 2) - pow(x.next(), 2)),
  );
  final space = SearchSpace([x, y, z]);

  // Defining an annealing schedule.
  final schedule = AnnealingSchedule(
    exponentialSequence(100, 1e-8, n: 750),
    space.size,
    [1e-6, 1e-6, 1e-6],
  );

  // Defining an energy function.
  // The energy function has a local minimum at xLocalMin
  // and a global minimum at xGlobalMin.
  final xGlobalMin = [0.5, 0.7, 0.8];
  final xLocalMin = [-1.0, -1.0, -0.5];
  num energy(List<num> x) {
    return 4.0 -
        4.0 * exp(-4 * xGlobalMin.distance(x)) -
        2.0 * exp(-6 * xLocalMin.distance(x));
  }

  // ignore: unused_element
  int markov(num temperature) {
    return min(1 + 1 ~/ (100 * temperature), 25);
  }

  final system = AnnealingSystem(energy, space);

  // Construct a simulator instance.
  final simulator = LoggingSimulator(
    system,
    schedule,
    gamma: 0.8,
    dE0: system.eStdDev + 0.1,
    xMin0: [-1, -1, -0.5],
  );

  print(simulator);

  final sample = simulator.system.x;
  for (var i = 0; i < simulator.system.sampleSize; i++) {
    sample[i].add(simulator.system.e[i]);
  }

  final xSol = simulator.anneal((t) => 1);
  await File('../data/log.dat').writeAsString(simulator.rec.export());
  await File('../data/energy_sample.dat')
      .writeAsString(sample.export(label: 'x y z energy'));

  print('Solution: $xSol');
}

```
</details>


![Convergence Graph](https://raw.githubusercontent.com/simphotonics/simulated_annealing/main/example/plots/convergence.svg?sanitize=true)

The figure above shows the system energy, temperature, and acceptance probability during the
annealing process.
The annealing schedule (blue curve) consists of a monotonically decreasing exponential sequence
with 750 elements, start value T<sub>0</sub> = 100 and end value T<sub>n</sub> = 1e-8. At high temperatures the algorithm explores the entire search space for the x-coordinate, (-2, 2), and new solutions are accepted with high probability (red dots along the line y = 1). As the temperature decreases fewer solutions are accepted and the x-coordinate converges towards 0.5.

![System Energy](https://raw.githubusercontent.com/simphotonics/simulated_annealing/main/example/plots/energy.svg?sanitize=true)

In order to demonstrate the ability of the algorithm to escape from a local minimum, we have
initialized **x**<sub>min</sub> as **x**<sub>loc</sub>. The figure above shows the
system energy evaluated at each point selected during the annealing
process. The energy is represented as a colour and varies between a maximum at 4.0 (red) and a minimum value of 0.0 (blue). The initial point can be identified as a green point situated at
**x**<sub>loc</sub> = \[-1.0, -1.0, -0.5\].

As the energy decreases the solution approaches **x**<sub>glob</sub> = \[0.5, 0.7, 0.8\] asymptotically (blue dots). A typical solution is **x**<sub>min</sub> = \[0.5000000457219432, 0.6999999722831786, 0.800000105007227\]. The solution precision is determined by the minimum value of the perturbation magnitude
**dxMin** (see [annealing schedule]).



## Features and bugs
Please file feature requests and bugs at the [issue tracker].

[issue tracker]: https://github.com/simphotonics/simulated_annealing/issues

[SearchSpace]: https://pub.dev/documentation/simulated_annealing/latest/simulated_annealing/SearchSpaceClass.html

[search space]: https://github.com/simphotonics/simulated_annealing/blob/main/example/SEARCH_SPACE.md

[annealing schedule]: https://github.com/simphotonics/simulated_annealing/blob/main/example/ANNEALING_SCHEDULE.md

[SimulatorClass]: https://pub.dev/documentation/simulated_annealing/latest/simulated_annealing/SimulatorClass.html
