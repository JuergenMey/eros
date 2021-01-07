function writeErosInputs(LEM)

% Writes the neccessary files for running Eros.exe

% define outputs to write
switch LEM.stress 
    case 1
        LEM.str_write = strcat(LEM.str_write,'stress');
    case 0
        LEM.str_nowrite = strcat(LEM.str_nowrite,'stress');
end
switch LEM.water 
    case 1
        LEM.str_write = strcat(LEM.str_write,':water');
    case 0
        LEM.str_nowrite = strcat(LEM.str_nowrite,':water');
end
switch LEM.discharge 
    case 1
        LEM.str_write = strcat(LEM.str_write,':discharge');
    case 0
        LEM.str_nowrite = strcat(LEM.str_nowrite,':discharge');
end
switch LEM.downward 
    case 1
        LEM.str_write = strcat(LEM.str_write,':downward');
    case 0
        LEM.str_nowrite = strcat(LEM.str_nowrite,':downward');
end
switch LEM.slope
    case 1
        LEM.str_write = strcat(LEM.str_write,':slope');
    case 0
        LEM.str_nowrite = strcat(LEM.str_nowrite,':slope');
end
switch LEM.qs 
    case 1
        LEM.str_write = strcat(LEM.str_write,':qs');
    case 0
        LEM.str_nowrite = strcat(LEM.str_nowrite,':qs');
end
switch LEM.capacity
    case 1
        LEM.str_write = strcat(LEM.str_write,':capacity');
    case 0
        LEM.str_nowrite = strcat(LEM.str_nowrite,':capacity');
end
switch LEM.rainfall
    case 1
        LEM.str_write = strcat(LEM.str_write,':rainfall');
    case 0
        LEM.str_nowrite = strcat(LEM.str_nowrite,':rainfall');
end
switch LEM.sediment
    case 1
        LEM.str_write = strcat(LEM.str_write,':sediment');
    case 0
        LEM.str_nowrite = strcat(LEM.str_nowrite,':sediment');
end

fileID = fopen([LEM.experiment,'.arg'],'w');
fprintf(fileID, ['dat=dat\\inputs.dat\n']);
fclose(fileID);

% write input file
fileID = fopen('./dat/inputs.dat','w');
fprintf(fileID, ['erosion_model=',LEM.erosion_model,'\n']); 
fprintf(fileID, ['deposition_model=',LEM.deposition_model,'\n']);
% ALLUVIAL
fprintf(fileID, ['sediment_stress_exponent_fluvial=',num2str(LEM.fluvial_stress_exponent),'\n']);
fprintf(fileID, ['deposition_length_fluvial=',num2str(LEM.deposition_length),'\n']); 
fprintf(fileID, ['sediment_erodability_fluvial=',num2str(LEM.fluvial_erodability),'\n']);
fprintf(fileID, ['sediment_threshold_fluvial=',num2str(LEM.fluvial_sediment_threshold),'\n']);
fprintf(fileID, ['sediment_grain=',num2str(LEM.sediment_grain),'\n']);


% Lateral erosion/deposition
fprintf(fileID, ['lateral_erosion_model=',num2str(LEM.lateral_erosion_model),'\n']);
fprintf(fileID, ['lateral_deposition_model=',num2str(LEM.lateral_deposition_model),'\n']);

fprintf(fileID, ['lateral_erosion_coefficient_fluvial=',num2str(LEM.fluvial_lateral_erosion_coefficient),'\n']);
fprintf(fileID, ['lateral_deposition_coefficient_fluvial=',num2str(LEM.fluvial_lateral_deposition_coefficient),'\n']);

fprintf(fileID, ['lateral_erosion_outbend=',num2str(LEM.outbend_erosion_coefficient),'\n']);
fprintf(fileID, ['lateral_erosion_inbend=',num2str(LEM.inbend_erosion_coefficient),'\n']);


% BEDROCK
fprintf(fileID, ['basement_erodability_fluvial=',num2str(LEM.fluvial_basement_erodability),'\n']);
fprintf(fileID, ['basement_threshold_fluvial=',num2str(LEM.fluvial_basement_threshold),'\n']);
fprintf(fileID, ['poisson_coefficient=',num2str(LEM.poisson_coefficient),'\n']);
fprintf(fileID, ['diffusion_coefficient=',num2str(LEM.diffusion_coefficient),'\n']);
fprintf(fileID, ['basement_grain=',num2str(LEM.basement_grain),'\n']);




