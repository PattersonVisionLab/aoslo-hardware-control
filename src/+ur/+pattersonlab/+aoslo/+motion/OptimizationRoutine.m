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
        INTEGRATION_FRAMES = 12;
        REF_XYZ = ["83857268", "83855258", "26250117"]
        VIS_XYZ = ["83848285", "83848287", "83848308"]
    end

    methods
        function obj = OptimizationRoutine(form, slo, targets, opts)
            arguments
                form
                slo
                targets {mustBeMember(targets, ["RefXY", "RefX", "RefZ", "VisYZ", "RefXYZ", "VisXY", "VisZ"])}
                opts.SearchWindow = 0.05
                opts.MaxIterations = 100
            end

            obj.Form = form;
            obj.targets = targets;

            obj.maxIterations = opts.MaxIterations;
            obj.searchWindow = opts.SearchWindow;

            if contains(targets, "Ref")
                obj.SloChannel = slo.Channels(1);
            else
                obj.SloChannel = slo.Channels(2);
            end

            switch targets
                case "RefXYZ"
                    obj.TargetDevices = obj.Form.Devices(1:3);
                case "RefXY"
                    obj.TargetDevices = obj.Form.Devices(1:2);
                case "RefX"
                    obj.TargetDevices = obj.Form.Devices(1);
                case "RefZ"
                    obj.TargetDevices = obj.Form.Devices(3);
                case "VisXY"
                    obj.TargetDevices = obj.Form.Devices(4:5);
                case "VisZ" 
                    obj.TargetDevices = obj.Form.Devices(6);
                case "VisYZ"
                    obj.TargetDevices = obj.Form.Devices(5:6);
            end
            if iscell(obj.TargetDevices)
                obj.TargetDevices = horzcat(obj.TargetDevices{:})';
            end
            if numel(obj.TargetDevices) > 1 && isscalar(obj.searchWindow)
                obj.searchWindow = [obj.searchWindow, obj.searchWindow];
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
            pause(0.04);
            [~, mu] = obj.SloChannel.getFrameValues(obj.INTEGRATION_FRAMES);
            pixelValue = mean(mu);
        end
    end

    methods
        function peakOptimization(obj, searchRange, stepSize)
            obj.prepOptimization();
            startPosition = obj.getCurrentPosition();
            startPixValue = obj.getMeanPixelValue();
            disp([startPosition, startPixValue]);


            forwardPositions = startPosition + (-searchRange/2:stepSize:searchRange/2);
            backPositions = fliplr(forwardPositions);
            allPositions = [forwardPositions, backPositions];
            totalNumPositions = numel(forwardPositions) * 2;
            idx = randperm(totalNumPositions);
            allPositions = allPositions(idx);
            cprintf('blue', 'Testing %u positions\n', numel(allPositions));



            ax = axes('Parent', figure()); hold on;
            stem(startPosition, startPixValue, 'filled', ...
                'Color', 'k', 'LineStyle', '-.');

            forwardRun = zeros(size(forwardPositions));
            backRun = zeros(size(backPositions));

            h1 = plot(allPositions, zeros(size(allPositions)), '.', 'Marker', '.',...
                'Color', 'b', 'LineStyle', 'none', 'MarkerSize', 10);

            for i = 1:totalNumPositions
                pos = allPositions(i);

                % Move detector to new position
                obj.movePosition(pos);
    
                pixelValue = obj.getMeanPixelValue();
    
                % Track history
                obj.evalCount = obj.evalCount + 1;
                obj.callHistory = [obj.callHistory; obj.evalCount, obj.getCurrentPosition()', pixelValue];
    
                % Catch zeroed values and stop from continuing
                if obj.evalCount > 5 && sum(obj.callHistory(end-4:end, end)) == 0
                        obj.haltOptimization();
                end
                
                h1.YData = forwardRun;

            end
        end

        function [optimalPosition, fVal, exitFlag, output] = optimize1D(obj)
            [startPoint, LB, UB] = obj.prepOptimization();

            opts = optimset("Display", "iter",...
                "MaxIter", obj.maxIterations,...
                "MaxFunEvals", obj.maxIterations,...
                "TolX", 0.0001, "TolFun", 0.001,...
                "PlotFcn", @optimplotfval);

            [optimalPosition, fVal, exitFlag, output] = fminbnd(...
                @obj.objectiveFunction, startPoint, LB, UB, opts);
        end

        function [optimalPosition, fVal, exitFlag, output] = optimizeND(obj)

            [startPoint, LB, UB] = obj.prepOptimization();
            opts = optimset("Display", "iter",...
                "MaxIter", obj.maxIterations,...
                'MaxFunEvals', obj.maxIterations,...
                'TolX', 0.001, 'TolFun', 0.001,...
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
                        %axis equal
                        colormap(flare(100)); colorbar()
                        rectangle('Position',[startPoint'-obj.searchWindow/2, ...
                                                obj.searchWindow(1),obj.searchWindow(2)],...
                                    'LineStyle', '--');
                        plot(startPoint(1), startPoint(2), 'ok', 'LineWidth', 1, 'MarkerSize', 10);
                        axis tight
                    case 'iter'
                        scatter( ...
                            obj.callHistory(end,end-2), obj.callHistory(end,end-1), ...
                            80, obj.callHistory(end,end), '.');
                    case 'done'
                        title(sprintf('Position: %.4f %.4f', obj.bestPosition));
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
            LB = startPoint - obj.searchWindow'/2;
            UB = startPoint + obj.searchWindow'/2;
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
            rectangle('Position', [obj.startingPosition(1)-obj.searchWindow(1), ...
                obj.startingPosition(2)-obj.searchWindow(2), ...
                obj.searchWindow(2), obj.searchWindow(2)]);
        end
    end
end