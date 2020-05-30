function [time,dt] = fread_timeVec(dP_fN,Nf)
%==========================================================================
time = [];
dt   = [];

fid  = fopen(dP_fN);

str1 = 'time:begin=';
str2 = 'end';
str3 = 'draw';

if(fid > 0) 
    tline = fgets(fid);
    while ischar(tline)
        tline = fgets(fid);     
        if (length(tline) > length(str1))                                  % line must be longer than str1
            if (strcmp(tline(1:length(str1)),str1))
                endl  = strfind(tline,str2);
                draw  = strfind(tline,str3);            
                dt    = str2double(tline(draw+5:end));
                %t_end = str2double(tline(endl+4:draw-2));
            end
        end
    end
    time  = 0:dt: Nf*dt-dt;
else   
    error('file not found')
end

fclose(fid);

end