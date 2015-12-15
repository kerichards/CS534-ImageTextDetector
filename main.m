<<<<<<< HEAD
colorImage = imread('Original.jpg');
I = rgb2gray(colorImage);

% Detect MSER regions.
[mserRegions] = detectMSERFeatures(I,'RegionAreaRange',[50 2000],'ThresholdDelta',6);
figure
imshow(I)
hold on
plot(mserRegions, 'showPixelList', true,'showEllipses',false)
title('MSER regions')
hold off
=======
colorimage = imread('Original.jpg');
I = rgb2gray(colorImage);

% Detect MSER regions.
[mserRegions] = detectMSERfeatures(I, 'RegionAreaRange',[50 2000],'ThresholdDelta',6);
>>>>>>> origin/master
