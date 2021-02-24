# Simulated Annealing For Dart
[![Build Status](https://travis-ci.com/simphotonics/simulated_annealing.svg?branch=main)](https://travis-ci.com/simphotonics/simulated_annealing)

## Introduction
[Simulated annealing][SA-Wiki] (SA) is an algorithm aimed at finding the *global* minimum
of a function E(x<sub>0</sub>,&nbsp;x<sub>1</sub>,&nbsp;...,&nbsp;x<sub>n</sub>)
for a given region &omega;(x<sub>0</sub>,&nbsp;x<sub>1</sub>,&nbsp;...,&nbsp;x<sub>n</sub>).
The function to be minimized can be interpreted as the
**system energy**. In that case, the global minimum represents
the **ground state** of the system.


The algorithm name was coined by Kirkpatrick et al. [\[1\]][kirkpatrick1983] and was
derived from the process of annealing a metal alloy or glass.
The first step of the annealing process consists of heating a
solid material above a critical temperature. This allows its atoms to gain
sufficient kinetic energy to be able to rearrange themselves.
Then the temperature is decreased sufficiently slowly
in order to minimize atomic lattice defects as the material solidifies.

*Simulated* annealing works by randomly selecting a new point in the neighbourhood of the
current solution,
evaluating the energy function, and deciding if the new solution is accepted or rejected.

If for a newly selected point the energy E is lower that the previous minimum energy
E<sub>min</sub>, the new solution is accepted: P(&Delta;E&nbsp;<&nbsp;0,&nbsp;T)&nbsp;=&nbsp;1,
where &Delta;E = E - E<sub>min</sub>.

 Crucially, if &Delta;E > 0, the algorithm still accepts the
 new solution with probability: P(&Delta;E > 0, T) = e<sup>-&Delta;E/(k<sub>B</sub>&middot;T)</sup>.
 Accepting up-hill moves provides a method of escaping from local energy minima.

![Energy Simulated Annealing](https://github.com/simphotonics/simulated_annealing/raw/main/example/plots/energy_composite.gif)

The process is demonstrated in the animation above. The left figure shows a
spherical 3D search space while the energy value is represented by colour.
The figure on the right shows a projection of the energy function onto the
x-y plane. Initially, random points are chosen
from a large region encompasing the entire spherical search space.
 In the simulation shown above, intermediate solutions
near the local minimum are followed by up-hill moves.
As the temperature drops the search neighourhood is contracted and the solution converges to the
global minimum.

## Usage
To use this package include [`simulated_annealing`][simulated_annealing]
as a `dependency` in your `pubspec.yaml` file.

The following steps are required to set up the SA algorithm.
1. Specify the [search space][search space] &omega;.
2. Define an [annealing schedule][annealing schedule].
3. Define the system [energy field][energy_field].
4. Extend the class [`Simulator`][SimulatorClass] implementing the methods `prepareLog()`
and  `recordLog()` or create an instance of [`LoggingSimulator`][LoggingSimulator].
5. Start the [simulated annealing][simulator] process.

<details><summary> Click to show source code.</summary>

```Dart

import 'dart:io';
import 'dart:math';

import 'package:list_operators/list_operators.dart';
import 'package:simulated_annealing/simulated_annealing.dart';

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
final dPositionMin = <num>[1e-6, 1e-6, 1e-6];
// Parameteric intervals must be listed in order of dependence.
// Example: y depends on x, z depends on x and y => list order: [x, y, z].
final space = SearchSpace([x, y, z], dPositionMin: [1e-6, 1e-6, 1e-6]);

// Defining an energy function.
final xGlobalMin = [0.5, 0.7, 0.8];
final xLocalMin = [-1.0, -1.0, -0.5];
num energy(List<num> x) {
  return 4.0 -
      4.0 * exp(-4 * xGlobalMin.distance(x)) -
      2.0 * exp(-6 * xLocalMin.distance(x));
}

// Constructing an instance of `EnergyField`.
final energyField = EnergyField(
  energy,
  space,
);
  // Constructing an instance of `LoggingSimulator`.
  final simulator = LoggingSimulator(energyField, exponentialSequence,
      iterations: 750, gammaStart: 0.7, gammaEnd: 0.05);

  print(await simulator.info);

  final xSol = await simulator.anneal((_) => 1, isRecursive: true);
  await File('../data/log.dat').writeAsString(simulator.rec.export());

  print('Solution: $xSol');
}

```
</details>

## Annealing Schedule

The [Boltzmann constant][Boltzmann] k<sub>B</sub> relates the system
temperature with the kinetic energy of particles in a gas.

In the context of SA, it is customary to set k<sub>B</sub> &equiv; 1.
With this convention, the probability of accepting a new solution is given by:

P(&Delta;E > 0, T) = e<sup>-&Delta;E/T</sup>&nbsp;&nbsp;and&nbsp;&nbsp;P(&Delta;E <0, T) = 1.0,
where &Delta;E = E - E<sub>min</sub>.

The expression above ensures
that the acceptance probability decreases with decreasing temperature (for &Delta;E > 0).
As such, the temperature is a parameter that controls the probability of up-hill moves.

An estimate for the average scale of the variation of the energy
function &Delta;E<sub>start</sub>
can be obtained by sampling the energy function E
at random points in the search space &omega;
and calculating the sample standard deviation &sigma;<sub>E</sub> [\[3\]][ledesma2008].
The initial temperature is set such that the initial acceptance probability is:

P(&Delta;E<sub>start</sub>,T<sub>start</sub>) =  e<sup>-&Delta;E<sub>start</sub>/T<sub>start</sub></sup>
= &gamma;<sub>start</sub>, where &gamma;<sub>start</sub> is a simulator parameter with default value 0.7.

For continuous problems, the size of the search region around the current
solution is gradually contracted
to &omega;<sub>end</sub> in order to generate a solution with the required precision.
An estimate of &Delta;E<sub>end</sub> can be obtained by sampling the energy at
points in the neighbourhood around the current minimizing solution and
calculating the standard deviation. The final annealing temperature T<sub>end</sub> is set such that:

P(&Delta;E<sub>end</sub>, T<sub>end</sub>) =  e<sup>-&Delta;E<sub>end</sub>/T<sub>end</sub></sup> = &gamma;<sub>end</sub>,
where &gamma;<sub>end</sub> is a simulator parameter with default value 0.05.

The following parameters are required to define an annealing schedule:
* T<sub>start</sub>, the initial temperature,
* T<sub>end</sub>, the final temperature,
* the number of (outer) iterations,
* a function of type [`TemperatureSequence`][TemperatureSequence]
  that is used to determine the temperature at each (outer) iteration step.

It is recommended to start with a higher number of
outer iterations (number of entries in the sequence of temperatures) and log
quantities like the current system energy, temperature, and the intermediate solutions.

The figure below shows a typical SA log where the x-coordinate of the solution (green dots)
converges asymptotically to 0.5.
The graph is discussed in more detail [here].

![Convergence Graph](https://github.com/simphotonics/simulated_annealing/raw/main/example/plots/convergence.gif)

The number of inner iterations (performed while the temperature is kept constant)
is also referred to as Markov chain length and is determined by a function with typedef [`MarkovChainLength`][MarkovChainLength]
see method [`anneal`][anneal].

For fast cooling schedules convergence to an acceptable solution can be improved by
increasing the number of inner iterations.


## Algorithm Tuning

For discrete problems it can be shown that by selecting a sufficiently high initial
temperature the algorithm converges to the global minimum if the temperature
decreases on a logarithmic scale (slow cooling schedule) and
the number of inner iterations (Markov chain length)
is sufficiently high [\[2\]][nikolaev2010].

Practical implementations of the SA algorithm aim to generate
an acceptable solution with *minimal* computational effort.
For such *fast cooling* schedules, algorithm convergence to the global minimum is not
strictly guaranteed. In that sense, SA is a heuristic approach and some
degree of trial and error is required to determine which annealing schedule
works best for a given problem.


The behaviour of the annealing simulator can be tuned using the following **optional** parameters of the class [`Simulator`][SimulatorClass]:
* `gammaStart`: Initial acceptance probability with default value 0.7. Useful values for &gamma;<sub>start</sub>
are in the range of (0.7, 0.9). If &gamma;<sub>start</sub> is too low, up-hill moves are unlikely (potentially) preventing the SA algorithm from
escaping a local miniumum. If &gamma;<sub>start</sub> is set close to 1.0 the algorithm will accept
too many up-hill moves at high temperatures wasting computational time and delaying convergence.
* `gammaEnd`: Final acceptance probability. Towards the end of the annealing process one assumes
   that the solution has converged towards the global minimum and up-hill moves should be restricted. For this reason &gamma;<sub>end</sub> has default value 0.05.
* `dEnergyStart`: A **critical SA parameter** used to estimate the initial temperature T<sub>start</sub>. It has default value `field.dEnergyStart`.
   If &Delta;E<sub>start</sub> is too large the algorithm will oscillate wildy between random points and will most likely not converge towards an acceptable solution.
   On the other hand, if &Delta;E<sub>start</sub> is too small up-hill moves are unlikely and the solution
   most likely converges towards a local minimum or a point situated in a plateau-shaped region.
* `dEnergyEnd`: Typical energy variation &Delta;E if the current position is perturbed within the minimum
search neighbourhood  &omega;<sub>end</sub>. It is used to calculate T<sub>end</sub>.
* `iterations`: Determines the number of temperature steps in the annealing schedule.

## Examples

Further information can be found in the folder [example]. The following topics are covered:
- [search space],
- [annealing schedule],
- system energy and logging [simulator].



## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/simphotonics/simulated_annealing/issues

[example]: example

[anneal]: https://pub.dev/documentation/simulated_annealing/latest/simulated_annealing/Simulator/anneal.html

[annealing schedule]: example/ANNEALING_SCHEDULE.md

[Boltzmann]: https://en.wikipedia.org/wiki/Boltzmann_constant

[energy_field]: https://pub.dev/documentation/simulated_annealing/latest/simulated_annealing/EnergyField-class.html

[here]: example/SIMULATOR.md

[kirkpatrick1983]: https://doi.org/10.1126%2Fscience.220.4598.671

[ledesma2008]: https://cdn.intechopen.com/pdfs/4631/InTech-Practical_considerations_for_simulated_annealing_implementation.pdf

[LoggingSimulator]: https://pub.dev/documentation/simulated_annealing/latest/simulated_annealing/LoggingSimulator-class.html

[MarkovChainLength]: https://pub.dev/documentation/simulated_annealing/latest/simulated_annealing/MarkovChainLength.html

[nikolaev2010]: https://doi.org/10.1007/978-1-4419-1665-5_1

[simulated_annealing]: https://pub.dev/packages/simulated_annealing

[SimulatorClass]: https://pub.dev/documentation/simulated_annealing/latest/simulated_annealing/Simulator-class.html

[SA-Wiki]: https://en.wikipedia.org/wiki/Simulated_annealing

[search space]: example/SEARCH_SPACE.md

[simulator]: example/SIMULATOR.md

[TemperatureSequence]: https://pub.dev/documentation/simulated_annealing/latest/simulated_annealing/TemperatureSequence.html