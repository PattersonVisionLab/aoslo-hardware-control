classdef SLO < ur.cvs.SLO
% SLO
%
% See also:
%   ur.cvs.Network


    methods
        function obj = SLO()
            obj.Channels = [...
                ur.pattersonlab.aoslo.slo.SLOChannel("Reflectance", 796), ...
                ur.pattersonlab.aoslo.slo.SLOChannel("Fluorescence")];
        end


        function setImagingMode(obj, name)
            value = ur.pattersonlab.aoslo.slo.ImagingModes.init(name);
            obj.sendSloCommand("imaging_mode", value.getTabID());
        end

        function tf = sendSloCommand(obj, param, value)
            json.command = "set";
            json.name = param;
            json.value = value;
            json.timestamp = ur.cvs.gettimestamp();

            obj.Client.write(ur.cvs.Network.TopicSloCommand, jsonencode(json));

            tf = true;
        end
    end

    % Development methods
    methods (Hidden)
        function value = getClient(obj)
            %   Returns protected "Client" property: handle to mqtt client
            value = obj.Client;
        end
    end
end


