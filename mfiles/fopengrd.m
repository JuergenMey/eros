function [grd,cs] = fopengrd(fN)

% Open Eros output file
%
% Syntax
%
%     [grd,cs] = fopengrd(fN)
%
% Input arguments
%
%     fN    file name
%
% Output arguments
%
%     grd   data (ex: elevation)
%     cs    cell size
%
% Date: 6 February 2017

fid = fopen(fN,'rb');

if fid == -1
   error('Unable to open the requested file')
end

% Read and store header
hdr     = fread(fid,[1 4],'*char');

% Read and store raster properties
sizeX   = fread(fid,1,'short');                                            % grd width                                
sizeY   = fread(fid,1,'short');                                            % grd length
xyzlohi = fread(fid,6,'double');                                           % min/max values of x,y,z

% Scale computation
cs      = (xyzlohi(2)-xyzlohi(1)) / (sizeX-1);                             % cellsize                                           

% Read grid values and store them in a matrix
grd   = fread(fid,[sizeX sizeY],'float');

% Nodata values are set to 0 for visual representation reasons
grd(grd == -9999) = 0;

fclose(fid);