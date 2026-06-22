classdef KDC101 < ur.pattersonlab.aoslo.motion.ThorlabsMotor
    % Wrapper for the .NET Thorlabs KDC101 stage controller

    methods
        function obj = KDC101(device)
            obj@ur.pattersonlab.aoslo.motion.ThorlabsMotor(device);
            import ur.pattersonlab.aoslo.motion.*
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

    end
end
