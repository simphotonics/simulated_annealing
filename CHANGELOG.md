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
