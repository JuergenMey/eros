%--------------------------------------------------------------------------
%                               PREPARE GRIDS
%--------------------------------------------------------------------------
%
% addpath('.\mfiles')
% ALT (elevation model)
clear
dem=GRIDobj('./Topo/Alps_basin_3.tif');


% RAIN (sources (>0) and sinks (-1))
rain = GRIDobj('.\Topo\Alps_basin_3_rain.tif'); % MAP after WorldClim2 (mm/yr)
% rain = resample(rain,dem);
% rain = rain/1000; % convert to m/yr
% rain = rain/3600/24/365.25/dem.cellsize.^2; % convert to m/s
% rain.Z(1:end,1)=-1;
% rain.Z(1,1:end)=-1;
% rain.Z(end,1:end)=-1;
% rain.Z(1:end,end)=-1;



% WATER
water = GRIDobj('.\Topo\Alps_basin_3_water.tif');

% UPLIFT
% uplift =  GRIDobj('.\Topo\uplift_m_per_s_baselevel_Basel.tif');
uplift =  GRIDobj('.\Topo\uplift_m_per_s_nagra_baselevel_Basel.tif');
uplift = resample(uplift,dem);

% SED (sediment thickness in meters)
sed = GRIDobj('.\Topo\mqu_140715g_utm32n.tif');
sed = resample(sed,dem);
sed.Z(isnan(sed.Z))=0;


LEM.dem = dem;
LEM.rain = rain;
% LEM.sed = sed;
% LEM.uplift = uplift;
LEM.water = water;

GRIDobj2grd(dem,['./Topo/',dem.name,'.alt']);
GRIDobj2grd(rain,['./Topo/',dem.name,'.rain']);
% GRIDobj2grd(sed,['./Topo/',dem.name,'.sed']);
% GRIDobj2grd(uplift,['./Topo/',dem.name,'.uplift']);
GRIDobj2grd(water,['./Topo/',dem.name,'.water']);

%--------------------------------------------------------------------------
%%                           DEFINE INPUT PARAMETERS
%--------------------------------------------------------------------------

LEM.experiment = 'hillslope_test2';                % Project name

LEM.ErosPath = 'D:\\USER\\mey';    % Path to .exe
LEM.outfolder = 'hillslope_test\\rgqs';                 % folder to store results in

% LEM.inflow = 1060;                          % [m3s-1]water inflow at source cells
LEM.rainfall = 2.8e-5*2;                      % Sets the precipitation rate per unit surface when multiplied by the rainfall map
LEM.initial_sediment_stock = '0:dir';             % % The total "stock" of sediment at the precipiton landing is:  input_sediment_concentration*cs_map[i]*Precipiton_volume
LEM.inertia = 0;                            % refers to inertia term in shallow water equation

LEM.begin = 0;          LEM.begin_option = 'time';                        % start time
LEM.end = 9e+5;          LEM.end_option = 'time';                           % length of model run
LEM.draw = 3000;        LEM.draw_option = 'time';                           % output interval
LEM.step = 100;         LEM.step_option = 'volume'; 
LEM.stepmin = 1e1;
LEM.stepmax = 1e4;
LEM.initbegin = 1e+1;                                   % initialization time (-)
LEM.initend = 1e+1;
LEM.initstep = 2;

LEM.TU_coefficient = '1:dir';                 % sets the proportion of rain pixels that make up 1 TU
LEM.flow_model = 'stationary:pow';
LEM.erosion_multiply = 100;               % multiplying factor for erosion rates. Equivalent to consider an "erosion time" larger than the hydrodynamic time
LEM.uplift_multiplier = 1/3600/24/365.25/1000*700000;

LEM.limiter = 1e-1;
LEM.continue_run = -1;             
%--------------------------------------------------------------------------
% EROSION/DEPOSITION
%--------------------------------------------------------------------------
LEM.erosion_model = 'MPM';                  % (stream_power, shear_stress, shear_mpm)
LEM.deposition_model = 'constant';          % need to know whether there are other options!
LEM.eros_version = 'eros7.3.112';
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
LEM.flow_boundary = '2';

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