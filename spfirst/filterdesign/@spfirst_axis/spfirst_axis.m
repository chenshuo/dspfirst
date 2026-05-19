function obj = spfirst_axis(hobj,variable,spfirst_scale,t_label,menu_label,varargin)
% spfirst_trans - transforms axis domain/range
%
% spfirst_obj
% spfirst_obj(hAxes,'form')
% spfirst_obj(hAxes,'form','property_name','property_value', ...)
% obj = spfirst_obj
%
%   METHODS:
%
%   spfirst_axis    Constructor
%   get             Get object property
%   set             Set object property
%   buttonfcns      Object related button/motion
%   transform       Transform object to another domain
%
%   See also ... @spfirst_axis\ ... get, set, buttonfcns, transform

% Author(s): Greg Krudysz
% Revision: 0.4  Date: 18-Dec-2006
%
% NOTES: implemented in filterdesign ver 2.44
%==============================================================

if nargin > 0 & isa(hobj,mfilename)
    % Load object from figure data 'spfirst_axis_DATA'
    obj = getappdata(hobj,[mfilename variable '_DATA']);
else
    % Private Data (OD: object data) 
    if nargin == 0
        hobj = line([0 200],[0 1],'tag',[mfilename 'DEFAULT_LINE']);    
        fs = 400;
        spfirst_scale = 2*pi/fs;
        xlabel('x-axis (Hz)');
        ylabel('y-axis');
        variable = 'x';
        t_label = 'Show transformed x';     
        menu_label = 'Menu X';
    end
    
    OD.var      = variable;
    OD.scale    = spfirst_scale;
    
    % Handle objects   
    OD.Object   = hobj;
    OD.Axes     = get(OD.Object,'parent');
    OD.Figure   = get(OD.Axes,'parent');
    OD.Label    = get(OD.Axes,[OD.var 'label']);
    set(OD.Label,'buttondown',['buttonfcns(getappdata(gcbf,''' mfilename OD.var '_DATA''),''ButtonDown'')'] );
    set(OD.Figure,'windowButtonMotionFcn',['buttonfcns(getappdata(gcbf,''' mfilename OD.var '_DATA''),''WindowMotion'')']);
    
    OD.labels   = {get(OD.Label,'string') t_label};

    % Add menus
    hmenu = findobj(OD.Figure,'type','uimenu','label','Edit');
    if isempty(hmenu)      
        OD.Menu = uimenu('parent',OD.Figure,'label','Edit');
    else
        OD.Menu = hmenu;      
    end   
    OD.Submenu = uimenu('parent',OD.Menu,'label',menu_label);   
    
    % Class constructor
    obj = class(OD,mfilename);

    % Update object properties
    if nargin > 0
        set(obj,varargin{1:end});
    end
    
    % Save spfirst object to figure data 'spfirst_axis_DATA'
    setappdata(OD.Figure,[mfilename OD.var '_DATA'],obj);
end