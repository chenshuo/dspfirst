function ma = movieaudio(a)
% MOVIEAUDIO is a constructor for class MOVIEAUDIO.   
%
% See also @MOVIEAUDIO/... RECORD, STOP, PAUSE, PLAY, GET, SET, SAVE,
% DISPLAY

% Author(s): Greg Krudysz

if or( nargin == 0 , and( nargin == 1 , ~isa(a,'movieaudio') ) )
    
    % Initialize Object Structure
    switch nargin
        case 0
            % defualt figure properties
            fig = figure;
        case 1
            % inherit properties from parent object: movietool
            fig = a.fig;
    end
    
    %     if isunix
    %         Fs = 44100; else
    %         Fs = 11025;
    %     end
    
    Fs = 11025;
    
    ma.fig      = fig;
    ma.Mver     = a.Mver;
    ma.Fs       = Fs;
    ma.bar_flag = 0; 
    ma.recorder = [];
    ma.player   = [];
    
    ma = class(ma,'movieaudio');     % create class of name 'movieaudio' 
    % from structure ma
elseif isa(a,'movieaudio')
    ma = a;                                                          
end 

