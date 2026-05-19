function o = savestate(o,init_flag)
% @GUIOBJECTS/SAVESTATE Save GUI objects' user input properties.  INIT_FLAG
% determines whether initial or current properties are saved. 
%
%   See also @GUIOBJECTS/... SETSTATE

%   Author(s): Greg Krudysz      

if nargin == 1
    init_flag = 0;
end

hobj_param = [];
for v = 1:length(o.name)
    style = o.style{v};
    switch style                
    case {'togglebutton','radiobutton','checkbox','slider','listbox','popupmenu'}
        hobj_param{v,1} = get(o.name(v),'value');
    case 'pushbutton'
        hobj_param{v,1} = [];
    case {'edit'}
        hobj_param{v,1} = get(o.name(v),'string');
    end
end

if init_flag
    o.paramI  = hobj_param;
    o.windowI = get(o.fig,{'ButtonDownFcn','Pointer','WindowButtonDownFcn', ...
            'WindowButtonMotionFcn','WindowButtonUpFcn'}); 
    o.window = o.windowI;
else
    o.param  = hobj_param;
    o.window = get(o.fig,{'ButtonDownFcn','Pointer','WindowButtonDownFcn', ...
            'WindowButtonMotionFcn','WindowButtonUpFcn'});   
end