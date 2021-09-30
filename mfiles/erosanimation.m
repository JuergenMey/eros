function [F] = erosanimation(variable,varargin)
% Visualize output of the EROS landscape evolution model as animations (LEM)
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
%   erosanimation creates movie frames of landscape evolution either in
%   profile view, map view or in 3d.
%
%
% INPUT (required)
%
%   variable       variable of interest (string)
%                  'topo'       Topographic elevation
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
%                  'profile'    custom profile, second argument needs to be a DEM (GRIDobj)
%                  'sprofile'   stream long profile, second argument needs to be a DEM (GRIDobj)
%
% INPUT (optional)
%
%   Parameter name/value pairs (pn,pv,...)
%
%   'mode'         visualization mode (string) (default: 'movie2')
%
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
%   F              movie frames
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
expectedInput_variable = {'topo','water','sediment','flux','qs',...
    'discharge','downward','stress','hum','slope','capacity','stock','sprofile','profile'};
addRequired(p,'variable',@(x) any(validatestring(x,expectedInput_variable)));
if strcmp(variable,'sprofile') || strcmp(variable,'profile')
    addRequired(p,'dem',@(x)isa(x,'GRIDobj'));
    default_flowmin = 100;
    addParameter(p,'flowmin',default_flowmin,@isnumeric);
    parse(p,variable,varargin{:});
    dem = p.Results.dem;
    flowmin = p.Results.flowmin;
else
    default_mode = 'movie2';
    expectedInput_mode = {'movie2','movie3'};
    addParameter(p,'mode',default_mode,@(x) any(validatestring(x,expectedInput_mode)));
    default_viewdir = [45,45];
    addParameter(p,'viewdir',default_viewdir,@isnumeric);
    parse(p,variable,varargin{:});
    mode = p.Results.mode;
    viewdir = p.Results.viewdir;
end



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
    case 'flux'
        filetype = 'flux';
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

