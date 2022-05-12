%% flood wave

x = 0:0.1:24;
y = 0.1*sin(x+pi/4)*10000+2000;
x = x/365.25/24;
y(1:39)=y(1:39)./y(1:39).*1000;
y(104:end)=y(104:end)./y(104:end).*1000;
y= y./1000;
h=figure;
plot(x,y)
xlabel('Time(yrs)')
ylabel('Q (m^3/s)')
saveas(h, 'floodwave','fig');

fileID = fopen(['floodwave.climate'],'w');
fprintf(fileID, ['time    flow:relative  \n']);  
for i = 1:length(x)
fprintf(fileID, [num2str(x(i)),'		',num2str(y(i)),'\n']);
end
fclose(fileID);


%% cyclic
x = 0:0.1:5;
y = 0.05*sin(x+pi/4)+0.15;
x = x*5000;
h=figure;
plot(x,y)
xlabel('Time')
ylabel('Qs (m^3/m^3)')
saveas(h, 'D:\USER\mey\ProjectFolder\Topo\test4_climate','fig');

fileID = fopen(['D:\USER\mey\ProjectFolder\Topo\test4.climate'],'w');
fprintf(fileID, ['time    flow:relative   cs:absolute\n']);  
for i = 1:length(x)
fprintf(fileID, [num2str(x(i)),'	1	',num2str(y(i)),'\n']);
end
fclose(fileID);

%% step changes
x = 1:2000:200000;
y=ones(size(x));
y(1:50) = 1;
y(51:end) = 1;
h=figure;
plot(x,y)
xlabel('Time')
ylabel('Qs (m^3/m^3)')
saveas(h, 'D:\USER\mey\ProjectFolder\Topo\100prcnt_cs','fig');

fileID = fopen(['D:\USER\mey\ProjectFolder\Topo\100prcnt_cs.climate'],'w');
fprintf(fileID, ['time    flow:relative   cs:absolute\n']);  
for i = 1:length(x)
fprintf(fileID, [num2str(x(i)),'	1	',num2str(y(i)),'\n']);
end
fclose(fileID);

%% 1 Million year
% sediment
erosion_multiplier = 1;

clear y z
x = 1:315:315000;

% sediment
y(1:10) = 0.1;
y(11:30) = 0.35;
y(31:90) = 0.15;
y(91:100) = 0.8;
y = horzcat(y,y,y,y,y,y,y,y,y,y);

% discharge
z(1:10) = 1;
z(11:30) = 0.3;
z(31:90) = 0.2;
z(91:100) = 0.87;
z = horzcat(z,z,z,z,z,z,z,z,z,z);


h=figure;
subplot(3,1,1)
plot(x,y)
xlabel('Time (yr)')
ylabel('Qs (m^3/s)')
ylim([0 1.0])

subplot(3,1,2)
plot(x,z)
xlabel('Time (yr)')
ylabel('Q (relative to 340 m^3s^-^1)')
ylim([0 1.2])

subplot(3,1,3)
plot(x,y./(z.*346)*erosion_multiplier)
xlabel('Time (yr)')
ylabel('Qs/Q')
% ylim([0 1.2])

saveas(h, 'D:\USER\mey\ProjectFolder\Topo\boundary_1Ma_','fig');

fileID = fopen(['D:\USER\mey\ProjectFolder\Topo\boundary_1Ma.climate'],'w');
fprintf(fileID, ['time    flow:relative   cs:absolute\n']);  
for i = 1:length(x)
fprintf(fileID, [num2str(x(i)),'    ',num2str(z(i)),'    ' num2str(y(i)/(z(i)*346)*erosion_multiplier),'\n']);
end
fclose(fileID);


%% 1 Million year (GT)
% sediment
erosion_multiplier = 1;

clear y z
x = 1:1000:1000000;

% sediment
y(1:10) = 0.1;
y(11:30) = 0.35;
y(31:90) = 0.15;
y(91:100) = 0.8;
y = horzcat(y,y,y,y,y,y,y,y,y,y);

% discharge
z(1:10) = 1;
z(11:30) = 0.3;
z(31:90) = 0.2;
z(91:100) = 0.87;
z = horzcat(z,z,z,z,z,z,z,z,z,z);


h=figure;
subplot(3,1,1)
plot(x,y)
xlabel('Time (yr)')
ylabel('Qs (m^3/s)')
ylim([0 1.0])

subplot(3,1,2)
plot(x,z)
xlabel('Time (yr)')
ylabel('Q (relative to 340 m^3s^-^1)')
ylim([0 1.2])

subplot(3,1,3)
plot(x,y./(z.*346)*erosion_multiplier)
xlabel('Time (yr)')
ylabel('Qs/Q')
% ylim([0 1.2])

saveas(h, 'D:\USER\mey\ProjectFolder\Topo\boundary_1Ma_GT','fig');

fileID = fopen(['D:\USER\mey\ProjectFolder\Topo\boundary_1Ma_GT.climate'],'w');
fprintf(fileID, ['time    flow:relative   cs:absolute\n']);  
for i = 1:length(x)
fprintf(fileID, [num2str(x(i)),'    ',num2str(z(i)),'    ' num2str(y(i)/(z(i)*346)*erosion_multiplier),'\n']);
end
fclose(fileID);