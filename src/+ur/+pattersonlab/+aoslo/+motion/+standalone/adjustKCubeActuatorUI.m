function [f,controller] = adjustKCubeActuatorUI(serialNumber, stageName)

    import System.Windows.Forms.*
    import Thorlabs.MotionControl.DeviceManagerCLI.*
    import Thorlabs.MotionControl.DeviceManagerUI.*
    import Thorlabs.MotionControl.GenericMotorCLI.*
    import Thorlabs.MotionControl.KCube.DCServoCLI.*
    import Thorlabs.MotionControl.KCube.DCServoUI.*
    import Thorlabs.MotionControl.Controls.*

    DeviceManagerCLI.BuildDeviceList();
    controller = KCubeDCServoControl();
    controller.LargeView = true;
    controller.Dock = DockStyle.Fill;
    controller.SerialNumber = serialNumber;

    if nargin > 1
        stageName = convertStringsToChars(stageName);
        motorSettings = controller.Device.LoadMotorConfiguration(serialNumber);
        motorSettings.DeviceSettingsName = System.String(stageName);
        motorSettings.UpdateCurrentConfiguration();
        controller.Device.SetSettings(motorDeviceSettings, true, false);
    end

    f = Form();
    f.Controls.Add(controller);
    f.Show();
end

