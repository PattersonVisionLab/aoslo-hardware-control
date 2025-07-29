% All the DLLs used in the package
% - adds each assembly
% - imports into base workspace

%% SYSTEM
NET.addAssembly('System.Drawing');
NET.addAssembly('System.Windows.Forms');

import System.Drawing.*;
import System.Windows.Forms.*;

%% KINESIS MOTOR CONTROL
kinesisPath = "C:\Program Files\Thorlabs\Kinesis";

kinesisDLLs = [...
    "Thorlabs.MotionControl.Controls.dll",...
    "Thorlabs.MotionControl.GenericMotorCLI.dll",...
    "Thorlabs.MotionControl.DeviceManagerCLI.dll",...
    "Thorlabs.MotionControl.DeviceManagerUI.dll",...
    "Thorlabs.MotionControl.KCube.DCServoCLI.dll",...
    "Thorlabs.MotionControl.KCube.StepperMotorCLI.dll",...
    "Thorlabs.MotionControl.TCube.StepperMotorCLI.dll"
    "Thorlabs.MotionControl.KCube.DCServoUI.dll",...
    "Thorlabs.MotionControl.KCube.StepperMotorUI.dll",...
    "Thorlabs.MotionControl.TCube.StepperMotorUI.dll"];

for i = 1:numel(kinesisDLLs)
    NET.addAssembly(fullfile(kinesisPath, kinesisDLLs(i)));
end

import Thorlabs.MotionControl.Controls.*;
import Thorlabs.MotionControl.GenericMotorCLI.*;
import Thorlabs.MotionControl.DeviceManagerCLI.*;
import Thorlabs.MotionControl.DeviceManagerUI.*;


%% DC40 LED DRIVER
NET.addAssembly("C:\Program Files (x86)\Microsoft.NET\Primary Interop Assemblies\Thorlabs.TLDC_64.Interop.dll");

import Thorlabs.TLDC_64.Interop.*

%% CMOS Cameras

