function text = parseLines(mserRegions, I, showFigures)
%
% Iterates through detected text and returns string with each row of text
% on a new line.
%
% Parameters:
%       mserRegions: regions of detected text
%       I: Image used, to find rows of text in
%       showFigures: boolean whether to display intermediate figures
% Returns:
%       text: String of the text found in image I

locations = mserRegions.Location;

if showFigures
    figure('name', 'histogram'), histY = histogram(locations(:,2)); title('Cropped location histogram');
else
    histY = histogram(locations(:,2));
end

rows = 1;   % # of rows of text found
values = histY.Values;
binEdges = histY.BinEdges;
[height, width] = size(values);

for i=1:width
    if i == 1 && i < width
        if values(i+1) < values(i)
            indices = find(locations(:,2)>binEdges(i) & locations(:,2) < binEdges(i+1));
            minX = min(locations(indices,1)) - 10;
            minY = min(locations(indices,2)) - 10;
            maxX = max(locations(indices,1)) + 10;
            maxY = max(locations(indices,2)) + 10;
            cropped2 = I(minY:maxY, minX:maxX);
            
            Icorrected = imtophat(cropped2, strel('disk', 15));

            th  = graythresh(Icorrected);
            BW1 = im2bw(Icorrected, th);
            
            if showFigures
                figure('name', 'Cropped line end'), imshow(cropped2), title('Cropped image');
                figure('name', 'montage'), imshowpair(Icorrected, BW2, 'montage'), title('Combined image montage');
            end

            ocrtxt = ocr(BW1,'TextLayout','Block');
            textCells(rows) = {strcat(ocrtxt.Text)};
            rows = rows + 1;
        end
    elseif i < width
        if values(i+1) < values(i) && values(i-1) < values(i)
            indices = find(locations(:,2)>binEdges(i) & locations(:,2) < binEdges(i+1));
            minX = min(locations(indices,1)) - 10;
            minY = min(locations(indices,2)) - 10;
            maxX = max(locations(indices,1)) + 10;
            maxY = max(locations(indices,2)) + 10;
            cropped2 = I(minY:maxY, minX:maxX);
            
            Icorrected = imtophat(cropped2, strel('disk', 15));

            th  = graythresh(Icorrected);
            BW1 = im2bw(Icorrected, th);

            if showFigures
                figure('name', 'Cropped line end'), imshow(cropped2), title('Cropped image');
                figure('name', 'montage'), imshowpair(Icorrected, BW1, 'montage'), title('Combined image montage');
            end

            ocrtxt = ocr(BW1,'TextLayOut','Block');
            textCells(rows) = {strcat(ocrtxt.Text)};
            rows = rows + 1;
        end
    elseif i == width && i ~= 1
        if values(i-1) < values(i)
            indices = find(locations(:,2)>binEdges(i) & locations(:,2) < binEdges(i+1));
            minX = min(locations(indices,1)) - 10;
            minY = min(locations(indices,2)) - 10;
            maxX = max(locations(indices,1)) + 10;
            maxY = max(locations(indices,2)) + 10;
            cropped2 = I(minY:maxY, minX:maxX);
            
            Icorrected = imtophat(cropped2, strel('disk', 15));

            th  = graythresh(Icorrected);
            BW1 = im2bw(Icorrected, th);
            
            marker = imerode(Icorrected, strel('line',10,0));
            Iclean = imreconstruct(marker, Icorrected);

            th  = graythresh(Iclean);
            BW2 = im2bw(Iclean, th);
            
            if showFigures
                figure('name', 'Cropped line end'), imshow(cropped2), title('Cropped image');
                figure('name', 'montage'), imshowpair(Iclean, BW2, 'montage'), title('Combined image montage');
            end

            ocrtxt = ocr(BW2,'TextLayout','Block');
            textCells(rows) = {strcat(ocrtxt.Text)};
            rows = rows + 1;
        end
    end
end

if iscellstr(textCells)
    text = char(textCells);
end