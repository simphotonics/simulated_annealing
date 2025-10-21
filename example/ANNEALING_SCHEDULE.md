##  Annealing Schedule - Example
[![Dart](https://github.com/simphotonics/simulated_annealing/actions/workflows/dart.yml/badge.svg)](https://github.com/simphotonics/simulated_annealing/actions/workflows/dart.yml)

The library `annealing_schedule` includes functions with signature
[`TemperatureSequence`][TemperatureSequence] for generating
*linear*, *geometric*, *normal*, *exponential*, and *Lundy*
temperature sequences.

The annealing schedule show below (figure on the left, red line) consists of a monotonically decreasing exponential sequence with start value T<sub>start</sub> = 0.3673892633, end value T<sub>end</sub> = 0.0000017939, and with 750 steps.

The simulated annealing temperature schedule can be specified via the [`Simulator`][SimulatorClass] parameter `outerIterations` and by setting the class variable `temperatureSequence`.

The green curve represents the first component of the perturbation magnitudes **deltaPosition**
calculated by interpolated between **deltaPositionMax**&nbsp;=&nbsp;\[2.0,&nbsp;2.0,&nbsp;2.0\]
and **deltaPositionMin**&nbsp;=&nbsp;\[1e-6,&nbsp;1e-6,&nbsp;1e-6\] using the
function: **deltaPosition**(T)&nbsp;=&nbsp;**a**\*&nbsp;T&nbsp;+&nbsp;**b**,
where **a**&nbsp;=&nbsp;(**deltaPositionMax**&nbsp;-&nbsp;**deltaPositionMin**)/(T<sub>start</sub>&nbsp;-&nbsp;T<sub>end</sub>)
and **b**&nbsp;=&nbsp;**deltaPositionMax**&nbsp;-&nbsp;**a**\*T<sub>start</sub>.

![Annealing Schedule](https://raw.githubusercontent.com/simphotonics/simulated_annealing/main/images/annealing_schedule.png)
![Temperature 3D](https://raw.githubusercontent.com/simphotonics/simulated_annealing/main/images/temperature.png)

The perturbation magnitude **deltaPosition** specifies a region of the search space around
the current solution **position**. From this region a random point is selected as the
next potential solution.

SA is typically used to solve discrete optimization problems.
However, the algorithm can be adapted to minimize continuous (multi-variate) functions by reducing the size of the
perturbation magnitude, **deltaPosition**, during each (outer) SA iteration until the required solution precision
is reached.

The right figure above shows the temperature during an SA process. In the example presented here, the search space is a
sphere centred at the origin with radius 2.
At high temperatures (red dots) **deltaPosition** approaches **deltaPositionMax**&nbsp;=&nbsp;\[2.0,&nbsp;2.0,&nbsp;2.0\]
and the potential solutions are selected from the entire search space.
As the temperature decreases (blue dots) **deltaPosition** approaches **deltaPositionMin** and,
in this example, the solution converges towards the global minimum.

## Features and bugs
Please file feature requests and bugs at the [issue tracker].

[issue tracker]: https://github.com/simphotonics/simulated_annealing/issues

[SimulatorClass]: https://pub.dev/documentation/simulated_annealing/latest/simulated_annealing/Simulator-class.html

[TemperatureSequence]: https://pub.dev/documentation/simulated_annealing/latest/simulated_annealing/TemperatureSequence.html
