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

% write MPM.dat (Erosion/Deposition model)
fileID = fopen('./dat/MPM.dat','w');
fprintf(fileID, [LEM.erosion_model,'	erosion model\n']); 
fprintf(fileID, [LEM.deposition_model,'		deposition model\n']);
% ALLUVIAL
fprintf(fileID, [num2str(LEM.stress_exponent),'		stress exponent\n']);
fprintf(fileID, [num2str(LEM.deposition_length),'	  		deposition length\n']);
fprintf(fileID, [num2str(LEM.sediment_erodability),'  	sediment erodability\n']);
fprintf(fileID, [num2str(LEM.sediment_threshold),'			sediment threshold\n']);
% Lateral erosion/deposition
fprintf(fileID, [num2str(LEM.lateral_erosion),'		lateral erosion\n']);
fprintf(fileID, [num2str(LEM.lateral_deposition),'			lateral deposition\n']);
% BEDROCK
fprintf(fileID, [num2str(LEM.basement_erodability),'  	basement erodability\n']);
fprintf(fileID, [num2str(LEM.threshold),'			threshold\n']);
fclose(fileID);

% write flow_model.dat
fileID = fopen('./dat/flow_model.dat','w');
fprintf(fileID, [num2str(LEM.diffusion_coefficient),'			diffusion coefficient\n']);
fprintf(fileID, [num2str(LEM.poisson_coefficient),'			poisson coefficient\n']);
fprintf(fileID, [num2str(LEM.flood_model),'			flood model\n']);
fprintf(fileID, [LEM.flow_model,'		flow model\n']);
fprintf(fileID, [num2str(LEM.minimum_flow_coefficient),' 	 	minimum flow coefficient\n']);
fprintf(fileID, [num2str(LEM.friction_coefficient),'		friction coefficient\n']);
fprintf(fileID, [num2str(LEM.water_depth_limit),'			water depth limit\n']);
fprintf(fileID, [num2str(LEM.flow_depth_constant),'			flow depth constant\n']);
fprintf(fileID, [num2str(LEM.flow_only),' 			flow only\n']);
fprintf(fileID, [num2str(LEM.fictious_area),'			fictious area\n']);
fclose(fileID);

% write .arg file
fileID = fopen([LEM.experiment,'.arg'],'w');
fprintf(fileID, '-dat:dat\\flow_model.dat\n');
fprintf(fileID, '-dat:dat\\MPM.dat\n\n');
fprintf(fileID, ['-timing:init:',num2str(LEM.start),':end:',num2str(LEM.stop),':draw:',num2str(LEM.draw),'\n']);
fprintf(fileID, '-timing:step:0.3:volume:min:0.3:max:0.3\n\n');
fprintf(fileID, '// Default management\n');
fprintf(fileID, '-limiter:1e-3\n');
fprintf(fileID, '-adapt:all:log10:20:4000:2000\n\n');
fprintf(fileID, '//Save_parameters\n');
fprintf(fileID, ['-write',LEM.str_write,'\n']);
fprintf(fileID, ['-nowrite',LEM.str_nowrite,'\n\n']);
fprintf(fileID, '//seed_and_time\n');
fprintf(fileID, ['-TU:',num2str(LEM.seedtime),'\n']);   % unknown parameter 
fclose(fileID);

% write .bat file
fileID = fopen([LEM.experiment,'.bat'],'w');
fprintf(fileID, '@rem  Run Eros program with following arguments\n');
fprintf(fileID, '@rem\n');
fprintf(fileID, '@echo off\n');
fprintf(fileID, ['@set EROS_PROG=',LEM.ErosPath,'\\bin\\Eros.exe\n']);
fprintf(fileID, '@set COMMAND=%%EROS_PROG%% %%*\n');
fprintf(fileID, '@echo on\n');
fprintf(fileID, '@rem\n\n');
fprintf(fileID, 'goto:todo\n\n');
fprintf(fileID, ':not_todo\n\n');
fprintf(fileID, ':todo\n\n\n');
fprintf(fileID, ['start /LOW %%COMMAND%% -dir:',LEM.outfolder,'\\ ',LEM.experiment,'.arg -alt:Topo\\',LEM.dem.name,'.alt -inflow:',num2str(LEM.inflow),':dir -initial_sediment_stock:',num2str(LEM.initial_sediment_stock),':dir -sediment_threshold:',num2str(LEM.sediment_threshold),':dir']);
fclose(fileID);