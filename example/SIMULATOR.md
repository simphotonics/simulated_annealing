##  Simulated Annealing - Example
[![Build Status](https://travis-ci.com/simphotonics/simulated_annealing.svg?branch=main)](https://travis-ci.com/simphotonics/simulated_annealing)

Simulated annealing (SA) is typically used to solve discrete optimisation problems. But the algorithm can be adapted to minimize continuous functions. The example below demonstrates how
to find the global minimum of the function:

E(**x**) = 4.0 - 4.0&middot;e<sup>-4&middot;|**x** - **x**<sub>glob</sub>|</sup> - 2.0&middot; e<sup>-6*&middot;|**x** - **x**<sub>loc</sub>|</sup>

defined for a spherical search space centred around the origin.
Hereby, |**x** - **y**| = &#8730; ( &sum;<sub> i = 1,..., 3</sub> (x<sub>i</sub> - y<sub>i</sub>)<sup>2</sup> ) is the distance between the vectors **x** and **y**.


![Energy Simulated Annealing](https://github.com/simphotonics/simulated_annealing/blob/main/example/plots/energy_composite.gif)

The figure above (right) shows a projection of E onto the x-y plane. The global minimum of E(**x**)
is situated at **x**<sub>glob</sub> = \[0.5, 0.7, 0.8\]. The function has a local minimum
at **x**<sub>loc</sub>&nbsp;= \[-1, -1, -0.5\].

After defining a ball shaped [search space] (left figure above) and the system `EnergyField` (see source code below),
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
final dPositionMin = <num>[1e-6, 1e-6, 1e-6];
final space = SearchSpace([x, y, z], dPositionMin: [1e-6, 1e-6, 1e-6]);

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
with 750 elements, with start value T<sub>start</sub> = 0.3673892633 andq end value T<sub>end</sub> = 0.0000017939.
At high temperatures the algorithm explores the entire search space for the x-coordinate (values ranging between -2 and 2),
and new solutions are accepted with high probability (red dots along the line y = 1).
As the temperature decreases fewer solutions are accepted and the x-coordinate converges towards 0.5.

![System Energy](https://raw.githubusercontent.com/simphotonics/simulated_annealing/main/example/plots/energy.png)
![Temperature 3D](https://raw.githubusercontent.com/simphotonics/simulated_annealing/main/example/plots/temperature.png)




The figure above (left) shows the
system energy evaluated at each point selected during the annealing
process. The energy is represented as a colour and varies between a maximum at 4.0 (red) and a minimum value of 0.0 (blue).

As the energy decreases the solution approaches **x**<sub>glob</sub> = \[0.5, 0.7, 0.8\] asymptotically (blue dots).
A typical solution is **x**<sub>min</sub> = \[0.5000000457219432, 0.6999999722831786, 0.800000105007227\].
The solution precision is determined by the minimum value of the perturbation magnitude **dPositionMin** (see [annealing schedule]).

The figure on the right show the temperature during the annealing process. At high temperatures the
algorithm selects potential solutions from the entire search space. As the temperature decreases
the search region around the current solution is contracted.


## Features and bugs
Please file feature requests and bugs at the [issue tracker].

[issue tracker]: https://github.com/simphotonics/simulated_annealing/issues

[SearchSpace]: https://pub.dev/documentation/simulated_annealing/latest/simulated_annealing/SearchSpace-class.html

[search space]: SEARCH_SPACE.md

[annealing schedule]: ANNEALING_SCHEDULE.md

[SimulatorClass]: https://pub.dev/documentation/simulated_annealing/latest/simulated_annealing/Simulator-class.html

[anneal]: https://pub.dev/documentation/simulated_annealing/latest/simulated_annealing/Simulator/anneal.html

[gnuplot]: http://gnuplot.sourceforge.net/
