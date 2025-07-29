classdef OptimizationRoutine < handle

    properties (SetAccess = private)
        Form
        SloChannel
        targets
        TargetDevices
        serialNumbers
        startingPosition
        bestPosition
    end

    properties
        searchWindow        % Upper + lower bounds around current position
        maxIterations
    end

    properties (Dependent)
        Devices
        DeviceManager
        Controllers
    end

    properties (SetAccess = private)
        evalCount = 0
        callHistory
        Table
    end

    properties (Hidden, Constant)
        INTEGRATION_FRAMES = 10;
        REF_XYZ = ["83857268", "83855258", "26250117"]
        VIS_XYZ = ["83848285", "83848287", "83848308"]
    end

    methods
        function obj = OptimizationRoutine(form, channel, targets, opts)
            arguments
                form
                channel
                targets {mustBeMember(targets, ["RefXY", "RefZ", "RefXYZ", "VisXY", "VisZ"])}
                opts.SearchWindow = 0.01
                opts.MaxIterations = 200
            end

            obj.Form = form;
            obj.SloChannel = channel;
            obj.targets = targets;

            obj.maxIterations = opts.MaxIterations;
            obj.searchWindow = opts.SearchWindow;

            switch targets
                case "RefXYZ"
                    obj.TargetDevices = obj.Form.Devices(1:3);
                case "RefXY"
                    obj.TargetDevices = obj.Form.Devices(1:2);
                case "RefZ"
                    obj.TargetDevices = obj.Form.Devices(3);
            end
            if iscell(obj.TargetDevices)
                obj.TargetDevices = horzcat(obj.TargetDevices{:})';
            end
            obj.logStartPoint();
        end
    end

    methods
        function value = get.DeviceManager(obj)
            value = obj.Form.DeviceManager;
        end

        function value = get.Controllers(obj)
            value = obj.Form.Controllers;
        end

        function value = get.Devices(obj)
            value = obj.Form.Devices;
        end
    end

    methods
        function pos = getCurrentPosition(obj)
            pos = obj.TargetDevices.getPosition();
        end

        function logStartPoint(obj)
            obj.startingPosition = obj.getCurrentPosition()';
        end

        function movePosition(obj, pos)
            for i = 1:numel(obj.TargetDevices)
                obj.TargetDevices(i).move(pos(i));
                % Move corresponding device to position i
            end
            pause(0.037);
        end

        function pixelValue = getMeanPixelValue(obj)
            [~, mu] = obj.SloChannel.getFrameValues(obj.INTEGRATION_FRAMES);
            pixelValue = mean(mu);
        end
    end

    methods
        function [optimalPosition, fVal, exitFlag, output] = optimize1D(obj)
            [startPoint, LB, UB] = obj.prepOptimization();

            opts = optimset("Display", "iter",...
                "MaxIter", obj.maxIterations,...
                "MaxFunEvals", obj.maxIterations,...
                "TolX", 0.001, "TolFun", 0.01,...
                "PlotFcn", @optimplotfval);

            [optimalPosition, fVal, exitFlag, output] = fminbnd(...
                @obj.objectiveFunction, startPoint, LB, UB, opts);
        end

        function [optimalPosition, fVal, exitFlag, output] = optimizeND(obj)

            [startPoint, LB, UB] = obj.prepOptimization();
            opts = optimset("Display", "iter",...
                "MaxIter", obj.maxIterations,...
                'MaxFunEvals', obj.maxIterations,...
                'TolX', 0.001, 'TolFun', 0.01,...
                "PlotFcn", {@optimplotfval, @plotFcn});

            [optimalPosition, fVal, exitFlag, output] = fminsearchbnd(...
                @obj.objectiveFunction, startPoint, LB, UB, opts);

            obj.bestPosition = optimalPosition;

            obj.Table = table(obj.callHistory(1), obj.callHistory(end), obj.callHistory(2:end-1),...
                'VariableNames', {'Iteration', 'Value', 'Position'});

            function stop = plotFcn(~, ~, state, varargin)
                stop = false;
                switch state
                    case 'init'
                        hold on;
                        axis equal
                        colormap('jet'); colorbar()
                        rectangle('Position',[startPt-obj.searchWindow/2, ...
                                                obj.searchWindow,obj.searchWindow],...
                                    'LineStyle', '--');
                        plot(startPt(1), startPt(2), 'xk', 'LineWidth', 1, 'MarkerSize', 10);
                        axis tight
                    case 'iter'
                        scatter( ...
                            obj.callHistory(end,end-2), obj.callHistory(end,end-1), ...
                            70, obj.callHistory(end,end),'.');
                    case 'done'
                        title(sprintf('Position: %.4f %.4f', obj.bestPosition));
                        c = clim();
                        clim([0 c(2)]);
                end
            end
        end

        function cost = objectiveFunction(obj, pos)

            % Move detector to new position
            obj.movePosition(pos);

            pixelValue = obj.getMeanPixelValue();
            cost = -pixelValue;

            % Track history
            obj.evalCount = obj.evalCount + 1;
            obj.callHistory = [obj.callHistory; obj.evalCount, pos', pixelValue];

            % Catch zeroed values and stop from continuing
            if obj.evalCount > 5 && sum(obj.callHistory(end-4:end, end)) == 0
                    obj.haltOptimization();
            end
        end

        function [startPoint, LB, UB] = prepOptimization(obj)

            obj.evalCount = 0;
            obj.callHistory = [];
            obj.Table = [];

            % Set the starting point and bounds
            startPoint = obj.getCurrentPosition(); % Initialize starting point
            LB = startPoint - obj.searchWindow/2;
            UB = startPoint + obj.searchWindow/2;
        end

        function haltOptimization(obj)
            obj.movePosition(obj.startingPosition);
            error("haltOptimization:InvalidData",...
                "Channel is returning zeros, check PMT gain");
        end

        function plotPositions(obj)
            if isempty(obj.callHistory)
                return
            end

            figure(); hold on;
            scatter(obj.callHistory(:,2), obj.callHistory(:,3), [], obj.callHistory(:,4));
            plot(obj.startingPosition(1), obj.startingPosition(2), 'xb');
            plot(obj.bestPosition(1), obj.bestPosition(2), 'xk');
            rectangle('Position', [obj.startingPosition(1)-obj.searchWindow, ...
                obj.startingPosition(2)-obj.searchWindow, ...
                obj.searchWindow, obj.searchWindow]);
        end
    end
end