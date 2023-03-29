function erossurf2(DEM,W)

surf(DEM+W,min(W,5), 'block', true, 'baselevel',250); 
colormap(flowcolor)
% hold on
% clr = flowcolor;
% depth = linspace(0,5,size(clr,1))';
% WRGB = interp1(depth,clr,W.Z(:));
% WRGB = reshape(WRGB,[W.size 3]);
% 
% surf(X,Y,DEM.Z+W.Z,WRGB,'AlphaData',min(W.Z,1),'EdgeColor','none')
% hold off
exaggerate(gca,4)
camlight
material dull
axis off
campos(1.0e+04 *[-0.6570   -3.5552    1.3238])

hold on
[X,Y] = getcoordinates(DEM,'matrix');
%plot3(X(:,1),Y(:,1),DEM.Z(:,1)-SED.Z(:,1),'color',[.7 .7 .7])
plot3(X(:,1),Y(:,1),DEM.Z(:,1),'k')
hold off
