function [peaks, pkinterval, aptinterval, s_data] = CDpeakFind( img )
% CDpeakFind find the interval and peaks of the spectrum for a specific column
%   within an image

data = mean(img, 2); %average over column to get smooth spectrum
s_data = mat2gray(smooth(data)); %smooth data and scale from 0 to 1
d_data = mat2gray(stdfilt(s_data)); % local standard deviation of smoothed data, again scale from 0 to 1

len = length(data);
xbins = 1:len(end);


% -------- get two tallest peaks (== signal)
[pkval,pkidx] = findpeaks(data, 'SortStr', 'descend',...
    'MinPeakProminence', 0.05, 'MinPeakHeight', 0.1, 'MinPeakDistance',...
    round(xbins(end)./5), 'WidthReference', 'halfprom');
    if length(pkidx)>=2
    %if more than 2 peaks are found, take the tallest
        [~, sortIndex] = sort(pkval(:), 'descend');  % Sort the values in descending order
        maxIndex = sortIndex(1:2);  % Get a linear index into A of the 2 largest values
        peaks = sort(pkidx(maxIndex), 'ascend');    
    
        peaks=sort(pkidx(1:2)', 'ascend');
    else % if less than two peaks found return NaN
        peaks=[NaN, NaN];
    end
% -------- get boundaries of tallest peaks and aperture
[boundval ,bound] = findpeaks(d_data, 'SortStr', 'descend', 'MinPeakHeight', mean(d_data)./2);
% should find 8 peaks giving the boundaries of:
% aperture1, pk1, pk1, aperture1, aperture2, pk2, pk2, aperture2,
    if length(bound)>= 8
    %if more than 8 peaks are found, take the tallest
        [~, sortIndex] = sort(boundval(:), 'descend');  % Sort the values in descending order
        maxIndex = sortIndex(1:8);  % Get a linear index into A of the 8 largest values
        boundaryIndices = sort(bound(maxIndex), 'ascend');
        
        pkinterval = [boundaryIndices(2) boundaryIndices(3) boundaryIndices(6) boundaryIndices(7)];
        aptinterval = [boundaryIndices(1) boundaryIndices(4) boundaryIndices(5) boundaryIndices(8)];
    else % if less than 8 peaks found return NaN
        pkinterval=[NaN, NaN, NaN, NaN];
        aptinterval=[NaN, NaN, NaN, NaN];
    end

%% ---- plot -----     
  figure(1), plot(xbins, s_data, 'b-'), hold on;
  plot(pkinterval, s_data(pkinterval), 'ro', aptinterval, s_data(aptinterval), 'mo'), hold off;
  pause(0.1);
  %plot(aptinterval, data(aptinterval), 'ro', pkidx, data(pkidx), 'go'), hold on;
  %plot(xbins, indices, 'cx'), drawnow, hold off;

% % -------- get boundaries of aperture by thresholding with mean value
% indices = imbinarize(d_data, mean(data)); % thresholding the data with 1 for >mean and 0 for <mean
% % % split in upper and lower aperture
% center=ceil(len/2.);
% % lower = indices(1:center-mod(len,2));
% % upper = indices(center+1:len);
% % find indices surviving the thresholding and pick the 4 on the edge
% aptinterval = {find(indices(1:center),1), find(indices(1:center),1,'last'), find(indices(center:end),1)+center-1, find(indices(center:end),1,'last')+center-1};
% 
% figure(1), plot(xbins, s_data, 'b', xbins, d_data, 'm');% hold on, plot(xbins, indices, 'r-');
% hold off, drawnow, pause(0.05);
%% --------- old code    ------- 
% % get intervals around tallest peaks in which the aperture didn't block the
% % signal
% [~,intervalidx, width] = findpeaks(s_data);
%     if length(intervalidx)>=4
%         [~, sortIndex] = sort(width, 'descend');
%         maxIndex = sortIndex(3:7);
%         filteredinterval=intervalidx(maxIndex);
%         interval = sort(filteredinterval, 'ascend');
%     else
%         interval =[NaN; NaN; NaN; NaN];
%     end
% 

end

