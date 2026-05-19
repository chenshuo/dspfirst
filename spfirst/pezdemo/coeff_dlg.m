function varargout = coeff_dlg(varargin)

% This is coeffdlg.m equivalent, but works on Matlab 6.1 and 6.5.
% COEFF_DLG Application M-file for coeff_dlg.fig
%    FIG = COEFF_DLG launch coeff_dlg GUI.
%    COEFF_DLG('callback_name', ...) invoke the named callback.

% G Krudysz 15-Mar-2006 (ver 1.3) : fixed file extension problems, minor changes 
% G Krudysz  7-Mar-2006 (ver 1.1) : fig color consistent with main figure

if isstruct(varargin{1})  % LAUNCH GUI
    fig = openfig(mfilename,'reuse');

    % Use system color scheme for figure:
    fig_color = get(varargin{1}.figure_pez,'color');

    % Generate a structure of handles to pass to callbacks, and store it.
    handles = guihandles(fig);
    guidata(fig, handles);

    set([findobj(fig,'style','text')',handles.export,handles.cancel],'back',fig_color);
    set(handles.export,'userdata','open');
    set(handles.cancel,'userdata','no');

    % Use WAITFOR to have the GUI 'pause' until the userdata property is changed to 'close'
    waitfor(handles.export,'userdata','close');

    if ~strcmp(get(handles.cancel,'userdata'),'yes');

        if nargout > 0
            % Store data directly in the handles structure and Save the new
            % structure to the application data of the figure

            handles.done = 1;

            guidata(fig, handles);
            varargout{1} = handles;
            set(fig,'visible','off');

        end
    else % if Cancel pressed
        if nargout > 0
            handles.done = 0;
            guidata(fig, handles);
            varargout{1} = handles;
            delete(fig);
        end
    end

elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK

    try
        [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
    catch
        disp(lasterr);
    end

end

%======================================================================
%======================================================================
%======================================================================
function varargout = cancel_Callback(h, eventdata, handles, varargin)
%======================================================================
set(handles.export,'userdata','close');
set(handles.cancel,'userdata','yes');
%======================================================================
function varargout = export_Callback(h, eventdata, handles, varargin)
%======================================================================
set(handles.export,'userdata','close')
%======================================================================
function varargout = zero_edit_Callback(h, eventdata, handles, varargin)
%======================================================================
z_string = get(handles.zero_edit,'string');
if isempty(z_string)
    set(handles.zero_edit,'string','z_values');
end
%======================================================================
function varargout = pole_edit_Callback(h, eventdata, handles, varargin)
%======================================================================
p_string = get(handles.pole_edit,'string');
if isempty(p_string)
    set(handles.pole_edit,'string','p_values');
end
%======================================================================
function varargout = popupmenu_Callback(h, eventdata, handles, varargin)
%======================================================================
value = get(handles.popupmenu,'value');
if 2-value
    set(handles.name_button,'visible','on');
else
    set(handles.name_button,'visible','off');
end
%======================================================================
function varargout = name_button_Callback(h, eventdata, handles, varargin)
%======================================================================
[fname, pname] = uiputfile('*.mat','Export to File');
if fname
    fname = strrep(fname,'.mat','');
    set(handles.name_button,'string',[fname '.mat'],'userdata',pname);
end
%======================================================================
function varargout = zero_form_Callback(h, eventdata, handles, varargin)
%======================================================================
function varargout = pole_form_Callback(h, eventdata, handles, varargin)
%======================================================================
