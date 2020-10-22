function F = profileEros


f = dir('*.alt');
[~,ix] = sort({f.date});
f = f(ix);
D = cellfun(@(x) grd2GRIDobj(x),{f.name},'UniformOutput',false);

f = dir('*.water');
[~,ix] = sort({f.date});
f = f(ix);

[d,z,x,y] = demprofile(D{1});

DIS = cellfun(@(x) grd2GRIDobj(x),{f.name},'UniformOutput',false);
for r = 1:numel(D)-1 
    [d,z] = demprofile(D{r+1},numel(x),x,y);
    [d,w] = demprofile(DIS{r+1},numel(x),x,y);
    plot(d,z+w,'b');
    hold on
    plot(d,z,'k');
    pause(0.1)
    hold off
    F(r) = getframe(gcf);
%     if r == 2
%         gif('test3.gif','DelayTime',0.1,'frame',gcf);
%     else
%         gif
%     end
end
