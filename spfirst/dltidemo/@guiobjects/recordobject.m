function [o,var1,write_flag] = recordobject(o,obj,var1)        
% @GUIOBJECTS/RECORDOBJECT Identifies GUI object and obtains object properties
% for recording.  A write_flag is set if a valid object with properites has 
% been found.
%
%       o:      GUIobjects object
%       obj:    GUI object handle
%
% See also @GUIOBJECTS/... GET, SET

% Author(s): Greg Krudysz

write_flag = 0;

if ishandle(obj)
    object_index = find(o.name == obj);          
    if  any(object_index)
        
        style = o.style{object_index};
        switch style                
            case {'togglebutton','radiobutton','checkbox','slider','listbox','popupmenu'}                   
                new_var = get(obj,'value');                          
            case 'pushbutton'
                new_var = [];
            case 'edit'
                new_var = get(obj,'string');              
        end
        old_var = o.param{object_index};
        var1 = {old_var ; new_var};
        o.param{object_index} = new_var;
        write_flag = 1;
        
        % Update object states
        o = savestate(o);  
    end
end