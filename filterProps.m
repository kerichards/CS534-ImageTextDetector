function [mserRegions, mserStats] = filterProps(mserRegions, sz, areaThres, eccThres, perThres)
%
% Filters the mserRegions by properties: area, eccentricity and perimeter.
%
% Parameters:
%       mserRegions: regions of detected text
%       sz: 
%       areaThres: integer area threshold
%       eccThres: integer eccentricity threshold
%       perThres: integer perimeter threshold

pixelIdxList = cellfun(@(xy)sub2ind(sz, xy(:,2), xy(:,1)), ...
    mserRegions.PixelList, 'UniformOutput', false);

% Filter by Area, Eccentricity & Perimeter
mserConnComp.Connectivity = 8;
mserConnComp.ImageSize = sz;
mserConnComp.NumObjects = mserRegions.Count;
mserConnComp.PixelIdxList = pixelIdxList;

mserStats = regionprops(mserConnComp, 'Area','Perimeter', 'Eccentricity','Centroid', 'Image');

filterIdx = [mserStats.Area] > areaThres;
filterIdx = filterIdx | [mserStats.Eccentricity] > eccThres;
filterIdx = filterIdx | [mserStats.Perimeter] > perThres;

mserStats(filterIdx) = [];
mserRegions(filterIdx) = [];