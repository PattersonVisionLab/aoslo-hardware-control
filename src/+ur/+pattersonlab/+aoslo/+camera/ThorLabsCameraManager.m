classdef ThorLabsCameraManager < handle

    properties
        tlCameraSDK
        cameraObjects

        serialNumbers
        cameraSerialNumbers
    end

    methods
        function obj = ThorLabsCameraManager()
            obj.initialize();
        end

        function cameraObj = createCameraObject(obj, cameraID)
            if nargin < 2
                cameraID = 1;
            end

            if isnumeric(cameraID)
                mustBeMember(cameraID, 1:numel(obj.cameraSerialNumbers));
            else
                cameraID = convertCharsToStrings(cameraID);
                cameraID = find(obj.cameraSerialNumbers == cameraID);
            end

            % Here's where we actually open the camera
            tlCamera = obj.tlCameraSDK.OpenCamera(char(obj.cameraSerialNumbers(cameraID)), false);

            if tlCamera.CameraSensorType == Thorlabs.TSI.TLCameraInterfaces.CameraSensorType.Bayer
                cameraObj = ThorLabsColorCMOS(tlCamera);
            else
                cameraObj = ThorLabsMonochromeCMOS(tlCamera);
            end

            obj.cameraObjects{cameraID} = cameraObj;
        end
    end

    methods (Access = private)
        function initialize(obj)
            NET.addAssembly([pwd, '\Thorlabs.TSI.TLCamera.dll']);
            disp('Dot NET assembly loaded.');

            obj.tlCameraSDK = Thorlabs.TSI.TLCamera.TLCameraSDK.OpenTLCameraSDK;

            % Get serial numbers of all connected cameras
            obj.serialNumbers = obj.tlCameraSDK.DiscoverAvailableCameras;
            disp([num2str(obj.serialNumbers.Count) ' camera(s) found']);
            obj.cameraSerialNumbers = [];
            for i = 1:obj.serialNumbers.Count
                obj.cameraSerialNumbers = string(obj.serialNumbers.Item(i-1));
            end

            obj.cameraObjects = cell(1, numel(obj.cameraSerialNumbers));
        end
    end
end