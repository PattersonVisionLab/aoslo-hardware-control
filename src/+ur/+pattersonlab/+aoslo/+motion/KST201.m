classdef KST201 < ur.pattersonlab.aoslo.motion.ThorlabsMotor

    methods
        function obj = KST201(device, stageName)
            if nargin < 2
                stageName = [];
            end
            obj@ur.pattersonlab.aoslo.motion.ThorlabsMotor(device, stageName);
            obj.DeviceType = ur.pattersonlab.aoslo.motion.DeviceTypes.KST201;
        end
    end

    methods (Static)
        function obj = init(serialNumber, stageName, deviceManager)
            ur.pattersonlab.aoslo.motion.util.loadDLLs();

            import Thorlabs.MotionControl.DeviceManagerCLI.*
            import Thorlabs.MotionControl.GenericMotorCLI.*
            import Thorlabs.MotionControl.KCube.StepperMotorCLI.*

            if nargin < 3 || isempty(deviceManager)
                DeviceManagerCLI.BuildDeviceList();
            end

            device = KCubeStepper.CreateKCubeStepper(serialNumber);
            device.Connect(serialNumber);
                        
            device.WaitForSettingsInitialized(5000);
            device.StartPolling(250);

            pause(0.5);
            device.EnableDevice();
            pause(0.5);

            obj = ur.pattersonlab.aoslo.motion.KST201(device, stageName);
        end
    end
end
