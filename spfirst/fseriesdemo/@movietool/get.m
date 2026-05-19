function val = get(a,prop_name)
% @MOVIETOOL/GET Get movietool property from the specified object
% and return the value. Property names are: figure, extendby 
% play_flag, rec_flag, stop_flag, hili_flag, and Mversion.
%
% See also @MOVIETOOL/ ... SET

% Author(s): Greg Krudysz

switch prop_name
    case 'figure'
        val = a.fig;
    case 'extendby'
        val = a.extendby;
    case 'play_flag'
        val = a.play_flag;
    case 'rec_flag'
        val = a.rec_flag;
    case 'stop_flag'
        val = a.stop_flag;
    case 'hili_flag'
        val = a.hili_flag;
    case 'Mversion'
        val = a.Mver;
    otherwise
        error([prop_name,' is not a valid @MOVIETOOL/GET property'])
end