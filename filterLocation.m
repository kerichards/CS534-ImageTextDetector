function [mserRegions, mserStats] = filterLocation(mserRegions, mserStats, threshold)
%
% Filters the mserRegions by distance given by threshold, 
% between the centers on each region
%
% Parameters:
%       mserRegions: regions of detected text
%       mserStats: used to get the centroid locations
%       threshold: integer distance to check between regions

% Filter by Location
cen = cat(1, mserStats.Centroid);
x = cen(:,1);
y = cen(:,2);
avgX = mean(x);
avgY = mean(y);
minusAvgX = avgX - threshold;
plusAvgX = avgX + threshold;
minusAvgY = avgY - threshold;
plusAvgY = avgY + threshold;

filterx = cen(:,1) < minusAvgX | cen(:,1) > plusAvgX;
filtery = cen(:,2) < minusAvgY | cen(:,2) > plusAvgY;
filter = filterx | filtery;

mserStats(filter) = [];
mserRegions(filter) = [];