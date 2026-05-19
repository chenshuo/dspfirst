function ma = save(ma,fname,pname)
% @MOVIEAUDIO/SAVE Save audio data to a file.
%
% See also @MOVIEAUDIO/ ... PLAY, RECORD, STOP, PAUSE

% Author(s): Greg Krudysz

% Load recorder object from figure memory
r = getappdata(ma.fig,'movietoolDataAudioR');

if isempty(r) 
    % save audio to wav file (if audio exists)  
    ffname = strrep(fname,'.mat','');
    if exist([pname ffname '.wav'],'file') == 2
        delete([pname ffname '.wav']);  
    end
else
    ffname = strrep(fname,'.mat','');
    ffname = [ffname '.wav'];
    switch ma.Mver
        case 6.0
            errordlg('Audio playback unavailable','Audio Error');
        case 6.1
            signal = getaudiodata(r);
        case {6.5,7.0}
            rmappdata(ma.fig,'movietoolDataAudioR');
            dsignal = double(GetAudioData(r,'int16'));
            %max_value = max(abs(min(dsignal)),max(dsignal));
            signal = dsignal/32767; % normalize: use max(int16)
        otherwise
            errordlg({'Audio recording has not been set up', ...
                    'for this version of MATLAB'},'Audio Error');
    end
    
    wavwrite(signal,ma.Fs,16,[pname ffname]); % N = 16 
    ma.recorder = [];
end