function DEVICE = singleKCubeConnect(serialNumber, stageName, kinesisPath)
% SINGLEKCUBECONNECT
%
% Description:
%   Standalone creation of a single KCube connection
% -------------------------------------------------------------------------

    loadDLLs(kinesisPath);
    import Thorlabs.MotionControl.DeviceManagerCLI.*
    import Thorlabs.MotionControl.GenericMotorCLI.*
    import Thorlabs.MotionControl.KCube.DCServoCLI.*


    DeviceManagerCLI.BuildDeviceList();

    DEVICE = KCubeDCServo.CreateKCubeDCServo(serialNumber);
    DEVICE.Connect(serialNumber);

    try
        DEVICE.WaitForSettingsInitialized(5000);

        % Running this because Thorlabs Github docs included it, 
        % but not sure if it's necessary...
        motorSettings = DDEVICE.LoadMotorConfiguration(serialNumber);
        motorSettings.DeviceSettingsName = stageName; % Already set?
        motorSettings.UpdateCurrentConfiguration(); % Returns false?
        motorDeviceSettings = DEVICE.MotorDeviceSettings;
        DEVICE.SetSettings(motorDeviceSettings, true, false);

        DEVICE.StartPolling(250);
        DEVICE.EnableDevice();
        pause(1);

        fprintf('Device %s is ready to go!\n', serialNumber);
    catch ME
        fprintf("Error has caused the program to stop, disconnecting..\n")
        throwWarning(ME);
    end