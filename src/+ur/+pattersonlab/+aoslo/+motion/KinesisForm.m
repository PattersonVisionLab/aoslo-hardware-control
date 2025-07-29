classdef KinesisForm < handle

    properties
        DeviceManager
        Controllers
    end

    properties
        Form            % System.Windows.Forms.Form
        Layout
    end

    properties (Dependent)
        Devices
        NetDevices
    end

    properties (Hidden, Constant)
        REF_XYZ = ["83857268", "83855258", "26250117"]
        VIS_XYZ = ["83848285", "83848287", "83848308"]
    end

    methods
        function obj = KinesisForm(deviceManager)
            if nargin < 1
                obj.DeviceManager = ur.pattersonlab.aoslo.motion.ThorlabsMotorManager();
            else
                obj.DeviceManager = deviceManager;
            end
            obj.Controllers = cell(6, 1);
            obj.createForm();
        end

        function value = get.NetDevices(obj)
            if isempty(obj.Controllers)
                value = [];
            else
                value = cellfun(@(x) x.Device, obj.Controllers,...
                    'UniformOutput', false);
            end
        end

        function value = get.Devices(obj)
            if isempty(obj.Controllers)
                value = [];
            else
                value = cellfun(@(x) DeviceTypes.getDevice(x), obj.NetDevices,...
                    'UniformOutput', false);
            end
        end
    end

    methods
        function closeForm(obj)
            cellfun(@(x) x.CloseDevice(), obj.Controllers);
            obj.Form.Close();
            obj.Controllers = cell(6,1);
            obj.Form = [];
            obj.Layout = [];
        end

        function createForm(obj)
            NET.addAssembly('System.Drawing');
            NET.addAssembly('System.Windows.Forms');

            import System.Windows.Forms.*
            import System.Drawing.*

            obj.Form = Form(); %#ok<CPROP>
            obj.Form.Text = 'Kinesis UI';
            obj.Form.Width = 1322;
            obj.Form.Height = 700;

            obj.Layout = TableLayoutPanel();
            obj.Layout.Dock = DockStyle.Fill;
            obj.Layout.ColumnCount = 3;
            obj.Layout.RowCount = 4;

            obj.Form.Controls.Add(obj.Layout);
            obj.Form.Show();

            rowSizes = [4 32 32 32];
            columnSizes = [6 47 47];

            for i = 1:numel(rowSizes)
                obj.Layout.RowStyles.Add(RowStyle(SizeType.Percent, rowSizes(i)));
            end

            for i = 1:numel(columnSizes)
                obj.Layout.ColumnStyles.Add(ColumnStyle(SizeType.Percent, columnSizes(i)));
            end

            % Create the XYZ labels
            controllerTypes = ["X", "Y", "Z"];
            for i = 1:numel(controllerTypes)
                iLabel = KinesisForm.labelMaker(controllerTypes(i), 24);
                obj.Layout.Controls.Add(iLabel, 0, i);
            end
            channelNames = ["Reflectance", "Fluorescence"];
            for i = 1:numel(channelNames)
                iLabel = KinesisForm.labelMaker(channelNames(i), 16);
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
