##  Annealing Schedule - Example
[![Build Status](https://travis-ci.com/simphotonics/simulated_annealing.svg?branch=main)](https://travis-ci.com/simphotonics/simulated_annealing)

The class [`AnnealingSchedule`][AnnealingSchedule] provides a
decreasing sequence of temperatures (T<sub>0</sub>,&nbsp;...T<sub>n</sub>) and a decreasing sequence
of perturbation magnitudes (**dx**<sub>0</sub>,&nbsp;... **dx**<sub>n</sub>)
also known as neighbourhood function. Note: Bold characters indicate vector valued quantities.

The package includes functions for generating
*linear*, *geometric*, *normal*, and *exponential*
temperature sequences.

<details><summary> Click to show source code.</summary>

```Dart
import 'package:simulated_annealing/simulated_annealing.dart';

void main() async {
  // The search space is assumed to be 3-dimensional with sizes [2.0, 2.0, 2.0].
  final dxMax = [2.0, 2.0, 2.0];

  // The perturbation magnitude at the end of the annealing process.
  final dxMin = [1e-6, 1e-6, 1e-6];

  // Defining an annealing schedule.
  // The initial temperature is 100, the final temperature is 1e-8.
  final schedule = AnnealingSchedule(
    exponentialSequence(100, 1e-8, n: 750),
    dxMax,
    dxMin,
  );
```
</details>

Any user supplied temperature sequence may be used as annealing schedule. However,
the *initial* sequence member T<sub>0</sub> must be the *highest* temperature
since it is used to estimate the constant k<sub>B</sub> which determines how
how likely uphill moves are T<sub>0</sub>.

The final value of the annealing schedule T<sub>n</sub> should be chosen
sufficiently small such that
P(&Delta;E, T<sub>n</sub>) = e<sup>-&Delta;E/(k<sub>B</sub>&middot;T<sub>n</sub>)</sup> -> 0,
that is during the final iterations of the annealing process uphill moves are unlikely.

The neighbourhood function **dx** specifies a region of the search space around
the current solution **x**. From this region a random point is selected as the
next potential solution.

SA is typically used to solve discrete optimization problems.
SA can be adapted to minimize continuous (multi-variate) functions by reducing the size of the
search neighbourhood, **dx**, during each (outer) SA iteration until the required solution precision
is reached.

![Annealing Schedule](https://raw.githubusercontent.com/simphotonics/simulated_annealing/main/example/plots/annealing_schedule.svg)

The annealing schedule shown above consists of a monotonically decreasing exponential sequence
with 750 elements, start value T<sub>0</sub> = 100 and end value T<sub>n</sub> = 1e-8.

[`AnnealingSchedule`][AnnealingSchedule] provides the method `dx(num temperature)`.
The values of dx (green curve) are calculated by interpolated between **dxMax**&nbsp;=&nbsp;\[2.0,&nbsp;2.0,&nbsp;2.0\]
and **dxMin**&nbsp;=&nbsp;\[1e-6,&nbsp;1e-6,&nbsp;1e-6\] using the
function: **dx**(T)&nbsp;=&nbsp;**a**\*&nbsp;T&nbsp;+&nbsp;**b**,
where **a**&nbsp;=&nbsp;(**dxMax**&nbsp;-&nbsp;**dxMin**)/(T<sub>0</sub>&nbsp;-&nbsp;T<sub>n</sub>) and **b**&nbsp;=&nbsp;**dxMax**&nbsp;-&nbsp;**a**\*t<sub>0</sub>.

![Temperature 3D](https://raw.githubusercontent.com/simphotonics/simulated_annealing/main/example/plots/temperature.svg?sanitize=true)

The figure above shows the temperature during the SA process. At high temperatures (red dots) **dxMax**&nbsp;=&nbsp;\[2.0,&nbsp;2.0,&nbsp;2.0\] and the solutions are selected from the entire search space.
As the temperature decreases (blue dots) the solution converges towards the global minimum.

## Features and bugs
Please file feature requests and bugs at the [issue tracker].

[issue tracker]: https://github.com/simphotonics/simulated_annealing/issues

[AnnealingSchedule]: https://pub.dev/documentation/simulated_annealing/latest/simulated_annealing/AnnealingSchedule-class.html
