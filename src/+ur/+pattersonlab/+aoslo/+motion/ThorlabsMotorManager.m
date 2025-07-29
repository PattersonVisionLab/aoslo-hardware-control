classdef ThorlabsMotorManager < handle
    % Wrapper for DeviceManagerCLI

    properties (SetAccess = private)
        serialNumbers
        numDevices
    end

    methods
        function obj = ThorlabsMotorManager(dllPath)
            arguments
                dllPath  (1,1)  string  {isfolder} = "C:\Program Files\Thorlabs\Kinesis"
            end

            import ur.pattersonlab.aoslo.*;

            motion.util.loadDLLs(dllPath);

            % Build an internal list of all connected devices
            obj.buildDeviceList();
            obj.getDeviceList();
        end
    end

    methods
        function [serialNumbers, numDevices] = getDeviceList(obj)
            % Gets list of all connected devices' serial numbers

            import Thorlabs.MotionControl.DeviceManagerCLI.*

            snList = DeviceManagerCLI.GetDeviceList();

            if snList.Count == 0
                cprintf('red', 'No devices found!\n');
                obj.numDevices = 0;
                return
            end

            [serialNumbers, numDevices] = list2string(snList);

            cprintf('blue', 'Identified %u devices: %s',...
                obj.numDevices, strjoin(serialNumbers, ", "));

            obj.serialNumbers = serialNumbers;
            obj.numDevices = numDevices;

        end

        function [newSerialNumbers, newCount] = checkForConnectionChanges(obj)
            % See if any devices have been added or removed

            import Thorlabs.MotionControl.DeviceManagerCLI.*

            updateList = DeviceManagerCLI.CheckForConnectionChanges();

            if updateList.Count == 0
                cprintf('blue', 'No additional devices found.\n');
                return
            end

            [newSerialNumbers, newCount] = list2string(snList);
            obj.serialNumbers = cat(1, obj.serialNumbers, newSerialNumbers);
            obj.numDevices = obj.numDevices + newCount;

            cprintf('blue', 'Identified %u new devices:', newCount);
            disp(newSerialNumbers);
        end
    end

    methods (Static, Access = private)
        function buildDeviceList()
            % Build an internal list of all connected devices
            % This should only be run once

            import Thorlabs.MotionControl.DeviceManagerCLI.*

            DeviceManagerCLI.BuildDeviceList();
        end
    end

    methods (Static)
        function tf = isDeviceConnected(deviceSerialNumber)
            import Thorlabs.MotionControl.DeviceManagerCLI.*
            tf = DeviceManagerCLI.IsDeviceConnected(deviceSerialNumber);
        end
    end


end