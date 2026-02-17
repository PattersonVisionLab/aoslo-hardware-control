function [form1, form2, slo,deviceManager] = runForm(slo,deviceManager)

    arguments
        slo = []%ur.pattersonlab.aoslo.slo.SLO();
        deviceManager = []% ur.pattersonlab.aoslo.motion.ThorlabsMotorManager()
    end


    if isempty(deviceManager)
        ur.pattersonlab.aoslo.motion.util.loadDLLs();
        deviceManager = ur.pattersonlab.aoslo.motion.ThorlabsMotorManager();
    end
    %if slo.Status == ur.cvs.SloState.Offline
    %    slo.connect();
    %end

    % Check if devices are connected

    form1 = ur.pattersonlab.aoslo.motion.KinesisForm(deviceManager);

    [form2, ~] = ur.pattersonlab.aoslo.motion.standalone.adjustKCubeActuatorUI( ...
        deviceManager, "27007514", "Z925B");
    
end

