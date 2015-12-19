clc;
clear;
% set(0, 'DefaultFigureWindowStyle', 'docked'); % Dock Figures

colorImage = imread('Original.jpg');
I = rgb2gray(colorImage);

% 1st pass through text detection & filtering
mserRegions = detectText(I, [50 2000], 6);
sz = size(I);
[mserRegions, mserStats] = filterProps(mserRegions, sz, 200, .8, 65);
mserRegions = filterLocation(mserRegions, mserStats, 100);

% Show mserRegions on complete input I
figure('name', 'mserRegions I'), imshow(I)
hold on
plot(mserRegions, 'showPixelList', true,'showEllipses',false)
title('MSER regions in input image')
hold off

% Crop Region
locations = mserRegions.Location;
minX = min(locations(:,1)) - 50;
minY = min(locations(:,2)) - 50;
maxX = max(locations(:,1)) + 50;
maxY = max(locations(:,2)) + 50;

% Show cropped image
cropped = I(minY:maxY, minX:maxX);
figure('name', 'cropped'), imshow(cropped), title('Cropped image');

% 2nd pass through text detection & filtering
mserRegions = detectText(cropped, [50 200], 3);

sz = size(cropped);
[mserRegions, mserStats] = filterProps(mserRegions, sz, 200, 1, 75);
mserRegions = filterLocation(mserRegions, mserStats, 100);

strokeWidthThreshold = 0.29;
for j = 1:numel(mserStats)

    regionImage = mserStats(j).Image;
    regionImage = padarray(regionImage, [1 1], 0);

    distanceImage = bwdist(~regionImage);
    skeletonImage = bwmorph(regionImage, 'thin', inf);

    strokeWidthValues = distanceImage(skeletonImage);

    strokeWidthMetric = std(strokeWidthValues)/mean(strokeWidthValues);

    strokeWidthFilterIdx(j) = strokeWidthMetric > strokeWidthThreshold;

end

% Remove regions based on the stroke width variation
mserRegions(strokeWidthFilterIdx) = [];
mserStats(strokeWidthFilterIdx) = [];
% Show cropped mserRegions
figure('name', 'mserRegions'), imshow(cropped)
hold on
plot(mserRegions, 'showPixelList', true,'showEllipses',false)
title('MSER regions in cropped image')
hold off