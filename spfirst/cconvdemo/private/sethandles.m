function Handles = sethandles(h,field,value)
%SETHANDLES
%   Handles = sethandles(Handles,field,value) sets the field to the 
%   given value within the structure Handles and then saves the
%   structure in the current figure's USERDATA property.

% Jordan Rosenthal, updated 01-Feb-2001

if iscell(field)
    Handles = setfield(h,field{:},value);
elseif ischar(field)
    Handles = setfield(h,field,value);
else
    error('Illegal parameter.');
end
set(gcbf,'UserData',Handles);
