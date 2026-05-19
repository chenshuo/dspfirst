function OD = set(OD,varargin)
% @spfirst_obj/set Set object properties to the specified values
% and return the updated object.
%
% Valid properties:
%                   number
%                   tag
%                   coord
%                   type
%                   (axes or uicontrol)
%
% See also @spfirst_obj/ ... get

% Author(s): Greg Krudysz
%==============================================================

property_argin = varargin;
while length(property_argin) >= 2
    prop = property_argin{1};
    val = property_argin{2};
    property_argin = property_argin(3:end);
    switch prop
        %---%---------------
        case 'number'
            %---------------
            if ischar(val)
                switch val
                    case 'plus'
                        OD.number = OD.number + 1;
                    case 'minus'
                        OD.number = OD.number - 1;
                end
            else
                OD.number = val;
            end
            %---------------
        case 'parents'
            %---------------
            OD.parents  =  val;
            %---------------
        case 'children'
            %---------------
            OD.children = val;
            %---------------
        case 'tag'
            %---------------
            OD.tag = val;
            %---------------
        case 'coord'
            %---------------
            OD.coord = val;
            pos = get(OD.Object,'pos');
            set(OD.Object,'pos',[val(1) val(2) pos(3) pos(4)]);
            %---------------
        case 'type'
            %---------------
            OD.type = val;                       
            %---------------
        case 'string'
            %---------------
            switch OD.form
                case 'button'  
                    set(OD.Object,'string',val);
                case 'note'
                    set(OD.Text,'string',val);
                    
                    % resize object if necessary (text outside of boundary)
                    set(OD.Object,'units','pixels');
                    set(OD.Text,'units','pixels','fontunits','points');
                    txt_ext = get(OD.Text,'extent');
                    obj_pos = get(OD.Object,'pos');  
                    set(OD.Object,'pos',[obj_pos(1) obj_pos(2) txt_ext(3)+10 txt_ext(4)]); 
                    set(OD.Object,'units','norm');
                    set(OD.Text,'units','norm','fontunits','norm');
            end
            %---------------
        case {'visible','vis'}
            %---------------
            set([OD.Object,OD.Text],'vis',val);
            %---------------
        otherwise
            %---------------
            if isprop(OD.Object,prop)
                set(OD.Object,prop,val);
            else
                valid_props = ['Object,',' Figure,',' Axes,',' parents,',' children,',' coord,',' tag'];
                error([prop_name,' is not a valid @node/get property: ... try: ' valid_props]);
            end
    end
end