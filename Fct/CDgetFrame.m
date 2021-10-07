function [ img ] = CDgetFrame( sif, frameNumber )
%UNTITLED2 grab a frame and rteurn it as normalized image (0-1)
[rc, tmp]=atsif_getframe(0,frameNumber,sif.framesize); %0 is for signal, not background or anything else...

if rc~=22002
    error('Error (Return code 22002) while trying to call frame %i. \nMaybe this frame doesn''t exist? \nOr no file opened -- atsif_closefile()', frameNumber)
end

img = (rot90(reshape(tmp, sif.width, sif.height)));
expT=str2double(sif.properties.ExposureTime); %get exposure time
img=img/expT; %normalize img by exposure time

end

