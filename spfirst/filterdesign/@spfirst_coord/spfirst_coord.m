function obj = spfirst_coord(hObject,varargin)
% spfirst_coord - line coordiante lookup
%
% spfirst_coord
% spfirst_coord(hFigure)
% spfirst_coord(hFigure,'property_name','property_value', ...)
% obj = spfirst_dialog
%
%   METHODS:
%
%   spfirst_coord   Constructor
%   get             Get object property
%   set             Set object property
%
%   See also ... @spfirst_coord\ ... get, set

% Author(s): Greg Krudysz
% Revision: 0.2  Date:28-Feb-2009 - OD.Point 'marker' bug
% Revision: 0.1  Date: 7-Apr-2008
%
% NOTES: implemented in filterdesign ver 2.7
%==============================================================

if nargin > 0 & isa(hObject,mfilename)
    % Load object from figure data 'spfirst_dialog_DATA'
    obj = getappdata(hobj,[mfilename '_DATA']);
else
    % Private Data (OD: object data)
    if nargin == 0
        t = 0:0.01:2*pi;
        hObject = line(t,sin(t));
    end

    % Handle objects
    OD.Axes   = get(hObject,'parent');
    OD.Figure = get(OD.Axes,'parent');
    OD.Line   = hObject;
    OD.Text   = text(0,0,'','parent',OD.Axes, ...
                            'tag','coords', ...
                            'fontweight','bold',...
                            'horiz','left','vert','bottom', ...
                            'BackgroundColor',[0.8 1 0.8]); %,'edgecolor','k'
    OD.Point = line(0,0,'parent',OD.Axes,'color','r','marker','.','vis','off');
    OD.LineX = line(0,0,'parent',OD.Axes,'color','k','linestyle',':','vis','off');
    OD.LineY = line(0,0,'parent',OD.Axes,'color','k','linestyle',':','vis','off');

    % Class constructor
    obj = class(OD,mfilename);

    % Update object properties
    set(OD.Figure,'WindowButtonMotionFcn',['buttonfcns(getappdata(gcbf,''' mfilename '_DATA''),''WindowMotion'')']);

    if ~isempty(varargin)
        set(obj,varargin{1:end});
    end

    % Save spfirst object to figure data 'spfirst_coord_DATA'
    setappdata(OD.Figure,[mfilename '_DATA'],obj);
end