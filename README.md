# Simulated Annealing For Dart

## Introduction
[Simulated annealing][SA-Wiki] (SA) is an algorithm aimed at finding the *global* minimum of
of a function E(x<sub>0</sub>, x<sub>1</sub>, ..., x<sub>n</sub>) for a given region &omega;.
The function to be minimized can be interpreted as the
**system energy**. In that case, the global minimum represents
the **ground state** of the system.

The algorithm name is taken from the process of annealing a metal alloy or glass.
First the material is heated above a critical temperature. This allows its atoms to gain
sufficient kinetic energy to be able to rearrange themselves.
Then the temperature is decreased sufficiently slowly
in order to minimize atomic lattice defects as the material solidifies.

*Simulated* annealing works by randomly selecting points in the search space &omega;,
evaluating the energy function, and deciding if the new solution is accepted or rejected.
If for a newly selected point the energy E is lower that the previous minimum energy
E<sub>min</sub>, the new solution is accepted: P(&Delta;E < 0, T) = 1,
where &Delta;E = E - E<sub>min</sub>.

 Crucially, if the energy is larger than E<sub>min</sub>, the algorithm still accepts the
 new solution with probability: P(&Delta;E > 0, T) = e<sup>-&Delta;E/(k<sub>B</sub>&middot;T)</sup>.
 Accepting up-hill moves provides a method of escaping from local energy minima.
 The probability of accepting a solution with &Delta;E > 0 decreases with decreasing temperature.

In Physics, the [Boltzmann constant][Boltzmann] k<sub>B</sub> relates the system
temperature with the kinetic energy of particles in a gas. In the context of SA,
k<sub>B</sub> relates the system temperature with the probability of accepting a solution where &Delta;E > 0.

Many authors set k<sub>B</sub> = 1 and scale the temperature to control the
solution acceptance probability. I find it more practical to define a temperature
scale say T<sub>0</sub> = 100, T<sub>n</sub> = 1e-6, where n is the number of
outer iterations (see method `anneal`) and calculate the system dependent
constant k<sub>B</sub> (see next section).
<!-- Note: The initial temperature T<sub>0</sub> must be
the largest value in the sequence and T<sub>n</sub>
is a small value approaching zero. -->

## Algorithm Tuning
It can be shown that by selecting a sufficiently high initial
temperature  the algorithm converges to the global minimum in
the asymptotic limit [\[1\]][1].

Practical implementations of the SA algorith aim to generate
an acceptable solution with *minimal* computational effort. In such circumstances,
algorithm convergence is not
strictly guaranteed. In that sense, SA is a heuristic approach and some
degree of trial and error is required to determine which annealing schedule
works best for a given problem.

### Estimating the value of k<sub>B</sub>
An estimate for the average scale of &Delta;E can be obtained by sampling the energy function E
at random points in the search space &omega; and calculating the sample standard deviation &sigma;<sub>E</sub>
[\[2\]][2]. The constant k<sub>B</sub> is set such that the probability of accepting a solution
P(&Delta;E = &sigma;<sub>E</sub>, T<sub>0</sub>) = &gamma; where T<sub>0</sub> is the initial temperature.

Since gamma represents a probability, 0 < &gamma; < 1,  however useful values for &gamma;
are in the range of (0.7, 0.9). If &gamma; is too low, up-hill moves are unlikely (potentially) preventing the SA algorithm from
escaping a local miniumum. If &gamma; is set close to 1.0 the algorithm will accept too many up-hill
moves at high temperatures wasting computational time and delaying convergence.


### Selecting an annealing schedule.
The package includes functions for generating *linear*, *geometric*, *normal*, and *exponential*
decreasing temperature sequences.
It is recommended to start with a higher number of
outer iterations (number of entries in the sequence of temperatures) and log
quantities like the current system energy, temperature, and the intermediate solutions.

![Histogram](https://raw.githubusercontent.com/simphotonics/simulated_annealing/main/example/plots/convergence.svg?sanitize=true)


Any user supplied temperature sequence may be used as annealing schedule. However,
the *initial* sequence member T<sub>0</sub> must be the *highest* temperature since it is used
to estimate the constant k<sub>B</sub>.

For continuous problems, the
final value T<sub>n</sub> is related to the required *solution precision*.
The size of the search neighbourhood: dx is typically reduced during each (outer) SA iteration.
Towards the end of the annealing cycle T&nbsp;->&nbsp;T<sub>n</sub>,
dx approaches the *solution precision* and E(x<sub>min</sub> + dx) - E(x<sub>min</sub>) = &Delta;E -> 0.
At this stage of the annealing cycle it is advisable to limit uphill moves and choose T<sub>n</sub>
sufficiently small such that
P(&Delta;E, T<sub>n</sub>) = e<sup>-&Delta;E/(k<sub>B</sub>&middot;T<sub>n</sub>)</sup> -> 0.

The number of inner iterations (performed while the temperature is kept constant)
is determined by a function with `typedef` `MarkovChainLength`, see method `anneal`.


## Usage
To use this package include [`simulated_annealing`][simulated_annealing] as a `dependency` in your `pubspec.yaml` file.

The following steps are required to set up the SA algorithm.
1. Extend the class [`Simulator`][SimulatorClass] implementing the methods `prepareLog()` and  `recordLog()`.
2. Specify the search space &omega;.
3. Define an annealing schedule and a neighbourhood function.
4. Define the system energy function E(x<sub>0</sub>, x<sub>1</sub>, ..., x<sub>n</sub>).

<details><summary> Click to show source code.</summary>

```Dart
import 'dart:io';
import 'dart:math';

import 'package:simulated_annealing/simulated_annealing.dart';

class Sim extends Simulator {
  Sim(
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
    rec.prepareScalar('P(dE)');
    rec.prepareScalar('Temperature');
    rec.prepareVector('dx', 3);
  }

  @override
  void recordLog() {
    rec.addVector('x', x);
    rec.addVector('dx', dx);
    rec.addScalar('Energy', eCurrent);
    rec.addScalar('P(dE)',
        (eCurrent - eMin) < 0 ? 1 : exp(-(eCurrent - eMin) / (kB * t)));
    rec.addScalar('Temperature', t);
  }
}

void main() async {
  // Defining a spherical search space.
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
  final space = SearchRegion([x, y, z]);

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
     return 1;
    //return min(1 + 1~/(100*temperature),25);
  }

  // Construct a simulator instance.
  final simulator = Sim(
    AnnealingSystem(
      energy,
      space,
    ),
    schedule,
    gamma: 0.8,
    xMin0: xLocalMin,
  );

  print(simulator);

  final sample = simulator.system.x;
  for (var i = 0; i < simulator.system.sampleSize; i++) {
    sample[i].add(simulator.system.e[i]);
  }

  final xSol = simulator.anneal(markov);
  await File('../sample_data/log.dat').writeAsString(simulator.rec.export());
  await File('../sample_data/energy_sample.dat')
      .writeAsString(sample.export(label: 'x y z energy'));

  print(xSol);
}


```
</details>



## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: http://github.com/simphotonics/simulated_annealing/issues

[Boltzmann]: https://en.wikipedia.org/wiki/Boltzmann_constant

[1]: https://doi.org/10.1007/978-1-4419-1665-5_1

[2]: https://cdn.intechopen.com/pdfs/4631/InTech-Practical_considerations_for_simulated_annealing_implementation.pdf


[simulated_annealing]: https://pub.dev/packages/simulated_annealing

[SimulatorClass]: https://pub.dev/

[SA-Wiki]: https://en.wikipedia.org/wiki/Simulated_annealing
