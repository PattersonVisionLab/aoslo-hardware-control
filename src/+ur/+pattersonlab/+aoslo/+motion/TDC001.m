classdef TDC001 < ur.pattersonlab.aoslo.motion.ThorlabsMotor

    methods
        function obj = TDC001(device)
            netClass = "Thorlabs.MotionControl.TCube.DCServoCLI.TCubeDCServo";
            assert(isa(device, netClass), sprintf("Wrong class: %s", class(device)));

            obj@ur.pattersonlab.aoslo.motion.ThorlabsMotor(device);

            obj.DeviceType = DeviceTypes.TDC001;
        end
    end
end