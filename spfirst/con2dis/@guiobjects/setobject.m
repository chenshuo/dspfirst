function setobject(o,callback,playdata)
% @GUIOBJECTS/SETOBJECT Identifies GUI object and sets object property
% according to file data entry.
%
%       o:          GUIobjects object
%       callback:   GUI object callback
%       playdata:   movie frame data
%
% See also @GUIOBJECTS/... RECORDOBJECT

%   Author(s): Greg Krudysz
Lcbk = length(o.callbk);
current_callbk(1:Lcbk) = 0;
for i = 1:Lcbk
    if ~isempty( findstr(o.callbk{i},callback) )
        current_callbk(i) = i;
    else
        current_callbk(i) = 0;
    end
end
object_index = max(current_callbk);

if  any(object_index)
    object   = o.name(object_index);
    style    = o.style{object_index};
    
    set(o.fig,'CurrentObject',object);
    
    if ~isempty(playdata)
        if strcmp(playdata{3},'next')
            index = 2; else index = 1;
        end         
        
        if isempty(playdata{1})
            var = [];
        elseif ~strcmp(style,'pushbutton')
            if length(playdata{1}) == 1
                var = playdata{1};
            else
                var = playdata{1}{index};
            end
            
            switch style       
                case {'togglebutton','radiobutton','checkbox','slider','listbox','popupmenu'}
                    set(object,'value',var);
                case {'pushbutton'}
                case 'edit'
                    set(object,'string',var);  
            end
        end
    end
    highlight(o,object);
end