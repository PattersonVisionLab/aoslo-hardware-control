function [f,controller] = adjustKCubeActuatorUI(deviceManager, serialNumber, stageName)

    ur.pattersonlab.aoslo.motion.util.loadDLLs();

    import System.Windows.Forms.*
    import Thorlabs.MotionControl.DeviceManagerCLI.*
    import Thorlabs.MotionControl.DeviceManagerUI.*
    import Thorlabs.MotionControl.GenericMotorCLI.*
    import Thorlabs.MotionControl.KCube.DCServoCLI.*
    import Thorlabs.MotionControl.KCube.DCServoUI.*
    import Thorlabs.MotionControl.Controls.*

    

    if isempty(deviceManager)
        DeviceManagerCLI.BuildDeviceList();
    end
    controller = KCubeDCServoControl();
    controller.LargeView = true;
    controller.Dock = DockStyle.Fill;
    controller.SerialNumber = serialNumber;
    controller.CreateDevice()

    if nargin > 1
        stageName = convertStringsToChars(stageName);
        motorSettings = controller.Device.LoadMotorConfiguration(serialNumber);
        motorSettings.DeviceSettingsName = System.String(stageName);
        motorSettings.UpdateCurrentConfiguration();
        motorDeviceSettings = controller.Device.MotorDeviceSettings;
        controller.Device.SetSettings(motorDeviceSettings, true, false);
    end

    f = Form();
    f.Controls.Add(controller);
    f.Show();
end

