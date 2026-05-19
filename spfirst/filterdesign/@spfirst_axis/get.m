function val = get(OD,prop_name)
%function val = get(OD,prop_name)
% @spfirst_axis/get - gets object values for specified object properties
%
% Valid properties:
%                   Menu
%                   Submenu
%                  
% See also @spfirst_axis/ ... set

% Author(s): Greg Krudysz
%==============================================================

switch prop_name
    %---%---------------
    case 'Menu'
        %---------------
        val = OD.Menu;
        %---------------
    case 'Submenu'
        %---------------
        val = OD.Submenu;
        %---------------
    otherwise
        %---------------
        if isprop(OD.Object,prop_name)
            val = get(OD.Object,prop_name);
        else
            error([prop_name,' is not a valid @' class(OD) '/get property'])
        end
        %---------------
end