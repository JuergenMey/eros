function [LEM] = eros(varargin)
% Function to run the landscape evolution model EROS
%
%     The following function library is required, which can be downloaded
%     from e.g. the MATLAB file exchange:
%
%     TopoToolbox - A MATLAB program for the analysis of digital elevation
%               models. (https://github.com/wschwanghart/topotoolbox)
%
% Syntax !bin folder needs to reside in the working directory!
%
%     LEM = eros
%     LEM = eros(dem)
%     LEM = eros(dem,pn,pv,...)
%
% Description
%
%     EROS follows a particle based approach where elemental water units   
%	  (precipitons) are routed over the topography.	On their path the 2d 
%     shallow water equation is solved including both basal and lateral 
%     erosion and deposition. It is also referred to as Xi-q model, with Xi
%     being the deposition length parameter, and as such it accounts for 
%     the transition between detachment-limited to transport-limited 
%     behavior (see Davy et al., 2017). 
%     
%     If called without any input eros will run an example based on the
%     Big Tujunga DEM that comes with TopoToolbox.
%
% Input
%
%     dem         digital elevation model (GRIDobj)
%
% Parameter name/value pairs
%
%     GRIDS
%
%     rain             number or GRIDobj. [m/yr/m^2]. Water inflow boundary 
%                      condition, including precipitation AND stream inflow 
%                      at the inlets. If a single number is passed it will 
%                      be interpreted as precipitation that is uniformly 
%                      distributed over the model domain. 
%                      Discharge at inlet has to be provided in [m/yr/m^2].
%                      i.e. m3/s => m/yr/yr^2:
%                      m3/s*seconds_per_year/ninletcells/cellsize^2.   
%     uplift           number (default: 0.002) or GRIDobj. [m/yr]. 
%                      If a single number is passed it will be 
%                      interpreted as spatially uniform uplift.                     
%     cs               number (default: 0) or GRIDobj. Volumetric sediment 
%                      concentration at the inlets (qs/q). 
%     sediment         number (default: 2) or GRIDobj. [m]. Sediment 
%                      thickness. A single value will be interpreted as a
%                      uniform sediment thickness distribution.
%     water            number (default: 0) or GRIDobj. [m] Initial water 
%                      depth. Sometimes it is advisable to provide an
%                      initial water depth distribution e.g. when there are
%                      large lakes in the domain.
%
%     OTHER  
%
%     climate          n-by-3 element vector. Allows for using a timeseries
%                      of water and sediment inflows. First row is time,
%                      second row is relative discharge wrt the rain-file
%                      and third row is the absolute sediment concentration
%     ...              description of more parameters will follow
%     
%
% Output
%
%     LEM         [struct] structure containing all inputs
%
%
% Example 1: Geomorphic simulation over 10 kyrs using Big Tujunga 
%            topography and default rain (1 m/yr), uplift (0.002 m/yr) and 
%            sediment thickness (2 m).   
%
%            LEM = eros;
%            cd LEM.outfolder
%            frames2gif(erosanimation('flux'),'flux.gif',0.1);
%
% Example 2: Simulation using a climate-file (i.e. inflow timeseries) 
%     
%            dem = GRIDobj('srtm_bigtujunga30m_utm11.tif');
%            A=zeros(11,3);
%            A(:,1)=0:1000:10000;
%            A(1:5,2)=ones(5,1)*1;
%            A(6:11,2)=ones(6,1)*3;
%            LEM = eros(dem,'climate',A)
%            cd(LEM.outfolder)
%            erosinfo('q_out');
%   
%
% References
%
%     Davy, P., Croissant, T., & Lague, D. (2017). A precipiton method to 
%     calculate river hydrodynamics, with applications to flood prediction, 
%     landscape evolution models, and braiding instabilities. Journal of 
%     geophysical research: earth surface, 122(8), 1491-1512.
%
% See also: erosanimation, erosinfo
%
% Author: Juergen Mey (juemey[at].uni-potsdam.de)
% Date: 29. March 2023

%############## DEFAULTS #################################
% grids
default_dem = GRIDobj('srtm_bigtujunga30m_utm11.tif');
default_rain = 1;                                                           % precipitation (m/yr)
default_uplift = 0.002;                                                     % uplift rate (m/yr)
default_sediment = 2;                                                       % sediment thickness (m)
default_cs = 0;                                                             % inflow sediment concentration (volumetric)
default_water = 0;                                                          % initial water depth (m)

% other
default_climate = 0;                                                        % inflow timeseries
default_experiment = 'run';                                                 % name of experiment
default_model = 'eros';                                                     % model: eros or floodos
default_eros_version = 'eros8.0.131M';                                      % model version
default_outfolder = 'out\\out';                                             % output folder
default_overwrite = false;                                                      % overwrite ouput option
default_inertia = 0;                                                        % inertia of precipitons (!computation time)

% time
default_time_unit = 'year';                                                 % time unit: year or seconds
default_begin = 0;
default_end = 1e+4;                                                     
default_draw = 1e+3;                                                        % output interval
default_step = 250;                                                         % step
default_stepmin = 0.1e1;
default_stepmax = 1e4;
default_begin_option = 'time';
default_end_option = 'time';
default_draw_option = 'time';
default_step_option = 'volume:adapt';
default_TU = 'TU:surface=rain:coefficient=0.001';
default_erosion_multiplier = 1000;                                          % enhance the erosion by this factor for each precipiton
default_erosion_multiplier_increment = '3:log10';
default_erosion_multiplier_op = '*';
default_erosion_multiplier_min = 1000;                                      % smallest erosion_multiplier during calculation
default_erosion_multiplier_max = 1000';                                     % largest erosion_multiplier during calculation;
default_erosion_multiplier_default_min = 10000;                             % minimum number of defaults that triggers a time step increase
default_erosion_multiplier_default_max = 20000;                             % maximum number of defaults that triggers a time step decrease
default_time_extension = 2e+3;

% erosion/deposition
default_erosion_model = 'MPM';                                              % (stream_power, shear_stress, shear_mpm)
default_deposition_model = 'constant';                                      % need to know whether there are other options!
default_stress_model = 'rgqs';                                              % stress calculation: rgqs or rghs
default_limiter_dh = 0.1;                                                   % define how excessive must be the topography variations to trigger defaults
default_limiter_mode = 'unclip';                                            % determine whether triggering of defaults changes topography or not
default_fluvial_stress_exponent = 1.5;                                      % exponent in sediment flux eq. (MPM): qs = E(tau-tau_c)^a
default_fluvial_sediment_erodability = 2.6e-8;                              % [kg-1.5 m-3.5 s-2] E in MPM equation
default_fluvial_sediment_threshold = 0.05;                                  % [Pa] critical shear stress (tau_c) in MPM equation
default_deposition_length = 60;                                             % [m] xi in vertical erosion term: edot = qs/xi
default_fluvial_lateral_erosion_coefficient = 1e-2;                         % dimensionless coefficient (Eq. 17 in Davy et al., (2017))
default_fluvial_lateral_deposition_coefficient = 1e-2;                      % dimensionless coefficient (Eq. 18 in Davy et al., (2017))
default_lateral_erosion_model = 1;                                          % 0 or 1: constant/0: prop. to bed erosion; bedslope/1(default): prop. to bed erosion by bank slope
default_lateral_deposition_model = 'constant';
default_fluvial_basement_erodability = 0.01;                                % bedrock erodibility relative to the sediment erodibility
default_fluvial_basement_threshold = 0.5;
default_outbend_erosion_coefficient = 1.000000;
default_inbend_erosion_coefficient = 1.00000;
default_poisson_coefficient = 5;
default_diffusion_coefficient = 4;
default_sediment_grain = 0.0025;
default_basement_grain = 0.025;

% flow model
default_flow_model = 'stationary:pow';
default_friction_model = 'manning';
default_friction_coefficient = 0.025;
default_flow_boundary = 'free';

% outputs
% options:
% stress, waters, discharge, downward, slope, qs, capacity, sediment, precipiton_flux, stock
default_str_write = 'water:qs:precipiton_flux:sed';

% expected inputs
expectedInput_time_unit = {'year','second'};
expectedInput_begin_option = {'volume','time'};
expectedInput_end_option = {'volume','time'};
expectedInput_draw_option = {'volume','time'};
expectedInput_step_option = {'time','volume','time:adapt','volume:adapt'};
expectedInput_limiter_mode = {'clip','unclip'};
expectedInput_erosion_model = {'MPM'};
expectedInput_deposition_model = {'constant'};
expectedInput_stress_model = {'rghs','rgqs'};
expectedInput_lateral_deposition_model = {'constant'};
expectedInput_flow_model = {'stationary:pow'};
expectedInput_friction_model = {'manning'};
expectedInput_flow_boundary = {'free'};

p = inputParser;

% grids
addOptional(p,'dem',default_dem,@(x)isa(x,'GRIDobj'))
addParameter(p,'rain',default_rain,@(x)isa(x,'GRIDobj') || isnumeric(x))
addParameter(p,'uplift',default_uplift,@(x)isa(x,'GRIDobj') || isnumeric(x))
addParameter(p,'sediment',default_sediment,@(x)isa(x,'GRIDobj') || isnumeric(x))
addParameter(p,'cs',default_cs,@(x)isa(x,'GRIDobj') || isnumeric(x))
addParameter(p,'water',default_water,@(x)isa(x,'GRIDobj') || isnumeric(x))

% other
addParameter(p,'climate',default_climate,@(x) isnumeric(x) && size(x,2) == 3)
addParameter(p,'experiment',default_experiment,@ischar)
addParameter(p,'model',default_model,@ischar)
addParameter(p,'eros_version',default_eros_version,@ischar)
addParameter(p,'outfolder',default_outfolder,@ischar)
addParameter(p,'inertia',default_inertia,@isnumeric)
addParameter(p,'time_unit',default_time_unit,@(x) any(validatestring(x,expectedInput_time_unit)))
addParameter(p,'begin',default_begin,@isnumeric)
addParameter(p,'end',default_end,@isnumeric)
addParameter(p,'draw',default_draw,@isnumeric)
addParameter(p,'step',default_step,@isnumeric)
addParameter(p,'stepmin',default_stepmin,@isnumeric)
addParameter(p,'stepmax',default_stepmax,@isnumeric)
addParameter(p,'begin_option',default_begin_option,@(x) any(validatestring(x,expectedInput_begin_option)))
addParameter(p,'end_option',default_end_option,@(x) any(validatestring(x,expectedInput_end_option)))
addParameter(p,'draw_option',default_draw_option,@(x) any(validatestring(x,expectedInput_draw_option)))
addParameter(p,'step_option',default_step_option,@(x) any(validatestring(x,expectedInput_step_option)))
addParameter(p,'TU',default_TU)
addParameter(p,'erosion_multiplier',default_erosion_multiplier,@isnumeric)
addParameter(p,'erosion_multiplier_increment',default_erosion_multiplier_increment,@isnumeric)
addParameter(p,'erosion_multiplier_op',default_erosion_multiplier_op,@ischar)
addParameter(p,'erosion_multiplier_min',default_erosion_multiplier_min,@isnumeric)
addParameter(p,'erosion_multiplier_max',default_erosion_multiplier_max,@isnumeric)
addParameter(p,'erosion_multiplier_default_min',default_erosion_multiplier_default_min,@isnumeric)
addParameter(p,'erosion_multiplier_default_max',default_erosion_multiplier_default_max,@isnumeric)
addParameter(p,'time_extension',default_time_extension,@isnumeric)
addParameter(p,'limiter_dh',default_limiter_dh,@isnumeric)
addParameter(p,'limiter_mode',default_limiter_mode,@(x) any(validatestring(x,expectedInput_limiter_mode)))
addParameter(p,'erosion_model',default_erosion_model,@(x) any(validatestring(x,expectedInput_erosion_model)))
addParameter(p,'deposition_model',default_deposition_model,@(x) any(validatestring(x,expectedInput_deposition_model)))
addParameter(p,'stress_model',default_stress_model,@(x) any(validatestring(x,expectedInput_stress_model)))
addParameter(p,'fluvial_stress_exponent',default_fluvial_stress_exponent,@isnumeric)
addParameter(p,'fluvial_sediment_erodability',default_fluvial_sediment_erodability,@isnumeric)
addParameter(p,'fluvial_sediment_threshold',default_fluvial_sediment_threshold,@isnumeric)
addParameter(p,'deposition_length',default_deposition_length,@isnumeric)
addParameter(p,'fluvial_lateral_erosion_coefficient',default_fluvial_lateral_erosion_coefficient,@isnumeric)
addParameter(p,'fluvial_lateral_deposition_coefficient',default_fluvial_lateral_deposition_coefficient,@isnumeric)
addParameter(p,'lateral_erosion_model',default_lateral_erosion_model,@isnumeric)
addParameter(p,'lateral_deposition_model',default_lateral_deposition_model,@(x) any(validatestring(x,expectedInput_lateral_deposition_model)))
addParameter(p,'fluvial_basement_erodability',default_fluvial_basement_erodability,@isnumeric)
addParameter(p,'fluvial_basement_threshold',default_fluvial_basement_threshold,@isnumeric)
addParameter(p,'outbend_erosion_coefficient',default_outbend_erosion_coefficient,@isnumeric)
addParameter(p,'inbend_erosion_coefficient',default_inbend_erosion_coefficient,@isnumeric)
addParameter(p,'poisson_coefficient',default_poisson_coefficient,@isnumeric)
addParameter(p,'diffusion_coefficient',default_diffusion_coefficient,@isnumeric)
addParameter(p,'sediment_grain',default_sediment_grain,@isnumeric)
addParameter(p,'basement_grain',default_basement_grain,@isnumeric)
addParameter(p,'flow_model',default_flow_model,@(x) any(validatestring(x,expectedInput_flow_model)))
addParameter(p,'friction_model',default_friction_model,@(x) any(validatestring(x,expectedInput_friction_model)))
addParameter(p,'friction_coefficient',default_friction_coefficient,@isnumeric)
addParameter(p,'flow_boundary',default_flow_boundary,@(x) any(validatestring(x,expectedInput_flow_boundary)))
addParameter(p,'str_write',default_str_write,@ischar)
addParameter(p,'overwrite',default_overwrite,@islogical)

parse(p,varargin{:});
LEM = p.Results;

% prepare GRIDobjs
if isnumeric(LEM.rain)
    rain = LEM.dem;
    rain.Z = ones(rain.size)*p.Results.rain;
    rain.Z = rain.Z./365.25/24/3600;
    rain.Z(1,:) = -1;
    rain.Z(:,1) = -1;
    rain.Z(end,:) = -1;
    rain.Z(:,end) = -1;
    LEM.rain = rain;
end
if isnumeric(LEM.sediment)
    sed = LEM.dem;
    sed.Z = ones(sed.size)*p.Results.sediment;
    LEM.sediment = sed;
end
if isnumeric(LEM.uplift)
    uplift = LEM.dem;
    uplift.Z = ones(uplift.size)*p.Results.uplift;
    uplift.Z(:,1) = 0;uplift.Z(:,end) = 0;uplift.Z(1,:) = 0;uplift.Z(end,:) = 0;
    LEM.uplift = uplift;
end
if isnumeric(LEM.cs)
    cs = LEM.dem;
    cs.Z = ones(cs.size)*p.Results.cs;
    LEM.cs = cs;
end
if isnumeric(LEM.water)
    water = LEM.dem;
    water.Z = ones(water.size)*p.Results.water;
    LEM.water = water;
end

% create grds
if ~(isfolder('Topo'))
    mkdir('Topo')
end
GRIDobj2grd(LEM.dem,['./Topo/',LEM.dem.name,'.alt']);
GRIDobj2grd(LEM.rain,['./Topo/',LEM.dem.name,'.rain']);
GRIDobj2grd(LEM.sediment,['./Topo/',LEM.dem.name,'.sed']);
GRIDobj2grd(LEM.uplift,['./Topo/',LEM.dem.name,'.uplift']);
GRIDobj2grd(LEM.rain,['./Topo/',LEM.dem.name,'.rain']);
GRIDobj2grd(LEM.water,['./Topo/',LEM.dem.name,'.water']);
GRIDobj2grd(LEM.cs,['./Topo/',LEM.dem.name,'.cs']);

% climate
if sum(LEM.climate(:)) ~= 0
    fileID = fopen(['.\Topo\',LEM.experiment,'.climate'],'w');
    fprintf(fileID, 'time    flow:relative   cs:absolute\n');
    for i = 1:size(LEM.climate,1)
        fprintf(fileID, [num2str(LEM.climate(i,1)),'    ',num2str(LEM.climate(i,2)),'    ' num2str(LEM.climate(i,3)),'\n']);
    end
    fclose(fileID);
end

% make sure nothing gets overwritten unless explicitly wanted
if ~LEM.overwrite
    [~,~,Status]=mkdir(LEM.outfolder);
    i=1;
    while isempty(Status)==0
        outpath = [LEM.outfolder,'_',num2str(i)];
        [~,~,Status]=mkdir(outpath);
        i=i+1;
    end
    if i>1
        LEM.outfolder = outpath;
    end
end

% write input file (.arg)
fileID = fopen([LEM.experiment,'.arg'],'w');
fprintf(fileID, ['model=',LEM.model,'\n']);
fprintf(fileID, ['erosion_model=',LEM.erosion_model,'\n']);
fprintf(fileID, ['deposition_model=',LEM.deposition_model,'\n']);
fprintf(fileID, ['deposition_length_fluvial=',num2str(LEM.deposition_length),'\n']);
fprintf(fileID, ['sediment_grain=',num2str(LEM.sediment_grain),'\n']);
fprintf(fileID, ['lateral_erosion_model=',num2str(LEM.lateral_erosion_model),'\n']);
fprintf(fileID, ['lateral_deposition_model=',num2str(LEM.lateral_deposition_model),'\n']);
fprintf(fileID, ['lateral_erosion_coefficient_fluvial=',num2str(LEM.fluvial_lateral_erosion_coefficient),'\n']);
fprintf(fileID, ['lateral_deposition_coefficient_fluvial=',num2str(LEM.fluvial_lateral_deposition_coefficient),'\n']);
fprintf(fileID, ['lateral_erosion_outbend=',num2str(LEM.outbend_erosion_coefficient),'\n']);
fprintf(fileID, ['lateral_erosion_inbend=',num2str(LEM.inbend_erosion_coefficient),'\n']);
fprintf(fileID, ['poisson_coefficient=',num2str(LEM.poisson_coefficient),'\n']);
fprintf(fileID, ['diffusion_coefficient=',num2str(LEM.diffusion_coefficient),'\n']);
fprintf(fileID, ['basement_grain=',num2str(LEM.basement_grain),'\n']);
fprintf(fileID, ['basement_erodibility=',num2str(LEM.fluvial_basement_erodability),'\n']);
fprintf(fileID, ['sediment_erodability=',num2str(LEM.fluvial_sediment_erodability),'\n']);
fprintf(fileID, ['flow_model=',LEM.flow_model,'\n']);
fprintf(fileID, ['friction_coefficient=',num2str(LEM.friction_coefficient),'\n']);
fprintf(fileID, ['flow_boundary=',num2str(LEM.flow_boundary),'\n']);
fprintf(fileID, ['stress_model=',num2str(LEM.stress_model),'\n']);

% grids
fprintf(fileID, ['topo=Topo\\',LEM.dem.name,'.alt\n']);
fprintf(fileID, ['rain=Topo\\',LEM.dem.name,'.rain\n']);
fprintf(fileID, ['water=Topo\\',LEM.dem.name,'.water\n']);
fprintf(fileID, ['sed=Topo\\',LEM.dem.name,'.sed\n']);
fprintf(fileID, ['uplift=Topo\\',LEM.dem.name,'.uplift\n']);
fprintf(fileID, ['cs=Topo\\',LEM.dem.name,'.cs\n']);
if sum(LEM.climate(:)) ~= 0
    fprintf(fileID, ['climate=Topo\\',LEM.experiment,'.climate\n']);
end

% time
fprintf(fileID, ['time:unit=',LEM.time_unit,'\n']);
fprintf(fileID, ['time_extension=',num2str(LEM.time_extension),'\n']);
fprintf(fileID, ['time:end=',num2str(LEM.end),':',LEM.end_option,'\n']);
fprintf(fileID, ['time:draw=',num2str(LEM.draw),':',LEM.draw_option,'\n']);
fprintf(fileID, ['time:step=',num2str(LEM.step),':',LEM.step_option,'\n']);
fprintf(fileID, ['time:step:min=',num2str(LEM.stepmin),':max=',num2str(LEM.stepmax),'\n']);
fprintf(fileID, ['erosion_multiplier=',num2str(LEM.erosion_multiplier),'\n']);
fprintf(fileID, ['erosion_multiplier_op=',num2str(LEM.erosion_multiplier_op),'\n']);
fprintf(fileID, ['erosion_multiplier_min=',num2str(LEM.erosion_multiplier_min),'\n']);
fprintf(fileID, ['erosion_multiplier_max=',num2str(LEM.erosion_multiplier_max),'\n']);
fprintf(fileID, ['erosion_multiplier_increment=',num2str(LEM.erosion_multiplier_increment),'\n']);
fprintf(fileID, ['erosion_multiplier_default_min=',num2str(LEM.erosion_multiplier_default_min),'\n']);
fprintf(fileID, ['erosion_multiplier_default_max=',num2str(LEM.erosion_multiplier_default_max),'\n']);
fprintf(fileID, ['limiter_dh=',num2str(LEM.limiter_dh),'\n']);
fprintf(fileID, ['limiter_mode=',num2str(LEM.limiter_mode),'\n']);
fprintf(fileID, ['write=',LEM.str_write,'\n']);
fprintf(fileID, [LEM.TU,'\n']);
fprintf(fileID, ['flow_inertia_coefficient=',num2str(LEM.inertia),'\n']);   % inertia in shallow water equation
fprintf(fileID, ['friction_model=',LEM.friction_model,'\n']);   % floodos mode
fclose(fileID);

% save inputs to outfolder
copyfile([LEM.experiment,'.arg'],LEM.outfolder);
save([LEM.outfolder,'/LEM.mat'],'LEM');
if sum(LEM.climate(:)) ~= 0
    copyfile(['.\Topo\',LEM.experiment,'.climate'],LEM.outfolder);
end

% write start file
fileID = fopen([LEM.experiment,'.bat'],'w');
fprintf(fileID, '@rem  Run Eros program with following arguments\n');
fprintf(fileID, '@rem\n');
fprintf(fileID, '@echo off\n');
fprintf(fileID, ['@set EROS_PROG=bin\\',LEM.eros_version,'.exe\n']);
fprintf(fileID, '@set COMMAND=%%EROS_PROG%% %%*\n');
fprintf(fileID, '@echo on\n');
fprintf(fileID, '@rem\n\n');
fprintf(fileID, 'goto:todo\n\n');
fprintf(fileID, ':not_todo\n\n');
fprintf(fileID, ':todo\n\n\n');
fprintf(fileID, ['start /LOW %%COMMAND%% -dir=',LEM.outfolder,'\\ ',LEM.experiment,'.arg']);
fclose(fileID);

% run model
system([LEM.experiment,'.bat'])
