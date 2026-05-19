function ml = movielog(mt)
% MOVIELOG Movie log class constructor.
%
% See also @MOVIELOG/ ... GET, SET, WRITE, READ, DISPLAY, SAVE

% Author(s): Greg Krudysz

if nargin == 1
    % inherited
    ml.Mver      = mt.Mver;
    ml.moviename = mt.moviename;
    ml.moviepath = mt.moviepath;
    
    ml.lineNo    = 2;
    ml.time0     = clock;      % reference clock
    
    data{1,1} = 'initializeMovie(mt,guidata(gcbf));';
    data{1,4} = 2;
    ml.data      = data;

    ml = class(ml,'movielog');  % create class of name 'movielog' 
                                % from structure ml   
elseif isa(mt,'movielog')
    ml = mt;
end