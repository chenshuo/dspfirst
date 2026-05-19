function val = get(c,prop_name)
% @MOVIECONTROLS/GET Get moviecontrols property from the specified object
% and return the value. Property names are: moviename, 
% moviepath, frameNo, time, playdata, audio_flag, and pause_flag.
%
% See also @MOVIECONTROLS/ ... SET

% Author(s): Greg Krudysz

switch prop_name
    case 'moviename'
        val = c.moviename;
    case 'moviepath'
        val = c.moviepath;
    case 'frameNo'
        val = c.frameNo;
    case 'time'
        val = c.time;
    case 'playdata'
        val = c.playdata;
    case 'audio_flag'
        val = get(c.recAudio,'value');
    case 'pause_flag'
        val = strcmp(get(c.pause,'checked'),'on');
    otherwise
        error([prop_name,' is not a valid @MOVIETOOL/GET property: moviename, moviepath, frameNo, time, playdata, audio_flag, and pause_flag'])
end