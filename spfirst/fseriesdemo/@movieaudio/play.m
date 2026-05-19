function ma = play(ma,file,path,time)
% @MOVIEAUDIO/PLAY Play audio.
% 
% See also @MOVIEAUDIO/ ... RECORD, STOP, PAUSE

% Author(s): Greg Krudysz

%--- load & play audio ----%

% Load player object from figure memory
p = getappdata(ma.fig,'movietoolDataAudioP');

if isempty(findstr(file,'.mat'))
    file = [file '.mat'];
end
fname = strrep(file,'.mat','.wav');

if exist([path fname],'file') == 2
    ma.bar_flag = 1;
    
    if ma.Mver >= 6.5
        % For Version 6.5.0 and higher use JavaAudioPlayer
        p = com.mathworks.toolbox.audio.JavaAudioPlayer(wavread([path fname]),ma.Fs,16);
        setappdata(ma.fig,'movietoolDataAudioP',p);
        start_sample = floor(ma.Fs*time)+1;
        p.play(start_sample);
    else
        % For Version 6.x ,1 <= x < 6, use Windows audioplayer
        if and(ispc, ma.Mver > 6.0)
            p = audioplayer(wavread([path fname]),ma.Fs,16);
            start_sample = floor(ma.Fs*time)+1;
            play(p,start_sample);
        else
            errordlg('Audio player is only available on Windows platforms', ...
                'Audio Player Not Found')                     
        end
    end
else
    ma.bar_flag = 0;
end

if ~isempty(p)
    ma.bar_flag = 1;
end