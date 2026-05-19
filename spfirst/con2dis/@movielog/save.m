function [fname,pname] = save(ml,filename)
% @MOVIELOG/SAVE log data into a file.
%
% SAVE(m1,FILENAME) saves data stored in movielog 
% object ml to a file by the name of FILENAME. 
%
% See also @MOVIELOG/ ... GET, DISPLAY

% Author(s): Greg Krudysz

% point to "...\private\movies\" directory
filepath  = which(filename);

if ml.Mver >= 6.5
    p_name = [filepath(1:end-length(filename)-2) 'movies\'];  else
    p_name = [filepath(1:24) 'movies\'];
end

[fname, pname] = uiputfile([p_name '*.mat'],'Save GUI Movie As');

if ischar(fname)
    % save movie data to a file
    data  = ml.data;
    save([pname,fname],'data');
    clear data    % Conserve memory 
end

set(ml,'data',[]);