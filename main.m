colorimage = imread('Original.jpg');
I = rgb2gray(colorImage);

% Detect MSER regions.
[mserRegions] = detectMSERfeatures(I, 'RegionAreaRange',[50 2000],'ThresholdDelta',6);