function setstate(o,init_flag)
% @GUIOBJECTS/SAVESTATE Set GUI objects' to data from the log file.  INIT_FLAG
% determines whether initial or current properties are assigned. 
%
%       mt:       movietool object
%       method:   state operation: 'initialize'|'save_state'|'set_state'
%       varargin: 1 = 'initialize'
%
%   See also @MOVIETOOL/... SAVESTATE

%   Author(s): Greg Krudysz

if nargin == 1
    init_flag = 0;
end

% Set WINDOW Parameters
if init_flag  
    param = o.paramI;
    set(o,'figure','initial');
else
    param = o.param;
    set(o,'figure','current');
end

% Set OBJECT Parameters
for v = 1:length(o.name)
    style = o.style{v};
    set(o.fig,'CurrentObject',o.name(v));
    
    switch style
        case {'radiobutton','checkbox','slider','listbox','popupmenu'}       
            param_current = get(o.name(v),'value');
            if param_current ~= param{v}
                set(o.fig,'CurrentObject',o.name(v))
                set(o.name(v),'value',param{v});
                eval(o.callbk{v});
            end
        case 'togglebutton'
            param_current = get(o.name(v),'value');
            if param_current ~= param{v}
                set(o.fig,'CurrentObject',o.name(v))
                set(o.name(v),'value',param{v});
                eval(o.callbk{v});
            end
        case 'pushbutton'
            %set(o.name(v),'value',param{v});
        case 'edit'
            param_current = get(o.name(v),'string');
            if ~strcmp(param_current,param{v})
                set(o.fig,'CurrentObject',o.name(v))
                set(o.name(v),'string',param{v});
                eval(o.callbk{v});
            end
    end
end