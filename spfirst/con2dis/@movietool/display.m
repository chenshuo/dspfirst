function display(t)
% @MOVIETOOL/DISPLAY Command window display of a movietool object

% Author(s): Greg Krudysz

if t.rec_flag
    status = 'recording';
elseif t.play_flag
    status = 'playing';
elseif t.rec_flag*t.play_flag
    status = 'error';
else
    status = 'idle';
end

stg = sprintf(...
    ' Version: %s\n File name: %s.m\n Status: %s\n',...
    t.version,t.filename,status);

disp(' ');
disp([inputname(1),' = '])
disp(' ');
disp(stg)
disp(' ');