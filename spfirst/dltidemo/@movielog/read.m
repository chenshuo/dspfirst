function read(ml,row,column)
% @MOVIELOG/READ read movie log data
%
% READ(m1) obtains entire log data
% READ(ml,row) obtains row ROW of log data
% READ(ml,ROW,COLUMN) obtains entry of log data 
% specified by the ROW and the COLUMN
%
% See also @MOVIELOG/ ... GET, SET, WRITE, DISPLAY

% Author(s): Greg Krudysz

% Load movie if it exists
if ~isempty(ml.moviename)
    ml.data = load([ml.moviepath,ml.moviename]);
end

switch nargin
    case 1
        ml.data
    case 2
        ml.data{row,:};
    case 3
        ml.data{row,column};
    otherwise
        error('@MOVIELOG/READ')
end