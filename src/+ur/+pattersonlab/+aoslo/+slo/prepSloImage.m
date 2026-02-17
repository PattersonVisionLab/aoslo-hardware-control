function [out, roi] = prepSloImage(img, roi, trimPix)

    arguments 
        img
        roi  = []
        trimPix  (1,1) {mustBeInteger} = 4
    end

    if isempty(roi)

        imgLine = sum(img, 2);
        [low, high] = bounds(find(imgLine > 0));
        %roi = [low, high];
        roi = [low+trimPix high-trimPix trimPix size(img, 2)-trimPix];
    end

    roi(roi==0) = 1;

    out = img(roi(1):roi(2), roi(3):roi(4));
