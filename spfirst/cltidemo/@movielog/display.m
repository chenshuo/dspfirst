function display(ml)
% @MOVIELOG/DISPLAY Command window display of a movielog object

% Author(s): Greg Krudysz

% Movie name and path
if isempty(ml.moviename)
file_name = ml.moviename;
path_name = ml.moviepath;
else
file_name = '';
path_name = '';
end

% Movie size
if isempty(ml.data)
    data_status = 'empty'; 
else
    [r,c] = size(ml.data);
    if r == 1
        entry_str = 'entry';  else
        entry_str = 'entries'; 
    end
    
    data_status = sprintf('%d %s',r,entry_str);
end

stg = sprintf(...
    ' Movie name: %s\n Movie path: %s\n lineNo: %d\n time0: %s\n Data: %s',...
    file_name,path_name,ml.lineNo,datestr(ml.time0),data_status);

disp(' ');
disp([inputname(1),' = '])
disp(' ');
disp(stg)
disp(' ');