function eros_continue(projectpath)
% This function enables the continuation of a eros/floodos run from the
% time of the last output. The inflow timeseries will also be started from where it was stopped.
% The function allows for changing boundary conditions and/or parameters in the continued run. 

% USAGE:    1. navigate into the output folder of the run to be continued
%              before calling eros_continue
%           2. projectpath is the path 1 step upwards of the folder where
%              the grids are stored, i.e. the folder in which the topo
%              folder resides
%    
%
%           After you have started a floodos/eros run ALWAYS save the LEM 
%           object as LEM.mat to the output folder. If you haven't then you
%           need to construct it again using your run template.


load LEM.mat        % load previous model setup
T = dir('*.txt');
[~,index] = sortrows({T.datenum}.');
T = T(index);
T = readtable(T(end).name);
ix = find(~strcmp(T{:,end},'-'));           % find the index of the last output
T(ix(end)+1:end,:)=[];

tablename = dir('*.txt');
[~,index] = sortrows({tablename.datenum}.');
tablename = tablename(index);
tablename=tablename(end).name;
writetable(T,tablename);                    % prune the table to the last output

H = dir('*.alt');
W = dir('*.water');
S = dir('*.sed');
[~,index] = sortrows({H.datenum}.');
H = H(index);
W = W(index);


LEM.dem = grd2GRIDobj(H(end).name,LEM.dem);
LEM.water = grd2GRIDobj(W(end).name,LEM.dem);
LEM.dem.name = 'continue';

if ~isempty(S)
S = S(index);
sediment = grd2GRIDobj(S(end).name,dem);
LEM.sed = sediment;
end

cd(projectpath)        %<<< path to your project folder
climate = importdata(LEM.climate,'\t'); 
climate.data = climate.data(:,~isnan(climate.data(1,:))); % in case NaNs appear during import
interupt_state = (length(ix)-1)*LEM.draw;
unpassed = climate.data(:,1)>=interupt_state;
climate.data = climate.data(unpassed,:);    % start timeseries from the last output time

fileID = fopen([projectpath,'\Topo\continue.climate'],'w');
fprintf(fileID, ['time   flow:relative\n']);
% fprintf(fileID, [climate.colheaders{1}, '   ',  climate.colheaders{2}, '     ',   climate.colheaders{3},'\n']);  
for i = 1:length(climate.data)
% fprintf(fileID, [num2str(climate.data(i,1)),'    ',num2str(climate.data(i,2)),'    ' num2str(climate.data(i,3)),'\n']);
fprintf(fileID, [num2str(climate.data(i,1)),'    ',num2str(climate.data(i,2)),'\n']);
end
fclose(fileID);

LEM.end = LEM.end-interupt_state;   % end time reduces by the already computed time

GRIDobj2grd(LEM.dem,['./Topo/',dem.name,'.alt']);
GRIDobj2grd(LEM.rain,['./Topo/',dem.name,'.rain']);
try
GRIDobj2grd(LEM.sed,['./Topo/',dem.name,'.sed']);
catch nosediment
end
    GRIDobj2grd(LEM.water,['./Topo/',dem.name,'.water']);
try
GRIDobj2grd(LEM.cs,['./Topo/',dem.name,'.cs']);
catch nocsgrid
end
try
GRIDobj2grd(LEM.uplift,['./Topo/',dem.name,'.uplift']);
catch nouplift
end
writeErosInputs(LEM);
system([LEM.experiment,'.bat'])