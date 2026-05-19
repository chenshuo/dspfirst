function highlight(o,hobj,status)
% @GUIOBJECTS/HIGHLIGHT Highlights log file simulated GUI object during
% movie playback.
%
%  HIGHLIGHT(O,HOBJ,STATUS), where O is the guiobject object, HOBJ is 
%  the GUI object handle to be highlighted, and SATUS indicates whether
%  to highlight 'ON' or un-highlight 'OFF'.
%
%  HIGHLIGHT(O,'ALL') highlights all GUI object.

% See also @GUIOBJECTS/... GET, SET

% Author(s): Greg Krudysz

if nargin == 2;
    status = 'on';
end

if and(ischar(hobj) , strcmp(hobj,'all'))
    hobj  = o.name;
    color = o.color;
    background = eval('{''back''}');
else  
    index = find(hobj == o.name);
    color = o.color{index};
    
    if length(index) > 1
        background = eval('{''back''}');
    else
        background = 'back';
    end
end

switch status
    case 'on'
        set(hobj,background,[0.9 0.9 0]);
    case 'off'
        set(hobj,background,color);
end