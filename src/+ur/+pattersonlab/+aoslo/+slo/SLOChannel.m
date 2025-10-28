classdef SLOChannel < ur.cvs.SLOChannel
    % TODO: isStreaming check

    properties (SetAccess = protected)
        Alias
    end

    properties (Dependent)
        Image
    end

    methods
        function obj = SLOChannel(name, wavelength)
            arguments
                name         (1,1)   string = ""
                wavelength   (1,1)   double = 0
            end

            obj = obj@ur.cvs.SLOChannel();
            
            obj.Alias = name;
            obj.Wavelength = wavelength;
        end
    end

    methods
        function value = get.Image(obj)
            value = obj.ImageStream.Image;
        end
    end

    methods
        function [whens, meanPixels, stDevs] = getFrameValues(obj, N)

            whens = strings(N, 1);
            meanPixels = zeros(N,1);
            stDevs = zeros(N,1);
            tic
            for i = 1:N
                out = obj.getCurrentStats();
                whens(i) = string(out{1});
                meanPixels(i) = out{2};
                stDevs(i) = out{3};
                while strcmp(out{1}, obj.When)
                    pause(0.01);
                end
            end
            toc
        end

        function img = getSummaryImage(obj, nFrames, metric)
            lastFrameTime = obj.ImageStream.When;
            img = im2double(obj.Image);
            for i = 1:nFrames
                currentTime = obj.ImageStream.When;
                currentImage = obj.ImageStream.Image;
                while strcmp(currentTime, lastFrameTime)
                    pause(0.01);  % Wait 10 ms
                end
                img = im2double(currentImage) + img;
                lastFrameTime = currentTime;
            end

            if metric == "mean"
                img = img / nFrames;
            end
        end
    end

    methods (Access = protected)
        function values = getCurrentStats(obj)
            values = {obj.When, obj.MeanPixelValue, obj.StdDev};
        end
    end
end

