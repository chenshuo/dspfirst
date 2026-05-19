function ma = stop(ma,varargin)
% @MOVIEAUDIO/STOP Stop recording audio.
%
% See also @MOVIEAUDIO/ ... PLAY, RECORD, PAUSE

% Author(s): Greg Krudysz

% Load recorder object from figure memory
r = getappdata(ma.fig,'movietoolDataAudioR');

if ~isempty(r)             
    if ma.Mver >= 6.5
        % For Version 6.5.0 and higher use JavaAudioRecorder
        r.stop;      
    else
        % For Version 6.x , x < 5, use Windows audiorecorder
        if ispc
            stop(r);    % stop audio recording
        end
    end
    
    if nargin == 1
        setappdata(ma.fig,'movietoolDataAudioR',r);
    end
end