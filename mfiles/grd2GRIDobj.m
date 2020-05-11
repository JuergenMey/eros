function Z = grd2GRIDobj(filename,G) 
%
% Read Surfer 6 binary grid file (.GRD) and convert to GRIDobj.
%
% The following function library is required, which can be downloaded 
% from e.g. the MATLAB file exchange:
% 
% TopoToolbox - A MATLAB program for the analysis of digital elevation
%               models. (https://github.com/wschwanghart/topotoolbox)
%
% SYNTAX
%
%     Z = grd2GRIDobj(filename)
%     Z = grd2GRIDobj(filename,G)
%
% INPUT (required)
%
%     filename    file name (string)
%
% INPUT (optional)
%
%     G    template grid (class: GRIDobj) used to provide georeference data
%          G has to be the same size as the .GRD file 
%
% OUTPUT
%
%     Z    data (ex: elevation)
%
% EXAMPLE
%               DEM1 = GRIDobj('srtm_bigtujunga30m_utm11.tif');
%               GRIDobj2grd(DEM1,'srtm_bigtujunga30m_utm11.alt');
%               DEM2 = grd2GRIDobj('srtm_bigtujunga30m_utm11.alt',DEM1)
%
% Author: Juergen Mey (juemey[at]uni-potsdam.de) modified after Davy (2017)
% https://osur.univ-rennes1.fr/eros/index.php/matlab-functions/ 
% Date: 28. May, 2020


fid = fopen(filename,'rb');

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
fclose(fid);

% Nodata values are set to NaN for visual representation reasons
grd(grd == -9999) = NaN;

if nargin == 1
    Y = 0:cs:cs*sizeY-cs;
    X = 0:cs:cs*sizeX-cs;
    Z = GRIDobj(Y,X,flipud(grd));
else
    Z = GRIDobj(G);
    Z.Z = grd;
end


