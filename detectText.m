function mserRegions = detectText(I, areaRange, delta)
% Detect Regions
[mserRegions] = detectMSERFeatures(I,...
    'RegionAreaRange',areaRange,'ThresholdDelta',delta);
