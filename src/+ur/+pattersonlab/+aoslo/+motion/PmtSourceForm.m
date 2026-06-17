classdef PmtSourceForm < ur.pattersonlab.aoslo.motion.KinesisControllerForm

    properties
        formSize = [1322 700]
        layoutGrid = [4 4]
    end

    methods
        function obj = PmtSourceForm(deviceManager)
            arguments 
                deviceManager = []
            end

            obj@ur.pattersonlab.aoslo.motion.KinesisControllerForm(deviceManager, 6);
        end
    end

    methods (Access = protected)

        function createForm(obj)
            import System.Windows.Forms.*
            import System.Drawing.*
            import ur.pattersonlab.aoslo.motion.*;
            createForm@ur.pattersonlab.aoslo.motion.KinesisControllerForm(obj);

            rowSizes = [4 32 32 32];
            columnSizes = [4 32 32 32];
            obj.addRowsAndColumns(rowSizes, columnSizes);

            % Create the XYZ labels
            controllerTypes = ["X", "Y", "Z"];
            for i = 1:numel(controllerTypes)
                iLabel = obj.labelMaker(controllerTypes(i), 24);
                obj.Layout.Controls.Add(iLabel, 0, i);
            end
            channelNames = ["Reflectance", "Fluorescence", "Source"];
            for i = 1:numel(channelNames)
                iLabel = obj.labelMaker(channelNames(i), 16);
                obj.Layout.Controls.Add(iLabel, i, 0);
            end

            fprintf('Adding controls... ');
            for i = 1:numel(obj.REF_XYZ)
                refController = DeviceTypes.getController(obj.REF_XYZ(i));
                obj.Controllers{i} = refController;
                obj.Layout.Controls.Add(refController, 1, i);

                visController = DeviceTypes.getController(obj.VIS_XYZ(i));
                obj.Controllers{i+3} = visController;
                obj.Layout.Controls.Add(visController, 2, i);

                sourceController = DeviceTypes.getController(obj.SOURCES(i));
                obj.Controllers{i+9} = sourceController;
                obj.Layout.Controls.Add(sourceController, 4, i);

                fprintf('%s ...', controllerTypes(i));
            end

            fprintf('Done\n');
        end
    end
end
