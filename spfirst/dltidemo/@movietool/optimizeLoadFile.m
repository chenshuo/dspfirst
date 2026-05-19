function mvn = optimizeLoadFile(mt,Data,k,N2)                
% Optimize loading of a movie file.
%
% A movie is loaded upto its current frame number 
% by evaluating each frame sequentially, similarly 
% to playing a file.  To speed up this process,
% certain functions (dragging functions) can be 
% ignored, since there is no history associated 
% with them.
%
% In pezdemo, 'movepez' function can be ignored.
%
%   DATA: movie data log
%      K: current frame number
%     N2: number of frames in a movie

% Author(s): Greg Krudysz 

if strcmp(mt.filename,'dltidemo')
    
%     mv = findstr(Data{k,1},'SomeFcn');
%     if or(isempty(mv),(k+1 > N2-1))
%         mvn = [];
%     else
%         mvn = findstr(Data{k+1,1},'SomeFcn');
%     end
mvn = [];
    
else
    msg1 = sprintf('@movietool\\optimizeLoadFile is written specifically for:\n\t %s \n',mt.filename);
    msg2 = ['Seting the output in ''optimizeLoadFile'' to mvn = [] to disable optimization'];
    
    if ~strcmp(lastwarn,[msg1,msg2])
        warning([msg1,msg2]);
    end
    
    mvn = [];
end
