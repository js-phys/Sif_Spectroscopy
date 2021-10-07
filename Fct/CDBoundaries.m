function [ peak_delta, median_aperture, PlotOfBoundaries ] = CDBoundaries(sif, AllSpectra )
%CDBoundaries
%   Function to plot the spectral peaks, which were found
%% plot boundaries over frames
aptcoord = reshape([AllSpectra.ApertureBound],4,AllSpectra(end).frame+1);
pkbound = reshape([AllSpectra.PeakBound],4,AllSpectra(end).frame+1);
pkcoord = reshape([AllSpectra.Peak],2,AllSpectra(end).frame+1);

% for x={AllSpectra.Peak}
% 
% end
% for y={AllSpectra.ApertureBound}
%    aptcoord=[aptcoord, cell2mat(y{:}')];
% end
% 
% for z={AllSpectra.PeakBound}
%    pkbound=[pkbound, cell2mat(z{:}')];
% end

PlotOfBoundaries = figure;
plot([AllSpectra.frame], aptcoord(1,:), 'r-'), hold on;
plot([AllSpectra.frame], aptcoord(2,:), 'r-');
plot([AllSpectra.frame], aptcoord(3,:), 'r-');
plot([AllSpectra.frame], aptcoord(4,:), 'r-');
plot([AllSpectra.frame], pkbound(1,:), 'b-');
plot([AllSpectra.frame], pkbound(2,:), 'b-');
plot([AllSpectra.frame], pkbound(3,:), 'b-');
plot([AllSpectra.frame], pkbound(4,:), 'b-');
plot([AllSpectra.frame], pkcoord(1,:), '.m');
plot([AllSpectra.frame], pkcoord(2,:), '.m');
figure(PlotOfBoundaries), title(fullfile(sif.path,sif.name), 'Interpreter', 'none', 'FontSize', 8);
xlabel('Frame #'), ylabel('Peak & Boundaries')

%calculate median
median_aperture = [nanmedian(aptcoord(1,:)), nanmedian(aptcoord(2,:)), nanmedian(aptcoord(3,:)), nanmedian(aptcoord(4,:))];
median_delta = [nanmedian(pkbound(2,:))-nanmedian(pkbound(1,:)), nanmedian(pkbound(4,:))-nanmedian(pkbound(3,:))];
peak_delta=max(median_delta);

linespecs = {'Color',[0 100/255 0],'LineStyle','-','LineWidth', 5};

line([AllSpectra(end).frame, AllSpectra(end).frame+100],[median_aperture(1) median_aperture(1)], linespecs{:});
line([AllSpectra(end).frame, AllSpectra(end).frame+100],[median_aperture(2) median_aperture(2)], linespecs{:});
line([AllSpectra(end).frame, AllSpectra(end).frame+100],[median_aperture(3) median_aperture(3)], linespecs{:});
line([AllSpectra(end).frame, AllSpectra(end).frame+100],[median_aperture(4) median_aperture(4)], linespecs{:});
end

