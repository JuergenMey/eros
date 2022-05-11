%--------------------------------------------------------------------------
%                               PREPARE GRIDS
%--------------------------------------------------------------------------
%
% addpath('.\mfiles')
% ALT (elevation model)
clear
dem=GRIDobj('./Topo/cop30DEM_utm32n_subset_carved.tif');
dem.name = 'hochrhein_subset';

% RAIN (sources (>0) and sinks (-1))
rain = dem;
rain.Z = zeros(dem.size);

% INFLOWS
inflow_rhine = 1000; % (m^3/s)
inflow_rhine_y = [63:68]; % y-location (column) of inlet
inflow_rhine_x = ones(6,1)'*286; % x-location (row) of inlet
inflow_rhine = inflow_rhine/length(inflow_rhine_x)/dem.cellsize.^2; % divide by number of inflow cells and by cellsize^2
rain.Z(inflow_rhine_y,inflow_rhine_x(1)) = ones(length(inflow_rhine_x),1)*inflow_rhine;
rain.Z(1:end,1)=-1;
rain.Z(1,1:end)=-1;
rain.Z(end,1:end)=-1;


LEM.dem = dem;
LEM.rain = rain;

GRIDobj2grd(dem,['./Topo/',dem.name,'.alt']);
GRIDobj2grd(rain,['./Topo/',dem.name,'.rain']);


%--------------------------------------------------------------------------
%%                           DEFINE INPUT PARAMETERS
%--------------------------------------------------------------------------

LEM.experiment = 'template';                % Project name

LEM.ErosPath = 'D:\\USER\\mey';    % Path to .exe
LEM.outfolder = 'template';                 % folder to store results in


LEM.rainfall = 1;                      % Sets the precipitation rate per unit surface when multiplied by the rainfall map
LEM.inertia = 0;                            % refers to inertia term in shallow water equation

LEM.time_unit = 'year';
LEM.begin = 0;          LEM.begin_option = 'time';                        % start time
LEM.end = 1/365.25;         LEM.end_option = 'time';                           % length of model run
LEM.draw = 500;         LEM.draw_option = 'time';                           % output interval
LEM.step = 1;           LEM.step_option = 'volume'; 
LEM.stepmin = 1;
LEM.stepmax = 1;
LEM.initbegin = 1e+1;                                   % initialization time (-)
LEM.initend = 1e+1;
LEM.initstep = 2;

LEM.TU_coefficient = '1';                 % sets the proportion of rain pixels that make up 1 TU
LEM.flow_model = 'stationary:pow';
LEM.erosion_multiply = 1;               % multiplying factor for erosion rates. Equivalent to consider an "erosion time" larger than the hydrodynamic time
LEM.uplift_multiplier = 1;
LEM.time_extension = 1;

LEM.limiter = 1e-1;
%--------------------------------------------------------------------------
% EROSION/DEPOSITION
%--------------------------------------------------------------------------
LEM.erosion_model = 'MPM';                  % (stream_power, shear_stress, shear_mpm)
LEM.deposition_model = 'constant';          % need to know whether there are other options!
LEM.eros_version = 'eros7.5.92';
LEM.stress_model = 'rgqs';

% ALLUVIAL
LEM.fluvial_stress_exponent = 1.5;          % exponent in sediment flux eq. (MPM): qs = E(tau-tau_c)^a
LEM.fluvial_erodability = 2.6e-8;              % [kg-1.5 m-3.5 s-2] E in MPM equation
LEM.fluvial_sediment_threshold = 0.05;     % [Pa] critical shear stress (tau_c) in MPM equation
LEM.deposition_length = 30;                  % [m] xi in vertical erosion term: edot = qs/xi

% LATERAL EROSION/DEPOSITION
LEM.fluvial_lateral_erosion_coefficient = 1e-4;             % dimensionless coefficient (Eq. 17 in Davy, Croissant, Lague (2017))
LEM.fluvial_lateral_deposition_coefficient = 0.5;
LEM.lateral_erosion_model = 1;
LEM.lateral_deposition_model = 'constant';

% BEDROCK
LEM.fluvial_basement_erodability = 0.1;
LEM.fluvial_basement_threshold = 0.5;

LEM.outbend_erosion_coefficient = 1.000000;
LEM.inbend_erosion_coefficient = 1.00000;

LEM.poisson_coefficient = 5;
LEM.diffusion_coefficient = 4;
LEM.sediment_grain = 0.0025;
LEM.basement_grain = 0.025;
%--------------------------------------------------------------------------
% FLOW MODEL
%--------------------------------------------------------------------------
LEM.friction_model = 'manning';
LEM.friction_coefficient = 0.025;       % 
LEM.flow_boundary = 'free';

%--------------------------------------------------------------------------
% OUTPUTS TO WRITE
%--------------------------------------------------------------------------
LEM.stress = 0;
LEM.waters = 1;
LEM.discharge = 0;
LEM.downward = 0;
LEM.slope = 0;
LEM.qs = 1;
LEM.capacity = 0;
LEM.sediment = 1;
LEM.flux =1;
LEM.stock =1;

LEM.str_write = '';
LEM.str_nowrite = '';

writeErosInputs(LEM);

%% run model
system([LEM.experiment,'.bat'])