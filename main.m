clc;
clear;

colorImage = imread('Original.jpg');
I = rgb2gray(colorImage);

[mserRegions] = detectMSERFeatures(I,...
    'RegionAreaRange',[50 2000],'ThresholdDelta',6);

sz = size(I);
pixelIdxList = cellfun(@(xy)sub2ind(sz, xy(:,2), xy(:,1)), ...
    mserRegions.PixelList, 'UniformOutput', false);

mserConnComp.Connectivity = 8;
mserConnComp.ImageSize = sz;
mserConnComp.NumObjects = mserRegions.Count;
mserConnComp.PixelIdxList = pixelIdxList;

mserStats = regionprops(mserConnComp, 'Area', 'Eccentricity','Centroid');

filterIdx = [mserStats.Area] > 200;
filterIdx = filterIdx | [mserStats.Eccentricity] > .8 ;

mserStats(filterIdx) = [];
mserRegions(filterIdx) = [];

figure
imshow(I)
hold on
plot(mserRegions, 'showPixelList', true,'showEllipses',false)
title('MSER regions')
hold off