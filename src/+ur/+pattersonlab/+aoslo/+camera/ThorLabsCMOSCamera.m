classdef ThorLabsCMOSCamera < handle

    events
        StoppedCamera
        ClosedCamera
        OpenedCamera
        NewFrame
    end

    properties (SetAccess = private)
        tlCamera
    end

    properties (SetAccess = protected)
        lastFrame
    end

    properties
        currentCamera
        isColorCamera
        hasHardwareTrigger
        acquisitionMode
        bitDepth
        %readoutSpeed
        %gainRange
        %blackLevelRange
    end

    properties
        doStopAcquisition = false;
    end

    properties (Dependent)
        gain            uint32
        blackLevel      uint32
        readoutSpeed    {mustBeMember(readoutSpeed, [20 40])}
        % Note: exposure internally represented with us but ms seemed easier
        exposureTime    uint32      % Milliseconds
    end

    properties (Hidden, Constant)
        pixelSize = [3.45 3.45];
        numPixels = [1440 1080];    % horizontal, vertical
    end

    methods
        function obj = ThorLabsCMOSCamera(tlCamera)
            obj.tlCamera = tlCamera;

            obj.open();
        end
    end

    methods
        function stop(obj)
            if isvalid(obj.tlCamera)
                disp('Stopping camera');
                if obj.tlCamera.IsArmed
                    obj.tlCamera.Disarm();
                end
                notify(obj, 'StoppedCamera');
            end
        end

        function close(obj)
            if ~isempty(obj.tlCamera) && isvalid(obj.tlCamera)
                disp('Closing camera');
                if obj.tlCamera.IsArmed
                    obj.tlCamera.Disarm();
                end
                obj.tlCamera.Dispose();
                delete(obj.tlCamera);
                notify(obj, 'ClosedCamera');
            end
        end
    end

    methods
        function value = get.gain(obj)
            value = obj.tlCamera.Gain;
        end

        function value = get.blackLevel(obj)
            value = obj.tlCamera.BlackLevel;
        end

        function value = get.exposureTime(obj)
            value = obj.tlCamera.ExposureTime_us / 1000;
        end

        function value = get.readoutSpeed(obj)
            value = obj.tlCamera.DataRate;
        end
    end

    methods
        function setGain(obj, value)
            arguments
                obj
                value       (1,1)   {mustBeNumeric, mustBeNonnegative}
            end

            gainRange = obj.tlCamera.GainRange;
            if value > gainRange.Maximum
                value = gainRange.Maximum;
                    warning('setGain:InputOutOfRange', 'Gain set to maximum value');
            else
                if value < gainRange.Minimum
                    value = gainRange.Minimum;
                    warning('setGain:InputOutOfRange', 'Gain set to minimum value');
                end
            end
            obj.tlCamera.Gain = uint32(value);
        end

        function setBlackLevel(obj, value)
            arguments
                obj
                value       (1,1)   {mustBeNumeric, mustBeNonnegative}
            end

            blackLevelRange = obj.tlCamera.BlackLevelRange;

            if value > blackLevelRange.Maximum
                value = blackLevelRange.Maximum;
                warning('setBlackValue:InputOutOfRange', 'Black level set to maximum value');
            else
                if value < blackLevelRange.Minimum
                    value = blackLevelRange.Minimum;
                    warning('setBlackValue:InputOutOfRange', 'Black level set to minimum value');
                end
            end
            obj.tlCamera.BlackLevel = uint32(value);
        end

        function setExposureTime(obj, value)
            % SETEXPOSURETIME  Set the exposure time of the camera
            %
            % Inputs:
            %   value:  The exposure time in milliseconds
            % --------------------------------------------------------------

            arguments
                obj
                value       (1,1)   {mustBeNumeric, mustBeNonnegative}
            end

            obj.tlCamera.ExposureTime_us = uint32(value * 1000);
        end

        function setReadoutSpeed(obj, speed)
            % SETREADOUTSPEED  Set the readout speed of the camera
            %
            % Inputs:
            %   speed:  The readout speed in MHz (20 or 40)
            % --------------------------------------------------------------

            arguments
                obj
                speed       (1,1)   {mustBeMember(speed, [20 40])}
            end

            switch speed
                case 20
                    obj.tlCamera.DataRate = Thorlabs.TSI.TLCameraInterfaces.DataRate.ReadoutSpeed20MHz;
                case 40
                    obj.tlCamera.DataRate = Thorlabs.TSI.TLCameraInterfaces.DataRate.ReadoutSpeed40MHz;
            end
        end
    end

    methods
        function startCamera(obj)

            % Arm and issue software trigger if not in hardware trigger mode
            if obj.tlCamera.OperationMode ~= Thorlabs.TSI.TLCameraInterfaces.OperationMode.HardwareTriggered
                obj.tlCamera.IssueSoftwareTrigger;
            end

            keepRunning = true;
            obj.doStopAcquisition = false;
            while keepRunning
                % Check if image buffer has been filled
                if isvalid(obj.tlCamera) && obj.tlCamera.NumberOfQueuedFrames > 0
                    imageFrame = obj.tlCamera.GetPendingFrameOrNull;
                    if ~isempty(imageFrame)
                        obj.processFrame(imageFrame);
                        delete(imageFrame);
                    end
                end
                drawnow();

                % TODO: Check controller for stop acquisition
                if obj.doStopAcquisition
                    keepRunning = false;
                end
                delete(imageFrame);
            end

            % Stop the camera
            obj.stop();
        end

        function processFrame(obj, imageFrame)
            imageData = imageFrame.ImageData.ImageData_monoOrBGR;
            imageHeight = imageFrame.ImageData.Height_pixels;
            imageWidth = imageFrame.ImageData.Width_pixels;

            obj.lastFrame = reshape(uint16(imageData), [imageWidth, imageHeight]);
            notify(obj, 'NewFrame');

        end
    end

    methods
        function fullStop(obj)
            % Close TLCameraSDK
            if ~isempty(obj.tlCameraSDK)
                obj.tlCameraSDK.Dispose;
                delete(obj.tlCameraSDK);
            end

            % TODO: Close the color processing, if needed
        end

        function closeCamera(obj)
            if ~isempty(obj.tlCamera) && isvalid(obj.tlCamera)
                disp('Closing the camera');
                if obj.tlCamera.IsArmed
                    obj.tlCamera.Disarm;
                end
                obj.tlCamera.Dispose;
                delete(obj.tlCamera);
            end
        end

        function open(obj)

            % Get some properties of the camera that was opened
            obj.tlCamera.FramesPerTrigger = 0;  % 0 = unlimited
            obj.acquisitionMode = "continuous";
            obj.bitDepth = int32(obj.tlCamera.BitDepth);

            obj.hasHardwareTrigger = obj.tlCamera.GetIsOperationMode(Thorlabs.TSI.TLCameraInterfaces.OperationMode.HardwareTriggered);
            if obj.hasHardwareTrigger
                obj.tlCamera.OperationMode = Thorlabs.TSI.TLCameraInterfaces.OperationMode.SoftwareTriggered;
                obj.tlCamera.TriggerPolarity = Thorlabs.TSI.TLCameraInterfaces.TriggerPolarity.ActiveHigh;
            end
        end
    end
end