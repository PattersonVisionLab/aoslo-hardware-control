

%% Load Assemblies
NET.addAssembly('System.Windows.Forms');
NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.DeviceManagerCLI.dll');
NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.DeviceManagerUI.dll');
NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.GenericMotorCLI.dll');
NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.KCube.DCServoCLI.dll');
NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.KCube.DCServoUI.dll');
NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.Controls.dll');

import System.Windows.Forms.*;
import Thorlabs.MotionControl.DeviceManagerCLI.*
import Thorlabs.MotionControl.DeviceManagerUI.*
import Thorlabs.MotionControl.GenericMotorCLI.*
import Thorlabs.MotionControl.KCube.DCServoCLI.*
import Thorlabs.MotionControl.KCube.DCServoUI.*
import Thorlabs.MotionControl.Controls.*

serialNumber = '27007514';

f = Form;

DeviceManagerCLI.BuildDeviceList();

controller = KCubeDCServoControl();
controller.LargeView = true;
controller.Dock = DockStyle.Fill;
controller.SerialNumber = serialNumber;

controller.CreateDevice();

f.Controls.Add(controller);
f.Show();

