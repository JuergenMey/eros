function frames2gif(frames,filename,delay) 

for idx = 1:length(frames)
    [A,map] = rgb2ind(frame2im(frames(idx)),256);
    if idx == 1
        imwrite(A,map,filename,'gif','LoopCount',Inf,'DelayTime',delay);
    else
        imwrite(A,map,filename,'gif','WriteMode','append','DelayTime',delay);
    end
end