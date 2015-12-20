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

locations = mserRegions.Location;
minX = min(locations(:,1)) - 10;
minY = min(locations(:,2)) - 10;
maxX = max(locations(:,1)) + 10;
maxY = max(locations(:,2)) + 10;
figure('name', 'histogram'), histY = histogram(locations(:,2)), title('Cropped location histogram')

values = histY.Values;
binEdges = histY.BinEdges;
[height, width] = size(values);
x = zeros(1, width);
bins = zeros(size(values));
count = 0;
for i=1:width
    if i == 1 && i < width
        if values(i+1) < values(i)
            bins(:,count) = i;
            count = count + 1;
            indices = find(locations(:,2)>binEdges(i) & locations(:,2) < binEdges(i+1));
            minX = min(locations(indices,1)) - 10;
            minY = min(locations(indices,2)) - 10;
            maxX = max(locations(indices,1)) + 10;
            maxY = max(locations(indices,2)) + 10;
            cropped2 = cropped(minY:maxY, minX:maxX);
            figure('name', 'Cropped line'), imshow(cropped2), title('Cropped image');
            Icorrected = imtophat(cropped2, strel('disk', 15));

th  = graythresh(Icorrected);
BW1 = im2bw(Icorrected, th);

figure;
imshowpair(Icorrected, BW1, 'montage');

            ocrtxt = ocr(BW1,'TextLayout','Block');
            [ocrtxt.Text]
        end
    elseif i < width
        if values(i+1) < values(i) && values(i-1) < values(i)
            bins(:,i) = i;
            count = count + 1;
            indices = find(locations(:,2)>binEdges(i) & locations(:,2) < binEdges(i+1));
            minX = min(locations(indices,1)) - 10;
            minY = min(locations(indices,2)) - 10;
            maxX = max(locations(indices,1)) + 10;
            maxY = max(locations(indices,2)) + 10;
            cropped2 = cropped(minY:maxY, minX:maxX);
            figure('name', 'Cropped line mid'), imshow(cropped2), title('Cropped image');
            Icorrected = imtophat(cropped2, strel('disk', 15));

th  = graythresh(Icorrected);
BW1 = im2bw(Icorrected, th);

figure;
imshowpair(Icorrected, BW1, 'montage');

            ocrtxt = ocr(BW1,'TextLayOut','Block');
            [ocrtxt.Text]
        end
    elseif i == width && i ~= 1
        if values(i-1) < values(i)
            bins(:,i) = i;
            count = count + 1;
            indices = find(locations(:,2)>binEdges(i) & locations(:,2) < binEdges(i+1));
            minX = min(locations(indices,1)) - 10;
            minY = min(locations(indices,2)) - 10;
            maxX = max(locations(indices,1)) + 10;
            maxY = max(locations(indices,2)) + 10;
            cropped2 = cropped(minY:maxY, minX:maxX);
            figure('name', 'Cropped line end'), imshow(cropped2), title('Cropped image');
            Icorrected = imtophat(cropped2, strel('disk', 15));

th  = graythresh(Icorrected);
BW1 = im2bw(Icorrected, th);

figure;
imshowpair(Icorrected, BW1, 'montage');
marker = imerode(Icorrected, strel('line',10,0));
Iclean = imreconstruct(marker, Icorrected);

th  = graythresh(Iclean);
BW2 = im2bw(Iclean, th);

figure;
imshowpair(Iclean, BW2, 'montage');
            ocrtxt = ocr(BW2,'TextLayout','Block');
            [ocrtxt.Text]
            
        end
    end
end

% Show cropped image
% cropped2 = cropped(minY:maxY, minX:maxX);
% figure('name', 'cropped2'), imshow(cropped2), title('Cropped image');
% 
% ocrtxt = ocr(cropped2);
% [ocrtxt.Text]