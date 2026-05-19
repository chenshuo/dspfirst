function ma = pause(ma)
% @MOVIEAUDIO/PAUSE pause audio.
%
% See also @MOVIEAUDIO/ ... PLAY, RECORD, STOP

% Author(s): Greg Krudysz

% Load player object from figure memory
p = getappdata(ma.fig,'movietoolDataAudioP');

if ~isempty(p)
    if ma.Mver >= 6.5
        % For Version 6.5.0 and higher use JavaAudioRecorder
        p.pause;
        %setappdata(ma.fig,'movietoolDataAudioP',p);
    else
        % For Version 6.x ,1 <= x < 6, use Windows audiorecorder
        if and(ispc,(ma.Mver > 6.0))
            pause(p);       % pause audio playback
            %setappdata(ma.fig,'movietoolDataAudioP',p);
        end
    end
end