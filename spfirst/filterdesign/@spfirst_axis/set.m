function set(OD,varargin)
%function set(OD,varargin)
% @spfirst_axis/set Set object properties to the specified values
% and return the updated object.
%
% Valid properties:
%                   xticklabel (overload)
%                   ButtonDownFcn (overload)
%                   string (overload)
%                   visible (overload)
%
% See also @spfirst_axis/ ... get

% Author(s): Greg Krudysz
%==============================================================

ver = version;
MATLABVER =str2double(ver(1:3));

property_argin = varargin;
while length(property_argin) >= 2
    prop = property_argin{1};
    val = property_argin{2};
    property_argin = property_argin(3:end);
    switch prop

        %---%---------------
        case 'xticklabel'
            %---------------
            if MATLABVER<8.4
                set(OD.Axes,'fontname','symbol','fontweight','bold', ...
                    'XTick',0.5*(-2:2),'XTickLabel',{'-2p';'-p';'0';'p';'2p'});
            else
                set(OD.Axes,'interpreter','latex','fontweight','bold', ...
                    'XTick',0.5*(-2:2),'XTickLabel',{'-2\pi';'-\pi';'0';'\pi';'2\pi'});
            end
            %---------------
        case 'ButtonDownFcn'
            %---------------
            set(OD.Label,prop,val);
            set(OD.Submenu,'callback',val);
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
            set([OD.Object,OD.Text],'vis',val);
        otherwise
            set(OD.Object,prop,val);
            %error([prop_name,' is not a valid @node/get property: ... try ''number'',''Button'',''parents'',''children'',''tag'',''coord'' '])
    end
end