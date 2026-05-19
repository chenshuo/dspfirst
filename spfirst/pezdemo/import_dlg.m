function varargout = import_dlg(varargin)

% IMPORT_DLG Application M-file for import_dlg.fig
%    FIG = IMPORT_DLG launch import_dlg GUI.
%    IMPORT_DLG('callback_name', ...) invoke the named callback.

% G Krudysz 19-Mar-2006 (ver 1.4) : added 'dat' structure for data retrieval
% G Krudysz 15-Mar-2006 (ver 1.3) : fixed file extension problems, minor changes
%                                 : fig color consistent with main figure

if isstruct(varargin{1})  % LAUNCH GUI
    fig = openfig(mfilename,'reuse');

    % Use system color scheme for figure:
    set(fig,'color',get(gcbf,'color'));
    set(findobj(fig,'style','text')','back',get(gcbf,'color'));

    % Generate a structure of handles to pass to callbacks, and store it.
    handles = guihandles(fig);
    handles.InfoText = uicontrol('style','text','parent',fig,'units','norm','foreg','r', ...
        'fontsize',10,'back',get(gcbf,'color'),'pos',[0.2 0 0.6 0.07],'vis','off', ...
        'string','File "noname.mat" not found !!');
    guidata(fig, handles);

    set(handles.figure1,'visible','on');
    set(handles.import,'userdata','open');
    set(handles.cancel,'userdata','no')

    set(handles.popupmenu,'value',1);
    set([handles.zero_edit,handles.pole_edit],'string','[1]');

    % Use WAITFOR to have the GUI 'pause' until the userdata property is changed to 'close'
    waitfor(handles.import,'userdata','close');

    if ~strcmp(get(handles.cancel,'userdata'),'yes');
        if nargout > 0
            % Store data directly in the handles structure and Save the new
            % structure to the application data of the figure

            handles.done = 1;

            guidata(fig,handles);
            varargout{1} = handles;
            set(fig,'visible','off');
        end
    else % if Cancel pressed
        if nargout > 0
            handles.done = 0;
            guidata(fig,handles);
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
%====================================================================
%====================================================================
%====================================================================
function varargout = cancel_Callback(h, eventdata, handles, varargin)
% ====================================================================
set(handles.import,'userdata','close');
set(handles.cancel,'userdata','yes');
%====================================================================
function varargout = import_Callback(h, eventdata, handles, varargin)
%====================================================================
value = get(handles.popupmenu,'value');

if 2-value
    % Import values
    set(handles.import,'userdata','close');
else
    % Import from file
    fname = get(handles.name_button,'string');
    pname = get(handles.name_button,'userdata');

    if exist([pname,fname],'file')
        set(handles.import,'userdata','close');
    else
        set(handles.InfoText,'str',['File "' fname '" not found !!'],'vis','on');
    end
end
%====================================================================
function varargout = popupmenu_Callback(h, eventdata, handles, varargin)
%====================================================================
value = get(handles.popupmenu,'value');

if value == 1
    set([handles.name_button,handles.pole_form,handles.zero_form],'visible','off');
    set(handles.zero_text,'string','Numerator Filter Coefficients');
    set(handles.pole_text,'string','Denominator Filter Coefficients');
    set([handles.zero_edit,handles.pole_edit],'string','[1]');
elseif value == 2
    set(handles.zero_text,'string','Zero Variable Name');
    set(handles.pole_text,'string','Pole Variable Name');
    set([handles.name_button,handles.pole_form,handles.zero_form],'visible','on');

    % Check for already existing "noname.mat" file (default file)
    fname = get(handles.name_button,'string');
    pname = get(handles.name_button,'userdata');

    if exist([pname,fname],'file')
        fname = strrep(fname,'.mat','');
        dat = load([pname fname '.mat']);

        set(handles.name_button,'string',[fname '.mat'],'userdata',pname);
        set(handles.zero_edit,'string',dat.coeff_dlg_names{1},'enable','off');
        set(handles.zero_form,'value',dat.coeff_dlg_format(1),'enable','off');
        set(handles.pole_edit,'string',dat.coeff_dlg_names{2},'enable','off');
        set(handles.pole_form,'value',dat.coeff_dlg_format(2),'enable','off');
    else
        set(handles.zero_edit,'string','z_values');
        set(handles.pole_edit,'string','p_values');
    end
end
%====================================================================
function varargout = name_button_Callback(h, eventdata, handles, varargin)
%====================================================================
[fname,pname] = uigetfile('*.mat','Import from File');
set(handles.InfoText,'vis','off');

if fname
    fname = strrep(fname,'.mat','');
    dat = load([pname fname '.mat']);

    set(handles.name_button,'string',[fname '.mat'],'userdata',pname);
    set(handles.zero_edit,'string',dat.coeff_dlg_names{1},'enable','off');
    set(handles.zero_form,'value',dat.coeff_dlg_format(1),'enable','off');
    set(handles.pole_edit,'string',dat.coeff_dlg_names{2},'enable','off');
    set(handles.pole_form,'value',dat.coeff_dlg_format(2),'enable','off');
else
    set(handles.name_button,'string','noname.mat','userdata',pname);
end
%====================================================================
function varargout = zero_form_Callback(h, eventdata, handles, varargin)
%====================================================================
function varargout = pole_form_Callback(h, eventdata, handles, varargin)
%====================================================================
function varargout = zero_edit_Callback(h, eventdata, handles, varargin)
%====================================================================
function varargout = pole_edit_Callback(h, eventdata, handles, varargin)
%====================================================================