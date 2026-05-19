function b = subsref(a,index)
%@MOVIEAUDIO/SUBSREF Define field name indexing for movieaudio objects.
%
% See also @MOVIEAUDIO/ ... PLAY, RECORD, STOP, PAUSE, SAVE, DISPLAY

% Author(s): Greg Krudysz

switch index.type
    case '()'
        switch index.subs{:}
            case 3
                b = a.Fs;
            case 4
                b = a.bar_flag;
            otherwise
                error('Index out of range')
        end
    case '.'
        switch index.subs
            case 'fig'
                b = a.fig;
            case 'Mver'
                b = a.Mver;
            case 'Fs'
                b = a.Fs;
            case 'bar_flag'
                b = a.bar_flag;
            otherwise
                error('Invalid field name')
        end
    case '{}'
        error('Cell array indexing not supported by asset objects')
end