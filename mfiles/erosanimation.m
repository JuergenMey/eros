function [B,varargout] = erosanimation(variable,varargin)
% Visualize output of the EROS landscape evolution model (LEM)
%
%
% The following function library is required, which can be downloaded
% from e.g. the MATLAB file exchange:
%
% TopoToolbox - A MATLAB program for the analysis of digital elevation
%               models. (https://github.com/wschwanghart/topotoolbox)
%
%
% SYNTAX
%
%   B = erosanimation(variable)
%   B = erosanimation(variable,pn,pv,...)
%
%
% DESCRIPTION
%
%   erosanimation shows timeseries data either as grid average or as 2d/3d movie
%
%
% INPUT (required)
%
%   variable       variable of interest (string)
%                  'elevation'  Topographic elevation
%                  'sediment'   Sediment thickness
%                  'water'      Water depth
%                  'discharge'  Water discharge
%                  'qs'         Unit-sediment flux
%                  'downward'   Flow orientation
%                  'stress'     Shear stress
%                  'slope'      Stream slope
%                  'capacity'   Stream capacity
%                  'stock'      Sediment stock
%                  'hum'        Water discharge on the topography
%                  'rain'       Sources (>0) and sinks (-1) of water and sediment
%
% INPUT (optional)
%
%   Parameter name/value pairs (pn,pv,...)
%
%   'mode'         visualization mode (string) (default: 'movie2')
%                  'average'    shows the evolution of the spatial average
%                               of the variable defined as required input
%                  'movie2'     2d movie of variable
%                  'movie3'     3d movie of topographic evolution
%
%   'viewdir'      view geometry specified as 2-element vector of azimuth
%                  and elevation (default: [45,45])
%                  only apllies to mode 'movie3'
%
%
%
% OUTPUT
%
%   B              movie frames captured with modes 'movie2' and 'movie3'
%   B              (mode='average') 3d array of the variable of interest.
%
%
% OUTPUT (optional)
%
%   meanB       spatial average of variable through time           
%
% EXAMPLE
%
%   Run the example that comes with the Eros download and:
%
%       1. make an 2d-animation of sediment thickness and use the returned
%          frames to construct an animated .gif
%
%           eros_template.m
%           B = erosanimation('sediment');
%           frames2gif(B,'sediment.gif',0.1)
%
%       2. plot the average sediment thickness versus time
%
%           B = erosanimation('sediment','mode','average');
%
%       3. make an 3d-animation of topography and return frames
%
%           B = erosanmimation('topo','mode','movie3');
%
% REFERENCES:
%
% Davy, P., & Lague, D. (2009). Fluvial erosion/transport equation of land-
%  scape evolution models revisited. Journal of Geophysical Research, 114,
%  116. https://doi.org/10.1029/2008JF001146.
%
% Davy, P., Croissant, T., & Lague, D. (2017). A precipiton method to cal-
%  culate river hydrodynamics, with applications to flood prediction, land-
%  scape evolution models, and braiding instabilities. Journal of
%  Geophysical Research: Earth Surface, 122, 14911512.
%  https://doi.org/10.1002/2016JF004156
%
%
% Author: Juergen Mey (juemey[at]uni-potsdam.de)
% Date: 28. May, 2020

p = inputParser;
expectedInput_variable = {'topo','water','sediment','qs',...
    'discharge','downward','stress','hum','slope','capacity','stock'};
addRequired(p,'variable',@(x) any(validatestring(x,expectedInput_variable)));

default_mode = 'movie2';
expectedInput_mode = {'average','movie2','movie3'};
addParameter(p,'mode',default_mode,@(x) any(validatestring(x,expectedInput_mode)));

default_viewdir = [45,45];
addParameter(p,'viewdir',default_viewdir,@isnumeric);

parse(p,variable,varargin{:});

mode = p.Results.mode;
viewdir = p.Results.viewdir;

switch variable
    case 'topo'
        filetype = 'alt';
        iylabel = 'Elevation (m)';
        colors = 'landcolor';
    case 'sediment'
        filetype = 'sed';
        iylabel = 'Sediment thickness (m)';
        colors = 'jet';
    case 'water'
        filetype = 'water';
        iylabel = 'Water depth (m)';
        colors = 'flowcolor';
    case 'capacity'
        filetype = 'capacity';
        iylabel = 'Capacity';
        colors = 'jet';
    case 'discharge'
        filetype = 'discharge';
        iylabel = 'Water discharge (m^3/s)';
        colors = 'flowcolor';
    case 'downward'
        filetype = 'downward';
        iylabel = 'Mean settling velocity (m/s)';
        colors = 'parula';
    case 'hum'
        filetype = 'hum';
        iylabel = 'Water discharge on topography (m^3/s)';
        colors = 'flowcolor';
    case 'qs'
        filetype = 'qs';
        iylabel = 'Sediment flux (m^3/s)';
        colors = 'jet';
    case 'slope'
        filetype = 'slope';
        iylabel = 'Slope';
        colors = 'parula';
    case 'stock'
        filetype = 'stock';
        iylabel = 'Sediment stock (m^3)';
        colors = 'jet';
    case 'stress'
        filetype = 'stress';
        iylabel = 'Shear stress (Pa)';
        colors = 'jet';
end

% determine timesteps

T = dir('*.ini');
Z = dir(['*.',filetype]);
[t,~] = fread_timeVec(T.name,length(Z));
if isempty(t)
    t=1:length(Z);
end

[~,index] = sortrows({Z.date}.');
Z = Z(index);
for i = 1:length(Z)
    [z,~] = fopengrd(Z(i).name);
    B(:,:,i) = z;
    meanB(i)=mean(z(:));
end
switch mode
    case 'average'
                plot(t,meanB)
                ylabel(iylabel);
                xlabel('time');
                grid on
                B=meanB;
    case 'movie2'
        H = dir('*.alt');
        Z = dir(['*.',filetype]);
        [~,index] = sortrows({H.date}.');
        H = H(index);
        Z = Z(index);
        w = waitbar(1/length(H),['Collecting movie frames ... ']);
        for i = 1:length(H)-1
            h = grd2GRIDobj(H(i+1).name);
            z = grd2GRIDobj(Z(i+1).name);
            z.Z(z.Z==0)=NaN;
            imageschs(h,z,'colormap',colors);
            c = colorbar;
            c.Label.String = iylabel;
            caxis([nanmin(B(:)),nanmax(B(:))])
            title(['Time = ',num2str(t(i)),''])
            set(gcf,'Visible','off')
            F(i) = getframe(gcf);
            close all
            waitbar(i/length(H))
        end
        close(w)
        f = figure;
        movie(f,F,1,10)
        close(f)
        B = F;
    case 'movie3'
        H = dir('*.alt');
        %         Z = dir(['*.',filetype]);
        [~,index] = sortrows({H.date}.');
        H = H(index);
        %         Z = Z(index);
        w = waitbar(1/length(H),['Collecting movie frames ... ']);
        for i = 1:length(H)
            h = grd2GRIDobj(H(i).name);
            %             z = grd2GRIDobj(Z(i).name);
            [xm,ym] = getcoordinates(h);
            axis off
            surface(xm,ym,h.Z,'EdgeColor','none');colorbar
            view(viewdir(1),viewdir(2))
            axis equal
            c = colorbar;
            c.Label.String = 'Elevation (m)';
            colormap(landcolor)
            %             caxis([nanmin(B(:)),nanmax(B(:))])
            title(['Time = ',num2str(t(i)),''])
            set(gcf,'Visible','off')
            F(i) = getframe(gcf);
            close all
            waitbar(i/length(H))
        end
        close(w)
        f = figure;
        movie(f,F,1,10)
        close(f)
        B = F;
end