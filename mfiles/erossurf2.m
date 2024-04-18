function erossurf2(DEM,W)

surf(DEM+W,min(W,5), 'block', true, 'baselevel',250); 
exaggerate(gca,1.5)
camlight
material dull
axis off

hold on
[X,Y] = getcoordinates(DEM,'matrix');
%plot3(X(:,1),Y(:,1),DEM.Z(:,1)-SED.Z(:,1),'color',[.7 .7 .7])
plot3(X(:,1),Y(:,1),DEM.Z(:,1),'k')
plot3(X(1,:),Y(1,:),DEM.Z(1,:),'k')
plot3(X(end,:),Y(end,:),DEM.Z(end,:),'k')
plot3(X(:,end),Y(:,end),DEM.Z(:,end),'k')
hold off
