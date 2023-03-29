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
%   F = erosanimation(variable)
%   F = erosanimation(variable,pn,pv,...)
%   F = erosanimation('profile',LEM);
%   F = erosanimation('sprofile',LEM);
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
%                  'profile'    custom profile, second argument needs to be
%                               a structure like the one created by eros.m
%                  'sprofile'   stream long profile, second argument needs
%                               to be a structure like the one created by
%                               eros.m. 
%                  LEM          Structure required only for 'profile' and
%                               'sprofile'.
%
% INPUT (optional)
%
%   Parameter name/value pairs (pn,pv,...)
%
%   'flowmin'      Controls the initiation of streams in the STREAMobj 
%                  (default: 100). Only works with 'sprofile'. 
%
%   'mode'         visualization mode (string) (default: 'movie2')
%
%                  'movie2'     2d movie of variable
%                  'movie3'     3d movie of topographic evolution
%
%   'viewdir'      view geometry specified as 2-element vector of azimuth
%                  and elevation (default: [45,45])
%                  only aplies to mode 'movie3'
%
% OUTPUT
%
%   F              movie frames
%
% EXAMPLE
%
%   Run the example that comes with the Eros download and:
%
%       1. make an 2d-animation of water discharge and use the returned
%          frames to construct an animated .gif
%           LEM = eros;
%           F = erosanimation('flux');
%           frames2gif(B,'flux.gif',0.1)
%
%       2. make an 3d-animation of topography with sediment overlay            
%           LEM = eros;
%           F = erosanmimation('sediment','mode','movie3');
%           frames2gif(F,'sed3.gif',0.1)
%
%       3. long-profile evolution
%           LEM = eros;
%           F = erosanmimation('sprofile',LEM,'flowmin',1000);
%           frames2gif(F,'longprofile.gif,0.1)
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
% Last update: 29. March 2023

p = inputParser;
expectedInput_variable = {'topo','water','sediment','flux','qs',...
    'discharge','downward','stress','hum','slope','capacity','stock','sprofile','profile'};
addRequired(p,'variable',@(x) any(validatestring(x,expectedInput_variable)));
if strcmp(variable,'sprofile') || strcmp(variable,'profile')
    addRequired(p,'LEM',@isstruct);
    default_flowmin = 100;
    addParameter(p,'flowmin',default_flowmin,@isnumeric);
    parse(p,variable,varargin{:});
    dem = p.Results.LEM.dem;
    flowmin = p.Results.flowmin;
    uplift = p.Results.LEM.uplift;
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
    
    % time vector
    T = dir('*.txt');
    [~,index] = sortrows({T.datenum}.');
    T = T(index);
    time = [];
    for i = 1:length(index)
        Ta{i} = readtable(T(i).name);
        try
            time = vertcat(time,Ta{i}{:,1} + Ta{i-1}{end,1}); % this is for the case when a model was continued and more than one .txt file exists
        catch
            time = Ta{i}{:,1};
        end
    end
    T = vertcat(Ta{:});
    
    % boundary conditions
    cols = contains(T.Properties.VariableNames,'q_');
    q = T{:,cols};
    cols = contains(T.Properties.VariableNames,'qs')|contains(T.Properties.VariableNames,'cs');
    cs = T{:,cols};
    
    % output times
    tid = ~strcmp(T{:,end},'-');
    t = time(tid);
    qt = q(tid,:);
    cst = cs(tid,:);
    
    FD = FLOWobj(dem,'preprocess','c');
    S = STREAMobj(FD,flowacc(FD)>flowmin);
    h =figure;
    S2 = modify(S,'interactive','reachselect');
    close(h)
    H = dir('*.alt');
    W = dir('*.water');
    S = dir('*.sed');
    D = dir('*.flux');
    
    [~,index] = sortrows({H.datenum}.');
    H = H(index);
    W = W(index);
    D = D(index);
    try % in case there is no sediment involved
        S = S(index);
        sed = grd2GRIDobj(S(1).name,dem);
    catch
        sed = dem;
        sed.Z = zeros(dem.size);
    end
    
    
    w = waitbar(1/length(H),['Collecting movie frames ... ']);
    for i=1:length(H)
        figure;
        subplot(2,2,[1 2])
        water2 = grd2GRIDobj(W(i).name,dem);
        dem2 = grd2GRIDobj(H(i).name,dem);
        try % in case there is no sediment involved
            sed2 = grd2GRIDobj(S(i).name,dem);
        catch
            sed2 = sed;
        end
        plotdz(S2,dem,'color',[0.9 0.9 0.9]);hold on % initial river profile
        plotdz(S2,dem-sed,'color',[0.7 0.7 0.7]) % initial bedrock profile
        plotdz(S2,dem2+water2,'color',[0 0.61 1]) % water surface
        
        plotdz(S2,dem2,'color',[1 0.5 0.1]);hold on % updated river profile
        plotdz(S2,dem2-sed2,'color','k')    % updated bedrock profile
        xlim([0 S2.distance(end)])
        yl(i,1:2) = ylim;
        ylim([yl(1,1),yl(i,2)+20]);
        title(['Time = ',sprintf('%1.0f',round(t(i)/1e+3,1)),' kyrs'])
        xlabel('Distance (m)')
        ylabel('Elevation (m)');
        legend({'Initial topo','Initial bedrock','Water','Sediment','Bedrock'},'Location','northwest')
        legend('boxoff')
        x0=10;
        y0=10;
        width=2200;
        height=1900;
        set(gcf,'position',[x0,y0,width,height])
        set(gcf,'Visible','off')
        
        subplot(2,2,3)
        plot(time,q(:,1));
        hold on
        plot(t(i),qt(i,1),'o',...
            'LineWidth',2,...
            'MarkerSize',10,...
            'MarkerEdgeColor','k',...
            'MarkerFaceColor',[0 0.45 0.74])
        xlabel('Time')
        ylabel('Water flux (m^3s^-^1)')
        xlim([0 max(time)])
        legend('q\_in')
        
        subplot(2,2,4)
        plot(time,cs);
        hold on
        plot(t(i),cst(i,1),'o',...
            'LineWidth',2,...
            'MarkerSize',10,...
            'MarkerEdgeColor','k',...
            'MarkerFaceColor',[0 0.45 0.74])
        hold on
        plot(t(i),cst(i,2),'o',...
            'LineWidth',2,...
            'MarkerSize',10,...
            'MarkerEdgeColor','k',...
            'MarkerFaceColor',[0.85 0.33 0.1])
        xlabel('Time')
        ylabel('Sediment concentration, q_s/q')
        xlim([0 max(time)])
        legend('cs\_in','cs\_out')
        F(i) = getframe(gcf);
        close all
        waitbar(i/length(H))
    end
    close(w)
elseif strcmp(variable,'profile')
    
    % time vector
    T = dir('*.txt');
    [~,index] = sortrows({T.datenum}.');
    T = T(index);
    time = [];
    for i = 1:length(index)
        Ta{i} = readtable(T(i).name);
        try
            time = vertcat(time,Ta{i}{:,1} + Ta{i-1}{end,1}); % this is for the case when a model was continued and more than 1 .txt file exists
        catch
            time = Ta{i}{:,1};
        end
    end
    T = vertcat(Ta{:});
    
    % boundary conditions
    cols = contains(T.Properties.VariableNames,'q_');
    q = T{:,cols};
    cols = contains(T.Properties.VariableNames,'qs')|contains(T.Properties.VariableNames,'cs');
    cs = T{:,cols};
    
    % output times
    tid = ~strcmp(T{:,end},'-');
    t = time(tid);
    qt = q(tid,:);
    cst = cs(tid,:);
    H = dir('*.alt');
    W = dir('*.water');
    S = dir('*.sed');
    D = dir('*.flux');
    
    
    [~,index] = sortrows({H.datenum}.');
    H = H(index);
    W = W(index);
    D = D(index);
    try % in case there is no sediment involved
        S = S(index);
        sed = grd2GRIDobj(S(1).name,dem);
    catch
        sed = dem;
        sed.Z = zeros(dem.size);
    end
    
    [d,~,x,y] = demprofile(dem);            % distance, x and y values of the profile
    [~,urate] = demprofile(uplift,[],x,y);  % uplift rates along the profile
    close all
    colors = colormap(flipud(parula));
    if sum(cst(:,1))~=0
        color = interp1(linspace(min(cst(:,1)),max(cst(:,1)),length(colors)),colors,cst(:,1)); % map color to y values
    else
        color = interp1(linspace(min(cst(:,2)),max(cst(:,2)),length(colors)),colors,cst(:,2)); % map color to y values
    end
    duration = length(H);
    w = waitbar(1/length(H),['Collecting movie frames ... ']);
    for i=1:duration
        figure;
        subplot(3,3,[5 6 8 9])
        water2 = grd2GRIDobj(W(i).name,dem);
        dem2 = grd2GRIDobj(H(i).name,dem);
        try % in case there is no sediment involved
            sed2 = grd2GRIDobj(S(i).name,dem);
        catch
            sed2 = sed;
        end
        [~,hz(:,i)] = demprofile(dem2,[],x,y);   % topography
        [~,wz] = demprofile(water2,[],x,y); % water surface
        [~,sz] = demprofile(sed2,[],x,y);   % sediment thickness
        
        f = size(hz,2):-1:1;
        ff = ones(size(hz));
        ufac = (f-1.*ff).*1e+3;
        plot(d,hz(:,i)+wz,'color',[0 0.61 1],'LineWidth',1); hold on       % water surface
        if i>=2
            id=hz(:,1:i)+urate.*ufac(:,1:i)>hz(:,i)+urate.*ufac(:,i);
            hz(id)=NaN;
            colororder(color(1:i,:))
            plot(d,hz+urate.*ufac,'LineWidth',1);hold on
            plot(d,hz(:,1)+urate.*ufac(:,1),'color',[0.5 0.5 0.5],'LineWidth',1);hold on % first sediment layer
        end
        plot(d,hz(:,end)-sz,'color','k','LineWidth',1)               % bedrock surface
        xlim([0 d(end)])
        ylim([min(hz(:,end)-sz) max(hz(:,end))])
        title([num2str(i),' kyr'])
        xlabel('Distance (m)')
        ylabel('Elevation (m)');
        
        subplot(3,3,[4])
        plot(time,q(:,1),'color',[0 0.61 1]);
        hold on
        plot(t(i),qt(i,1),'o',...
            'LineWidth',2,...
            'MarkerSize',10,...
            'MarkerEdgeColor','k',...
            'MarkerFaceColor',[0 0.61 1])
        xlabel('Time (yr)')
        ylabel('Water flux (m^3s^-^1)')
        legend('q\_in','Location','southwest')
        xlim([0 max(time)])
        legend('boxoff');
        
        subplot(3,3,[7])
        h=plot(t,cst(:,1));
        cd1 = uint8(color'*255); % need a 4xN uint8 array
        cd1(4,:) = 255; % last column is transparency
        hold on
        plot(time,cs(:,2),'Color',[0.85 0.33 0.1]);
        plot(t(i),cst(i,1),'o',...
            'LineWidth',2,...
            'MarkerSize',10,...
            'MarkerEdgeColor','k',...
            'MarkerFaceColor',color(i,:))
        plot(t(i),cst(i,2),'o',...
            'LineWidth',2,...
            'MarkerSize',10,...
            'MarkerEdgeColor','k',...
            'MarkerFaceColor',[0.85 0.33 0.1])
        xlabel('Time (yr)')
        ylabel('Sediment concentration, q_s/q')
        legend('cs\_in','cs\_out')
        legend('boxoff')
        xlim([0 max(time)])
        subplot(3,3,1:3)
        flux = grd2GRIDobj(D(i).name,dem);
        flux.Z(flux.Z==0)=NaN;
        try
            imageschs(dem2,flux,'colormap','flowcolor','colorbarylabel','Water discharge (m^3/s)');
        catch
            imageschs(dem2,flux,'colormap','flowcolor','caxis',[0,100],'colorbarylabel','Water discharge (m^3/s)');
        end
        hold on;
        plot(x,y,'k')
        x0=10;
        y0=10;
        width=2200;
        height=1900/2;
        set(gcf,'position',[x0,y0,width,height])
        set(h.Edge,'ColorBinding','interpolated','ColorData',cd1)
        set(gcf,'Visible','off')
        F(i) = getframe(gcf);
        close all
        waitbar(i/duration)
    end
    close(w)
else
    % time vector
    T = dir('*.txt');
    [~,index] = sortrows({T.datenum}.');
    T = T(index);
    time = [];
    for i = 1:length(index)
        Ta{i} = readtable(T(i).name);
        try
            time = vertcat(time,Ta{i}{:,1} + Ta{i-1}{end,1}); % this is for the case when a model was continued and more than 1 .txt file exists
        catch
            time = Ta{i}{:,1};
        end
    end
    T = vertcat(Ta{:});
    
    % boundary conditions
    cols = contains(T.Properties.VariableNames,'q_');
    q = T{:,cols};
    cols = contains(T.Properties.VariableNames,'qs')|contains(T.Properties.VariableNames,'cs');
    cs = T{:,cols};
    
    % variable
    Z = dir(['*.',filetype]);
    t=1:length(Z);
    [~,index] = sortrows({Z.datenum}.');
    Z = Z(index);
    for i = 1:length(Z)
        [z,~] = fopengrd(Z(i).name);
        z(z==0)=NaN;
        B(:,:,i) = z;
    end
    
    % output times
    tid = ~strcmp(T{:,end},'-');
    t = time(tid);
    qt = q(tid,:);
    cst = cs(tid,:);
    
    switch mode
        case 'movie2'
            H = dir('*.alt');
            Z = dir(['*.',filetype]);
            [~,index] = sortrows({H.datenum}.');
            H = H(index);
            Z = Z(index);
            w = waitbar(1/length(H),['Collecting movie frames ... ']);
            for i = 1:length(H)
                figure
                subplot(2,2,[1 2])
                h = grd2GRIDobj(H(i).name);
                z = grd2GRIDobj(Z(i).name);
                z.Z(z.Z==0)=NaN;
                try
                    imageschs(dem2,flux,'colormap','flowcolor','colorbarylabel','Water discharge (m^3/s)');
                catch
                    imageschs(dem2,flux,'colormap','flowcolor','caxis',[0,100],'colorbarylabel','Water discharge (m^3/s)');
                end
                title(['Time = ',sprintf('%1.0f',round(t(i)/1e+3,1)),' kyrs'])
                x0=10;
                y0=10;
                width=2200;
                height=1900;
                set(gcf,'position',[x0,y0,width,height])
                set(gcf,'Visible','off')
                
                subplot(2,2,3)
                plot(time,q(:,1));
                hold on
                plot(t(i),qt(i,1),'o',...
                    'LineWidth',2,...
                    'MarkerSize',10,...
                    'MarkerEdgeColor','k',...
                    'MarkerFaceColor',[0 0.45 0.74])
                xlabel('Time')
                ylabel('Water flux (m^3s^-^1)')
                legend('q\_in')
                
                if ~isempty(cs)
                    subplot(2,2,4)
                    plot(time,cs);
                    hold on
                    plot(t(i),cst(i,1),'o',...
                        'LineWidth',2,...
                        'MarkerSize',10,...
                        'MarkerEdgeColor','k',...
                        'MarkerFaceColor',[0 0.45 0.74])
                    hold on
                    plot(t(i),cst(i,2),'o',...
                        'LineWidth',2,...
                        'MarkerSize',10,...
                        'MarkerEdgeColor','k',...
                        'MarkerFaceColor',[0.85 0.33 0.1])
                    xlabel('Time')
                    ylabel('Sediment concentration, q_s/q')
                    legend('cs\_in','cs\_out')
                end
                F(i) = getframe(gcf);
                close all
                waitbar(i/length(H))
            end
            close(w)
            
        case 'movie3'
            H = dir('*.alt');
            W = dir(['*.',filetype]);
            [~,index] = sortrows({H.datenum}.');
            H = H(index);
            W = W(index);
            wb = waitbar(1/length(H),['Collecting movie frames ... ']);
            for i = 2:length(H)
                h = grd2GRIDobj(H(i).name);
                w = grd2GRIDobj(W(i).name);
                erossurf2(h,w);
                title(['Time = ',num2str(t(i)),''])
                x0=10;
                y0=10;
                width=2200;
                height=1900;
                set(gcf,'position',[x0,y0,width,height])
                set(gcf,'Visible','off')
                F(i-1) = getframe(gcf);
                close all
                waitbar(i/length(H))
            end
            close(wb)
            
    end
    
    
end