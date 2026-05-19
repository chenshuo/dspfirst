function mo = GUIobjects(o)
% GUIOBJECTS Gui objects class constructor.  The object idenfifies and    
% also monitors the state of GUI objects.
%
% See also @GUIOBJECTS/... GET, SET, SAVESTATE, SETSTATE, SETOBJECT, and
% RECOBJECT

% Author(s): Greg Krudysz 

switch nargin
    case 0
        % defualt figure properties
        mo.fig = figure;
    case 1
        % inherit properties from parent object: movietool
        mo.fig = o.fig;
end

if or( nargin == 0 , and( nargin == 1 , ~isa(o,'guiobjects') ) )
    
    % Initialize Object Structure
    mo.name   = findobj(mo.fig,{'style'},{'pushbutton';'togglebutton';'radiobutton'; ...
            'checkbox';'edit';'slider';'listbox';'popupmenu'});
    mo.style   = get(mo.name,'style');
    mo.color   = get(mo.name,'back'); 
    mo.enable  = get(mo.name,'enable');
    mo.callbk  = get(mo.name,'callback');
    mo.state   = [];
    mo.paramI  = [];
    mo.param   = [];
    mo.windowI = [];
    mo.window  = [];
    
    mo = class(mo,'guiobjects');    % create class of name 'GUIobjects' 
                                    % from structure mo
elseif isa(o,'guiobjects')
    mo = o;                                                          
end