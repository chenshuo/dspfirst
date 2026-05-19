function ml = write(ml,DATA)
% @MOVIELOG/WRITE write data to movie log file
%
% ml = WRITE(ml,{h,var1,var2}) where DATA_IN has the 
% format:
%        DATA_IN = {H, VAR1, VAR2, COUNTER_FLAG}
%       
%        H:        GUI object handle
%        VAR1:     Variable - typically object "value"/"string" property
%        VAR2:     Variable - typically object "value"/"string" property
%        COUNTER:  increment timestamp counter flag 
%
% Save to DATA_OUT structure with the following format:
%        DATA_OUT = {CALLBACK,VAR1,VAR2,TIMESTAMP}
%
%        CALLBACK:  GUI object handle
%        VAR1:      Variable - typically object "value"/"string" property
%        VAR2:      Variable - typically object "value"/"string" property
%        TIMESTAMP: timestamp -  time in seconds
%
% See also @MOVIELOG/ ... GET, SET, READ

% Author(s): Greg Krudysz

h       = DATA{1};
var1    = DATA{2};
var2    = DATA{3};
COUNTER = DATA{4};

%--- Get CALLBACK String ---%
if ~isempty(h)
    if ishandle(h)
        callback = strrep(get(h,'Callback'),'gcbo',sprintf('findobj(mt.fig,''tag'',''%s'')',get(h,'tag')));
        %callback = strrep(get(h,'Callback'),'gcbo',sprintf('handles.%s',get(h,'tag')));
    else
        if ischar(h)
            callback = h;
        else
            handles = guidata(gcbo);
            callback = strrep([handles.movie.filename  ...
                    '(''callback'',[],[],guidata(gcbo))'],'callback',h);
        end
    end
else
    callback = [];
end

%--- Save CALLBACK ---%
if ~isempty(callback)
    ml.data{ml.lineNo,1} = callback;
end
%--- Save VAR1 ---%
if ~isempty(var1)
    ml.data{ml.lineNo,2} = var1;
end
%--- Save VAR2 ---%
if ~isempty(var2)
    ml.data{ml.lineNo,3} = var2;
end
%--- Save Time-stamp ---%
if COUNTER == 1
    timestamp = etime(clock,ml.time0) + 2; % add 2 sec due to frame #1: InitializeMovie
    ml.data{ml.lineNo,4} = timestamp;
end

ml.lineNo = ml.lineNo + 1;  % increment lineNo counter