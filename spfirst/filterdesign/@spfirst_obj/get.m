function val = get(OD,prop_name)
% @spfirst_obj/set - gets object values for specified object properties
%
% Valid properties:
%                   number
%                   tag
%                   coord
%                   type
%                   (axes or uicontrol)
%
% See also @spfirst_obj/ ... set

% Author(s): Greg Krudysz
%==============================================================

switch prop_name
    case 'Object'
        val = OD.Object;
    case 'Figure'
        val = OD.Figure;
    case 'Axes'
        val = OD.Axes;
    case 'parents'
        val = OD.parents;
    case 'children'
        val = OD.children;
    case 'coord'
        val = OD.coord;
    case 'tag'
        val = OD.tag;
    otherwise
        if isprop(OD.Object,prop_name)
            val = get(OD.Object,prop_name);
        else
            valid_props = ['Object,',' Figure,',' Axes,',' parents,',' children,',' coord,',' tag'];
            error([prop_name,' is not a valid @node/get property: ... try: ' valid_props]);
        end
end