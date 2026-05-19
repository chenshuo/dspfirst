function ma = stopplaying(ma)
% @MOVIEAUDIO/STOP Stop audio playback.
%
% See also @MOVIEAUDIO/ ... PLAY, RECORD, PAUSE, STOP

% Author(s): Greg Krudysz

% Load player object from figure memory
p = getappdata(ma.fig,'movietoolDataAudioP');

if ~isempty(p)
    if ma.Mver >= 6.5
        %----------------------------------------------------------
        % For Version 6.5.0 and higher use JavaAudioRecorder
        %----------------------------------------------------------
        if isplaying(p)
            p.stop;
        end
        %----------------------------------------------------------
    else
        %----------------------------------------------------------
        % For Version 6.x ,1 <= x < 6, use Windows audiorecorder
        %----------------------------------------------------------
        if and(ispc,(ma.Mver > 6.0))
            if isplaying(p)
                stop(p);   % stop audio playback
            end
        end
        %----------------------------------------------------------
    end
end