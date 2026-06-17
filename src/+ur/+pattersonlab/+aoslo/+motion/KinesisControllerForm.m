classdef KinesisControllerForm < handle

    properties (SetAccess = private)
        DeviceManager
        numControllers
    end

    properties (SetAccess = protected)
        Controllers
        Form            % System.Windows.Forms.Form
        Layout
    end

    properties (Dependent)
        Devices
        NetDevices
    end

    properties (Abstract)
        formSize
        layoutGrid
    end

    properties (Hidden, Constant)
        REF_XYZ = ["83857268", "83855258", "27270129"]
        VIS_XYZ = ["83848285", "83848287", "83848308"]
        SOURCES = ["27006819", ""83849957", "83850011"]
        STEREOTAX = ["27007514", "27007530", "27007586"]
    end

    methods
        function obj = KinesisControllerForm(deviceManager, numControllers)
            if isempty(obj.DeviceManager)
                obj.DeviceManager = ur.pattersonlab.aoslo.motion.ThorlabsMotorManager();
            else
                obj.DeviceManager = deviceManager;
            end
            obj.numControllers = numControllers;

            obj.Controllers = cell(obj.numControllers, 1);
            obj.createForm();
        end
    end

    methods  % Dependent set/get methods
        function value = get.NetDevices(obj)
            if isempty(obj.Controllers)
                value = [];
            else
                value = cellfun(@(x) x.Device, obj.Controllers,...
                    'UniformOutput', false);
            end
        end

        function value = get.Devices(obj)
            import ur.pattersonlab.aoslo.motion.*;

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
            obj.Controllers = cell(obj.numControllers,1);
            obj.Form = [];
            obj.Layout = [];
        end
    end

    methods (Access = protected)
        function createForm(obj)
            NET.addAssembly('System.Drawing');
            NET.addAssembly('System.Windows.Forms');

            import System.Windows.Forms.*
            import System.Drawing.*
            import ur.pattersonlab.aoslo.motion.*;

            obj.Form = Form(); %#ok<CPROP>
            obj.Form.Text = 'Kinesis UI';
            obj.Form.Width = obj.formSize(1);
            obj.Form.Height = obj.formSize(2);

            obj.Layout = TableLayoutPanel();
            obj.Layout.Dock = DockStyle.Fill;
            obj.Layout.ColumnCount = obj.layoutGrid(2);
            obj.Layout.RowCount = obj.layoutGrid(1);

            obj.Form.Controls.Add(obj.Layout);
            obj.Form.Show();
        end

        function addRowsAndColumns(obj, rowSizes, columnSizes)
            import System.Windows.Forms.*
            import System.Drawing.*

            for i = 1:numel(rowSizes)
                obj.Layout.RowStyles.Add(RowStyle(SizeType.Percent, rowSizes(i)));
            end

            for i = 1:numel(columnSizes)
                obj.Layout.ColumnStyles.Add(ColumnStyle(SizeType.Percent, columnSizes(i)));
            end
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
