function mserRegions = filterLocation(mserRegions, mserStats, threshold)
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