function [ sif, lambda ] = CDloadSif( varargin )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%close all;
clc;

if nargin==0
    [name,path,FilterIndex] = uigetfile({'*.sif;*.sifx','Andor files (*.sif, *.sifx)';},'Open file');
    if (FilterIndex ==0)
        return
    end
else
    [path, name, ending] = fileparts(varargin{1});
    name = strcat(name,ending);
end

sif.name = name;
sif.path = path;

%open sifx
signal=0;
rc=atsif_setfileaccessmode(0);
rc=atsif_readfromfile(fullfile(path,name));

if (rc == 22002)

  [rc,present]=atsif_isdatasourcepresent(signal);
  
  if present %get file data
    format long;
    sif.properties = CDgetProperties(0); %input is 0 = signal, 1= background, 2=....
    
%     [rc,sif.no_frames]=atsif_getnumberframes(signal);
    [rc,sif.framesize]=atsif_getframesize(signal);
    [rc,left,bottom,right,top,hBin,vBin]=atsif_getsubimageinfo(signal,0);
    
    sif.width = ((right - left)+1)/hBin;
    sif.height = ((top-bottom)+1)/vBin;
    
    
    lambda=[];
    for i=1:right
        [rc, wl] = atsif_getpixelcalibration(signal, 0, i); %(source, axis, pixel)
        lambda = [lambda, wl];
        %i=i+1;
    end
    %either lambda is correct in wavelengths or in pixels form 0 to end
    
    if ~strcmp(sif.properties.XAxisType, 'Wavelength') %then lambda is in pixels
        %in this case try to open the .report file
        flnm = erase(name, '.sif');
        if 2==exist(fullfile(sif.path, [flnm, '.report'])) %file has an own report file
            filetoopen = [flnm, '.report'];
            flagOwn = 1;
            
        else  %if no own report file use only the file stem for the report file
            filetoopen = regexprep(name,'(_\d*)?.sif$','.report');
            flagOwn = 2;
        end
           disp(filetoopen) 
        try
            %filetoopen = regexprep(name,'(_\d*)?.sif$','.report');
            fileID = fopen(fullfile(path,filetoopen),'r');
                txt=textscan(fileID,'%s %s %s %s %s', 'Delimiter', '\t');
                searchcell=regexprep(txt{:,2}, '(\.\d*)', ''); %use timestamp to identify the associated file
            fclose(fileID);
            
            if flagOwn==1
                row=1;
            else
            % find the row of the corresponding date/time in the .report file
            % for old files only
            stampInReport = datetime(txt{:,2}, 'InputFormat', 'eee MMM d HH:mm:ss.SSS yyyy', 'Format','d-MMM-y HH:mm:ss');
            stampInFile = datetime(sif.properties.FormattedTime, 'InputFormat', 'eee MMM d HH:mm:ss yyyy','Format','d-MMM-y HH:mm:ss')-hours(1);
            
                [row,~]=find(string(stampInReport)==string(stampInFile));
                if isempty(row)
                    [row,~]=find(string(stampInReport+seconds(1))==string(stampInFile));
                    if isempty(row) %append an hour and +- 5 seconds if nothing is found 
                        [row,~]=find(string(stampInReport+seconds(1))==string(stampInFile+hours(1)));
                    end
                end
            end
            % extract information and save to sif.properties
            cellcoeff=textscan(strrep(txt{3}{row},'CalibrationCoeff:',''), '%f,%f,%f,%f');
                sif.properties.fromReport_CalibCoeff=cell2mat(cellcoeff);
                
            cellwave=strrep(txt{4}{row},'CenterWavelength:','');
                sif.properties.fromReport_DetectionWavelength=cellwave;
                
            cellslit=strrep(txt{5}{row},'SlitWidth:','');
                sif.properties.fromReport_SlitWidth=cellslit;
            
            % create lambda in Wavelength    
            lambda = cellcoeff{1} + cellcoeff{2}*lambda + cellcoeff{3}*lambda.^2 + cellcoeff{4}*lambda.^3;
            warning(['No wavelength calibration saved in .sif file! ',...
                '--> Using Calibration from .report file']);
            
        catch
        %disp(sprintf('>>\n>> No wavelength calibration found in file! Use the calibration coefficients from: AndorWavelengthCalibration.dat\n>>\n'));
        coeff = readtable('AndorWavelengthCalibration.dat');
        coeff = table2array(coeff);
        calib = coeff(1) + coeff(2)*lambda + coeff(3)*lambda.^2 + coeff(4)*lambda.^3;
        lambda=calib;
            
            warndlg([sprintf('No wavelength calibration in .sif and no .report file available or error while reading! Using Standard calibration AndorWavelengthCalibration.dat\n%s ### ', sif.name),...
                sprintf('Try to find %s in:\n',stampInFile), sprintf('%s \n', stampInReport)]);
        end
        
    %elseif ~strcmp(sif.properties.XAxisType, 'Wavelength') %if no .report file is present or error while reading the nuse standard calibration 

    else
        warning('GetPixelCalibration:FromFile', 'Wavelength calibration present in file!')
    end

  end
end