if strcmp(variable,'sprofile')
    FD = FLOWobj(dem,'preprocess','c');
    S = STREAMobj(FD,flowacc(FD)>flowmin);
    S2 = modify(S,'interactive','reachselect');
    marker = round(linspace(1,length(S2.distance),10));
    H = dir('*.alt');
    W = dir('*.water');
    S = dir('*.sed');
    D = dir('*.flux');
    
    [~,index] = sortrows({H.date}.');
    H = H(index);
    W = W(index);
    S = S(index);
    D = D(index);
    
    for i = 1:length(D)
        [z,~] = fopengrd(D(i).name);
        z(z==0)=NaN;
        B(:,:,i) = z;
    end
    
    sed = grd2GRIDobj(S(1).name,dem);
    w = waitbar(1/length(H),['Collecting movie frames ... ']);
    for i=1:length(H)
        h=figure;
        subplot(2,1,1)
        water2 = grd2GRIDobj(W(i).name,dem);
        dem2 = grd2GRIDobj(H(i).name,dem);
        sed2 = grd2GRIDobj(S(i).name,dem);
        plotdz(S2,dem,'color',[0.9 0.9 0.9]);hold on
        plotdz(S2,dem-sed,'color',[0.7 0.7 0.7])
        plotdz(S2,dem2+water2,'color',[0 0.61 1])
        
        plotdz(S2,dem2,'color',[1 0.5 0.1]);hold on
        plotdz(S2,dem2-sed2,'color','k')
        xlim([0 S2.distance(end)])
        yl(i,1:2) = ylim;
        ylim([yl(1,1),yl(1,2)+20]);
        title(['Time = ',num2str(i),''])
        xlabel('Distance (m)')
        ylabel('Elevation (m)');
        legend({'Initial topo','Initial bedrock','Water','Sediment','Bedrock'},'Location','northwest')
        legend('boxoff')
        
        
        subplot(2,1,2)
        flux = grd2GRIDobj(D(i).name,dem);
        flux.Z(flux.Z==0)=NaN;
        imageschs(dem2,flux,'colormap','flowcolor','caxis',[nanmin(B(:)),nanmax(B(:))],'colorbarylabel','Water discharge (m^3/s)');
        hold on;
        plot(S2,'k--')
%         scatter(S2.x(marker),S2.y(marker),'k')
        text(S2.x(marker),S2.y(marker),num2str(round(S2.distance(marker)/1000)),'FontWeight','bold')
        x0=10;
        y0=10;
        width=2200;
        height=1900/2;
        set(gcf,'position',[x0,y0,width,height])
        set(gcf,'Visible','off')
        F(i) = getframe(gcf);
        close all
        waitbar(i/length(H))
    end
    close(w)
elseif strcmp(variable,'profile')
    H = dir('*.alt');
    W = dir('*.water');
    S = dir('*.sed');
    D = dir('*.flux');
    
    [~,index] = sortrows({H.date}.');
    H = H(index);
    W = W(index);
    S = S(index);
    D = D(index);
    
    for i = 1:length(D)
        [z,~] = fopengrd(D(i).name);
        z(z==0)=NaN;
        B(:,:,i) = z;
    end
    
    
    sed = grd2GRIDobj(S(1).name,dem);
    [d,z,x,y] = demprofile(dem);
    [~,sz0] = demprofile(sed,[],x,y);
    
    w = waitbar(1/length(H),['Collecting movie frames ... ']);
    for i=1:length(H)
        h=figure;
        subplot(2,1,1)
        water2 = grd2GRIDobj(W(i).name,dem);
        dem2 = grd2GRIDobj(H(i).name,dem);
        sed2 = grd2GRIDobj(S(i).name,dem);
        [~,hz] = demprofile(dem2,[],x,y);
        [~,wz] = demprofile(water2,[],x,y);
        [~,sz] = demprofile(sed2,[],x,y);
        
        plot(d,z,'color',[0.9 0.9 0.9]);hold on
        plot(d,z-sz0,'color',[0.7 0.7 0.7])
        plot(d,hz+wz,'color',[0 0.61 1])
        
        plot(d,hz,'color',[1 0.5 0.1]);hold on
        plot(d,hz-sz,'color','k')
        xlim([0 d(end)])
        yl(i,1:2) = ylim;
        ylim([yl(1,1),yl(1,2)+20]);
        title(['Time = ',num2str(i),''])
        xlabel('Distance (m)')
        ylabel('Elevation (m)');
        
        
        subplot(2,1,2)
        flux = grd2GRIDobj(D(i).name,dem);
        flux.Z(flux.Z==0)=NaN;
        imageschs(dem2,flux,'colormap','flowcolor','caxis',[nanmin(B(:)),nanmax(B(:))],'colorbarylabel','Water discharge (m^3/s)');
        hold on;
        plot(x,y,'k--')
        text(x(1)+10,y(1)+10,'left');
        text(x(end)+10,y(end)+10,'right');
        x0=10;
        y0=10;
        width=2200;
        height=1900/2;
        set(gcf,'position',[x0,y0,width,height])
        set(gcf,'Visible','off')
        F(i) = getframe(gcf);
        close all
        waitbar(i/length(H))
    end
    close(w)
else
    
    T = dir('*.ini');
    Z = dir(['*.',filetype]);
    [t,~] = fread_timeVec(T.name,length(Z));
    if isempty(t)
        t=1:length(Z);
    end
    if isnan(t)
        t=1:length(Z);
    end
    
    [~,index] = sortrows({Z.date}.');
    Z = Z(index);
    for i = 1:length(Z)
        [z,~] = fopengrd(Z(i).name);
        z(z==0)=NaN;
        B(:,:,i) = z;
    end
    switch mode
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
                %imageschs(h,z,'colormap',colors,'caxis',[0,1],'colorbarylabel',iylabel);
                imageschs(h,z,'colormap',colors,'caxis',[nanmin(B(:)),nanmax(B(:))],'colorbarylabel',iylabel);
                %set(gca,'ColorScale','log')
                title(['Time = ',num2str(t(i)),''])
                x0=10;
                y0=10;
                width=2200;
                height=1900;
                set(gcf,'position',[x0,y0,width,height])
                set(gcf,'Visible','off')
                F(i) = getframe(gcf);
                close all
                waitbar(i/length(H))
            end
            close(w)
            
        case 'movie3'
            H = dir('*.alt');
            [~,index] = sortrows({H.date}.');
            H = H(index);
            w = waitbar(1/length(H),['Collecting movie frames ... ']);
            for i = 1:length(H)
                h = grd2GRIDobj(H(i).name);
                [xm,ym] = getcoordinates(h);
                axis off
                surface(xm,ym,h.Z,'EdgeColor','none');colorbar
                view(viewdir(1),viewdir(2))
                axis equal
                c = colorbar;
                c.Label.String = 'Elevation (m)';
                colormap(landcolor)
                caxis([nanmin(B(:)),nanmax(B(:))])
                title(['Time = ',num2str(t(i)),''])
                set(gcf,'Visible','off')
                F(i) = getframe(gcf);
                close all
                waitbar(i/length(H))
            end
            close(w)
            
    end
    
    
end