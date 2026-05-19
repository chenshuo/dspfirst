function ma = record(ma)
% @MOVIEAUDIO/RECORD Record audio.
%
% See also @MOVIEAUDIO/ ... PLAY, STOP, PAUSE

% Author(s): Greg Krudysz

if ma.Mver >= 6.5
    % For Version 6.5.0 and higher use JavaAudioRecorder
    % Load recorder object from figure memory
    r = com.mathworks.toolbox.audio.JavaAudioRecorder(ma.Fs,16,1);
    setappdata(ma.fig,'movietoolDataAudioR',r);
    r.record;
    ma.recorder = 1;
else
    % For Version 6.x ,1 <= x < 5, use Windows audiorecorder
    if and(ispc,(ma.Mver > 6.0))
        r = audiorecorder(ma.Fs,16,1); 
        setappdata(ma.fig,'movietoolDataAudioR',r);
        record(r);
    else
        errordlg({'Audio recording is unavailable for this platform',...
                'and/or this version of Matlab'},'Audio Error')
    end
end