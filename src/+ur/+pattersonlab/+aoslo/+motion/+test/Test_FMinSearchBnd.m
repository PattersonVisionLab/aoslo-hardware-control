classdef Test_FMinSearchBnd < handle

    properties
        Range
        xGrid
        yGrid
        Data
        TrueData
        FData
        underlyingData
        noiseValue = 0.05
        maxIterations = 200
        bestPosition

        searchWindow = 0.02

        callHistory
        evalCount
        Table
    end

    methods
        function obj = Test_FMinSearchBnd(searchWindow)
            obj.searchWindow = searchWindow;
            obj.Range = 0:0.0001:obj.searchWindow;
            [obj.xGrid, obj.yGrid] = ndgrid(obj.Range);
            obj.TrueData = peaks(numel(obj.Range));
            obj.TrueData = obj.TrueData / max(abs(obj.TrueData(:)));
            obj.Data = obj.TrueData + normrnd(0, obj.noiseValue, size(obj.TrueData));
            obj.FData = griddedInterpolant(obj.xGrid, obj.yGrid, obj.Data);
        end

        function [bestPosition, fVal, exitFlag, output] = optimize(obj)
            startPt = [obj.searchWindow/2, obj.searchWindow/2];
            LB = [0 0]; UB = [obj.searchWindow, obj.searchWindow];

            opts = optimset("Display", "iter",...
                "MaxIter", obj.maxIterations,...
                'MaxFunEvals', obj.maxIterations,...
                'TolX', 0.0005, 'TolFun', 0.001,...
                "PlotFcn", @plotFcn);

            [bestPosition, fVal, exitFlag, output] = fminsearchbnd(...
                @obj.objectiveFcn, startPt, LB, UB, opts);
            obj.bestPosition = bestPosition;

            obj.Table = table(obj.callHistory(1), obj.callHistory(end),...
                obj.callHistory(2:end-1),...
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

        function cost = objectiveFcn(obj, pos)
            value = obj.FData(pos(1), pos(2));
            value = round(value, 4);
            cost = -value;

            % Track history
            obj.evalCount = obj.evalCount + 1;
            obj.callHistory = [obj.callHistory; obj.evalCount, pos, value];
            pause(0.1);
        end

    end
end
