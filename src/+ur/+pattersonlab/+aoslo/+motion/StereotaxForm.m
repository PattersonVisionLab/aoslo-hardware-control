classdef StereotaxForm < ur.pattersonlab.aoslo.motion.KinesisControllerForm

    properties
        formSize = [1322 700]
        layoutGrid = [4 2]
    end

    properties (Hidden, Constant)
        REF_XYZ = ["83857268", "83855258", "26250117"]
        VIS_XYZ = ["83848285", "83848287", "83848308"]
        SOURCES = ["27006819", "83850011", "83849957"]
    end

    methods
        function obj = StereotaxForm(deviceManager)
            arguments
                deviceManager = [];
            end
            obj@ur.pattersonlab.aoslo.motion.KinesisControllerForm(deviceManager, 3);
            if nargin < 1
                obj.DeviceManager = ur.pattersonlab.aoslo.motion.ThorlabsMotorManager();
            else
                obj.DeviceManager = deviceManager;
            end
        end
    end

    methods
        function createForm(obj)
            import System.Windows.Forms.*
            import System.Drawing.*
            import ur.pattersonlab.aoslo.motion.*;

            createForm@ur.pattersonlab.aoslo.motion.KinesisControllerForm(obj)

            rowSizes = [4 32 32 32];
            columnSizes = [6 92];

            for i = 1:numel(rowSizes)
                obj.Layout.RowStyles.Add(RowStyle(SizeType.Percent, rowSizes(i)));
            end

            for i = 1:numel(columnSizes)
                obj.Layout.ColumnStyles.Add(ColumnStyle(SizeType.Percent, columnSizes(i)));
            end

            % Create the XYZ labels
            controllerTypes = ["X", "Pitch", "Yaw"];
            for i = 1:numel(controllerTypes)
                iLabel = KinesisForm.labelMaker(controllerTypes(i), 24);
                obj.Layout.Controls.Add(iLabel, 0, i);
            end
            channelNames = "Stereotax";
            for i = 1:numel(channelNames)
                iLabel = KinesisForm.labelMaker(channelNames(i), 16);
                obj.Layout.Controls.Add(iLabel, i, 0);
            end

            fprintf('Adding controls... ');
            for i = 1:numel(obj.STEREOTAX)
                refController = DeviceTypes.getController(obj.STEREOTAX(i));
                obj.Controllers{i} = refController;
                obj.Layout.Controls.Add(refController, 1, i);

                fprintf('%s ...', controllerTypes(i));
            end

            fprintf('Done\n');
        end
    end

    methods (Static)
        function lbl = labelMaker(txt, fontSize, rgbValue)
            import System.Windows.Forms.*
            import System.Drawing.*
            lbl = Label();
            lbl.Text = txt;
            lbl.Dock = DockStyle.Fill;
            lbl.TextAlign = ContentAlignment.MiddleCenter;
            lbl.Font = Font('Arial', fontSize, FontStyle.Bold);
            if nargin > 2
                [R, G, B] = rgb2argb(rgbValue);
                lbl.BackColor = Color.FromArgb(R, G, B);
            end
        end
    end
end
