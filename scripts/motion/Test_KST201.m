
devCLI = NET.addAssembly(fullfile(kinesisPath,...
    'Thorlabs.MotionControl.DeviceManagerCLI.dll'));
genCLI = NET.addAssembly(fullfile(kinesisPath,...
    'Thorlabs.MotionControl.GenericMotorCLI.dll'));
motCLI = NET.addAssembly(fullfile(kinesisPath,...
    'Thorlabs.MotionControl.KCube.StepperMotorCLI.dll'));

import Thorlabs.MotionControl.DeviceManagerCLI.*;
import Thorlabs.MotionControl.GenericMotorCLI.*;
import Thorlabs.MotionControl.KCube.StepperMotorCLI.*;

serialNumber = '260006239';
timeoutValue = 20000;

DeviceManagerCLI.BuildDeviceList();

device = KCubeStepper.CreateKCubeStepper(serialNumber);
device.Connect(serialNumber);

deviceInfo = device.GetDeviceInfo();
disp(deviceInfo.Description);

device.WaitForSettingsInitialized(5000);
device.StartPolling(250);

pause(1);
device.EnableDevice();
pause(1);

deviceConfig = device.LoadMotorConfiguration(device.DeviceID);

% Set homing velocity
device.SetHomingVelocity(0.5);
homingVelocity = device.GetHomingVelocity();
disp("Homing velocity set to: ");
disp(System.Decimal.ToDouble(homingVelocity));

% Home the stage
device.Home(timeoutValue);

% Move the stage
device.MoveTo(1.0, timeoutValue);

% Disconnect the device
device.StopPolling();
device.Disconnect();

