function writeErosInputs(LEM)

% Writes the neccessary files for running Eros.exe

% define outputs to write
switch LEM.stress 
    case 1
        LEM.str_write = strcat(LEM.str_write,':stress');
    case 0
        LEM.str_nowrite = strcat(LEM.str_nowrite,':stress');
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
fprintf(fileID, ['fluvial_stress_exponent=',num2str(LEM.fluvial_stress_exponent),'\n']);
fprintf(fileID, ['fluvial_river-to-bed_transfert_length=',num2str(LEM.deposition_length),'\n']); % be aware of the t in transfert_length
fprintf(fileID, ['fluvial_erodability=',num2str(LEM.fluvial_erodability),':dir\n']);
fprintf(fileID, ['fluvial_sediment_threshold=',num2str(LEM.fluvial_sediment_threshold),'\n']);
% Lateral erosion/deposition
fprintf(fileID, ['fluvial_lateral_erosion_coefficient=',num2str(LEM.fluvial_lateral_erosion_coefficient),'\n']);
fprintf(fileID, ['fluvial_lateral_deposition_coefficient=',num2str(LEM.fluvial_lateral_deposition_coefficient),'\n']);
% BEDROCK
fprintf(fileID, ['fluvial_basement_erodability=',num2str(LEM.fluvial_basement_erodability),'\n']);
fprintf(fileID, ['fluvial_basement_threshold=',num2str(LEM.fluvial_basement_threshold),'\n']);

% FLOW MODEL
fprintf(fileID, ['diffusion_coefficient=',num2str(LEM.diffusion_coefficient),'\n']);
fprintf(fileID, ['poisson_coefficient=',num2str(LEM.poisson_coefficient),'\n']);
fprintf(fileID, ['flood_model=',num2str(LEM.flood_model),'\n']);
fprintf(fileID, ['flow_model=',LEM.flow_model,'\n']);
fprintf(fileID, ['minimum_flow_coefficient=',num2str(LEM.minimum_flow_coefficient),'\n']);
fprintf(fileID, ['friction_coefficient=',num2str(LEM.friction_coefficient),'\n']);
fprintf(fileID, ['water_depth_limit=',num2str(LEM.water_depth_limit),'\n']);
fprintf(fileID, ['flow_depth_constant=',num2str(LEM.flow_depth_constant),'\n']);
fprintf(fileID, ['flow_only=',num2str(LEM.flow_only),'\n']);
fprintf(fileID, ['fictious_area=',num2str(LEM.fictious_area),'\n']);

% Boundary conditions
% Topo
fprintf(fileID, ['topo=Topo\\',LEM.dem.name,'.alt:dir:short\n']);
fprintf(fileID, ['rain=Topo\\',LEM.dem.name,'.rain\n']);
fprintf(fileID, ['sed=Topo\\',LEM.dem.name,'.sed\n']);

% inflow conditions
fprintf(fileID, ['inflow=',num2str(LEM.inflow),':dir\n']);
fprintf(fileID, ['initial_sediment_stock=',num2str(LEM.initial_sediment_stock),':dir\n']);

% Time
fprintf(fileID, ['time:begin=',num2str(LEM.start),':end=',num2str(LEM.stop),':step=',num2str(LEM.step),':volume:draw=',num2str(LEM.draw),'\n']);
% fprintf(fileID, ['time:begin=',num2str(LEM.start),':end=',num2str(LEM.stop),':init=',num2str(LEM.init),':draw=',num2str(LEM.draw),'\n']);
% fprintf(fileID, ['time:step=',num2str(LEM.step),':volume:min=',num2str(LEM.stepmin),':max=',num2str(LEM.stepmax),'\n']);

% Default management
fprintf(fileID, 'limiter=1e-3\n');
% fprintf(fileID, 'adapt:all:log10:20:4000:2000\n\n');

% Save parameters
fprintf(fileID, ['write=',LEM.str_write,'\n']);
% fprintf(fileID, ['-nowrite',LEM.str_nowrite,'\n\n']);
% % fprintf(fileID, '# seed_and_time\n');
fprintf(fileID, ['TU=',num2str(LEM.TU),':dir\n']);   % unknown parameter 
fprintf(fileID, ['inertia=',num2str(LEM.inertia),':dir\n']);   % inertia in shallow water equation 
fprintf(fileID, ['floodos=',LEM.floodos,':dir\n']);   % floodos mode 
% fprintf(fileID, ['i=',num2str(LEM.i),':dir\n']);   % unknown parameter
fclose(fileID);

% write .bat file
fileID = fopen([LEM.experiment,'.bat'],'w');
fprintf(fileID, '@rem  Run Eros program with following arguments\n');
fprintf(fileID, '@rem\n');
fprintf(fileID, '@echo off\n');
fprintf(fileID, ['@set EROS_PROG=',LEM.ErosPath,'\\bin\\eros7.exe\n']);
fprintf(fileID, '@set COMMAND=%%EROS_PROG%% %%*\n');
fprintf(fileID, '@echo on\n');
fprintf(fileID, '@rem\n\n');
fprintf(fileID, 'goto:todo\n\n');
fprintf(fileID, ':not_todo\n\n');
fprintf(fileID, ':todo\n\n\n');
fprintf(fileID, ['start /LOW %%COMMAND%% -dir=',LEM.outfolder,'\\ ',LEM.experiment,'.arg']);
fclose(fileID);