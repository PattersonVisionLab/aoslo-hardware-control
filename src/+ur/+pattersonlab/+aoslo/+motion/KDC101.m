classdef KDC101 < ur.pattersonlab.aoslo.motion.ThorlabsMotor
    % Wrapper for the .NET Thorlabs KDC101 stage controller

    methods
        function obj = KDC101(device)
            obj@ur.pattersonlab.aoslo.motion.ThorlabsMotor(device);
            obj.DeviceType = DeviceTypes.KDC101;
        end
    end

    methods (Access = private)
        function info = getDeviceInfo(obj)
            info = struct();
            if ~obj.isConnected
                return;
            end
            deviceInfo = obj.DEVICE.GetDeviceInfo();
            info.Name = string(deviceInfo.Name);
            info.Description = string(deviceInfo.Description);
            info.SerialNumber = string(deviceInfo.SerialNumberText);
            info.FirmwareVersion = deviceInfo.FirmwareVersion;
            info.SoftwareVersion = deviceInfo.SoftwareVersion;
            info.HardwareVersion = deviceInfo.HardwareVersion;
            info.DeviceType = deviceInfo.DeviceType;
        end

        function out = getVelocityParams(obj)
            out = struct();
            if ~obj.isConnected
                error('Device is not connected.');
            end
            velocityParams = obj.DEVICE.GetVelocityParams();
            out.Acceleration = System.Decimal.ToDouble(velocityParams.Acceleration);
            out.MinVelocity = System.Decimal.ToDouble(velocityParams.MinVelocity);
            out.MaxVelocity = System.Decimal.ToDouble(velocityParams.MaxVelocity);
        end

        function out = getJogParams(obj)
            out = struct();
            if ~obj.isValid
                return
            end
            jogParams = obj.DEVICE.GetJogParams();
            out.Acceleration = System.Decimal.ToDouble(jogParams.Acceleration);
            out.StepSize = obj.jogStepSize;
        end
    end
end