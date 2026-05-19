function move(OD,varargin)
% @spfirst_obj/move - moves graphical object using a cursor and returns the updated
% object.
%
% See also @spfirst_obj/ ... get, set

% Author(s): Greg Krudysz
%==============================================================

switch varargin{1}
    %===%==================================================================
    case 'norm2twopi'
        %==================================================================
        setptr(OD.Figure,'fleur');
        CurrPt = get(OD.Figure,'CurrentPoint');
        motion_data.CurrentPoint = CurrPt(1,1:2);
        set([OD.Object,OD.Text],'units','pixels');

        % store previous figure WindowButton {Motion|Up} Fcn
        motion_data.window_button_fcn = get(OD.Figure,{'WindowButtonUpFcn','WindowButtonMotionFcn'});
        set(OD.Figure,'WindowButtonUpFcn','move(getappdata(gcbf,''spfirst_obj_DATA''),''ObjectDragStop'')', ...
            'WindowButtonMotionFcn','move(getappdata(gcbf,''spfirst_obj_DATA''),''MoveObject'')');
        set(OD.Object,'userdata',motion_data);
        %==================================================================
    case 'ObjectDragStop'
        %==================================================================
        setptr(OD.Figure,'arrow');
        motion_data = get(OD.Object,'userdata');
        set(OD.Figure,{'WindowButtonUpFcn','WindowButtonMotionFcn'},motion_data.window_button_fcn);
        set(OD.Object,'userdata',[]);
        set([OD.Object,OD.Text],'units','norm');
        %==================================================================
    case 'MoveObject'
        %==================================================================
        motion_data = get(OD.Object,'userdata');            	% get old coordinates
        CurrentPoint = get(OD.Figure,'CurrentPoint');          	% get current coordinates
        CurrentXY = CurrentPoint(1,1:2);
        DistanceMoved = CurrentXY - motion_data.CurrentPoint;  	% find distance moved
        motion_data.CurrentPoint = CurrentXY;
        obj_pos = get(OD.Object,'pos') + [DistanceMoved(1) DistanceMoved(2) 0 0];
        set(OD.Object,'pos',obj_pos','userdata',motion_data);
        %==================================================================
end