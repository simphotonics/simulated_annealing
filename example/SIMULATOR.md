##  Simulated Annealing - Example
[![Build Status](https://travis-ci.com/simphotonics/simulated_annealing.svg?branch=main)](https://travis-ci.com/simphotonics/simulated_annealing)

Simulated annealing (SA) is typically used to solve discrete optimisation problems. But the algorithm can be adapted to minimize continuous functions. The example below demonstrates how
to find the global minimum of the function:

E(**x**) = 4.0 - 4.0&middot;e<sup>-4&middot;|**x** - **x**<sub>glob</sub>|</sup> - 2.0&middot; e<sup>-6*&middot;|**x** - **x**<sub>loc</sub>|</sup>

defined for a spherical search space centred around the origin.
Hereby, |**x** - **y**| = &#8730; ( &sum;<sub> i</sub><sup>3</sup> (x<sub>i</sub> - y<sub>i</sub>)<sup>2</sup> ) is the distance between the vectors **x** and **y**.

![Energy Function X-Y Projection](https://raw.githubusercontent.com/simphotonics/simulated_annealing/main/example/plots/energy_xy_proj.png)
![Spherical Search Space](https://raw.githubusercontent.com/simphotonics/simulated_annealing/main/example/plots/spherical_space.png)


The figure above (left) shows a projection of E onto the x-y plane. The global minimum of E(**x**)
is situated at **x**<sub>glob</sub> = \[0.5, 0.7, 0.8\]. The function has a local minimum
at **x**<sub>loc</sub>&nbsp;= \[-1, -1, -0.5\].

After defining a ball shaped [search space] (right figure above) and the system `EnergyField` (see source code below),
we create an instance of `LoggingSimulator`. The annealing process is started by calling the method [`anneal`][anneal].

<details><summary> Click to show source code.</summary>

```Dart
import 'dart:io';
import 'dart:math';

import 'package:list_operators/list_operators.dart';

import 'package:simulated_annealing/simulated_annealing.dart';

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
final dxMin = <num>[1e-6, 1e-6, 1e-6];
final space = SearchSpace([x, y, z], dxMin: [1e-6, 1e-6, 1e-6]);

// Defining an energy function.
// The energy function has a minimum at xMin.
final xGlobalMin = [0.5, 0.7, 0.8];
final xLocalMin = [-1.0, -1.0, -0.5];
num energy(List<num> x) {
  return 4.0 -
      4.0 * exp(-4 * xGlobalMin.distance(x)) -
      2.0 * exp(-6 * xLocalMin.distance(x));
}

final energyField = EnergyField(
  energy,
  space,
);


/// To run this program navigate to the folder `example/bin` in your local
/// copy of the package `simulated_annealing` and use the command:
/// $ dart simulated_annealing_example.dart
void main() async {
  // Construct a simulator instance.
  final simulator = LoggingSimulator(energyField, exponentialSequence,
      perturbationSequence,
      iterations: 750, gammaStart: 0.7, gammaEnd: 0.05);

  print(await simulator.info);

  final xSol = await simulator.anneal((_) => 1, isRecursive: true);
  await File('../data/log.dat').writeAsString(simulator.rec.export());

  print('Solution: $xSol');
}

```
</details>


![Convergence Graph](https://raw.githubusercontent.com/simphotonics/simulated_annealing/main/example/plots/convergence.png)

The figure above shows the system energy, min. system energy, temperature, and acceptance probability during the SA process.

The graphs were generated using [gnuplot] and the scripts are available in the folder `example/gnuplot_scripts`.

The annealing schedule (blue curve) consists of a monotonically decreasing exponential sequence
with 750 elements, start value T<sub>0</sub> = 100 and end value T<sub>n</sub> = 1e-8. At high temperatures the algorithm explores the entire search space for the x-coordinate (values ranging between -2 and 2), and new solutions are accepted with high probability (red dots along the line y = 1). As the temperature decreases fewer solutions are accepted and the x-coordinate converges towards 0.5.

![System Energy](https://raw.githubusercontent.com/simphotonics/simulated_annealing/main/example/plots/energy.png)
![Temperature 3D](https://raw.githubusercontent.com/simphotonics/simulated_annealing/main/example/plots/temperature.png)


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

[SearchSpace]: https://pub.dev/documentation/simulated_annealing/latest/simulated_annealing/SearchSpace-class.html

[search space]: SEARCH_SPACE.md

[annealing schedule]: ANNEALING_SCHEDULE.md

[SimulatorClass]: https://pub.dev/documentation/simulated_annealing/latest/simulated_annealing/Simulator-class.html

[anneal]: https://pub.dev/documentation/simulated_annealing/latest/simulated_annealing/Simulator/anneal.html

[gnuplot]: http://gnuplot.sourceforge.net/