% FLOW MODEL
fprintf(fileID, ['flood_model=',num2str(LEM.flood_model),'\n']);
fprintf(fileID, ['flow_model=',LEM.flow_model,'\n']);
fprintf(fileID, ['friction_coefficient=',num2str(LEM.friction_coefficient),'\n']);
fprintf(fileID, ['flow_only=',num2str(LEM.flow_only),'\n']);
fprintf(fileID, ['flow_boundary=',num2str(LEM.flow_boundary),'\n']);


% Boundary conditions
% Topo
fprintf(fileID, ['topo=Topo\\',LEM.dem.name,'.alt:dir:name:short\n']);
fprintf(fileID, ['rain=Topo\\',LEM.dem.name,'.rain\n']);
% fprintf(fileID, ['sed=Topo\\',LEM.dem.name,'.sed\n']);
% fprintf(fileID, ['uplift=Topo\\',LEM.dem.name,'.uplift\n']);

% inflow conditions
% fprintf(fileID, ['inflow=',num2str(LEM.inflow),':dir\n']);
fprintf(fileID, ['rainfall=',num2str(LEM.rainfall),'\n']);
fprintf(fileID, ['initial_sediment_stock=',num2str(LEM.initial_sediment_stock),'\n']);

% Time
% fprintf(fileID, ['time:begin=',num2str(LEM.begin),':end=',num2str(LEM.end),':step:min=',num2str(LEM.stepmin),':max=',num2str(LEM.stepmax),':tu:draw=',num2str(LEM.draw),'\n']);
% fprintf(fileID, ['time:begin=',num2str(LEM.begin),':tu:end=',num2str(LEM.end),':tu:step=',num2str(LEM.step),':dir:volume:draw=',num2str(LEM.draw),'\n']);
fprintf(fileID, ['time:init:begin=',num2str(LEM.initbegin),':end=',num2str(LEM.initend),':step=',num2str(LEM.initstep),':log:op=*:tu=1\n']);
% fprintf(fileID, ['time:begin=',num2str(LEM.begin),':end=',num2str(LEM.end),':init=',num2str(LEM.init),':draw=',num2str(LEM.draw),'\n']);
% fprintf(fileID, ['time:step=',num2str(LEM.step),':volume:min=',num2str(LEM.stepmin),':max=',num2str(LEM.stepmax),'\n']);

fprintf(fileID, ['time:begin=',num2str(LEM.begin),':',LEM.begin_option,'\n']);
fprintf(fileID, ['time:end=',num2str(LEM.end),':',LEM.end_option,'\n']);
fprintf(fileID, ['time:draw=',num2str(LEM.draw),':',LEM.draw_option,'\n']);
fprintf(fileID, ['time:step=',num2str(LEM.step),':',LEM.step_option,'\n']);
fprintf(fileID, ['time:step:min=',num2str(LEM.stepmin),':max=',num2str(LEM.stepmax),'\n']);
fprintf(fileID, ['time:erosion_multiply=',num2str(LEM.erosion_multiply),'\n']);




% Default management
fprintf(fileID, ['limiter=',num2str(LEM.limiter),'\n']);
fprintf(fileID, 'default:model=all:min=20:max=10000:step=4:op=*:log10\n');

% Save parameters
fprintf(fileID, ['write=',LEM.str_write,'\n']);
% fprintf(fileID, ['-nowrite',LEM.str_nowrite,'\n\n']);
% % fprintf(fileID, '# seed_and_time\n');
fprintf(fileID, ['TU_coefficient=',num2str(LEM.TU_coefficient),'\n']);   % unknown parameter 
fprintf(fileID, ['flow_inertia_coefficient=',num2str(LEM.inertia),'\n']);   % inertia in shallow water equation 
fprintf(fileID, ['friction_model=',LEM.friction_model,'\n']);   % floodos mode 
% fprintf(fileID, ['i=',num2str(LEM.i),':dir\n']);   % unknown parameter
fclose(fileID);

% write .bat file
fileID = fopen([LEM.experiment,'.bat'],'w');
fprintf(fileID, '@rem  Run Eros program with following arguments\n');
fprintf(fileID, '@rem\n');
fprintf(fileID, '@echo off\n');
fprintf(fileID, ['@set EROS_PROG=',LEM.ErosPath,'\\bin\\eros7.3.exe\n']);
fprintf(fileID, '@set COMMAND=%%EROS_PROG%% %%*\n');
fprintf(fileID, '@echo on\n');
fprintf(fileID, '@rem\n\n');
fprintf(fileID, 'goto:todo\n\n');
fprintf(fileID, ':not_todo\n\n');
fprintf(fileID, ':todo\n\n\n');
fprintf(fileID, ['start /LOW %%COMMAND%% -dir=',LEM.outfolder,'\\ ',LEM.experiment,'.arg']);
fclose(fileID);