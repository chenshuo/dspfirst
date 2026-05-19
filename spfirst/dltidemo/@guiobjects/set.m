function set(o,varargin)
% @GUIOBJECTS/SET Set GUIobjects properties to the specified values
% and return the updated object.  The following are valid properties:
% figure, enable.
%
% o = set(o,'figure',VALUE), where VALUE is 1-sets initial window 
% properties, 2-sets null window properties, and if no VALUE has been
% specified, then current window peoperties are assigned.

% See also @MOVIETOOL/ ... GET

% Author(s): Greg Krudysz

property_argin = varargin;
while length(property_argin) >= 2,
    prop = property_argin{1};
    val = property_argin{2};
    property_argin = property_argin(3:end);
    switch prop
    case 'figure'
        switch val
        case 'initial'
            window = o.windowI;
        case 'current'
            window = o.window;
        case 'arrow'
            window = {'','arrow','','',''};
        end
        
        set(o.fig,{'ButtonDownFcn','Pointer','WindowButtonDownFcn', ...
                'WindowButtonMotionFcn','WindowButtonUpFcn'},window);   
    case 'enable'
        switch val
        case 'on'
            set(o.name,{'enable'},o.enable);
        case 'off'
            set(o.name,'enable','off');
        end
    otherwise
        error('GUIobjects properties: figure, enable')
    end
end