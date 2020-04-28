function GRIDobj2grd(A,filename)
%
% Write a GRD file in Eros format from raster data stored in a GRIDobj.
%
% INPUT
%
%   A           data raster [GRIDobj] (e.g., elevation, discharge, ...)
%   filename    name of the output file [string] (.sed, .alt, .rain ...)
% 
% EXAMPLE: 
%               DEM = GRIDobj('srtm_bigtujunga30m_utm11.tif');
%               GRIDobj2grd(DEM,'srtm_bigtujunga30m_utm11.alt');
%
%
% mofified fwritegrd.m after Philippe Davy (2017) 
% https://osur.univ-rennes1.fr/eros/index.php/matlab-functions/ 

% Open file
fid = fopen(filename,'wb');
if fid == -1
    error('Unable to open the requested file')
end

% Write header
fwrite(fid,'DSBB','char');
fwrite(fid,A.size,'short');
fwrite(fid,0,'double');
fwrite(fid,(A.size(1)-1)*A.cellsize,'double');
fwrite(fid,0,'double');
fwrite(fid,(A.size(2)-1)*A.cellsize,'double');
fwrite(fid,min(A),'double');
fwrite(fid,max(A),'double');

% Write data
fwrite(fid,A.Z,'float');

fclose(fid);