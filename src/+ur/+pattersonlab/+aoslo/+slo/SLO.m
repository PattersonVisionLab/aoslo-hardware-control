classdef SLO < dynamicprops
% SLO
%
% Methods:
%   connect
%   record(seconds)
%   start()
%   stop()
%
% See also:
%   ur.cvs.Network
%
% TODO: Inherit from ur.cvs.SLO class


    properties (SetAccess = protected)
        Status = ur.cvs.SloState.Offline;
        When
        TrackingOffset = [0, 0];
        TrackingUnits = "px";
        VideoFilename = "";
        Channels
    end

    properties (Access = public)
        Username
        Password
        Hostname = 'tcp://127.0.0.1';    % address of mqtt broker
        Port = 1883;
    end

    properties (Access = protected)
        Client
    end

    methods
        function obj = SLO()
            obj.Channels = [...
                ur.pattersonlab.aoslo.slo.SloChannel(),...
                ur.pattersonlab.aoslo.slo.SloChannel()];

            % Try to connect and warn if unsuccessful
            try
                obj.connect();
            catch ME
                throwWarning(ME);
                error('SLO:ConnectionFailed', 'Could not connect to SLO');
            end

            obj.Channels(1).Wavelength = 796;
        end

        function connect(obj)
            if (isempty(obj.Client))
                if (isempty(obj.Username))
                    obj.Client = mqttclient(obj.Hostname, Port=obj.Port);
                else
                    obj.Client = mqttclient(obj.Hostname, ...
                        Username=obj.Username, Password=obj.Password, ...
                        Port=obj.Port);
                end
            end
            obj.Client.subscribe(ur.cvs.Network.TopicSloStatus,...
                Callback=@obj.statusMessage);
            obj.Client.subscribe(ur.cvs.Network.TopicSloOnline,...
                Callback=@obj.onlineMessage);
            obj.Client.subscribe(ur.cvs.Network.TopicSloErrors,...
                Callback=@obj.errorMessage);
            obj.Client.subscribe(...
                ur.cvs.Network.TopicSloStatistics + "/" + ...
                ur.cvs.Network.FieldChannel1,...
                Callback=@obj.channel1StatisticsMessage);
            obj.Client.subscribe(ur.cvs.Network.TopicSloStatistics + "/" + ...
                ur.cvs.Network.FieldChannel2, Callback=@obj.channel2StatisticsMessage);
            obj.Client.subscribe(ur.cvs.Network.TopicSloSettings,...
                Callback=@obj.settingsMessage);
        end

        function success = record(obj, seconds)
            arguments
                obj
                seconds = 0;
            end

            if (obj.Status ~= ur.cvs.SloState.Running)
                success = false;
                return
            end

            json.command = ur.cvs.Network.CommandStartRecording;
            if (seconds > 0)
                json.seconds = ceil(seconds);
            end
            json.timestamp = ur.cvs.gettimestamp();
            topic=ur.cvs.Network.TopicSloCommand;
            obj.Client.write(topic, jsonencode(json));
            success = true;
        end

        function success = start(obj)
            if (obj.Status ~= ur.cvs.SloState.Stopped)
                success = false;
                return
            end

            json.command = ur.cvs.Network.CommandStart;
            json.timestamp = ur.cvs.gettimestamp();
            topic=ur.cvs.Network.TopicSloCommand;
            obj.Client.write(topic, jsonencode(json));
            success = true;
        end

        function success = stop(obj)
            if (obj.Status ~= ur.cvs.SloState.Running && ...
                    obj.Status ~= ur.cvs.SloState.Recording )
                success = false;
                return
            end

            json.command = ur.cvs.Network.CommandStop;
            topic=ur.cvs.Network.TopicSloCommand;

            if (obj.Status == ur.cvs.SloState.Recording)
                json.timestamp = ur.cvs.gettimestamp();
                json.command = ur.cvs.Network.CommandStopRecording;
                obj.Client.write(topic, jsonencode(json));
            end

            json.command = ur.cvs.Network.CommandStop;
            json.timestamp = ur.cvs.gettimestamp();
            obj.Client.write(topic, jsonencode(json));

            success = true;
        end
    end

    % Callback methods
    methods
        function statusMessage(obj, ~, data)
            json =  jsondecode(data);

            if isfield(json, ur.cvs.Network.FieldData)
                if (json.data == ur.cvs.Network.StatusRunning)
                    obj.Status = ur.cvs.SloState.Running;

                elseif (json.data == ur.cvs.Network.StatusStopped)
                    obj.Status = ur.cvs.SloState.Stopped;
                elseif (json.data == ur.cvs.Network.StatusRecording)
                    obj.Status = ur.cvs.SloState.Recording;
                end
            end
            % topic
            % data
        end

        function onlineMessage(obj, ~, data)
            json = jsondecode(data);

            if isfield(json, ur.cvs.Network.FieldData)
                if (json.data && obj.Status == ur.cvs.SloState.Offline)
                    obj.Status = ur.cvs.SloState.Stopped;
                elseif (~json.data)
                    obj.Status = ur.cvs.SloState.Offline;
                end
            end
        end

        function channel1StatisticsMessage(obj, ~, data)
            json = jsondecode(data);
            % data

            obj.Channels(1).When = json.timestamp;
            obj.Channels(1).StdDev = json.stddev;
            obj.Channels(1).MeanPixelValue = json.mean;
        end

        function channel2StatisticsMessage(obj, ~, data)
            json = jsondecode(data);
            % data

            obj.Channels(2).When = json.timestamp;
            obj.Channels(2).StdDev = json.stddev;
            obj.Channels(2).MeanPixelValue = json.mean;
        end

        function settingsMessage(obj, ~, data)
            json = jsondecode(data);

            if isfield(json, ur.cvs.Network.SettingVideoFilename)
                outstr = strrep(json.video_filename,"\","\\");
                obj.VideoFilename = outstr;
            end
        end

        function errorMessage(obj, ~, data)
            json = jsondecode(data);

            if isfield(json, ur.cvs.Network.FieldData)
                if (json.data && obj.Status == ur.cvs.SloState.Offline)
                    obj.Status = ur.cvs.SloState.Stopped;
                elseif (~json.data)
                    obj.Status = ur.cvs.SloState.Offline;
                end
            end
        end
    end

    % Development methods
    methods
        function value = getClient(obj)
            value = obj.Client;
        end
    end
end


