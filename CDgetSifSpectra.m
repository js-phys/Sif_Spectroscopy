function [ sif, lambda, AllSpectra, BoundFig ] = CDgetSifSpectra( path )
% Function to extract all frames, i.e. spectra from a .sif file.

%% ----- LOAD SIF -----
%  --------------------

    [sif, lambda] = CDloadSIF( path );

%create x-axis: Average wavelengths to binned channels 
    bins=reshape(lambda', str2double(sif.properties.SubImageHBin), sif.width);
    lambda = mean(bins, 1);


%% ----- FIND SIGNAL AND APERTURE -----
%  ------------------------------------
%clearvars -except sif lambda

AllSpectra=[];

% find peaks and boundaries in every frame
for i = 0:(str2double(sif.properties.NumberImages)-1) %loop over frames
    img2find = CDgetFrame(sif, i); %get frame
    %imshow(mat2gray(img2find)), drawnow, pause(0.01);
    
    [peaks, pkbound, aptbound, AvgOverWavel] = CDpeakFind(img2find); % find peak and aperture coordinates
    
% append boundary and peak data    
    Idx.AvgOverWavel= AvgOverWavel;
    Idx.Peak = peaks;
    Idx.ApertureBound = aptbound;
    Idx.PeakBound = pkbound;
    Idx.frame = i;
    AllSpectra = [AllSpectra; Idx];  

end
% plot the found Boundaries & calculate median of boundaries/delta around peak
    [peak_delta, apertureboundaries, BoundFig]=CDBoundaries(sif, AllSpectra);
    sif.PeakBinningPixels = peak_delta;
    sif.ApertureBoundaries = apertureboundaries;

    
% save the image of boundaries
%     savepath = fullfile(sif.path, datestr(now, 'dd-mmm-yy'));
%     mkdir(savepath);
%     saveas(BoundFig, fullfile(savepath, strrep(sif.name, '.sif', '_peakfinding.png')));
%     fprintf('>>\n>>\n>> Saved as %s\n>>\n>>', fullfile(savepath, strrep(sif.name, '.sif', '_peakfinding.png')));
%     pause(0.5)
    
atsif_closefile();

end



