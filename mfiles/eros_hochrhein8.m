%--------------------------------------------------------------------------
%                               PREPARE GRIDS
%--------------------------------------------------------------------------
%
% addpath('.\mfiles')
% ALT (elevation model)
clear
dem=GRIDobj('./Topo/cop30DEM_utm32n_hochrhein_carved_filled.tif');
dem = resample(dem,60);dem = crop(dem);
dem.name = 'hochrhein_60m';

% RAIN (sources (>0) and sinks (-1))
rain = GRIDobj('.\Topo\map_wc2.tif'); % MAP after WorldClim2 (mm/yr/m^2)
rain = resample(rain,dem);
rain = rain/1000; % convert to m/yr/m^2
rain = rain/3600/24/365.25; % convert to m/s/m^2

upstream = GRIDobj('.\Topo\rain_boundaries_ms-1.tif');
upstream = resample(upstream,dem);
upstream.Z(isnan(upstream.Z))=0;


inflow_factor = 2.45;
rain = (rain+upstream)*inflow_factor;

% INFLOWS
inflow_rhine = 346*inflow_factor; % (m^3/s)
% inflow_rhine_y = [273:279]; % y-location (column) of inlet
% inflow_rhine_x = ones(7,1)'*3266; % x-location (row) of inlet
inflow_rhine_y = [137:140]; % y-location (column) of inlet
inflow_rhine_x = ones(4,1)'*1632; % x-location (row) of inlet
inflow_rhine = inflow_rhine/length(inflow_rhine_x)/dem.cellsize.^2; % divide by number of inflow cells and by cellsize^2
rain.Z(inflow_rhine_y,inflow_rhine_x(1)) = ones(length(inflow_rhine_x),1)*inflow_rhine;

inflow_aare = 349*inflow_factor; % (m^3/s)
% inflow_aare_x = [1461:1462]; % y-location (column) of inlet
% inflow_aare_y = ones(2,1)'*998; % x-location (row) of inlet
inflow_aare_x = [731]; % y-location (column) of inlet
inflow_aare_y = ones(length(inflow_aare_x),1)'*498; % x-location (row) of inlet
inflow_aare = inflow_aare/length(inflow_aare_x)/dem.cellsize.^2; % divide by number of inflow cells and by cellsize^2
rain.Z(inflow_aare_y,inflow_aare_x(1)) = ones(length(inflow_aare_x),1)*inflow_aare;

inflow_reuss = 140*inflow_factor; % (m^3/s)
% inflow_reuss_x = [1680:1682]; % y-location (column) of inlet
% inflow_reuss_y = ones(3,1)'*998; % x-location (row) of inlet
inflow_reuss_x = [842]; % y-location (column) of inlet
inflow_reuss_y = ones(length(inflow_reuss_x),1)'*498; % x-location (row) of inlet
inflow_reuss = inflow_reuss/length(inflow_reuss_x)/dem.cellsize.^2; % divide by number of inflow cells and by cellsize^2
rain.Z(inflow_reuss_y,inflow_reuss_x(1)) = ones(length(inflow_reuss_x),1)*inflow_reuss;

inflow_limmat = 114*inflow_factor; % (m^3/s)
% inflow_limmat_x = [1851:1852]; % y-location (column) of inlet
% inflow_limmat_y = ones(2,1)'*998; % x-location (row) of inlet
inflow_limmat_x = [926]; % y-location (column) of inlet
inflow_limmat_y = ones(length(inflow_limmat_x),1)'*498; % x-location (row) of inlet
inflow_limmat = inflow_limmat/length(inflow_limmat_x)/dem.cellsize.^2; % divide by number of inflow cells and by cellsize^2
rain.Z(inflow_limmat_y,inflow_limmat_x(1)) = ones(length(inflow_limmat_x),1)*inflow_limmat;

% rain = resample(rain,dem60);
rain.Z(1:end,1)=-1;
% rain.Z(1,1:end)=-1;
% rain.Z(end,1:end)=-1;
% rivers = GRIDobj('.\Topo\rivers2raster.tif');

% INITIAL SEDIMENT CONCENTRATION
cs = rain;
cs.Z=cs.Z*0;
cs.Z(1,:) = 1;
cs.Z(:,end) = 1;
cs.Z(end,:) = 1;

climate = 'Topo\\boundary_1Ma_GT_clear.climate';


% WATER
% water = GRIDobj('.\Topo\HochRhein_WATER+LAKE_1000m.tif');

% UPLIFT
% uplift =  GRIDobj('.\Topo\uplift_m_per_s_baselevel_Basel.tif');
uplift =  GRIDobj('.\Topo\uplift_elicited_updated.tif')-5.63e-5; % [m/yr] minus the uplift at the outlet to make it the baselevel
uplift = resample(uplift,dem);
uplift.Z(1,:) = uplift.Z(2,:);
uplift.Z(:,1) = uplift.Z(:,2);

% SED (sediment thickness in meters)
sed = GRIDobj('.\Topo\mqu_140715g_utm32n_aug.tif');
sed = resample(sed,dem);
sed.Z(isnan(sed.Z))=0;

LEM.dem = dem;
LEM.rain = rain;
LEM.sed = sed;
LEM.uplift = uplift;
% LEM.water = water;
LEM.cs = cs;
LEM.climate = climate;


