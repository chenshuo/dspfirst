function varargout = buttonfcns(OD,action)
%function varargout = buttonfcns(OD,action)
% @spfirst_axis/buttonfcns - execute upon action:
%
%   'ButtonDown'   - object has been pressed
%   'WindowMotion' - motion over object
%
% See also @spfirst_axis/ ... get, set, transform

% Author(s): Greg Krudysz
%==============================================================

switch action
    %===%==================================================================
    case 'ButtonDown'
        %==================================================================
        set(OD,'visible','off');
        %==================================================================
    case 'WindowMotion'
        %==================================================================
        % Determine if cursor is over Plot
        old_units = get([OD.Axes,OD.Label],'units'); % OD.Label

        % Change all units to "pixels"
        set([OD.Axes,OD.Label],'units','pixels');
        [mouse_x,mouse_y,fig_size] = mousepos;

        ax = get(OD.Axes,'position');
        eL = get(OD.Label,'extent');
        pL = get(OD.Label,'position');
        set([OD.Axes,OD.Label],{'units'},old_units);
        
        switch OD.var
            case 'x'
                over_flag = any( (mouse_y < ax(2)+pL(2)) & (mouse_y > ax(2)+pL(2)-eL(4)) & (abs(mouse_x-ax(1)-pL(1)) < eL(3)/2) );
            case 'y'
                over_flag = any( (mouse_x < ax(1)+pL(1)) & (mouse_x > ax(1)+pL(1)-eL(3)) & (abs(mouse_y-ax(2)-pL(2)) < eL(4)/2) );
        end
            
        if over_flag
            set(OD.Label,'fontweight','bold','color','b');
        else
            set(OD.Label,'fontweight','normal','color','k');
        end
        %==================================================================
end