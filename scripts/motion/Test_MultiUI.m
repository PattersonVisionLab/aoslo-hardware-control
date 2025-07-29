

%% Load Assemblies
NET.addAssembly('System.Windows.Forms');
NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.DeviceManagerCLI.dll');
NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.DeviceManagerUI.dll');
NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.GenericMotorCLI.dll');
NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.KCube.DCServoCLI.dll');
NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.KCube.DCServoUI.dll');
NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.KCube.StepperMotorCLI.dll');
NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.KCube.StepperMotorUI.dll');
NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.TCube.DCServoCLI.dll');
NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.TCube.DCServoUI.dll');
NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.Controls.dll');

import System.Windows.Forms.*;
import Thorlabs.MotionControl.DeviceManagerCLI.*
import Thorlabs.MotionControl.DeviceManagerUI.*
import Thorlabs.MotionControl.GenericMotorCLI.*
import Thorlabs.MotionControl.KCube.DCServoCLI.*
import Thorlabs.MotionControl.KCube.DCServoUI.*
import Thorlabs.MotionControl.KCube.StepperMotorCLI.*
import Thorlabs.MotionControl.KCube.StepperMotorUI.*
import Thorlabs.MotionControl.TCube.DCServoCLI.*
import Thorlabs.MotionControl.TCube.DCServoUI.*
import Thorlabs.MotionControl.Controls.*

%%
DeviceManagerCLI.BuildDeviceList();
serialNumbersNet = DeviceManagerCLI.GetDeviceList();
serialNumbers = cell(ToArray(serialNumbersNet));
disp(string(serialNumbers)');
% Reflectance: X - 83857268, Y - 83855258, Z - 26250117

% Visible: X - 83848285, Y - 83848287, Z - 83848308

serialNumber1 = '83857268';
serialNumber2 = '83855258';
serialNumber3 = '26250117';

%%
controller1 = TCubeDCServoControl();
controller1.LargeView = true;
controller1.Dock = DockStyle.Fill;
controller1.SerialNumber = serialNumber1;
controller1.CreateDevice();

controller2 = TCubeDCServoControl();
controller2.LargeView = true;
controller2.Dock = DockStyle.Fill;
controller2.SerialNumber = serialNumber2;
controller2.CreateDevice();

controller3 = KCubeStepperControl();
controller3.LargeView = true;
controller3.Dock = DockStyle.Fill;
controller3.SerialNumber = serialNumber3;
controller3.CreateDevice();

%%
f = Form;
f.Controls.Add(controller1);
f.Controls.Add(controller2);
f.Show();

% Not great 
controller1.Dock = System.Windows.Forms.DockStyle.Bottom;
controller2.Dock = System.Windows.Forms.DockStyle.Top;


% Independent forms is maybe the way to go? Look into Container class as well.
f2 = Form;
f2.Controls.Add(controller3);
f2.Show();

f2.Height = 350; 
f2.Width = 950;
f1.Top = f2.Top + f2.Height + 10;

% Concatenation only with cells, not arrays
controllers = {controller1; controller2; controller3};
devices = cellfun(@(x) x.Device, controllers, 'UniformOutput', false);

% Need code to close the windows! clear all close all doesn't work