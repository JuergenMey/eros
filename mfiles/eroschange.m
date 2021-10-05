function D = eroschange(variable,first,last)


narginchk(1,inf);
nargoutchk(0,1);

if nargin == 1 
    first = 2;
end



switch variable
    case 'topo'
        filetype = 'alt';
        iylabel = 'Elevation (m)';
    case 'sediment'
        filetype = 'sed';
        iylabel = 'Sediment thickness (m)';
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
[t,~] = fread_timeVec(T.name,length(Z));
if isempty(t)
    t=1:length(Z);
end
if isnan(t)
    t=1:length(Z);
end

[~,index] = sortrows({Z.date}.');
Z = Z(index);

if nargin == 1
    [z1,~] = fopengrd(Z(first).name);
    [z2,~] = fopengrd(Z(end).name);
elseif nargin == 2
    [z1,~] = fopengrd(Z(first).name);
    [z2,~] = fopengrd(Z(end).name);
else
    [z1,~] = fopengrd(Z(first).name);
    [z2,~] = fopengrd(Z(last).name);
end

fig = figure;imagesc(z2-z1),colorbar
D = z2-z1;

title(['Change in ',iylabel]);
