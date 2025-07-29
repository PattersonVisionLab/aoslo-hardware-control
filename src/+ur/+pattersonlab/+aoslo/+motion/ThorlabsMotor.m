classdef (Abstract) ThorlabsMotor < handle & matlab.mixin.Heterogeneous

    events
        Jogged
        Moved
        Connected
        Disconnected
        ChangedStepSize
        TriggeredWarning
        ViewOpened
    end

    properties (SetAccess = private)
        DEVICE               % .NET Device
    end

    properties (SetAccess = protected)
        DeviceType
    end

    properties (SetAccess = private)
        serialNumber
        stageName           % stage name (e.g., 'Z912B')
        controllerName      % controller device name ('KDC101')
        aliasName           % user-defined name for controller
    end

    properties (Dependent)
        position
        jogStepSize
        isValid

        isConnected
        isEnabled
        isHomed
        isBusy
    end

    properties (Hidden, Constant)
        TIMEOUT_VALUE = 60000;
    end

    methods
        function obj = ThorlabsMotor(device)
            obj.DEVICE = device;
            obj.serialNumber = string(obj.DEVICE.SerialNo);

            % Grab some useful metadata
            deviceInfo = obj.DEVICE.GetDeviceInfo();
            obj.controllerName = string(deviceInfo.Name);

            obj.stageName = string(obj.DEVICE.MotorConfiguration.DeviceSettingsName);
            obj.aliasName = string(obj.DEVICE.MotorConfiguration.DeviceAlias);
        end
    end

    % Core methods
    methods
        function identify(obj)
            obj.DEVICE.IdentifyDevice();
        end

        function jog(obj, whichDir)
            % JOG
            %
            % Kinesis Methods:
            % Thorlabs.MotionControl.KCube.DCServoCLI.KCubeDCServo.MoveJog
            % -------------------------------------------------------------
            arguments
                obj
                whichDir (1,1) string {mustBeMember(whichDir, ["up", "down", "foward", "backward"])}
            end

            % Contains MotorDirection enum
            import Thorlabs.MotionControl.GenericMotorCLI.*

            try
                switch whichDir
                    case {"up", "forward"}
                        obj.DEVICE.MoveJog(MotorDirection.Forward, obj.TIMEOUT_VALUE);
                    case {"down", "backward"}
                        obj.DEVICE.MoveJog(MotorDirection.Backward, obj.TIMEOUT_VALUE);
                end
                notify(obj, 'Jogged');
            catch ME
                throwWarning(ME);
            end
        end

        function move(obj, newPosition)
            arguments
                obj
                newPosition   (1,1)      double {mustBeNonnegative}
            end

            try
                obj.DEVICE.MoveTo(newPosition, obj.TIMEOUT_VALUE);
                notify(obj, 'Moved')
            catch ME
                throwWarning(ME);
            end
        end

        function home(obj)
            try
                isDone = obj.DEVICE.InitializeWaitHandler();
                obj.DEVICE.Home(isDone);
                obj.DEVICE.Wait(obj.TIMEOUT_VALUE);
                notify(obj, 'Homed');
            catch ME
                cprintf('red', 'Device did not home');
                throwWarning(ME);
            end
        end

        function disconnect(obj)
            obj.DEVICE.StopPolling();
            obj.DEVICE.Disconnect();
            notify(obj, 'Disconnected');
        end
    end

    % Utility methods
    methods
        function value = getPosition(obj)
            if ~isscalar(obj)
                value = arrayfun(@(x) x.position, obj);
            else
                value = obj.position;
            end
        end

        function setJogStepSize(obj, value)
            % Thorlabs.MotionControl.GenericMotorCLI.ControlParameters.JogParameters
            arguments
                obj
                value   (1,1)   double  {mustBeNonnegative}
            end

            jogParams = obj.DEVICE.getJogParams;
            jogParams.StepSize = System.Double(value);
            obj.DEVICE.SetJogParams(jogParams);
        end

        function info = getDeviceAttributes(obj)
            info = struct();
            if ~obj.isConnected
                error('Device is not connected');
            end
            info.DeviceInfo = obj.getDeviceInfo();
            info.VelocityParams = obj.getVelocityParams();
            info.JogParams = obj.getJogParams();
            info.Backlash = System.Decimal.ToDouble(obj.DEVICE.Backlash);
        end
    end

    % Dependent set/get methods
    methods
        function tf = get.isValid(obj)
            if isempty(obj.DEVICE)
                tf = false;
            else
                tf = obj.isConnected & obj.isEnabled;
            end
        end

        function tf = get.isConnected(obj)
            tf = obj.DEVICE.IsConnected;
        end

        function tf = get.isEnabled(obj)
            tf = obj.DEVICE.IsEnabled;
        end

        function tf = get.isHomed(obj)
            tf = ~obj.DEVICE.Status.IsHomed;
        end

        function tf = get.isBusy(obj)
            tf = obj.DEVICE.IsDeviceBusy();
        end

        function value = get.position(obj)
            value = decimal2double(obj.DEVICE.Position);
        end

        function value = get.jogStepSize(obj)
            value = decimal2double(obj.DEVICE.GetJogStepSize());
        end
    end

end
