%--------------------------------------------------------------------------
%                               PREPARE GRIDS
%--------------------------------------------------------------------------
%
%+++++++++++++++++ Example data (1% inclined, flat surface) +++++++++++++++

% ALT (elevation model) 
dem=GRIDobj('./Topo/channel_dx8_S0.01.tif');

% RAIN (sources (>0) and sinks (-1))
 rain = dem*0;
 rain.Z(:,1)=-1;
 rain.Z(10:16,end)=1;

%SED (sediment thickness in meters)
 sed = dem*0;
 sed = sed+10;
 
 LEM.dem = dem;
 LEM.rain = rain;
 LEM.sed = sed;

 GRIDobj2grd(dem,['./Topo/',dem.name,'.alt']);
 GRIDobj2grd(rain,['./Topo/',dem.name,'.rain']);
 GRIDobj2grd(sed,['./Topo/',dem.name,'.sed']);

%+++++++++++++++++++++++++++ Real topography ++++++++++++++++++++++++++++++
% % ALT (elevation model)
% dem = GRIDobj(['./Topo/','hochrhein_crop.tif']);
% 
% % RAIN (sources and sinks)
% rain = dem*0;
% rain.Z(104:114)=-1;
% rain.Z([16638 35718 35719 35720 35721])=1;
% 
% % SED (sediment thickness)
% sed = dem*0;
% sed = sed+10;

% LEM.dem = dem;
% LEM.rain = rain;
% LEM.sed = sed;

% GRIDobj2grd(dem,['./Topo/',dem.name,'.alt']);
% GRIDobj2grd(rain,['./Topo/',dem.name,'.rain']);
% GRIDobj2grd(sed,['./Topo/',dem.name,'.sed']);
%--------------------------------------------------------------------------
%%                           DEFINE INPUT PARAMETERS
%--------------------------------------------------------------------------

LEM.experiment = 'Test';                % Project name

LEM.ErosPath = 'C:\\Projects\\EROS';    % Path to .exe
LEM.outfolder = 'test';                 % folder to store results in

LEM.inflow = 10;                        % [m3s-1]water inflow at source cells
LEM.initial_sediment_stock = 0.1;       % [%] volumetric sediment inflow at source cells)
LEM.inertia = 0;                        % refers to inertia term in shallow water equation

LEM.start = 0;                          % start time
LEM.stop = 200000;                      % length of model run
LEM.draw = 2000;                        % output interval
LEM.init = 2000;                        % initialization time (-)
LEM.step = 0.3;
LEM.stepmin = 0.3;
LEM.stepmax = 0.3;
% LEM.i = 1.5e-3;

LEM.TU = 100;                           % unknown parameter
LEM.floodos = 'stationary:pow';

%--------------------------------------------------------------------------
% EROSION/DEPOSITION
%--------------------------------------------------------------------------
LEM.erosion_model = 'shear_stress';     % (stream_power, shear_stress, shear_mpm)
LEM.deposition_model = 'constant';      % need to know whether there are other options!

% ALLUVIAL
LEM.fluvial_stress_exponent = 1.5;      % exponent in sediment flux eq. (MPM): qs = E(tau-tau_c)^a
LEM.fluvial_erodability = 0.0002;       % [kg-1.5 m-3.5 s-2] E in MPM equation
LEM.fluvial_sediment_threshold = 4.0;   % [Pa] critical shear stress (tau_c) in MPM equation
LEM.deposition_length = 2;              % [m] xi in vertical erosion term: edot = qs/xi

% Lateral erosion/deposition
LEM.fluvial_lateral_erosion_coefficient = 0.05;             % dimensionless coefficient (Eq. 17 in Davy, Croissant, Lague (2017))
LEM.fluvial_lateral_deposition_coefficient = 0.5;

% BEDROCK
LEM.fluvial_basement_erodability = 0.0002;
LEM.fluvial_basement_threshold = 4;

%--------------------------------------------------------------------------
% FLOW MODEL
%--------------------------------------------------------------------------
LEM.diffusion_coefficient = 0.5;
LEM.poisson_coefficient = 4;
LEM.flood_model = 1;
LEM.flow_model = 'manning';
LEM.minimum_flow_coefficient = 0.0;
LEM.friction_coefficient = 0.025;       % 
LEM.water_depth_limit = -1;
LEM.flow_depth_constant = 1.0;
LEM.flow_only = 0;
LEM.fictious_area = 1;

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
LEM.rainfall = 0;

LEM.str_write = '';
LEM.str_nowrite = '';

writeErosInputs(LEM);

%% run model
system([LEM.experiment,'.bat'])