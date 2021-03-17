%--------------------------------------------------------------------------
%                               PREPARE GRIDS
%--------------------------------------------------------------------------
%
% addpath('.\mfiles')
% ALT (elevation model)
dem=GRIDobj('./Topo/juraost_dem_30m.tif');


% RAIN (sources (>0) and sinks (-1))
rain = GRIDobj('.\Topo\juraost_qin_30m_corrected.tif');

% INITIAL SEDIMENT CONCENTRATION
cs = GRIDobj('./Topo/juraost_cs_30m.tif');

% WATER
water = GRIDobj('.\Topo\HochRhein_WATER_1000m.tif');

% UPLIFT
uplift =  GRIDobj('.\Topo\uplift_m_per_s.tif');
uplift = resample(uplift,dem);

% SED (sediment thickness in meters)
sed = dem*0;
sed.Z(~isnan(sed.Z))=100;

LEM.dem = dem;
LEM.rain = rain;
LEM.cs = cs;
% LEM.sed = sed;
% LEM.uplift = uplift;
% LEM.water = water;

GRIDobj2grd(dem,['./Topo/',dem.name,'.alt']);
GRIDobj2grd(rain,['./Topo/',dem.name,'.rain']);
% GRIDobj2grd(sed,['./Topo/',dem.name,'.sed']);
% GRIDobj2grd(uplift,['./Topo/',dem.name,'.uplift']);
% GRIDobj2grd(water,['./Topo/',dem.name,'.water']);
GRIDobj2grd(cs,['./Topo/',dem.name,'.cs']);
%--------------------------------------------------------------------------
%%                           DEFINE INPUT PARAMETERS
%--------------------------------------------------------------------------

LEM.experiment = 'juraost_test';                % Project name

LEM.ErosPath = 'C:\\Projects\\EROS\\Hochrhein';    % Path to .exe
LEM.outfolder = 'output\\juraost_test\\xi30\\step10\\new';                 % folder to store results in

% LEM.inflow = 1153;                          % [m3s-1]water inflow at source cells
LEM.rainfall = 1;                      % Sets the precipitation rate per unit surface when multiplied by the rainfall map
LEM.initial_sediment_stock = 1;             % The total "stock" of sediment at the precipiton landing is:  input_sediment_concentration*cs_map[i]*Precipiton_volume
LEM.inertia = 0;                            % refers to inertia term in shallow water equation

LEM.begin = 0;          LEM.begin_option = 'time';                        % start time
LEM.end = 7e8;          LEM.end_option = 'time';                           % length of model run
LEM.draw = 100;        LEM.draw_option = 'time';                           % output interval
LEM.step = 1e1;         LEM.step_option = 'volume'; 
LEM.stepmin = 1e0;
LEM.stepmax = 1e2;
LEM.initbegin = 1e+1;                                   % initialization time (-)
LEM.initend = 1e+1;
LEM.initstep = 2;

LEM.TU_coefficient = 1;                 % sets the proportion of rain pixels that make up 1 TU
LEM.flow_model = 'stationary:pow';
LEM.erosion_multiply = 1000;               % multiplying factor for erosion rates. Equivalent to consider an "erosion time" larger than the hydrodynamic time
LEM.uplift_multiplier = 0;

LEM.limiter = 1e-1;
LEM.continue_run = -1;                  % continue previous simulation from the specified stage (-1 for new run)
%--------------------------------------------------------------------------
% EROSION/DEPOSITION
%--------------------------------------------------------------------------
LEM.erosion_model = 'MPM';                  % (stream_power, shear_stress, shear_mpm)
LEM.deposition_model = 'constant';          % need to know whether there are other options!

% ALLUVIAL
LEM.fluvial_stress_exponent = 1.5;          % exponent in sediment flux eq. (MPM): qs = E(tau-tau_c)^a
LEM.fluvial_erodability = 2.6e-8;              % [kg-1.5 m-3.5 s-2] E in MPM equation
LEM.fluvial_sediment_threshold = 0.05;     % [Pa] critical shear stress (tau_c) in MPM equation
LEM.deposition_length = 30;                  % [m] xi in vertical erosion term: edot = qs/xi

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
LEM.sediment_grain = 0.0025;
LEM.basement_grain = 0.0025;
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