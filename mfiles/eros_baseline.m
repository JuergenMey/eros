%--------------------------------------------------------------------------
%                               PREPARE GRIDS
%--------------------------------------------------------------------------
%
% addpath('.\mfiles')
% ALT (elevation model)
dem=GRIDobj('./Topo/HochRhein_1000m.tif');


% RAIN (sources (>0) and sinks (-1))
rain = GRIDobj('.\Topo\HochRhein_MAP_1000m.tif');

% WATER
water = GRIDobj('.\Topo\HochRhein_WATER_1000m.tif');

% UPLIFT
uplift =  GRIDobj('.\Topo\uplift.tif');
uplift = resample(uplift,dem);

% SED (sediment thickness in meters)
sed = dem*0;
sed.Z(~isnan(sed.Z))=10;

LEM.dem = dem;
LEM.rain = rain;
LEM.sed = sed;
LEM.uplift = uplift;
LEM.water = water;

GRIDobj2grd(dem,['./Topo/',dem.name,'.alt']);
GRIDobj2grd(rain,['./Topo/',dem.name,'.rain']);
GRIDobj2grd(sed,['./Topo/',dem.name,'.sed']);
GRIDobj2grd(uplift,['./Topo/',dem.name,'.uplift']);
GRIDobj2grd(water,['./Topo/',dem.name,'.water']);
%--------------------------------------------------------------------------
%%                           DEFINE INPUT PARAMETERS
%--------------------------------------------------------------------------

LEM.experiment = 'baseline_test';                % Project name

LEM.ErosPath = 'C:\\Projects\\EROS\\Hochrhein';    % Path to .exe
LEM.outfolder = 'baseline_test';                 % folder to store results in

LEM.inflow = 1060;                          % [m3s-1]water inflow at source cells
LEM.rainfall = 3e-8;
LEM.initial_sediment_stock = 0;             % [%] volumetric sediment inflow at source cells)
LEM.inertia = 0;                            % refers to inertia term in shallow water equation

LEM.begin = 0;     LEM.begin_option = 'time';                        % start time
LEM.end = 100e7;   LEM.end_option = 'time';                           % length of model run
LEM.draw = 1e6;    LEM.draw_option = 'time';                           % output interval
LEM.step = 1e3;    LEM.step_option = 'volume';
LEM.stepmin = 1e3;
LEM.stepmax = 1e3;
LEM.initbegin = 1e+3;                                   % initialization time (-)
LEM.initend = 1e+3;
LEM.initstep = 2;

LEM.TU = 0.01;                              % unknown parameter
LEM.TU_coefficient = 1;
LEM.flow_model = 'stationary:pow';
LEM.erosion_multiply = 1;

LEM.limiter = 1e-1;
%--------------------------------------------------------------------------
% EROSION/DEPOSITION
%--------------------------------------------------------------------------
LEM.erosion_model = 'MPM';                  % (stream_power, shear_stress, shear_mpm)
LEM.deposition_model = 'constant';          % need to know whether there are other options!

% ALLUVIAL
LEM.fluvial_stress_exponent = 1.5;          % exponent in sediment flux eq. (MPM): qs = E(tau-tau_c)^a
LEM.fluvial_erodability = 2.6e-8;              % [kg-1.5 m-3.5 s-2] E in MPM equation
LEM.fluvial_sediment_threshold = 0.05;     % [Pa] critical shear stress (tau_c) in MPM equation
LEM.deposition_length = 1000;                  % [m] xi in vertical erosion term: edot = qs/xi

% Lateral erosion/deposition
LEM.fluvial_lateral_erosion_coefficient = 1e-4;             % dimensionless coefficient (Eq. 17 in Davy, Croissant, Lague (2017))
LEM.fluvial_lateral_deposition_coefficient = 0.5;
LEM.lateral_erosion_model = 1;
LEM.lateral_deposition_model = 'constant';

% BEDROCK
LEM.fluvial_basement_erodability = 2.6e-8;
LEM.fluvial_basement_threshold = 0.5;

LEM.outbend_erosion_coefficient = 1.000000;
LEM.inbend_erosion_coefficient = 1.00000;

LEM.poisson_coefficient = 5;
LEM.diffusion_coefficient = 4;
LEM.sediment_grain = 0.0001;
LEM.basement_grain = 0.001;
%--------------------------------------------------------------------------
% FLOW MODEL
%--------------------------------------------------------------------------
LEM.flood_model = 1;
LEM.friction_model = 'manning';
LEM.friction_coefficient = 0.025;       %
LEM.flow_only = 0;
LEM.flow_boundary = 'free';

%--------------------------------------------------------------------------
% OUTPUTS TO WRITE
%--------------------------------------------------------------------------
LEM.stress = 1;
LEM.water = 1;
LEM.discharge = 1;
LEM.downward = 1;
LEM.slope = 1;
LEM.qs = 1;
LEM.capacity = 1;
LEM.sediment = 1;

LEM.str_write = '';
LEM.str_nowrite = '';

writeErosInputs(LEM);

%% run model
system([LEM.experiment,'.bat'])