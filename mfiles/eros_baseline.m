%--------------------------------------------------------------------------
%                               PREPARE GRIDS
%--------------------------------------------------------------------------
%
% addpath('.\mfiles')
% ALT (elevation model)
clear
dem=GRIDobj('./Topo/HochRhein_LAKE_1000m.tif');


% RAIN (sources (>0) and sinks (-1))
rain = GRIDobj('.\Topo\HochRhein_MAP_1000m.tif');

% WATER
water = GRIDobj('.\Topo\HochRhein_WATER+LAKE_1000m.tif');

% UPLIFT
% uplift =  GRIDobj('.\Topo\uplift_m_per_s_baselevel_Basel.tif');
uplift =  GRIDobj('.\Topo\uplift_m_per_s_nagra_baselevel_Basel.tif');
uplift = resample(uplift,dem);

% SED (sediment thickness in meters)
sed = GRIDobj('.\Topo\Hochrhein_SEDLAKE_1000m.tif');
% sed = dem*0;
% sed.Z(~isnan(sed.Z))=10;

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

LEM.ErosPath = 'D:\\USER\\mey';    % Path to .exe
LEM.outfolder = 'baseline_test\\sediments';                 % folder to store results in

% LEM.inflow = 1060;                          % [m3s-1]water inflow at source cells
LEM.rainfall = 7.6e-8*10;                      % Sets the precipitation rate per unit surface when multiplied by the rainfall map
LEM.initial_sediment_stock = 0;             % [%] volumetric sediment inflow at source cells)
LEM.inertia = 0;                            % refers to inertia term in shallow water equation

LEM.end = 3e8;          LEM.end_option = 'time';                           % length of model run
LEM.draw = 3e4;     LEM.draw_option = 'time';                           % output interval
LEM.step = 1e3;         LEM.step_option = 'volume'; 
LEM.stepmin = 1e2;
LEM.stepmax = 1e4;
LEM.initbegin = 1e+3;                                   % initialization time (-)
LEM.initend = 1e+3;
LEM.initstep = 2;

LEM.TU_coefficient = 1;                 % sets the proportion of rain pixels that make up 1 TU
LEM.flow_model = 'stationary:pow';
LEM.erosion_multiply = 1000;%15654;               % multiplying factor for erosion rates. Equivalent to consider an "erosion time" larger than the hydrodynamic time
LEM.uplift_multiplier = 425516;%15654;

LEM.limiter = 1e-1;
LEM.continue_run = -1;                  % continue previous simulation from the specified stage (-1 for new run)
%--------------------------------------------------------------------------
% EROSION/DEPOSITION
%--------------------------------------------------------------------------
LEM.erosion_model = 'MPM';                  % (stream_power, shear_stress, shear_mpm)
LEM.deposition_model = 'constant';          % need to know whether there are other options!

% ALLUVIAL
LEM.deposition_length = 1000;                  % [m] xi in vertical erosion term: edot = qs/xi

% LATERAL EROSION/DEPOSITION
LEM.fluvial_lateral_erosion_coefficient = 1e-4;             % dimensionless coefficient (Eq. 17 in Davy, Croissant, Lague (2017))
LEM.fluvial_lateral_deposition_coefficient = 0.5;
LEM.lateral_erosion_model = 1;
LEM.lateral_deposition_model = 'constant';

% BEDROCK


LEM.poisson_coefficient = 5;
LEM.diffusion_coefficient = 4;
LEM.sediment_grain = 0.025;
LEM.basement_grain = 0.25;
%--------------------------------------------------------------------------
% FLOW MODEL
%--------------------------------------------------------------------------
LEM.friction_model = 'manning';
LEM.friction_coefficient = 0.025;       % 
LEM.flow_boundary = 'free';

%--------------------------------------------------------------------------
% OUTPUTS TO WRITE
%--------------------------------------------------------------------------
LEM.stress = 1;
LEM.waters = 1;
LEM.discharge = 1;
LEM.downward = 0;
LEM.slope = 1;
LEM.qs = 1;
LEM.capacity = 1;
LEM.sediment = 1;
LEM.flux =1;
LEM.stock =1;

LEM.str_write = '';
LEM.str_nowrite = '';

writeErosInputs(LEM);

%% run model
system([LEM.experiment,'.bat'])