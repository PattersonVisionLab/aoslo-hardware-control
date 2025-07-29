classdef DeviceTypes

    enumeration
        KDC101
        KST201
        TDC001
    end

    methods
        function loadDeviceDLLs(obj, kinesisPath)
            arguments
                obj     DeviceTypes
                kinesisPath (1,1) string {isfolder} = "C:\Program Files\Thorlabs\Kinesis"
            end

            import ur.patterson.aoslo.motion.*;

            switch obj
                case DeviceTypes.KDC101
                    NET.addAssembly(fullfile(kinesisPath, 'Thorlabs.MotionControl.KCube.DCServoCLI.dll'));
                    NET.addAssembly(fullfile(kinesisPath, 'Thorlabs.MotionControl.KCube.DCServoUI.dll'));
                case DeviceTypes.KST201
                    NET.addAssembly(fullfile(kinesisPath, 'Thorlabs.MotionControl.KCube.StepperMotorCLI.dll'));
                    NET.addAssembly(fullfile(kinesisPath, 'Thorlabs.MotionControl.KCube.StepperMotorUI.dll'));
                case DeviceTypes.TDC001
                    NET.addAssembly(fullfile(kinesisPath, 'Thorlabs.MotionControl.TCube.DCServoCLI.dll'));
                    NET.addAssembly(fullfile(kinesisPath, 'Thorlabs.MotionControl.TCube.DCServoUI.dll'));
            end
        end

        function device = createController(obj, serialNumber)
            import System.Windows.Forms.*
            import System.Drawing.*

            serialNumber = convertStringsToChars(serialNumber);

            import Thorlabs.MotionControl.Controls.*
            import Thorlabs.MotionControl.DeviceManagerCLI.*
            import Thorlabs.MotionControl.DeviceManagerUI.*
            import Thorlabs.MotionControl.GenericMotorCLI.*

            import ur.patterson.aoslo.motion.*;

            switch obj
                case DeviceTypes.TDC001
                    device = createTDC001();
                case DeviceTypes.KDC101
                    device = createKDC101();
                case DeviceTypes.KST201
                    device = createKDC201();
            end

            device.LargeView = true;
            device.Dock = DockStyle.Fill;
            device.SerialNumber = serialNumber;
            try
               device.CreateDevice();
            catch ME
                cprintf('red', 'Error creating %s %s\n', char(obj), serialNumber);
                throwWarning(ME);
            end

            function controller = createTDC001()
                import Thorlabs.MotionControl.TCube.DCServoCLI.*
                import Thorlabs.MotionControl.TCube.DCServoUI.*
                controller = TCubeDCServoControl();
            end

            function controller = createKDC101()
                import Thorlabs.MotionControl.KCube.DCServoCLI.*
                import Thorlabs.MotionControl.KCube.DCServoUI.*
                controller = KCubeDCServoControl();
            end

            function controller = createKDC201()
                import Thorlabs.MotionControl.KCube.StepperMotorCLI.*
                import Thorlabs.MotionControl.KCube.StepperMotorUI.*
                controller = KCubeStepperControl();
            end
        end
    end

    methods (Static)
        function deviceType = getDeviceType(serialNumber)
            % Get the device type based on the serial number prefix

            import ur.patterson.aoslo.motion.*;

            serialNumber = convertStringsToChars(serialNumber);
            switch serialNumber(1:2)
                case '26'
                    deviceType = DeviceTypes.KST201;
                case '27'
                    deviceType = DeviceTypes.KDC101;
                case '83'
                    deviceType = DeviceTypes.TDC001;
                otherwise
                    error('Unknown device type for serial number: %s', serialNumber);
            end
        end

        function device = getDevice(deviceNET)
            import ur.patterson.aoslo.motion.*;

            deviceType = DeviceTypes.getDeviceType(char(deviceNET.SerialNo));

            switch deviceType
                case DeviceTypes.KDC101
                    device = KDC101(deviceNET);
                case DeviceTypes.KST201
                    device = KST201(deviceNET);
                case DeviceTypes.TDC001
                    device = TDC001(deviceNET);
            end
        end

        function controller = getController(serialNumber)
            import ur.patterson.aoslo.motion.*;

            obj = DeviceTypes.getDeviceType(serialNumber);
            controller = obj.createController(serialNumber);
        end
    end
end