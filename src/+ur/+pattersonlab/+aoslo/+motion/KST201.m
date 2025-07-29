classdef KST201 < ur.pattersonlab.aoslo.motion.ThorlabsMotor

    methods
        function obj = KST201(device)
            obj@ur.pattersonlab.aoslo.motion.ThorlabsMotor(device);
            obj.DeviceType = DeviceTypes.KST201;
        end
    end
end