GRIDobj2grd(dem,['./Topo/',dem.name,'.alt']);
GRIDobj2grd(rain,['./Topo/',dem.name,'.rain']);
GRIDobj2grd(sed,['./Topo/',dem.name,'.sed']);
GRIDobj2grd(uplift,['./Topo/',dem.name,'.uplift']);
% GRIDobj2grd(water,['./Topo/',dem.name,'.water']);
GRIDobj2grd(cs,['./Topo/',dem.name,'.cs']);

%--------------------------------------------------------------------------
%%                           DEFINE INPUT PARAMETERS
%--------------------------------------------------------------------------

LEM.experiment = 'hochrhein';                % Project name

LEM.ErosPath = 'D:\\USER\\mey';    % Path to .exe
LEM.outfolder = 'hochrhein\\60m\\eros8\\clear\\';                 % folder to store results in
LEM.eros_version = 'eros8.0.131M';


% LEM.inflow = 1060;                          % [m3s-1]water inflow at source cells
LEM.rainfall = 1;                      % Sets the precipitation rate per unit surface when multiplied by the rainfall map
LEM.initial_sediment_stock = '0.01';             % % The total "stock" of sediment at the precipiton landing is:  input_sediment_concentration*cs_map[i]*Precipiton_volume
LEM.inertia = 0;                            % refers to inertia term in shallow water equation

LEM.time_unit = 'year';
LEM.begin = 0;          LEM.begin_option = 'time';                        % start time
LEM.end = 1e+5;          LEM.end_option = 'time';                           % length of model run
LEM.draw = 1e+3;        LEM.draw_option = 'time';                           % output interval
LEM.step = '2.5e2:dir';         LEM.step_option = 'volume:adapt'; 
LEM.stepmin = 0.1e1;
LEM.stepmax = 1e4;
LEM.initphase ='time:init:begin=10:end=1:step=1:log:op=*:tu=0.0001'; 

% LEM.TU_coefficient = 0.001;                 % sets the proportion of rain pixels that make up 1 TU
LEM.TU = 'TU:surface=rain:coefficient=0.001';
LEM.flow_model = 'stationary:pow';
LEM.erosion_multiplier = '1000';                 % enhance the erosion by this factor for each precipiton
LEM.erosion_multiplier_increment = '3:log10';
LEM.erosion_multiplier_op = '*';
LEM.erosion_multiplier_min = 1000;         % smallest erosion_multiplier during calculation
LEM.erosion_multiplier_max = 1000';    % largest erosion_multiplier during calculation;
LEM.erosion_multiplier_default_min = '10000';          % minimum number of defaults that triggers a time step increase 
LEM.erosion_multiplier_default_max = 20000';         % maximum number of defaults that triggers a time step decrease
LEM.time_extension = '2e+3';
LEM.uplift_multiplier = 1;

LEM.limiter_dh = '0.1:dir'; % define how excessive must be the topography variations and whether this limits topography or not
LEM.limiter_mode = 'unclip:dir';
%--------------------------------------------------------------------------
% EROSION/DEPOSITION
%--------------------------------------------------------------------------
LEM.erosion_model = 'MPM';                  % (stream_power, shear_stress, shear_mpm)
LEM.deposition_model = 'constant';          % need to know whether there are other options!
LEM.stress_model = 'rgqs';

% ALLUVIAL
LEM.fluvial_stress_exponent = 1.5;          % exponent in sediment flux eq. (MPM): qs = E(tau-tau_c)^a
LEM.fluvial_sediment_erodability = '2.6e-8';              % [kg-1.5 m-3.5 s-2] E in MPM equation
LEM.fluvial_sediment_threshold = 0.05;     % [Pa] critical shear stress (tau_c) in MPM equation
LEM.deposition_length = '60';                  % [m] xi in vertical erosion term: edot = qs/xi

% LATERAL EROSION/DEPOSITION
LEM.fluvial_lateral_erosion_coefficient = '1e-2';             % dimensionless coefficient (Eq. 17 in Davy, Croissant, Lague (2017))
LEM.fluvial_lateral_deposition_coefficient = 1e-2;
LEM.lateral_erosion_model = 1;
LEM.lateral_deposition_model = 'constant';

% BEDROCK
LEM.fluvial_basement_erodability = 0.01;
LEM.fluvial_basement_threshold = 0.5;

LEM.outbend_erosion_coefficient = 1.000000;
LEM.inbend_erosion_coefficient = 1.00000;

LEM.poisson_coefficient = 5;
LEM.diffusion_coefficient = 4;
LEM.sediment_grain = 0.0025;
LEM.basement_grain = 0.025;

% LEM.survey_points = '171130';
%--------------------------------------------------------------------------
% FLOW MODEL
%--------------------------------------------------------------------------
LEM.friction_model = 'manning';
LEM.friction_coefficient = 0.025;       % 
LEM.flow_boundary = 'free';

%--------------------------------------------------------------------------
% OUTPUTS TO WRITE
%--------------------------------------------------------------------------

% options: 
% stress, waters, discharge, downward, slope, qs, capacity, sediment, precipiton_flux, stock

LEM.str_write = 'stress:water:discharge:slope:qs:capacity:sediment:precipiton_flux:stock';


writeErosInputs8(LEM);

%% run model
system([LEM.experiment,'.bat'])