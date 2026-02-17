function deviceManager = runForm(slo,deviceManager)

    arguments
        slo = ur.pattersonlab.aoslo.slo.SLO();
        deviceManager = ur.pattersonlab.aoslo.motion.ThorlabsMotorManager()
    end

    if slo.Status == ur.cvs.SloState.Offline
        slo.connect();
    end

    % Check if devices are connected

    form = ur.pattersonlab.aoslo.motion.KinesisForm(deviceManager);
    
    
end

