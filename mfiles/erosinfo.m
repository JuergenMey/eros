function [varargout] = erosinfo(variable)
% Visualize output statistics of the EROS landscape evolution model (LEM)
%
%
% SYNTAX
%
%   B = erosinfo(variable)
%
%
% DESCRIPTION
%
%   erosinfo shows timeseries data from the .txt file written during
%   execution of the model and returns the data
%
%
% INPUT (required)
%
%   variable       variable of interest (string)
%
%                  'topo'       Topographic elevation
%                  'topo_std'   Topographic elevation
%                  'water'      Water depth
%                  'q_in'       Water discharge
%                  'q_out'      Water discharge
%                  'qs_in'      Unit-sediment flux
%                  'qs_out'     Unit-sediment flux
%                  'rain'       rain
%                  'dt'     	time steps
%                  'slope'      Stream slope
%                  'dv_p'       dv_p
%                  'dv_h'       dv_h
% 
%                  'time'       modelled time versus computation time 
%                  'all'        show all variables
%
%
%
% OUTPUT
%
%   B           Numeric array of the variable(s). First column is the time 
%               vector. If variable is 'all', B is (type:struct). 
%
%
%
% EXAMPLE
%
%   Run the example that comes with the Eros download and:
%          
%       1. plot the outflux of sediment versus time
%
%           eros_template.m
%           B = erosinfo('qs_out');
%
%       2. plot all variables in a 3-by-3 subplot
%
%           B = erosinfo('all');
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
% Date: 4. June, 2020

p = inputParser;
expectedInput_variable = {'topo','water','q_in','q_out','qs_in','qs_out','slope',...
    'rain','dt','dv_p','dh_p','all','time'};
addRequired(p,'variable',@(x) any(validatestring(x,expectedInput_variable)));

parse(p,variable);

allflag=0;
switch variable
    case 'topo'
        iylabel = 'Elevation (m)';
    case 'sediment'
        iylabel = 'Sediment thickness (m)';
    case {'water','water_max'}
        iylabel = 'Water depth (m)';
    case 'rain'
        iylabel = 'rain';
    case {'q_in','q_out','q'}
        iylabel = 'Water discharge (m^3/s)';
    case 'downward'
        iylabel = 'Flow orientation';
    case 'hum'
        iylabel = 'Water discharge on topography (m^3/s)';
    case {'qs_out','qs_in'}
        iylabel = 'Sediment flux (m^3/s)';
    case 'slope'
        variable = 'slope_eff';
        iylabel = 'Slope (%)';
    case 'dt'
        iylabel = 'Time steps';
    case 'dv_p'
        iylabel = 'dv_p';
        case 'dh_p'
        iylabel = 'dh_p';
    case 'all'
        allflag=1;
    case 'time'
        iylabel = 'Computation time (days)';
end

T = dir('*.txt');
T = readtable(T(1).name);
T(1,:)=[];
time = T{:,1};
Stat.time = time;

figure
if allflag == 1
    cols = contains(T.Properties.VariableNames,'dt');
    Stat.dt = T{:,cols};
    subplot(3,3,1)
    plot(time,T{:,cols});
    xlabel('Time')
    ylabel('dt')
    
    cols = contains(T.Properties.VariableNames,'q_');
    Stat.q = T{:,cols};
    subplot(3,3,2)
    plot(time,T{:,cols});
    xlabel('Time')
    ylabel('Water flux (m^3s^-^1)')
    legend('q\_in','q\_out')
    
    cols = contains(T.Properties.VariableNames,'topo');
    Stat.topo = T{:,cols};
    subplot(3,3,3)
    plot(time,T{:,cols});
    xlabel('Time')
    ylabel('Elevation (m)')
    legend('Mean','std')
    
    cols = contains(T.Properties.VariableNames,'water');
    ncols = contains(T.Properties.VariableNames,'water_nbr');
    cols(ncols)=0;
    Stat.water = T{:,cols};
    subplot(3,3,4)
    plot(time,T{:,cols});
    xlabel('Time')
    ylabel('Water depth (m)')
    legend('Mean','Max')
    
    cols = contains(T.Properties.VariableNames,'slope');
    Stat.slope = T{:,cols};
    subplot(3,3,5)
    plot(time,T{:,cols});
    xlabel('Time')
    ylabel('Slope (%)')
    
    try
    cols = contains(T.Properties.VariableNames,'qs');
    Stat.qs = T{:,cols};
    subplot(3,3,6)
    plot(time,T{:,cols});
    xlabel('Time')
    ylabel('Sediment flux')
    legend('qs_i_n','qs\_out')
    catch
    end
    
    cols = contains(T.Properties.VariableNames,'rain');
    Stat.rain = T{:,cols};
    subplot(3,3,7)
    plot(time,T{:,cols});
    xlabel('Time')
    ylabel('Rain')
    
    cols = contains(T.Properties.VariableNames,'dv_p');
    Stat.dv_p = T{:,cols};
    subplot(3,3,8)
    plot(time,T{:,cols});
    xlabel('Time')
    ylabel('dv\_p')
    
    cols = contains(T.Properties.VariableNames,'dh_p');
    Stat.dh_p = T{:,cols};
    subplot(3,3,9)
    plot(time,T{:,cols});
    xlabel('Time')
    ylabel('dh\_p')
    
    varargout{1} = Stat;
    
        
elseif strcmp(variable,'time')
    H = dir('*.alt');
    [~,index] = sortrows({H.datenum}.');
    H = H(index);
    datenum = extractfield(H,'datenum');
    plot(1:length(H),datenum-datenum(1))
    xlabel('Model time (yr)')
    ylabel('Computational time (d)')
else
    cols = strcmp(T.Properties.VariableNames,variable);
    varargout{1}=horzcat(time,T{:,cols});
    plot(time,T{:,cols});
    xlabel('Time')
    ylabel(iylabel)
    legend(T.Properties.VariableNames(cols))
end
