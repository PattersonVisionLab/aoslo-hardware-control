
%% Import DLLs
kinesisPath = 'C:\Program Files\Thorlabs\Kinesis\';
NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.DeviceManagerCLI.dll');
NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.GenericMotorCLI.dll');
NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.KCube.DCServoCLI.dll');

import Thorlabs.MotionControl.DeviceManagerCLI.*
import Thorlabs.MotionControl.GenericMotorCLI.*
import Thorlabs.MotionControl.KCube.DCServoCLI.*

%% Get list of available devices
DeviceManagerCLI.BuildDeviceList();
serialNumbers_NET = DeviceManagerCLI.GetDeviceList();
[serialNumbers, numDevices] = list2string(serialNumbers_NET);

fprintf('Found %d devices:\n', numDevices);
disp(serialNumbers);

%% Connect to controller
serialNumber = '27007514';
timeoutValue = 60000;

device = KCubeDCServo.CreateKCubeDCServo(serialNumber);
device.Connect(serialNumber);
device.WaitForSettingsInitialized(5000);
deviceInfo = device.GetDeviceInfo();
cprintf('blue', '\t%s connected: %s\n', ...
    deviceInfo.Name, deviceInfo.SerialNumberText);

motorSettings = device.LoadMotorConfiguration(serialNumber);
motorSettings.DeviceSettingsName = 'Z912B';
motorSettings.UpdateCurrentConfiguration();
motorDeviceSettings = device.MotorDeviceSettings;
device.SetSettings(motorDeviceSettings, true, false)


device.StartPolling(250);

device.EnableDevice();
pause(1);

if device.NeedsHoming
    device.Home(timeoutValue);
end

currentPosition = System.Decimal.ToDouble(device.Position);
if currentPosition > 0
    device.MoveTo(0, timeoutValue);
else
    device.MoveTo(10, timeoutValue);
end
currentPosition = System.Decimal.ToDouble(device.Position);
device.SetJogStepSize(System.Decimal(0.01));
jogStepSize = System.Decimal.ToDouble(device.GetJogStepSize());
device.MoveJog(MotorDirection.Forward, 60000);
cprintf('green', 'Device moved from %.3f to %.3f\n', currentPosition,...
    System.Decimal.ToDouble(device.Position));



currentPosition = System.Decimal.ToDouble(device.Position);
cprintf('Current position is %.3f\n', currentPosition);

device.StopPolling();
device.Disconnect();