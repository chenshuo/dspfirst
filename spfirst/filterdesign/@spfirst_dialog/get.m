function val = get(OD,prop_name)
% @spfirst_dialog/set - gets object values for specified object properties
%
% Valid properties:
%                   type
%                   message
%                   visible
%
% See also @spfirst_dialog/ ... set

% Author(s): Greg Krudysz
%==============================================================

switch prop_name
    case 'Object'
        val = OD.Object;
    case 'Figure'
        val = OD.Figure;
    case 'Axes'
        val = OD.Axes;
    case 'type'
        val = get(OD.Icon,'userdata');
    case 'message'
        val = get(OD.Text,'string');;
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