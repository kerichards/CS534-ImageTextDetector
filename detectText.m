function mserRegions = detectText(I, areaRange, delta)
% Detect Regions
[mserRegions] = detectMSERFeatures(I,...
    'RegionAreaRange',areaRange,'ThresholdDelta',delta);

sz = size(I);
[mserRegions, mserStats] = filterProps(mserRegions, sz, 200, .8, 65);

mserRegions = filterLocation(mserRegions, mserStats, 100);