##  Annealing Schedule - Example
[![Build Status](https://travis-ci.com/simphotonics/simulated_annealing.svg?branch=main)](https://travis-ci.com/simphotonics/simulated_annealing)

The library `annealing_schedule` includes functions for generating
*linear*, *geometric*, *normal*, *exponential*, and *Lundy*
temperature sequences.

These functions have typedef `TemperatureSequence` and can be used as an argument when
constructing objects of type `Simulator`.


![Annealing Schedule](https://raw.githubusercontent.com/simphotonics/simulated_annealing/main/example/plots/annealing_schedule.png)![Temperature 3D](https://raw.githubusercontent.com/simphotonics/simulated_annealing/main/example/plots/temperature.png)


The annealing schedule shown above consists of a monotonically decreasing exponential sequence
with 750 elements, start value T<sub>start</sub> = 1902.4 and end value T<sub>end</sub> = 1e-3.

The green curve represents the first component of the perturbation magnitudes **dx**
calculated by interpolated between **dxMax**&nbsp;=&nbsp;\[2.0,&nbsp;2.0,&nbsp;2.0\]
and **dxMin**&nbsp;=&nbsp;\[1e-6,&nbsp;1e-6,&nbsp;1e-6\] using the
function: **dx**(T)&nbsp;=&nbsp;**a**\*&nbsp;T&nbsp;+&nbsp;**b**,
where **a**&nbsp;=&nbsp;(**dxMax**&nbsp;-&nbsp;**dxMin**)/(T<sub>0</sub>&nbsp;-&nbsp;T<sub>n</sub>) and **b**&nbsp;=&nbsp;**dxMax**&nbsp;-&nbsp;**a**\*t<sub>0</sub>.

The perturbation magnitude **dx** specifies a region of the search space around
the current solution **x**. From this region a random point is selected as the
next potential solution.

SA is typically used to solve discrete optimization problems.
SA can be adapted to minimize continuous (multi-variate) functions by reducing the size of the
search neighbourhood, **dx**, during each (outer) SA iteration until the required solution precision
is reached.


![Temperature 3D](https://raw.githubusercontent.com/simphotonics/simulated_annealing/main/example/plots/temperature.png)


The figure above shows the temperature during an SA process. At high temperatures (red dots) **dx** approaches **dxMax**&nbsp;=&nbsp;\[2.0,&nbsp;2.0,&nbsp;2.0\] and the potential solutions are selected from the entire search space.
As the temperature decreases (blue dots) **dx** approaches **dxMin** and, in this example, the solution converges towards the global minimum.

## Features and bugs
Please file feature requests and bugs at the [issue tracker].

[issue tracker]: https://github.com/simphotonics/simulated_annealing/issues
