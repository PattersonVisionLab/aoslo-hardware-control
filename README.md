# AOSLO Hardware Control
Software for controlling the 1P AOSLO. May be useful to other systems as well.

### Packages
__Motion package__: Wrappers for the .NET classes controlling KDC101, TDC001 and KST101/KST201. Extending to other single-axis Thorlabs K-Cubes would be straightforward (update the `DeviceTypes` enumeration and create a subclass of `ThorlabsMotor`).
- `KinesisForm` is specific to the 1P AOSLO source/PMT motors
- `OptimizationRoutine` optimizes X, Y, Z, XY and XYZ for a PMT by finding the position that produces the largest mean pixel value.

__LED package__: *Work in progress!* Wrapper for the Thorlabs DC40 LED driver.

__SLO Package__: Uses mqtt to subscribe to information from the SLO software, will not work out of the box for AOSLOs outside ARIA.


### Third-party functions
DLLs for ThorLabs hardware (full list can be found in `loadDLLsForTestingAOSLO.m`)
- Motion control requires Thorlab's Kinesis DLLs which are usually installed in C:\Program Files\Thorlabs\Kinesis if you download the Kinesis software ([Thorlabs Kinesis](link)).
 - LED drivers require Thorlab's DC40 Driver software that are usually installed at "C:\Program Files (x86)\Thorlabs\TLDC" ([Thorlabs DC40](link)).

Included in the `lib` folder
- `evar`: estimates value of additive Gaussian noise in a N-D signal ([FileExchange](https://www.mathworks.com/matlabcentral/fileexchange/25645-noise-variance-estimation))
- `fminsearchbnd`: like MATLAB's fminsearch, but with upper and lower bound support. Used instead of fminbnd when more than one variable is being optimized ([FileExchange]())
- `cprintf`: like fprintf but with colors ([FileExchange](link))