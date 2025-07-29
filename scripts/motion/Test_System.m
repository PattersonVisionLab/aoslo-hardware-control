

NET.addAssembly('System.Drawing');
NET.addAssembly('System.Windows.Forms');
NET.addAssembly(fullfile(kinesisPath, 'Thorlabs.MotionControl.Controls.dll'));
NET.addAssembly(fullfile(kinesisPath, 'Thorlabs.MotionControl.DeviceManagerCLI.dll'));
NET.addAssembly(fullfile(kinesisPath, 'Thorlabs.MotionControl.DeviceManagerUI.dll'));
NET.addAssembly(fullfile(kinesisPath, 'Thorlabs.MotionControl.GenericMotorCLI.dll'));
NET.addAssembly(fullfile(kinesisPath, 'Thorlabs.MotionControl.KCube.DCServoCLI.dll'));
NET.addAssembly(fullfile(kinesisPath, 'Thorlabs.MotionControl.KCube.DCServoUI.dll'));
NET.addAssembly(fullfile(kinesisPath, 'Thorlabs.MotionControl.KCube.StepperMotorCLI.dll'));
NET.addAssembly(fullfile(kinesisPath, 'Thorlabs.MotionControl.KCube.StepperMotorUI.dll'));
NET.addAssembly(fullfile(kinesisPath, 'Thorlabs.MotionControl.TCube.StepperMotorCLI.dll'));
NET.addAssembly(fullfile(kinesisPath, 'Thorlabs.MotionControl.TCube.StepperMotorUI.dll'));

import System.Drawing.*
import System.Windows.Forms.*

import Thorlabs.MotionControl.Controls.*
import Thorlabs.MotionControl.DeviceManagerCLI.*
import Thorlabs.MotionControl.DeviceManagerUI.*
import Thorlabs.MotionControl.GenericMotorCLI.*

import Thorlabs.MotionControl.TCube.DCServoCLI.*
import Thorlabs.MotionControl.TCube.DCServoUI.*
import Thorlabs.MotionControl.KCube.DCServoCLI.*
import Thorlabs.MotionControl.KCube.DCServoUI.*
import Thorlabs.MotionControl.KCube.StepperMotorCLI.*
import Thorlabs.MotionControl.KCube.StepperMotorUI.*

obj = struct();

obj.REF_XYZ = ["83857268", "83855258", "26250117"];
obj.VIS_XYZ = ["83848285", "83848287", "83848308"];
obj.SOURCE_XYZ = [];
