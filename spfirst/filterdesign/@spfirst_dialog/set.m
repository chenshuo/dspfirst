function OD = set(OD,varargin)
% @spfirst_dialog/set Set object properties to the specified values
% and return the updated object.
%
% Valid properties:
%                   type: warn | help | error
%                   message
%                   visible
%
% See also @spfirst_dialog/ ... get

% Author(s): Greg Krudysz
%==============================================================

property_argin = varargin;
while length(property_argin) >= 2
    prop = property_argin{1};
    val = property_argin{2};
    property_argin = property_argin(3:end);
    switch prop
        %---%---------------
        case 'type'
            %---------------
            a = load('dialogicons.mat');
            switch val
                case'warn'
                    IconData=a.warnIconData;
                    a.warnIconMap(256,:)=get(OD.Figure,'color');
                    IconCMap=a.warnIconMap;
                    boxcolor = 'k';
                case 'help'
                    IconData=a.helpIconData;
                    a.helpIconMap(256,:)=get(OD.Figure,'color');
                    IconCMap=a.helpIconMap;
                    boxcolor = 'k';
                case 'error'
                    IconData=a.errorIconData;
                    a.errorIconMap(146,:)=get(OD.Figure,'color');
                    IconCMap=a.errorIconMap;
                    boxcolor = 'r';
            end
            
            set(OD.Img,'cdata',IconData);
            set(OD.Figure,'colormap',IconCMap);

            if ~isempty(get(OD.Img,'XData')) && ~isempty(get(OD.Img,'YData'))
                set(OD.Icon,'xlim',get(OD.Img,'XData')+[-0.5 0.5],'yLim',get(OD.Img,'YData')+[-0.5 0.5]);
            end

            set(OD.Icon,'YDir','reverse','userdata',val);
            set(OD.Object,'xcolor',boxcolor,'ycolor',boxcolor);
            set(OD,'visible','on');
            %---------------
        case {'message'}
            %---------------
            if strfind(val,'$$')
                val = strrep(val,'@','}$$');
                set(OD.Text,'string','','interpreter','latex','fontsize',12);
                set(OD.Text,'string',val);
            else
                set(OD.Text,'interpreter','tex','string',strrep(val,'@',''),'fontsize',0.45);
            end
            %---------------
        case {'visible','vis'}
            %---------------
            set([OD.Object,OD.Text,OD.Img,OD.Close],'vis',val);
            %---------------
        otherwise
            %---------------
            valid_props = ['icon','visible'];
            error([prop_name,' is not a valid @spfirst_dialog/get property: ... try: ' valid_props]);
    end
end