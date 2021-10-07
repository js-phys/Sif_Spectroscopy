function [ properties ] = CDgetProperties( signal )
% get the properties of a sif file
% input is like in Andor language: 0 = signal, 1= background, 2=....
% vals = {'SWVersionEx', 'FormattedTime', 'HeadModel', 'ExposureTime',...
%  'KineticCycleTime', 'SubImageHBin', 'SubImageVBin', 'IntegrationCycleTime',...
% 'NumberIntegrations', 'PixelReadOutTime', 'FrameTransferAcquisitionMode',...
% 'EMRealGain', 'Gain', 'DetectionWavelength'};

propertylist = readtable('AndorProperties.dat');
propertylist = table2cell(propertylist)';

    for x = propertylist
        %disp(x{:})
        [rc,propVal]=atsif_getpropertyvalue(signal,x{:});
        properties.(x{:}) = propVal;
    end

end