function [R, G, B] = rgb2argb(rgbValue)

    rgbValue = int32(rgbValue * 255);
    [R, G, B] = deal(rgbValue);