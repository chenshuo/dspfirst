function OD = spfirst_obj(hParent,form,varargin)
% spfirst_obj - adds an object of form 'form' to a specified axes with handle 'hAxes' which can be moved around
% within parent axes much like Matlab's legend object, were:
%
%  form = {'button'} | 'note'
%
% spfirst_obj
% spfirst_obj(hAxes,'form')
% spfirst_obj(hAxes,'form','property_name','property_value', ...)
% obj = spfirst_obj
%
%   METHODS:
%
%   spfirst_obj     Constructor
%   get             Get object property
%   set             Set object property
%   edit            Edit object
%   move            Move object
%   delete          Delete object
%
%   See also ... @spfirst_obj\get,set,edit,move,delete

% Author(s): Greg Krudysz
% Revision: 0.6  Date: 14-Nov-2006
%
% NOTES: implemented in filterdesign ver >= 2.3
%==============================================================

if nargin > 0 & isa(hParent,mfilename)
    % Load object from figure data 'spfirst_obj_DATA'
    obj = getappdata(hParent,[mfilename '_DATA']);
else
    % Private Data (OD: object data)
    OD.size       = [0.1 0.05];
    OD.coord      = [0.5 0.5];
    OD.tag        = mfilename;    

    % Handle objects
    if nargin == 0
        OD.form = 'button';
        OD.Axes = axes('tag',[mfilename 'DEFAULT_AXES']);
    else
        OD.form = form;
        OD.Axes = hParent;
    end
    OD.Text       = []; %% only for 'note'
    OD.Figure = get(OD.Axes,'parent');

    % Specify type of an object
    switch OD.form
        %---%---------------------------------------------
        case 'button'
            %---------------------------------------------
            OD.Object = uicontrol('parent',OD.Figure, ...
                'tag'       ,OD.tag, ...
                'string'    ,OD.tag, ...
                'units'     ,'norm', ...
                'fontunits' ,'norm', ...
                'fontweight','bold', ...
                'position'  ,[OD.coord(1) OD.coord(2) OD.size(1) OD.size(2)], ...
                'fontsize'  ,0.5);
                %'call'      ,'GraphIt(''EditNode'',gcbo,[],guidata(gcbo))');
            %---------------------------------------------
        case 'note'
            %---------------------------------------------
            ax_units = get(OD.Axes,'units');
            set(OD.Axes,'units','pixels');
            ax_pos = get(OD.Axes,'pos');

            leg_pos = [ax_pos(1)+0.5*ax_pos(3) ax_pos(2)+0.5*ax_pos(4) 0.25*ax_pos(3) 0.25*ax_pos(4)];
            OD.Object = axes('parent',OD.Figure, ...
                'units',   'pixels', ...
                'fontunits','norm', ...
                'box'      ,'on', ...
                'tag'      ,'legend', ...
                'pos'      ,[leg_pos], ...
                'xtick'    ,[], ...
                'ytick'    ,[], ...
                'ButtonDownFcn',['move(getappdata(gcbf,''' mfilename '_DATA''),''ObjectDragStart'')']);
            set(OD.Axes,'units',ax_units);
            OD.Text = text(0,0,'','parent',OD.Object, ...
                'tag'           ,'legend_text', ...         
                'units'         ,'norm', ...
                'fontunits'     ,'norm', ...
                'Vertical'      ,'bottom', ...
                'ButtonDownFcn'	,['move(getappdata(gcbf,''' mfilename '_DATA''),''ObjectDragStart'')']);
            set(OD.Object,'units','norm');
            %---------------------------------------------           
    end
    
    % Class constructor
    OD = class(OD,mfilename);

    % Update object properties
    if nargin > 0
        OD = set(OD,varargin{1:end});
    end

    % Save spfirst object to figure data 'spfirst_obj_DATA'
    setappdata(OD.Figure,[mfilename '_DATA'],OD);
end