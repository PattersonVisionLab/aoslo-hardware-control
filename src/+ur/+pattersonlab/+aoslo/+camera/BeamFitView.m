classdef BeamFitView < handle

    properties
        Beam
        Camera
    end

    properties (Access = private)
        Figure
        Axes
        Layout
    end

    methods
        function obj = Coalignment_SingleCamera(beamName, varargin)
            obj.Beam = BeamFit(beamName, varargin{:});

            obj.createUi();
        end

        function connectCamera(obj)
        end

        function disconnectCamera(obj)
        end

        function pauseAcquisition(obj)
        end

        function startAcquisition(obj)
        end
    end

    % Callback methods
    methods (Access = private)
        function onPushedFit(obj, src, ~)
            obj.pauseAcquisition();
        end

        function onToggledAcquisition(obj, src, ~)
            if src.Text == "Play"
                src.Text = "Pause";
                obj.startAcquisition();
            else
                src.Text = "Play";
                obj.pauseAcquisition();
            end
        end
    end

    % Initialization methods
    methods (Access = private)
        function setupCamera(obj)
            % Import the DLLs

        end

        function createUi(obj)
            obj.Figure = uifigure("Name", "Coalignment");
            obj.Layout = uigridlayout(obj.Layout, [3 1]);

            obj.Axes = uiaxes(obj.Layout);
            buttonLayout = uigridlayout(obj.Layout, [1 2]);
            uibutton(buttonLayout, "Text", "Play", @obj.onToggledAcquisition);
            uibutton(buttonLayout, "Text", "Fit", "ButtonPushedFcn", @obj.onPushedFit);
            uitextarea(obj.Layout, "Value", "", "Tag", "FitResults", "Editable", false);
        end
    end
end
