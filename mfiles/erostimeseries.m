function Q = erostimeseries(variable)


p = inputParser;
expectedInput_variable = {'topo','water','sediment','flux','qs','qs/qw',...
    'discharge','downward','stress','hum','slope','capacity','stock'};
addRequired(p,'variable',@(x) any(validatestring(x,expectedInput_variable)));
parse(p,variable);

switch variable
    case 'topo'
        filetype = 'alt';
        iylabel = 'Elevation (m)';
    case 'sediment'
        filetype = 'sed';
        iylabel = 'Mean sediment thickness along path (m)';
    case 'water'
        filetype = 'water';
        iylabel = 'Water depth (m)';
    case 'capacity'
        filetype = 'capacity';
        iylabel = 'Capacity';
    case 'discharge'
        filetype = 'discharge';
        iylabel = 'Water discharge (m^3/s)';
    case 'flux'
        filetype = 'flux';
        iylabel = 'Water discharge (m^3/s)';
    case 'downward'
        filetype = 'downward';
        iylabel = 'Mean settling velocity (m/s)';
    case 'hum'
        filetype = 'hum';
        iylabel = 'Water discharge on topography (m^3/s)';
    case 'qs'
        filetype = 'qs';
        iylabel = 'Sediment flux (m^3/s)';
    case 'slope'
        filetype = 'slope';
        iylabel = 'Slope';
    case 'stock'
        filetype = 'stock';
        iylabel = 'Sediment stock (m^3)';
    case 'stress'
        filetype = 'stress';
        iylabel = 'Shear stress (Pa)';
end

T = dir('*.ini');
Z = dir(['*.',filetype]);
F = dir('*.flux');
t=[];
% [t,~] = fread_timeVec(T.name,length(Z));
if isempty(t)
    t=1:length(Z);
end
if isnan(t)
    t=1:length(Z);
end

[~,index] = sortrows({Z.date}.');
Z = Z(index);
F = F(index);

[z,~] = fopengrd(F(2).name);
fig = figure;imagesc(z)
[x,y,~]=improfile;
close(fig)


for i = 1:length(Z)
    [z,~] = fopengrd(Z(i).name);
    z(z==0)=NaN;
    c = improfile(z,x,y);
    if strcmp(filetype,'sed')==1
        Q(i) = nanmean(c);
    else
        Q(i) = nansum(c);
    end
end
t(1)=[];
Q(1)=[];
figure;plot(t,Q)
ylabel(iylabel);
xlabel('Time');