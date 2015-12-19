clc;
clear;
% set(0, 'DefaultFigureWindowStyle', 'docked'); % Dock Figures

colorImage = imread('Original.jpg');
I = rgb2gray(colorImage);

% Detect Regions
[mserRegions] = detectMSERFeatures(I,...
    'RegionAreaRange',[50 2000],'ThresholdDelta',6);

sz = size(I);
pixelIdxList = cellfun(@(xy)sub2ind(sz, xy(:,2), xy(:,1)), ...
    mserRegions.PixelList, 'UniformOutput', false);

% Filter by Area, Eccentricity & Perimeter
mserConnComp.Connectivity = 8;
mserConnComp.ImageSize = sz;
mserConnComp.NumObjects = mserRegions.Count;
mserConnComp.PixelIdxList = pixelIdxList;

mserStats = regionprops(mserConnComp, 'Area','Perimeter', 'Eccentricity','Centroid');

filterIdx = [mserStats.Area] > 200;
filterIdx = filterIdx | [mserStats.Eccentricity] > .8 ;
filterIdx = filterIdx | [mserStats.Perimeter] > 65 ;

mserStats(filterIdx) = [];
mserRegions(filterIdx) = [];

% Filter by Location
cen = cat(1, mserStats.Centroid);
x = cen(:,1);
y = cen(:,2);
avgX = mean(x);
avgY = mean(y);
minusAvgX = avgX - 100;
plusAvgX = avgX + 100;
minusAvgY = avgY - 100;
plusAvgY = avgY + 100;

filterx = cen(:,1) < minusAvgX | cen(:,1) > plusAvgX;
filtery = cen(:,2) < minusAvgY | cen(:,2) > plusAvgY;
filter = filterx | filtery;

mserStats(filter) = [];
mserRegions(filter) = [];

% Crop Region
locations = mserRegions.Location;
minX = min(locations(:,1)) - 50;
minY = min(locations(:,2)) - 50;
maxX = max(locations(:,1)) + 50;
maxY = max(locations(:,2)) + 50;
cropped = I(minY:maxY, minX:maxX);
figure('name', 'cropped'), imshow(cropped), title('Cropped');

% Detect Regions (2nd time)
[mserRegions] = detectMSERFeatures(cropped,...
    'RegionAreaRange',[50 200],'ThresholdDelta',3);

% Show cropped mserRegions
figure('name', 'mserRegions'), imshow(cropped)
hold on
plot(mserRegions, 'showPixelList', true,'showEllipses',false)
title('MSER regions')
hold off