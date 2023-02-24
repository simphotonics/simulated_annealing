## 0.3.3

- Upgraded to `list_operators` 0.3.5.

## 0.3.2

- Amended input arguments of method `anneal` in class `Simulator` by removing
  the option to specify a certani Markov chain length function.
- Updated dependencies.

## 0.3.1

- Updated dependencies.
- Fixed potentially infinite loop condition in [`EnergyField`][EnergyField] methods
  * `perturb`,
  * `tStart`,
  * `tEnd`.

## 0.3.0

- Migrated to null-safety.
- The function [`nextInRange`][nextInRange] now has signature:
   num `nextInRange`(num xMin, num xMax, {InverseCdf? inverseCdf,
   int nGrid = 0}). The optional parameter `ngrid` enables
   returning discrete random numbers positioned along an
   equidistant grid.

## 0.2.2-nullsafety

- Renamed variables in class [`SearchSpace`][SearchSpace].
  x -> position, dx -> dPosition.
- Updated docs.

## 0.2.1-nullsafety

- Amended docs. Updated figures.

## 0.2.0-nullsafety

- Set k<sub>B</sub> &equiv;1. Removed simulator parameter `tEnd`.
  Updated docs and figures.

## 0.1.6-nullsafety

- Amended docs highlighting the fact that when instantiating an object of type [`SearchSpace`][SearchSpace],
  parameteric intervals must be listed in order of dependence.

## 0.1.5-nullsafety

- Changed the signature and name of the function `nextDoubleInRange()`.
  The function is now called `nextInRange()` and returns an object of type `num`.

## 0.1.4-nullsafety

- Amended the calculation of `dEnergyStart` and `dEnergyEnd` used to estimate the
  starting temperature of the annealing schedule.

## 0.1.3-nullsafety

- Removed public access to internal variables of type `List` used by class `EnergyField`.
- Removed public access to variables `temperatures` and `perturbationMagnitudes` used by class `Simulator`.

## 0.1.2-nullsafety

- Amended message attached to Error thrown in method `contains` of class `SearchSpace`.

## 0.1.1-nullsafety

- Removed dependency on `dart:io`.

## 0.1.0-nullsafety

- Computationally costly methods of `Simulator` and `EnergyField`  are now asynchronous.
- Class `DataRecorder` is now generic.
- Removed class `AnnealingSchedule`.
- Added `dxMax` and `dxMin` to the required list of parameters when constructing
  an object of type `SearchSpace`.
- Amended examples.

## 0.0.3-nullsafety

- Converted links to images to absolute links.


## 0.0.2-nullsafety

- Amended documentation: Converted hyperlinks to relative links.

## 0.0.1-nullsafety

- Initial version


[EnergyField]: https://pub.dev/documentation/simulated_annealing/latest/simulated_annealing/EnergyField-class.html

[nextInRange]: https://pub.dev/documentation/simulated_annealing/latest/simulated_annealing/RandomInRange/nextInRange.html


[SearchSpace]: https://pub.dev/documentation/simulated_annealing/latest/simulated_annealing/SearchSpace-class.html
