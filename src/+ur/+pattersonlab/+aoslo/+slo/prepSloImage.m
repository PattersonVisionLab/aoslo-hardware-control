function [out, roi] = prepSloImage(img, roi, trimPix)

    if nargin < 2 || isempty(roi)
        if nargin < 3
            trimPix = 0;
        end
        imgLine = sum(img, 2);
        [low, high] = bounds(find(imgLine > 0));
        %roi = [low, high];
        roi = [low+trimPix high-trimPix trimPix size(img, 2)-trimPix];
    end

    out = img(roi(1):roi(2), roi(3):roi(4));
