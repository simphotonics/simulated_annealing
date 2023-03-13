# Simulated Annealing For Dart
[![Dart](https://github.com/simphotonics/simulated_annealing/actions/workflows/dart.yml/badge.svg)](https://github.com/simphotonics/simulated_annealing/actions/workflows/dart.yml)


## Introduction
[Simulated annealing][SA-Wiki] (SA) is an algorithm aimed at finding the *global* minimum
of a function E(x<sub>0</sub>,&nbsp;x<sub>1</sub>,&nbsp;...,&nbsp;x<sub>n</sub>)
for a given region &omega;(x<sub>0</sub>,&nbsp;x<sub>1</sub>,&nbsp;...,&nbsp;x<sub>n</sub>).
The function to be minimized can be interpreted as the
**system energy**. In that case, the global minimum represents
the **ground state** of the system.

Simulated annealing works by randomly
selecting a new point (y<sub>0</sub>,&nbsp;y<sub>1</sub>,&nbsp;
...,&nbsp;y<sub>n</sub>)  in the neighbourhood of the
current solution, evaluating the energy function E(y<sub>0</sub>,&nbsp;
y<sub>1</sub>,&nbsp;...,&nbsp;y<sub>n</sub>),
and deciding if the new solution is accepted or rejected:
* If &Delta;E = E - E<sub>min</sub> < 0 ,where E<sub>min</sub> is a previously
found energy minimum, the new solution is accepted with probability: 1.0.
* If &Delta;E > 0, the new solution is accepted with probability:
P(&Delta;E > 0, T) = e<sup>-&Delta;E/(k<sub>B</sub>&middot;T)</sup>.
The [Boltzmann constant][Boltzmann] k<sub>B</sub>  relates the system
temperature with the kinetic energy of particles in a gas.
In the context of SA, it is customary to set k<sub>B</sub>&nbsp;&equiv;&nbsp;1.

Accepting up-hill moves provides a method of escaping from local energy minima.
The acceptance probability for solution satisfying &Delta;E > 0
decreases with decreasing temperature. As such, the temperature is a parameter
that controls the probability of up-hill moves.

<details><summary> The algorithm name was coined by ... click to show details.
</summary>
Kirkpatrick et al. and was
derived from the process of annealing a metal alloy or glass.
The first step of the annealing process consists of heating a
solid material above a critical temperature. This allows its atoms to gain
sufficient kinetic energy to be able to rearrange themselves.
Then the temperature is decreased sufficiently slowly
in order to minimize atomic lattice defects as the material solidifies.



The expression above ensures
that the acceptance probability decreases with decreasing temperature (for &Delta;E > 0).
As such, the temperature is a parameter that controls the probability of up-hill moves.
</details>

![Energy Simulated Annealing](https://github.com/simphotonics/simulated_annealing/raw/main/images/energy_composite.gif)

The process is demonstrated in the animation above. The left figure shows a
spherical 3D search space while the energy value is represented by colour.
The figure on the right shows a projection of the energy function onto the
x-y plane. Initially, random points are chosen
from a large region encompasing the entire spherical search space.
 In the simulation shown above, intermediate solutions
near the local minimum are followed by up-hill moves.
As the temperature drops the search neighourhood
is contracted and the solution converges to the
global minimum.

## Usage
To use this package include [`simulated_annealing`][simulated_annealing]
as a `dependency` in your `pubspec.yaml` file.

The following steps are required to set up the SA algorithm.
1. Specify the [search space][search space] &omega;.
   Common 2d and 3d search spaces
   (circle, sphere, rectangle, box, disk, cone, triangle)
   are predefined as static functions of the
   class [`SearchSpace`][SearchSpace].
2. Define the system [`EnergyField`][EnergyField], an object encapsulating
   the energy function (cost function) and its domain: the search space.
3. Create an instance of [`LoggingSimulator`][LoggingSimulator] or
   alternatively extend the abstract class [`Simulator`][SimulatorClass].
4. Start the [simulated annealing][simulator] process.

<details><summary> Click to show source code.</summary>

```Dart

import 'dart:io';

import 'package:list_operators/list_operators.dart';
import 'package:simulated_annealing/simulated_annealing.dart';

// A predefined search space.
final space = SearchSpace.sphere(rMin: 0, rMax: 2);

final globalMin = [0.5, 0.7, 0.8].cartesianToSpherical;
final localMin = [-1.0, -1.0, -0.5].cartesianToSpherical;

// Defining an energy function.
num energy(List<num> position) {
  return 4.0 -
      4.0 *
          exp(-4 *
              globalMin.distance(
                position,
                coordinates: Coordinates.spherical,
              )) -
      2.0 *
          exp(-6 *
              localMin.distance(
                position,
                coordinates: Coordinates.spherical,
              ));
}

final field = EnergyField(
  energy,
  space,
);

/// To run this program navigate to the root folder in your local
/// copy of the package `simulated_annealing` and use the command:
/// $ dart example/bin/simulated_annealing_example.dart
void main() async {
  // Construct a simulator instance.
  final simulator = LoggingSimulator(
    field, // Defined in file `energy_field_example.dart'
    gammaStart: 0.8,
    gammaEnd: 0.05,
    outerIterations: 150,
    innerIterationsStart: 5,
    innerIterationsEnd: 10,
  );

  simulator.gridStart = [];
  simulator.gridEnd = [];
  simulator.deltaPositionEnd = [1e-9, 1e-9, 1e-9];

  print(await simulator.info);

  print('Start annealing process ...');
  final xSol = await simulator.anneal(
    isRecursive: true,
  );
  print('Annealing ended.');
  print('Writing log to file: example/data/log.dat');
  await File('example/data/log.dat').writeAsString(simulator.export());
  print('Finished writing. ');

  print('Solution: $xSol');
  print('xSol - globalMin: ${xSol - globalMin}.');
}

```
</details><br/>

## Algorithm Tuning

It can be shown that by selecting a sufficiently high initial
temperature the algorithm converges to the global minimum if the temperature
decreases on a logarithmic scale (slow cooling schedule) and
the number of inner iterations (Markov chain length)
is sufficiently high [\[1\]][nikolaev2010].

Practical implementations of the SA algorithm aim to generate
an acceptable solution with *minimal* computational effort.
For such *fast cooling* schedules, algorithm convergence to the
global minimum is not
strictly guaranteed. In that sense, SA is a heuristic approach and some
degree of trial and error is required to determine which annealing schedule
works best for a given problem.


The behaviour of the annealing simulator can be tuned using the following **optional** parameters of the [`Simulator`][SimulatorClass] constructor:
* `gammaStart`: Initial acceptance probability with default value 0.7. Useful values for &gamma;<sub>start</sub>
are in the range of \[0.7,&nbsp;0.9\]. If &gamma;<sub>start</sub> is too low, up-hill moves are unlikely (potentially) preventing the SA algorithm from
escaping a local miniumum. If &gamma;<sub>start</sub> is set close to 1.0 the algorithm will accept
too many up-hill moves at high temperatures wasting computational time and delaying convergence.
* `gammaEnd`: Final acceptance probability. Towards the end of the annealing process one assumes
   that the solution has converged towards the global minimum and up-hill moves should be restricted. For this reason &gamma;<sub>end</sub> has default value 0.05.
* `outerIterations`: Determines the number of temperature steps in the annealing schedule.
   It is recommended to start with a higher number of
   outer iterations (number of entries in the sequence of temperatures) and log
   quantities like the current system energy, temperature, and the intermediate solutions.
* `innerIterationsStart`: The number of inner iterations (at constant temperature)
   at the start of the annealing process.
* `innerIterationsEnd`: The number of inner iterations (at constant temperature)
   at the end of the annealing process.
* `sampleSize`: The size of the sample used to determine the initial and final
   annealing temperature.


Additionally, it is possible to set the class variable `temperatureSequence`
to function of type [`TemperatureSequence`][TemperatureSequence]
that is used to determine the temperature at each outer iteration step.


The figure below shows a typical SA log where the x-coordinate of the solution (green dots)
converges asymptotically to 0.5.
The graph is discussed in more detail [here].

![Convergence Graph](https://github.com/simphotonics/simulated_annealing/raw/main/images/convergence.gif)

The number of inner iterations (performed while the temperature is kept constant)
is also referred to as Markov chain length and is determined by a function with typedef [`MarkovChainLength`][MarkovChainLength]. It can be adjusted by setting the
simulator arguments `innerIterationsSTart` and `innerIterationsEnd`. In general,
it is advisable to increase the number of inner Iterations towards the end of
the annealing process in order to increase the algorithm precision.


## Annealing Schedule

In general, the following information is required to define an annealing schedule:
* T<sub>start</sub>, the initial temperature,
* T<sub>end</sub>, the final temperature,
* the number of outer iterations (temperature steps),
* a function of type [`TemperatureSequence`][TemperatureSequence]
  that is used to determine the temperature at each (outer) iteration step.

The class [`EnergyField`][EnergyField] provides the methods `tStart` and `tEnd`.
These use an algorithm introduced by Ben-Ameur to calculate the
initial and final annealing temperature [\[2\]][ben-ameur2004].


## Examples

Further information can be found in the folder [example]. The following topics are covered:
- [search space],
- [annealing schedule],
- system energy and logging [simulator].



## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/simphotonics/simulated_annealing/issues

[example]: https://github.com/simphotonics/simulated_annealing/tree/main/example

[anneal]: https://pub.dev/documentation/simulated_annealing/latest/simulated_annealing/Simulator/anneal.html

[annealing schedule]: https://github.com/simphotonics/simulated_annealing/tree/main/example/ANNEALING_SCHEDULE.md

[Boltzmann]: https://en.wikipedia.org/wiki/Boltzmann_constant

[EnergyField]: https://pub.dev/documentation/simulated_annealing/latest/simulated_annealing/EnergyField-class.html

[here]: https://github.com/simphotonics/simulated_annealing/tree/main/example/SIMULATOR.md

[kirkpatrick1983]: https://doi.org/10.1126%2Fscience.220.4598.671

[ledesma2008]: https://cdn.intechopen.com/pdfs/4631/InTech-Practical_considerations_for_simulated_annealing_implementation.pdf

[LoggingSimulator]: https://pub.dev/documentation/simulated_annealing/latest/simulated_annealing/LoggingSimulator-class.html

[MarkovChainLength]: https://pub.dev/documentation/simulated_annealing/latest/simulated_annealing/MarkovChainLength.html

[nikolaev2010]: https://doi.org/10.1007/978-1-4419-1665-5_1

[simulated_annealing]: https://pub.dev/packages/simulated_annealing

[SimulatorClass]: https://pub.dev/documentation/simulated_annealing/latest/simulated_annealing/Simulator-class.html

[SA-Wiki]: https://en.wikipedia.org/wiki/Simulated_annealing

[search space]: https://github.com/simphotonics/simulated_annealing/tree/main/example/SEARCH_SPACE.md

[SearchSpace]: https://pub.dev/documentation/simulated_annealing/latest/simulated_annealing/SearchSpace-class.html

[simulator]: https://github.com/simphotonics/simulated_annealing/tree/main/example/SIMULATOR.md

[TemperatureSequence]: https://pub.dev/documentation/simulated_annealing/latest/simulated_annealing/TemperatureSequence.html

[ben-ameur2004]: https://www.researchgate.net/publication/227061666_Computing_the_Initial_Temperature_of_Simulated_Annealing