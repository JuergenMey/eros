%--------------------------------------------------------------------------
%                               PREPARE GRIDS
%--------------------------------------------------------------------------
%
clear
dem=GRIDobj('./Topo/hillslope_test2.tif');
% dem = resample(dem,300);


% rain = GRIDobj('.\Topo\map_wc2.tif'); % MAP after WorldClim2 (mm/yr)
% rain = resample(rain,dem);
% rain = rain/1000; % convert to m/yr
% rain = rain/3600/24/365.25; % convert to m/s
rain = dem;
rain.Z = ones(rain.size);
rain.Z(1:end,1)=-1;
rain.Z(1,1:end)=-1;
rain.Z(end,1:end)=-1;
rain.Z(1:end,end)=-1;

% WATER
water = GRIDobj('.\Topo\hillslope_test2_water.tif');

% UPLIFT
% uplift =  GRIDobj('.\Topo\uplift_m_per_s_baselevel_Basel.tif');
% uplift =  GRIDobj('.\Topo\uplift_m_per_s_nagra_baselevel_Basel.tif');
% uplift = resample(uplift,dem);

% SED (sediment thickness in meters)
% sed = GRIDobj('.\Topo\mqu_140715g_utm32n_subset.tif');
% sed = dem*0;
% sed.Z(~isnan(sed.Z))=10;

LEM.dem = dem;
LEM.rain = rain;
% LEM.sed = sed;
% LEM.uplift = uplift;
LEM.water = water;
% LEM.cs = cs;

GRIDobj2grd(dem,['./Topo/',dem.name,'.alt']);
GRIDobj2grd(rain,['./Topo/',dem.name,'.rain']);
% GRIDobj2grd(sed,['./Topo/',dem.name,'.sed']);
% GRIDobj2grd(uplift,['./Topo/',dem.name,'.uplift']);
GRIDobj2grd(water,['./Topo/',dem.name,'.water']);
% GRIDobj2grd(cs,['./Topo/',dem.name,'.cs']);


%--------------------------------------------------------------------------
%%                           DEFINE INPUT PARAMETERS
%--------------------------------------------------------------------------

LEM.experiment = 'hillslope_test';                % Project name
LEM.model = 'floodos';
LEM.flow_model = 'stationary:pow';
LEM.flow_boundary = 2;
LEM.flow_only = 1;
LEM.friction_model = 'manning';
LEM.friction_coefficient = '0.025:dir';

LEM.rainfall = '2.8e-9';

LEM.TU_coefficient = 0.01;

LEM.begin = 0;          LEM.begin_option = 'time';                        % start time
LEM.end = 1;          LEM.end_option = 'time';                           % length of model run
LEM.draw = 1;        LEM.draw_option = 'time';                           % output interval
LEM.step = 1;         LEM.step_option = 'volume'; 
LEM.stepmin = 1;
LEM.stepmax = 1e4;
LEM.initbegin = 1000;                                   % initialization time (-)
LEM.initend = 10;
LEM.initstep = 1;
LEM.inittu = 10;






LEM.ErosPath = 'D:\\USER\\mey';    % Path to .exe
LEM.outfolder = 'hillslope_test\\water_init';                 % folder to store results in
%%

% Writes the neccessary files for running Eros.exe

fileID = fopen([LEM.experiment,'.arg'],'w');
fprintf(fileID, ['dat=dat\\inputs.dat\n']);
fclose(fileID);

% write input file
fileID = fopen('./dat/inputs.dat','w');
fprintf(fileID, ['model=',LEM.model,'\n']); 

% FLOW MODEL
fprintf(fileID, ['flow_model=',LEM.flow_model,'\n']);
fprintf(fileID, ['flow_boundary=',num2str(LEM.flow_boundary),'\n']);
fprintf(fileID, ['flow_only=',num2str(LEM.flow_only),'\n']);
fprintf(fileID, ['friction_coefficient=',num2str(LEM.friction_coefficient),'\n']);   % inertia in shallow water equation 
fprintf(fileID, ['friction_model=',LEM.friction_model,'\n']);   % floodos mode 



% Boundary conditions
% Topo
fprintf(fileID, ['topo=Topo\\',LEM.dem.name,'.alt\n']);
if isfield(LEM,'rain')
fprintf(fileID, ['rain=Topo\\',LEM.dem.name,'.rain\n']);
end
if isfield(LEM,'water')
fprintf(fileID, ['water=Topo\\',LEM.dem.name,'.water\n']);
end
if isfield(LEM,'sed')
fprintf(fileID, ['sed=Topo\\',LEM.dem.name,'.sed\n']);
end
if isfield(LEM,'uplift')
fprintf(fileID, ['uplift=Topo\\',LEM.dem.name,'.uplift\n']);
end
if isfield(LEM,'cs')
fprintf(fileID, ['cs=Topo\\',LEM.dem.name,'.cs\n']);
end

% INFLOW/RAINFALL CONDITIONS
if isfield(LEM,'inflow')
fprintf(fileID, ['inflow=',num2str(LEM.inflow),':dir\n']);
end
if isfield(LEM,'rainfall')
fprintf(fileID, ['rainfall=',num2str(LEM.rainfall),':dir\n']);
end

% Time
% fprintf(fileID, ['time:init:begin=',num2str(LEM.initbegin),':end=',num2str(LEM.initend),':step=',num2str(LEM.initstep),':log:op=*:tu=10\n']);
fprintf(fileID, ['time:begin=',num2str(LEM.begin),':tu:end=',num2str(LEM.end),':tu:step=',num2str(LEM.step),':',LEM.step_option,':draw=',num2str(LEM.draw),':tu\n']);

% Save parameters
fprintf(fileID, ['write=water:unit_discharge:precipiton_flux:downward:slope:stress\n']);
fprintf(fileID, ['TU_coefficient=',num2str(LEM.TU_coefficient),'\n']);   % unknown parameter 
fclose(fileID);

% write .bat file
fileID = fopen([LEM.experiment,'.bat'],'w');
fprintf(fileID, '@rem  Run Eros program with following arguments\n');
fprintf(fileID, '@rem\n');
fprintf(fileID, '@echo off\n');
fprintf(fileID, ['@set EROS_PROG=',LEM.ErosPath,'\\bin\\eros7.3.108.0.exe\n']);
fprintf(fileID, '@set COMMAND=%%EROS_PROG%% %%*\n');
fprintf(fileID, '@echo on\n');
fprintf(fileID, '@rem\n\n');
fprintf(fileID, 'goto:todo\n\n');
fprintf(fileID, ':not_todo\n\n');
fprintf(fileID, ':todo\n\n\n');
fprintf(fileID, ['start /LOW %%COMMAND%% -dir=',LEM.outfolder,'\\ ',LEM.experiment,'.arg']);
fclose(fileID);


%% run model
system([LEM.experiment,'.bat'])