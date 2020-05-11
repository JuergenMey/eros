function [B,varargout] = plotEros(variable,varargin)
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
%   B = plotEros(variable)
%   B = plotEros(variable,pn,pv,...)
%
%
% DESCRIPTION
%
%   plotEros shows timeseries data either as grid average or as 2d/3d movie  
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
%                  'downward'   Average settling velocity
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
%   'mode'         visualization mode (string) (default: 'average') 
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
%   B           3d matrix of the variable of interest.
%   
%
% OUTPUT (optional)
%
%   meanB       spatial average of B through time
%   F           movie frames captured with modes 'movie2' and 'movie3'
%
% EXAMPLE 
%
%   Run the example that comes with the Eros download and: 
%       
%       1. plot the average sediment thickness versus timesteps
%
%           eros_template.m
%           B = plotEros('sediment');
%   
%       2. make an 2d-animation of sediment thickness and return frames
%
%           [B,~,F] = plotEros('sediment','mode','movie2');
%       
%       3. make an 3d-animation of topography and return frames
%       
%           [B,~,F] = plotEros('elevation','mode','movie3');
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
expectedInput_variable = {'elevation','water','sediment','qs',...
    'discharge','downward','stress','hum','slope','capacity','stock'};
addRequired(p,'variable',@(x) any(validatestring(x,expectedInput_variable)));

default_mode = 'average';
expectedInput_mode = {'average','movie2','movie3'};
addParameter(p,'mode',default_mode,@(x) any(validatestring(x,expectedInput_mode)));

default_viewdir = [45,45];
addParameter(p,'viewdir',default_viewdir,@isnumeric);

parse(p,variable,varargin{:});

mode = p.Results.mode;
viewdir = p.Results.viewdir;

switch variable
    case 'elevation'
        filetype = 'alt';
        iylabel = 'Elevation (m)';
    case 'sediment'
        filetype = 'sed';
        iylabel = 'Sediment thickness (m)';
    case 'water'
        filetype = 'water';
        iylabel = 'Water depth (m)';
    case 'capacity'
        filetype = 'capacity';
        iylabel = 'Capacity';
    case 'discharge'
        filetype = 'discharge';
        iylabel = 'Water discharge (m^3/s)';
    case 'downward'
        filetype = 'downward';
        iylabel = 'Mean settling velocity (m/s)';
    case 'hum'
        filetype = 'hum';
        iylabel = 'Water discharge on topography (m^3/s)';
    case 'qs'
        filetype = 'qs';
        iylabel = 'Sediment flux (m^3/s)';
    case 'slope'
        filetype = 'slope';
        iylabel = 'Slope';
    case 'stock'
        filetype = 'stock';
        iylabel = 'Sediment stock (m^3)';
    case 'stress'
        filetype = 'stress';
        iylabel = 'Shear stress (Pa)';
end

% determine timesteps
T = dir('*.txt');
opts = detectImportOptions(T.name);
A = readtable(T.name,opts);

D=table2cell(A(:,end));
idx = contains(D,'W');

A = table2array(A(:,1:end-1));
t = vertcat(0,A(idx,1));

Z = dir(['*.',filetype]);
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
        xlabel('time (s)');
    case 'movie2'
        H = dir('*.alt');
        Z = dir(['*.',filetype]);
        [~,index] = sortrows({H.date}.');
        H = H(index);
        Z = Z(index);
        for i = 1:length(H)
            h = grd2GRIDobj(H(i).name);
            z = grd2GRIDobj(Z(i).name);
%             z.Z(z.Z==0)=NaN;
            imageschs(h,z);
            c = colorbar;
            c.Label.String = iylabel;
            caxis([nanmin(B(:)),nanmax(B(:))])
            title(['Time = ',num2str(t(i)),' s'])
            F(i) = getframe(gcf);
            close all
        end
        f = figure;
        movie(f,F,2,5)
        close(f)
        varargout{2} = F;
    case 'movie3'
        H = dir('*.alt');
%         Z = dir(['*.',filetype]);
        [~,index] = sortrows({H.date}.');
        H = H(index);
%         Z = Z(index);
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
            title(['Time = ',num2str(t(i)),' s'])
            F(i) = getframe(gcf);
            close all
        end
        f = figure;
        movie(f,F,2,5)
        close(f)
        varargout{2} = F;
end

varargout{1} = meanB;