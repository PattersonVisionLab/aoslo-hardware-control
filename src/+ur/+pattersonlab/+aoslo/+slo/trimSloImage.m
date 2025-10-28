function out = trimSloImage(img, numPixels)
    % Get rid of ticker tape top that might mess up analysis
    if nargin < 2
        numPixels = 4;
    end

   out = img(numPixels:end-numPixels, numPixels:end-numPixels);