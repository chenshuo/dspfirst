function varargout = showgph(varargin)
% SHOWGPH Application M-file for showgph.fig
%    FIG = SHOWGPH launch showgph GUI.
%    SHOWGPH('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.0 24-May-2001 14:35:53

if nargin == 0  % LAUNCH GUI

    fig = openfig(mfilename,'new');

    % Generate a structure of handles to pass to callbacks, and store it.
    handles = guihandles(fig);
    guidata(fig, handles);

    if nargout > 0
        varargout{1} = fig;
    end

elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK

    try
        [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
    catch
        disp(lasterr);
    end
end

%====================================================================
%====================================================================
function varargout = Close_Callback(h, eventdata, handles, varargin)
%====================================================================
set(handles.showplot_h.figure_showplot,'visible','off');
pezdemo('resetclickpt',[],[],handles);
%====================================================================