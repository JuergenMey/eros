function writeErosInputs8(LEM)

% Writes the neccessary files for running Eros.exe

fileID = fopen([LEM.experiment,'.arg'],'w');
fprintf(fileID, ['dat=dat\\inputs.dat\n']);
fclose(fileID);

% write input file
fileID = fopen('./dat/inputs.dat','w');
fprintf(fileID, ['erosion_model=',LEM.erosion_model,'\n']); 
fprintf(fileID, ['deposition_model=',LEM.deposition_model,'\n']);
% ALLUVIAL
fprintf(fileID, ['deposition_length_fluvial=',num2str(LEM.deposition_length),'\n']); 
fprintf(fileID, ['sediment_grain=',num2str(LEM.sediment_grain),'\n']);


% Lateral erosion/deposition
fprintf(fileID, ['lateral_erosion_model=',num2str(LEM.lateral_erosion_model),'\n']);
fprintf(fileID, ['lateral_deposition_model=',num2str(LEM.lateral_deposition_model),'\n']);

fprintf(fileID, ['lateral_erosion_coefficient_fluvial=',num2str(LEM.fluvial_lateral_erosion_coefficient),'\n']);
fprintf(fileID, ['lateral_deposition_coefficient_fluvial=',num2str(LEM.fluvial_lateral_deposition_coefficient),'\n']);

try
fprintf(fileID, ['lateral_erosion_outbend=',num2str(LEM.outbend_erosion_coefficient),'\n']);
fprintf(fileID, ['lateral_erosion_inbend=',num2str(LEM.inbend_erosion_coefficient),'\n']);
catch
end


% BEDROCK
fprintf(fileID, ['poisson_coefficient=',num2str(LEM.poisson_coefficient),'\n']);
fprintf(fileID, ['diffusion_coefficient=',num2str(LEM.diffusion_coefficient),'\n']);
fprintf(fileID, ['basement_grain=',num2str(LEM.basement_grain),'\n']);
fprintf(fileID, ['basement_erodibility=',num2str(LEM.fluvial_basement_erodability),'\n']);
try
fprintf(fileID, ['sediment_erodability=',num2str(LEM.fluvial_sediment_erodability),'\n']);
catch
end


% FLOW MODEL
fprintf(fileID, ['flow_model=',LEM.flow_model,'\n']);
fprintf(fileID, ['friction_coefficient=',num2str(LEM.friction_coefficient),'\n']);
fprintf(fileID, ['flow_boundary=',num2str(LEM.flow_boundary),'\n']);
fprintf(fileID, ['stress_model=',num2str(LEM.stress_model),'\n']);



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
if isfield(LEM,'climate')
fprintf(fileID, ['climate=',LEM.climate,'\n']);
end


% INFLOW/RAINFALL CONDITIONS
if isfield(LEM,'inflow')
fprintf(fileID, ['inflow=',num2str(LEM.inflow),':dir\n']);
end
if isfield(LEM,'rainfall')
fprintf(fileID, ['rainfall=',num2str(LEM.rainfall),'\n']);
end
try
fprintf(fileID, ['input_sediment_concentration=',num2str(LEM.initial_sediment_stock),'\n']);
catch
end

try
fprintf(fileID, ['model=',LEM.model,'\n']);  
catch
end
% TIME
try % some parameters that are available from eros 7.5.92 onwards
fprintf(fileID, ['time:unit=',LEM.time_unit,'\n']);  
fprintf(fileID, ['time_extension=',num2str(LEM.time_extension),'\n']);
catch % in case we use an older eros version
end
fprintf(fileID, ['time:end=',num2str(LEM.end),':',LEM.end_option,'\n']);
fprintf(fileID, ['time:draw=',num2str(LEM.draw),':',LEM.draw_option,'\n']);
fprintf(fileID, ['time:step=',num2str(LEM.step),':',LEM.step_option,'\n']);
fprintf(fileID, ['time:step:min=',num2str(LEM.stepmin),':max=',num2str(LEM.stepmax),'\n']);
fprintf(fileID, [LEM.initphase,'\n']);
fprintf(fileID, ['erosion_multiplier=',num2str(LEM.erosion_multiplier),'\n']);
fprintf(fileID, ['erosion_multiplier_op=',num2str(LEM.erosion_multiplier_op),'\n']);
fprintf(fileID, ['erosion_multiplier_min=',num2str(LEM.erosion_multiplier_min),'\n']);
fprintf(fileID, ['erosion_multiplier_max=',num2str(LEM.erosion_multiplier_max),'\n']);
fprintf(fileID, ['erosion_multiplier_increment=',num2str(LEM.erosion_multiplier_increment),'\n']);
fprintf(fileID, ['erosion_multiplier_default_min=',num2str(LEM.erosion_multiplier_default_min),'\n']);
fprintf(fileID, ['erosion_multiplier_default_max=',num2str(LEM.erosion_multiplier_default_max),'\n']);

fprintf(fileID, ['uplift_rate=',num2str(LEM.uplift_multiplier),'\n']);

try
fprintf(fileID, ['Point=',LEM.survey_points,'\n']);
catch
end


% Default management
fprintf(fileID, ['limiter_dh=',num2str(LEM.limiter_dh),'\n']);
fprintf(fileID, ['limiter_mode=',num2str(LEM.limiter_mode),'\n']);
% fprintf(fileID, 'default:model=all:min=20:max=10000:step=4:op=*:log10\n');

% Save parameters
fprintf(fileID, ['write=',LEM.str_write,'\n']);
fprintf(fileID, [LEM.TU,'\n']);   % unknown parameter 
fprintf(fileID, ['flow_inertia_coefficient=',num2str(LEM.inertia),'\n']);   % inertia in shallow water equation 
fprintf(fileID, ['friction_model=',LEM.friction_model,'\n']);   % floodos mode 
fclose(fileID);

% write .bat file
fileID = fopen([LEM.experiment,'.bat'],'w');
fprintf(fileID, '@rem  Run Eros program with following arguments\n');
fprintf(fileID, '@rem\n');
fprintf(fileID, '@echo off\n');
fprintf(fileID, ['@set EROS_PROG=..\\bin\\',LEM.eros_version,'.exe\n']);
fprintf(fileID, '@set COMMAND=%%EROS_PROG%% %%*\n');
fprintf(fileID, '@echo on\n');
fprintf(fileID, '@rem\n\n');
fprintf(fileID, 'goto:todo\n\n');
fprintf(fileID, ':not_todo\n\n');
fprintf(fileID, ':todo\n\n\n');
fprintf(fileID, ['start /LOW %%COMMAND%% -dir=',LEM.outfolder,'\\ ',LEM.experiment,'.arg']);
fclose(fileID);