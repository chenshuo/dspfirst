function handles_coeffDLG = fd_coeffdlg(varargin)

% This is fd_coeffdlg.m is similar to coeff_dlg written for pezdemo, but works on Matlab 6.1, 6.5 and higher.
% FD_COEFFDLG Application M-file for fd_coeffdlg.fig

% Krudysz 28-Feb-2006 (ver 1.3)

if isstruct(varargin{1})  % LAUNCH GUI
    fig = openfig(mfilename,'reuse');

    % Use system color scheme for figure:
    set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));

    % Generate a structure of handles to pass to callbacks, and store it.
    handles = guihandles(fig);
    guidata(fig, handles);
    INVALID_INPUT = 1;

    while INVALID_INPUT
        set(handles.ok,'UserData','open');
        set(handles.cancel,'UserData','no');
        waitfor(handles.ok,'UserData','close');

        if strcmp(get(handles.cancel,'UserData'),'yes');
            % CANCEL
            INVALID_INPUT = 0;
            handles.export = 0;
            guidata(fig, handles);
            handles_coeffDLG = handles;
            delete(fig);
        else
            % OK
            num = get(handles.edit1,'string');
            den = get(handles.edit2,'string');

            % Check for editbox field completion
            if isempty(num)
                set(handles.text1,'ForegroundColor','r');
            elseif isempty(den)
                set(handles.text2,'ForegroundColor','r');
            else
                % Store data directly in the handles structure and Save the new structure
                % to the application data of the figure
                INVALID_INPUT = 0;
                handles.export = 1;
                handles.num = get(handles.edit1,'string');
                handles.den = get(handles.edit2,'string');                
                guidata(fig, handles);
                handles_coeffDLG = handles;
                delete(fig);
            end
        end
    end

elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK

    try
        [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
    catch
        disp(lasterr);
    end

end
% --------------------------------------------------------------------
% --------------------------------------------------------------------
function varargout = CloseRequestFcn(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
set(handles.ok,'UserData','close');
set(handles.cancel,'UserData','yes');
% --------------------------------------------------------------------
function varargout = cancel_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
set(handles.ok,'UserData','close');
set(handles.cancel,'UserData','yes');
% --------------------------------------------------------------------
function varargout = ok_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
set(handles.ok,'UserData','close')
% --------------------------------------------------------------------
function varargout = edit1_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
set(handles.text1,'ForegroundColor','k');
% --------------------------------------------------------------------
function varargout = edit2_Callback(h, eventdata, handles, varargin)
set(handles.text2,'ForegroundColor','k');
% --------------------------------------------------------------------