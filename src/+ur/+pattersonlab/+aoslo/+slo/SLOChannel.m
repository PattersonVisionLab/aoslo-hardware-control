classdef SLOChannel < handle

    properties
        When;
        MeanPixelValue = 0.0;
        StdDev = 0.0;
        Wavelength = 0;
        Alias
    end

    methods
        function values = getValuesNow(obj)
            values = {obj.When, obj.MeanPixelValue, obj.StdDev};
        end

        function [whens, meanPixels, stDevs] = getFrameValues(obj, N)
            counter = 0;
            whens = strings(N, 1);
            meanPixels = zeros(N,1);
            stDevs = zeros(N,1);
            tic
            for i = 1:N
                out = obj.getValuesNow();
                whens(i) = string(out{1});
                meanPixels(i) = out{2};
                stDevs(i) = out{3};
                counter = counter + 1;
                while strcmp(out{1}, obj.When)
                    pause(0.01);
                end
            end
            toc
        end
    end
end

