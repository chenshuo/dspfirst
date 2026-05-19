function varargout = pezdemo(varargin)
% For revision history please see readme.m file
spfirstVer =  'Revision: 2.9  30-Mar-2016';
% ================================================================== %
if nargin == 0  % LAUNCH GUI
    %---  Check the installation, the Matlab Version, and the Screen Size
    %%---%
    
    errCmd = 'errordlg(lasterr,''Error Initializing Figure''); error(lasterr);';
    cmdCheck1 = 'installcheck;';
    cmdCheck2 = 'MATLABVER = versioncheck(6.0);';
    cmdCheck3 = 'screensizecheck([800 600]);';
    cmdCheck4 = ['adjustpath(''' mfilename ''');'];
    cmdCheck5 = 'displaycheck( fig );';
    eval(cmdCheck1,errCmd);       % Simple installation check
    eval(cmdCheck2,errCmd);       % Check Matlab Version
    eval(cmdCheck3,errCmd);       % Check Screen Size
    eval(cmdCheck4,errCmd);       % Adjust path if necessary
    
    % Set up and invoke the GUI
    fig = openfig(mfilename,'new');
    
    eval(cmdCheck5,errCmd);       % check system display
    
    % Generate a structure of handles to pass to callbacks, and store it.
    handles = guihandles(fig);
    setappdata(fig,'init_handles',handles);
    
    handles.MATLABVER = versioncheck(6.0);
    handles = initialize_pez(handles,mfilename);
    handles.filepath  = which(mfilename);
    handles.real_motion     = 0;
    handles.circular_motion = 0;
    handles.circular_radius = 0.9;
    handles.radial_motion   = 0;
    set(fig,'visible','on','name',[get(fig,'name') spfirstVer(10:14)]);
       
    if handles.MATLABVER<8.4
        set(fig,'ResizeFcn','pezdemo(''figure_pez_ResizeFcn'',gcbo,[],guidata(gcbo))');
    else
        set(fig,'SizeChangedFcn','pezdemo(''figure_pez_ResizeFcn'',gcbo,[],guidata(gcbo))');
    end
    
    % User-Data Acquisition
    movietool('Initialize',fig,mfilename,0.08);
    guidata(fig,handles);
    
    if nargout > 0
        varargout{1} = fig;
    end
elseif strcmp(varargin{1},'--version')
    disp(spfirstVer);
elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK
    %  varargin{1}
    try
        mt = getappdata(varargin{4}.figure_pez,'movietoolData');
        if ~isempty(mt), varargin = pre_callbackAction(mt,varargin{:}); end
        [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
        if ~isempty(mt), post_callbackAction(mt,varargin{:}); end
    catch
        disp(lasterr);
    end
end
% ================================================================== %
%| ABOUT CALLBACKS:
%| GUIDE automatically appends subfunction prototypes to this file, and
%| sets objects' callback properties to call them through the FEVAL
%| switchyard above. This comment describes that mechanism.
%|
%| Each callback subfunction declaration has the following form:
%| <SUBFUNCTION_NAME>(H, EVENTDATA, HANDLES, VARARGIN)
%|
%| The subfunction name is composed using the object's Tag and the
%| callback type separated by '_', e.g. 'slider2_Callback',
%| 'figure1_CloseRequestFcn', 'axis1_ButtondownFcn'.
%|
%| H is the callback object's handle (obtained using GCBO).
%|
%| EVENTDATA is empty, but reserved for future use.
%|
%| HANDLES is a structure containing handles of components in GUI using
%| tags as fieldnames, e.g. handles.figure1, handles.slider2. This
%| structure is created at GUI startup using GUIHANDLES and stored in
%| the figure's application data using GUIDATA. A copy of the structure
%| is passed to each callback.  You can store additional information in
%| this structure at GUI startup, and you can change the structure
%| during callbacks.  Call guidata(h, handles) after changing your
%| copy to replace the stored original so that subsequent callbacks see
%| the updates. Type "help guihandles" and "help guidata" for more
%| information.
%|
%| VARARGIN contains any extra arguments you have passed to the
%| callback. Specify the extra arguments by editing the callback
%| property in the inspector. By default, GUIDE sets the property to:
%| <MFILENAME>('<SUBFUNCTION_NAME>', gcbo, [], guidata(gcbo))
%| Add any extra arguments after the last argument, before the final
%| closing parenthesis.
% ================================================================== %
function varargout =  menu_import_Callback(h, eventdata, handles, varargin)
% ================================================================== %
%Call for "Import..."
ihandles = import_dlg(handles);

if ihandles.done
    action = get(ihandles.popupmenu,'value');
    
    if action == 1      % import values
        
        zeros_name = get(ihandles.zero_edit,'String');
        poles_name = get(ihandles.pole_edit,'String');
        
        if isempty( str2num(zeros_name) )
            Nzeros = evalin('base',zeros_name);
        else
            eval(['Nzeros=',get(ihandles.zero_edit,'string'),';']);
        end
        if isempty( str2num(poles_name) )
            Npoles = evalin('base',poles_name);
        else
            eval(['Npoles=',get(ihandles.pole_edit,'string'),';']);
        end
        
    elseif action == 2   % import from file
        
        zform = get(ihandles.zero_form,'value');
        pform = get(ihandles.pole_form,'value');
        fname = get(ihandles.name_button,'string');
        pname = get(ihandles.name_button,'UserData');
        load ([pname,fname]);
        eval(['Nzeros=',get(ihandles.zero_edit,'string'),';']);
        eval(['Npoles=',get(ihandles.pole_edit,'string'),';']);
        
        if zform == 2
            Nzeros = poly(Nzeros);
        end
        
        if pform == 2
            Npoles = poly(Npoles);
        end;
        
    end
    
    handles.a = conv(handles.a,Npoles);
    handles.b = conv(handles.b,Nzeros);
    
    handles.poleloc = roots(handles.a)';
    handles.zeroloc = roots(handles.b)';
    
    handles = pezdemo('refresh_Callback',[],[],handles);
    
    % Link poles/zeros
    handles = pezdemo('check_connection',[],[],handles);
    
    guidata(handles.figure_pez,handles);
    delete(ihandles.figure1);
end
% ================================================================== %
function varargout =  menu_export_Callback(h, eventdata, handles, varargin)
% ================================================================== %
%Call for Export ...
if (isempty(handles.poleloc) & isempty(handles.zeroloc))
    hw = warndlg('Please select either poles and/or zeros before exporting to workspace.');
    set(hw,'color',get(handles.figure_pez,'color'));
else
    cdhandles = coeff_dlg(handles);
    
    if cdhandles.done
        num_name = get(cdhandles.zero_edit,'string');
        den_name = get(cdhandles.pole_edit,'string');
        zform = get(cdhandles.zero_form,'value');
        pform = get(cdhandles.pole_form,'value');
        
        % Export to file or workspace
        if 2-get(cdhandles.popupmenu,'value')
            % Create poly/root variables with proper names
            if 2-zform
                eval([num_name,'=handles.b;']);
            else
                eval([num_name,'=handles.zeroloc;']);
            end
            
            if 2-pform
                eval([den_name,'=handles.a;']);
            else
                eval([den_name,'=handles.poleloc;']);
            end
            
            coeff_dlg_names = {num_name den_name};
            coeff_dlg_format = [zform pform];
            save([get(cdhandles.name_button,'UserData'),get(cdhandles.name_button,'String')],num_name,den_name,'coeff_dlg_names','coeff_dlg_format');
        else
            % Create poly/root variables with proper names
            if 2-zform
                eval([num_name,'=handles.b']);
                assignin('base',num_name,handles.b );
            else
                eval([num_name,'=handles.zeroloc']);
                assignin('base',num_name,handles.zeroloc );
            end
            
            if 2-pform
                eval([den_name,'=handles.a']);
                assignin('base',den_name,handles.a );
            else
                eval([den_name,'=handles.poleloc']);
                assignin('base',den_name,handles.poleloc );
            end
            %disp(['"' num_name '"' ' and ' '"' den_name '"' ' have been added to workspace'])
        end
        delete(cdhandles.figure1);
    end
end
% ================================================================== %
function varargout =  menu_print_Callback(h, eventdata, handles, varargin)
% ================================================================== %
%Call for "Print..."
printdlg
% ================================================================== %
function varargout =  menu_exit_Callback(h, eventdata, handles, varargin)
% ================================================================== %
%Call for "Exit"
delete(handles.showplot_h.figure_showplot);
delete(handles.figure_pez);
% ================================================================== %
function varargout =  menu_addpole_Callback(h, eventdata, handles, varargin)
% ================================================================== %
%Call for Add pole
set(handles.figure_pez,'WindowButtonMotionFcn','');
set(handles.axes_pzplot,'ButtonDownFcn',[mfilename, '(''getclickpt'', [],[],guidata(gcbo), ''addpole'')']);
set(handles.figure_pez,'WindowButtonUpFcn',[mfilename, '(''resetclickpt'', [],[],guidata(gcbo))']);
setptr(handles.figure_pez,'crosshair');
% ================================================================== %
function varargout =  menu_addzero_Callback(h, eventdata, handles, varargin)
% ================================================================== %
%Call for Add zero
set(handles.figure_pez,'WindowButtonMotionFcn','');
set(handles.axes_pzplot,'ButtonDownFcn',[mfilename, '(''getclickpt'', [],[],guidata(gcbo), ''addzero'')']);
set(handles.figure_pez,'WindowButtonUpFcn',[mfilename, '(''resetclickpt'', [],[],guidata(gcbo))']);
setptr(handles.figure_pez,'crosshair');
% ================================================================== %
function varargout =  menu_addpez_Callback(h, eventdata, handles, varargin)
% ================================================================== %
%Call for Add pole and zero
set(handles.figure_pez,'WindowButtonMotionFcn','');
set(handles.axes_pzplot,'ButtonDownFcn',[mfilename, '(''getclickpt'', [],[],guidata(gcbo), ''addpez'')']);
set(handles.figure_pez,'WindowButtonUpFcn',[mfilename, '(''resetclickpt'', [],[],guidata(gcbo))']);
setptr(handles.figure_pez,'crosshair');
% ================================================================== %
function varargout =  menu_delpole_Callback(h, eventdata, handles, varargin)
% ================================================================== %
%Call for Remove all poles
set(handles.listbox_pole,'String',[],'Value',1);
set([handles.selectedpole, handles.selectedzero],'XData',[],'YData',[]);
handles.poleloc = [];

if( ~isempty(handles.connecttype) )
    polestring = find(handles.connecttype == 'x');
    handles.connection(polestring,:) = [];
    handles.connection(:,polestring) = [];
    handles.connecttype(polestring)  = [];
end

%% Update edit_poleloc
set(handles.edit_poleloc,'string',[]);
%%
handles = recal(handles, 'pole_to_poly');
handles = plot_gph(handles);
guidata(handles.figure_pez, handles);
% ================================================================== %
function varargout =  menu_delzero_Callback(h, eventdata, handles, varargin)
% ================================================================== %
%Call for Remove all zeros
set(handles.listbox_zero,'String',[],'Value',1);
set([handles.selectedzero, handles.showplot_h.selectedzero],'XData',[],'YData',[]);
handles.zeroloc = [];

if( ~isempty(handles.connecttype) )
    zerostring = find(handles.connecttype == 'o');
    handles.connection(zerostring,:) = [];
    handles.connection(:,zerostring) = [];
    handles.connecttype(zerostring)  = [];
end

%% Update edit_zeroloc
set(handles.edit_zeroloc,'string',[]);
%%

handles = recal(handles, 'pole_to_poly');
handles = plot_gph(handles);

guidata(handles.figure_pez, handles);
% ================================================================== %
function varargout =  menu_delall_Callback(h, eventdata, handles, varargin)
% ================================================================== %
%Call for Remove all
set([handles.listbox_pole, handles.listbox_zero],'String',[],'Value',1);
set([handles.selectedpole, handles.showplot_h.selectedpole],'XData',[],'YData',[]);
set([handles.selectedzero, handles.showplot_h.selectedzero],'XData',[],'YData',[]);
handles.poleloc = [];
handles.zeroloc = [];

handles.connection = [];
handles.connecttype = [];

%% Update edit_zeroloc/edit_poleloc
set([handles.edit_zeroloc,handles.edit_poleloc],'string',[]);
%%
handles = recal(handles, 'pole_to_poly');
handles = plot_gph(handles);
guidata(handles.figure_pez,handles);
% ================================================================== %
function varargout = menu_Zoom_Callback(h, eventdata, handles, varargin)
% ================================================================== %
%Call for Zoom
set(handles.figure_pez,'WindowButtonMotionFcn','');
hzoom = findall(0,'tag','Zoom Enable');
if strcmp(get(hzoom,'checked'),'off')
    set(hzoom,'checked','on');
else
    set(hzoom,'checked','off');
end

set(handles.axes_pzplot,'ButtonDownFcn','')
set(handles.figure_pez,'Pointer','arrow');

if strcmp(get(h,'tag'),'Zoom Enable')
    if get(findall(0,'tag','tb_zoomenable'), 'Value') == 1;
        set(findall(0,'tag','tb_zoomenable'), 'Value', 0);
    else
        set(findall(0,'tag','tb_zoomenable'), 'Value', 1);
    end
end

if  strcmp(get(handles.figure_pez,'HandleVisibility'), 'off')
    set(handles.figure_pez,'HandleVisibility','on');
    axes(handles.axes_pzplot);
    zoom on;
    set(handles.pezpb,'Visible','off');
else
    set(handles.pezpb,'Visible','on');
    axes(handles.axes_pzplot);
    zoom off;
    set(handles.figure_pez,'HandleVisibility','off','WindowButtonUpFcn','');
end

val = max(get(handles.axes_pzplot,'xlim'));
pezdemo('resetclickpt',[],[],handles);
update_axis_limit_check(h,eventdata,handles,val);
guidata(handles.figure_pez,handles);
% ================================================================== %
function varargout =  menu_ShowGraph_Callback(h, eventdata, handles, varargin)
% ================================================================== %
%Call for ShowGraph
set(handles.showplot_h.figure_showplot,'WindowButtonMotionFcn', ...
    [mfilename, '(''WindowButtonMotion'',[],[],guidata(gcbo))'],'vis','on');

set(handles.showplot_h.axes_pzplot,'ButtonDownFcn',[mfilename, '(''startdrag'',[],[],guidata(gcbo),1)']);
set(handles.showplot_h.figure_showplot,'WindowButtonUpFcn',[mfilename, '(''resetclickpt'', [],[],guidata(gcbo),1)'],'Pointer','arrow');
set([handles.selectedpole,handles.showplot_h.selectedpole,handles.selectedzero, handles.showplot_h.selectedzero], ...
    'XData',[],'YData',[]);
set(handles.figure_pez,'WindowButtonMotionFcn',[mfilename, '(''WindowButtonMotion'', [],[],guidata(gcbo))'], ...
    'WindowButtonUpFcn','','Pointer','arrow');
set(handles.axes_pzplot,'ButtonDownFcn','');

guidata(handles.showplot_h.figure_showplot, handles);
% ================================================================== %
function varargout =  menu_ClickEnable_Callback(h, eventdata, handles, varargin)
% ================================================================== %
%Call for Click Enable
hzoom = findall(0,'tag','Zoom Enable');
if strcmp(get(hzoom,'checked'),'off')
    set(hzoom,'checked','on');
else
    set(hzoom,'checked','off');
end

if strcmp(get(h, 'tag'), 'Click Enable')
    if get(findall(0,'tag','tb_clickenable'), 'Value') == 1;
        set(findall(0,'tag','tb_clickenable'), 'Value', 0);
    else
        set(findall(0,'tag','tb_clickenable'), 'Value', 1);
    end
end

pezdemo('resetclickpt',[],[],guidata(gcbo));
% ================================================================== %
function varargout =  menu_LineWidth_Callback(h, eventdata, handles, varargin)
% ================================================================== %
newLineWidth = linewidthdlg(handles.LineWidth);
handles.LineWidth = newLineWidth;

set([handles.linemag,...
    handles.linephase,...
    handles.lineimp_cir,...
    handles.lineimp_lin,...
    handles.lineimpimg_cir,...
    handles.lineimpimg_lin,...
    handles.linepezzero,...
    handles.linepezpole,...
    handles.selectedpole,...
    handles.selectedzero,...
    handles.showplot_h.linemag,...
    handles.showplot_h.linephase,...
    handles.showplot_h.lineimp_cir,...
    handles.showplot_h.lineimp_lin,...
    handles.showplot_h.linepezzero,...
    handles.showplot_h.linepezpole,...
    handles.showplot_h.selectedpole,...
    handles.showplot_h.selectedzero,...
    handles.lineray.main,handles.lineray.mag ,handles.lineray.phase], ...
    'LineWidth',handles.LineWidth);
drawnow;
guidata(handles.figure_pez, handles);
% ================================================================== %
function varargout =  menu_Screenshot_Callback(h, eventdata, handles, varargin)
% ================================================================== %
screenshotdlg(gcbf);
% ================================================================== %
function varargout =  menu_ShowMenu_Callback(h, eventdata, handles, varargin)
% ================================================================== %
check = get(gcbo,'Checked');
if strcmp(check,'off')
    set(gcbf,'MenuBar','figure');
    set(gcbo,'Checked','On');
else
    set(gcbf,'MenuBar','none');
    set(gcbo,'Checked','Off');
end
% ================================================================== %
function varargout =  menu_LineColor_Callback(h, eventdata, handles, varargin)
% ================================================================== %
set([handles.linemag,...
    handles.linephase,...
    handles.lineimp_cir,...
    handles.lineimp_lin,...
    handles.linepezzero,...
    handles.linepezpole,...
    handles.showplot_h.linemag,...
    handles.showplot_h.linephase,...
    handles.showplot_h.lineimp_cir,...
    handles.showplot_h.lineimp_lin,...
    handles.showplot_h.linepezzero,...
    handles.showplot_h.linepezpole],'Color',varargin{1});
set(handles.textcolor,'ForegroundColor',varargin{1});
set([handles.lineimp_cir,...
    handles.showplot_h.lineimp_cir],'MarkerFaceColor',varargin{1});

set(handles.grp_colortag,'Checked','off');
temp = [0,1,4,2,6];
hx = handles.grp_colortag(find(temp == bin2dec([num2str(varargin{1}(1)),num2str(varargin{1}(2)),num2str(varargin{1}(3))])));
if strcmp(get(hx,'checked'),'off')
    set(hx,'checked','on');
else
    set(hx,'checked','off');
end
% ================================================================== %
function varargout = menu_RepeatedAdd_Callback(h, eventdata, handles, varargin)
% ================================================================== %
hradd = findall(0,'tag','Add Repeatedly');
if strcmp(get(hradd,'checked'),'off')
    set(hradd,'checked','on');
else
    set(hradd,'checked','off');
end

if strcmp(handles.repeatedadd, 'off')
    handles.repeatedadd = 'on';
else
    handles.repeatedadd = 'off';
end

if strcmp(get(h,'tag'), 'Add Repeatedly')
    if get(findall(0,'tag','tb_addrepeatedly'),'Value') == 1;
        set(findall(0,'tag','tb_addrepeatedly'),'Value', 0);
    else
        set(findall(0,'tag','tb_addrepeatedly'),'Value', 1);
    end
end

guidata(handles.figure_pez, handles);
% ================================================================== %
function varargout = menu_real_motion(h,eventdata,handles,varargin)
% ================================================================== %
if strcmp(get(h,'checked'),'off')
    handles.real_motion = 1;
    set(h,'checked','on');
    set(handles.linepezy,'linewidth',2);
    set(handles.circular_motionT,'checked','off');
    % update "Move along a Circle" & "Move along a Radial Line"  menu
    handles.circular_motion = 0;
    handles.radial_motion   = 0;
    set([handles.circular_motionT,handles.radial_motionT],'checked','off');
else
    handles.real_motion = 0;
    set(h,'checked','off');
    set(handles.linepezy,'linewidth',0.5);
end
guidata(handles.figure_pez, handles);
% ================================================================== %
function varargout = menu_circular_motion(h,eventdata,handles,varargin)
% ================================================================== %
if strcmp(get(h,'checked'),'off')
    handles.circular_motion = 1;
    set(h,'checked','on');
    % update "Move on Real Line" menu
    handles.real_motion = 0;
    handles.radial_motion = 0;
    set([handles.real_motionT,handles.radial_motionT],'checked','off');
    set(handles.linepezy,'linewidth',0.5);
else
    handles.circular_motion = 0;
    set(h,'checked','off');
end
guidata(handles.figure_pez, handles);
% ================================================================== %
function varargout = menu_radial_motion(h,eventdata,handles,varargin)
% ================================================================== %
if strcmp(get(h,'checked'),'off')
    handles.radial_motion = 1;
    set(h,'checked','on');
    % update "Move on Radial Line" menu
    handles.real_motion = 0;
    handles.circular_motion = 0;
    set([handles.real_motionT,handles.circular_motionT],'checked','off');
    set(handles.linepezy,'linewidth',0.5);
else
    handles.radial_motion = 0;
    set(h,'checked','off');
end
guidata(handles.figure_pez, handles);
% ================================================================== %
function varargout = menu_Unlink_Callback(h, eventdata, handles, varargin)
% ================================================================== %

if strcmp(get(findobj(findall(0,'type','figure'),'tag','Click Enable'),'Checked'), 'on')
    tempvalue = handles.tempvalue;
    zero_selected = 0;
    if tempvalue > length(handles.poleloc)
        tempvalue = tempvalue-length(handles.poleloc);
        zero_selected = 1;
    end
    
    sxpole = get(handles.selectedpole,'XData');
    sxzero = get(handles.selectedzero,'XData');
    
    if isempty(sxzero)
        polestring = find(handles.connecttype == 'x');
        polelength = length(handles.connecttype);
        
        handles.connection(:,polestring(tempvalue)) = zeros(1,polelength);
        handles.connection(polestring(tempvalue),:) = [zeros(1,polestring(tempvalue)-1),1,zeros(1,polelength - polestring(tempvalue))];
        
        set([handles.selectedpole, handles.showplot_h.selectedpole],...
            'XData',real(handles.poleloc(handles.tempvalue)),...
            'YData',imag(handles.poleloc(handles.tempvalue)));
        
        guidata(handles.figure_pez, handles);
    elseif isempty(sxpole)
        
        zerostring = find(handles.connecttype == 'o');
        zerolength = length(handles.connecttype);
        
        handles.connection(:,zerostring(tempvalue)) = zeros(1,zerolength);
        handles.connection(zerostring(tempvalue),:) = [zeros(1,zerostring(tempvalue)-1),1,zeros(1,zerolength - zerostring(tempvalue))];
        
        set([handles.selectedzero, handles.showplot_h.selectedzero],...
            'XData',real(handles.zeroloc(tempvalue)),...
            'YData',imag(handles.zeroloc(tempvalue)));
        guidata(handles.figure_pez, handles);
    else
        if zero_selected
            zerostring = find(handles.connecttype == 'o');
            zerolength = length(handles.connecttype);
            
            linkzero = setdiff(intersect(find(handles.connection(:,zerostring(tempvalue))),find(handles.connecttype == 'o')),zerostring(tempvalue));
            if ~isempty(linkzero)
                handles.connection(:,linkzero) = zeros(1,zerolength);
                handles.connection(linkzero,:) = [zeros(1,linkzero-1),1,zeros(1,zerolength - linkzero)];
            end
            handles.connection(:,zerostring(tempvalue)) = zeros(1,zerolength);
            handles.connection(zerostring(tempvalue),:) = [zeros(1,zerostring(tempvalue)-1),1,zeros(1,zerolength - zerostring(tempvalue))];
            
            if ~isempty(linkzero)
                handles.connection(linkzero,zerostring(tempvalue)) = 1;
            end
            
            handles.connection(zerostring(tempvalue),linkzero) = 1;
            set([handles.selectedpole, handles.showplot_h.selectedpole],'XData',[],'YData',[]);
            set([handles.selectedzero, handles.showplot_h.selectedzero],...
                'XData',real(handles.zeroloc([tempvalue,find(zerostring == linkzero(1))])),...
                'YData',imag(handles.zeroloc([tempvalue,find(zerostring == linkzero(1))])));
            
        else
            polestring = find(handles.connecttype == 'x');
            polelength = length(handles.connecttype);
            
            linkpole = setdiff(intersect(find(handles.connection(:,polestring(tempvalue))),find(handles.connecttype == 'x')),polestring(tempvalue));
            if ~isempty(linkpole)
                handles.connection(:,linkpole) = zeros(1,polelength);
                handles.connection(linkpole,:) = [zeros(1,linkpole-1),1,zeros(1,polelength - linkpole)];
                handles.connection(linkpole,polestring(tempvalue)) = 1;
            end
            handles.connection(:,polestring(tempvalue)) = zeros(1,polelength);
            handles.connection(polestring(tempvalue),:) = [zeros(1,polestring(tempvalue)-1),1,zeros(1,polelength - polestring(tempvalue))];
            
            if ~isempty(linkpole)
                handles.connection(linkpole,polestring(tempvalue)) = 1;
            end
            handles.connection(polestring(tempvalue),linkpole) = 1;
            
            set([handles.selectedzero, handles.showplot_h.selectedzero],'XData',[],'YData',[]);
            set([handles.selectedpole, handles.showplot_h.selectedpole],...
                'XData',real(handles.poleloc([tempvalue,find(polestring == linkpole(1))])),...
                'YData',imag(handles.poleloc([tempvalue,find(polestring == linkpole(1))])));
        end
    end
    guidata(handles.figure_pez, handles);
end
% ================================================================== %
function varargout = edit_gain_Callback(h, eventdata, handles, varargin)
% ================================================================== %
% Stub for Callback of the uicontrol handles.edit1.
handles.k = str2num(get(handles.edit_gain,'String'));
handles = recal(handles, 'pole_to_poly');
handles = plot_imp(handles);
handles = plot_gph(handles);
guidata(handles.figure_pez, handles);
% ================================================================== %
function varargout = pb_addpole_Callback(h,eventdata, handles, varargin)
% ================================================================== %
str = get(handles.edit_poleloc,'string');
answer = pezdemo('getXY',h,eventdata,handles,'add_pole',str);

if ~isempty(answer)
    [r,c] = size(answer);
    for k = 1:r
        x = answer(k,1);
        y = answer(k,2);
        if handles.real_motion, y = 0; end
        if handles.circular_motion
            handles.circular_radius = sqrt(x*x+y*y);
            theta = atan2(y,x);
            x = handles.circular_radius*cos(theta);
            y = handles.circular_radius*sin(theta);
        end
        if handles.radial_motion
            handles.radial_theta = atan2(y,x);
        end
        
        if ~isempty(x) & ~isempty(y)
            if (x)^2 + (y)^2 ~= 1
                
                handles.poleloc = [handles.poleloc,x+y*i];
                
                set(handles.listbox_pole,'String',strvcat(get(handles.listbox_pole,'String'),...
                    ['( ',num2str(x),', ',num2str(y),' )']));
                temp = length(handles.connecttype);
                handles.connection = [handles.connection, zeros(temp,1); zeros(1,temp), 1];
                handles.connecttype = [handles.connecttype; 'x'];
                
                % if "Add with Conjugate" button pressed
                if get(handles.tb_addconjugate,'value') == 1
                    handles.poleloc = [handles.poleloc, x-y*i];
                    set(handles.listbox_pole,'String',strvcat(get(handles.listbox_pole,'String'),...
                        ['( ',num2str(x),', ',num2str(-y),' )']));
                    temp = length(handles.connecttype);
                    handles.connection = [handles.connection, [zeros(temp-1,1); 1]; zeros(1,temp-1), 1, 1];
                    handles.connecttype = [handles.connecttype; 'x'];
                end
                
                handles = recal(handles, 'pole_to_poly');
                handles = plot_gph(handles);
                
                handles.changed = 'on';
                
                % WindowButtonMotionFunction
                if get(handles.tb_zoomenable,'value')
                    set(handles.figure_pez,'WindowButtonMotionFcn','');
                else
                    set(handles.figure_pez,'WindowButtonMotionFcn',[mfilename, '(''WindowButtonMotion'', [],[],guidata(gcbo))']);
                    set(handles.axes_pzplot,'ButtonDownFcn',[mfilename,'(''startselected'',[],[],guidata(gcbo))']);
                    set(handles.figure_pez,'WindowButtonUpFcn',[mfilename, '(''resetclickpt'', [],[],guidata(gcbo))']);
                end
                guidata(handles.figure_pez, handles);
            else
                errordlg('Fourier Transform of the Pole Does Not Exist');
            end
        else
            errordlg('Input Must be a Number');
        end
    end
end
% ================================================================== %
function varargout = pb_editpole_Callback(h, eventdata, handles, varargin)
% ================================================================== %
if ~isempty(handles.poleloc)
    
    str = get(handles.edit_poleloc,'string');
    answer = pezdemo('getXY',h,eventdata,handles,'edit_pole',str);
    
    if ~isempty(answer)
        x = answer(1);  y = answer(2);
        if handles.real_motion, y = 0; end
        if handles.circular_motion
            handles.circular_radius = sqrt(x*x+y*y);
            theta = atan2(y,x);
            x = handles.circular_radius*cos(theta);
            y = handles.circular_radius*sin(theta);
        end
        if handles.radial_motion
            x = handles.circular_radius*cos(handles.radial_theta);
            y = handles.circular_radius*sin(handles.radial_theta);
        end
        
        if ((x)^2 + (y)^2) ~= 1
            tempvalue = get(handles.listbox_pole,'value');
            handles.poleloc(tempvalue)= x+y*i;
            handles = recal(handles, 'pole_to_poly');
            handles = plot_gph(handles);
            
            tempstring = get(handles.listbox_pole,'String');
            tempstring = strvcat(tempstring(1:tempvalue-1,:),...
                ['( ',num2str(real(handles.poleloc(tempvalue))),', ',num2str(imag(handles.poleloc(tempvalue))),' )'],...
                tempstring(tempvalue+1:end,:));
            set(handles.listbox_pole,'String',tempstring);
            
            polestring = find(handles.connecttype == 'x');
            polelength = length(handles.connecttype);
            
            linkpole = setdiff(intersect(find(handles.connection(:,polestring(tempvalue))),find(handles.connecttype == 'x')),polestring(tempvalue));
            if ~isempty(linkpole)
                handles.connection(:,linkpole) = zeros(1,polelength);
                handles.connection(linkpole,:) = [zeros(1,linkpole-1),1,zeros(1,polelength - linkpole)];
            end
            handles.connection(:,polestring(tempvalue)) = zeros(1,polelength);
            handles.connection(polestring(tempvalue),:) = [zeros(1,polestring(tempvalue)-1),1,zeros(1,polelength - polestring(tempvalue))];
            handles = pezdemo('check_connection',[],[],handles);
            guidata(handles.figure_pez, handles);
            
        else
            errordlg('Fourier Transform of the Pole Does Not Exist');
        end
    else
        errordlg('Input Must be a Non-Zero Number');
    end
end
% ================================================================== %
function varargout = pb_delpole_Callback(h, eventdata, handles, varargin)
% ================================================================== %
dlgTitle = 'delete pole';
set([handles.selectedpole,handles.showplot_h.selectedpole],'XData',[],'YData',[]);

tempstring = get(handles.listbox_pole ,'String');
tempvalue  = get(handles.listbox_pole ,'Value');
tempxdata  = get(handles.linepezpole  ,'XData');
tempydata  = get(handles.linepezpole  ,'YData');

if ~isempty(handles.poleloc)
    polestring = find(handles.connecttype == 'x');
    
    % Determine if linked conjugate pair exists
    pair = find( (handles.connecttype == 'x')'.*handles.connection(polestring(tempvalue),:) == 1);
    
    for k = 1:length(pair)
        index(k) = find( polestring == pair(k) );
    end
    
    tempstring = strvcat(tempstring(1:min(index)-1,:),tempstring(max(index)+1:end,:));
    handles.poleloc = [handles.poleloc(1:min(index)-1),handles.poleloc(max(index)+1:end)];
    
    %polelength = length(handles.connecttype);
    handles.connecttype(polestring(index))  = [];
    handles.connection(polestring(index),:) = [];
    handles.connection(:,polestring(index)) = [];
end

handles = recal(handles, 'pole_to_poly');
handles = plot_gph(handles);

set(handles.listbox_pole,'String',tempstring,'Value',1);
guidata(handles.figure_pez, handles);
% ================================================================== %
function varargout = pb_addzero_Callback(h, eventdata, handles, varargin)
% ================================================================== %
str = get(handles.edit_zeroloc,'string');
answer = pezdemo('getXY',h,eventdata,handles,'add_zero',str);

if ~isempty(answer)
    [r,c] = size(answer);
    for k = 1:r
        x = answer(k,1);
        y = answer(k,2);
        if handles.real_motion, y = 0; end
        if handles.circular_motion
            handles.circular_radius = sqrt(x*x+y*y);
            theta = atan2(y,x);
            x = handles.circular_radius*cos(theta);
            y = handles.circular_radius*sin(theta);
        end
        if handles.radial_motion
            handles.radial_theta = atan2(y,x);
        end
        if ~ isempty(x) & ~isempty(y)
            
            handles.zeroloc = [handles.zeroloc, x+y*i];
            
            set(handles.listbox_zero,'String',strvcat(get(handles.listbox_zero,'String'),...
                ['( ',num2str(x),', ',num2str(y),' )']));
            temp = length(handles.connecttype);
            handles.connection = [handles.connection, zeros(temp,1); zeros(1,temp), 1];
            handles.connecttype = [handles.connecttype; 'o'];
            
            % if "Add with Conjugate" button pressed
            if get(handles.tb_addconjugate,'value') == 1
                handles.zeroloc = [handles.zeroloc, x-y*i];
                set(handles.listbox_zero,'String',strvcat(get(handles.listbox_zero,'String'),...
                    ['( ',num2str(x),', ',num2str(-y),' )']));
                temp = length(handles.connecttype);
                handles.connection = [handles.connection, [zeros(temp-1,1); 1]; zeros(1,temp-1), 1, 1];
                handles.connecttype = [handles.connecttype; 'o'];
            end
            
            handles = recal(handles, 'pole_to_poly');
            handles = plot_gph(handles);
            
            handles.changed = 'on';
            
            % WindowButtonMotionFunction
            if get(handles.tb_zoomenable,'value')
                set(handles.figure_pez,'WindowButtonMotionFcn','');
            else
                set(handles.figure_pez,'WindowButtonMotionFcn',[mfilename, '(''WindowButtonMotion'', [],[],guidata(gcbo))']);
                set(handles.axes_pzplot,'ButtonDownFcn',[mfilename,'(''startselected'',[],[],guidata(gcbo))']);
                set(handles.figure_pez,'WindowButtonUpFcn',[mfilename, '(''resetclickpt'', [],[],guidata(gcbo))']);
            end
            guidata(handles.figure_pez, handles);
        else
            errordlg('Input Must be a Non-Zero Number');
        end
    end %for
end
% ================================================================== %
function varargout = pb_editzero_Callback(h, eventdata, handles, varargin)
% ================================================================== %
if ~isempty(handles.zeroloc)
    str = get(handles.edit_zeroloc,'string');
    answer = pezdemo('getXY',h,eventdata,handles,'edit_zero',str);
    
    if ~isempty(answer)
        x = answer(1); y = answer(2);
        if handles.real_motion, y = 0; end
        if handles.circular_motion
            handles.circular_radius = sqrt(x*x+y*y);
            theta = atan2(y,x);
            x = handles.circular_radius*cos(theta);
            y = handles.circular_radius*sin(theta);
        end
        if handles.radial_motion
            handles.radial_theta = sqrt(x*x+y*y);
        end
        tempvalue = get(handles.listbox_zero,'Value');
        handles.zeroloc(tempvalue)  = x+y*i;
        handles = recal(handles, 'pole_to_poly');
        handles = plot_gph(handles);
        
        tempstring = get(handles.listbox_zero,'String');
        tempstring = strvcat(tempstring(1:tempvalue-1,:),...
            ['( ',num2str(real(handles.zeroloc(tempvalue))),', ',num2str(imag(handles.zeroloc(tempvalue))),' )'],...
            tempstring(tempvalue+1:end,:));
        set(handles.listbox_zero,'String',tempstring);
        
        zerostring = find(handles.connecttype == 'o');
        zerolength = length(handles.connecttype);
        
        linkzero = setdiff(intersect(find(handles.connection(:,zerostring(tempvalue))),find(handles.connecttype == 'o')),zerostring(tempvalue));
        if ~isempty(linkzero)
            handles.connection(:,linkzero) = zeros(1,zerolength);
            handles.connection(linkzero,:) = [zeros(1,linkzero-1),1,zeros(1,zerolength - linkzero)];
        end
        handles.connection(:,zerostring(tempvalue)) = zeros(1,zerolength);
        handles.connection(zerostring(tempvalue),:) = [zeros(1,zerostring(tempvalue)-1),1,zeros(1,zerolength - zerostring(tempvalue))];
        handles = pezdemo('check_connection',[],[],handles);
        guidata(handles.figure_pez, handles);
    else
        errordlg('Input Must be a Non-Zero Number');
    end
end
% ================================================================== %
function varargout = pb_delzero_Callback(h, eventdata, handles, varargin)
% ================================================================== %
%dlgTitle = 'delete zero';
set([handles.selectedzero, handles.showplot_h.selectedzero],'XData',[],'YData',[]);

tempstring = get(handles.listbox_zero,'String');
tempvalue  = get(handles.listbox_zero,'Value');
%tempxdata  = get(handles.linepezzero,'XData');
%tempydata  = get(handles.linepezzero,'YData');

if ~isempty(handles.zeroloc)
    zerostring = find(handles.connecttype == 'o');
    
    % Determine if linked conjugate pair exists
    pair = find( (handles.connecttype == 'o')'.*handles.connection(zerostring(tempvalue),:) == 1);
    
    for k = 1:length(pair)
        index(k) = find( zerostring == pair(k) );
    end
    
    tempstring = strvcat(tempstring(1:min(index)-1,:),tempstring(max(index)+1:end,:));
    handles.zeroloc = [handles.zeroloc(1:min(index)-1),handles.zeroloc(max(index)+1:end)];
    
    %zerolength = length(handles.connecttype);
    handles.connecttype(zerostring(index))  = [];
    handles.connection(zerostring(index),:) = [];
    handles.connection(:,zerostring(index)) = [];
end

handles = recal(handles, 'pole_to_poly');
handles = plot_gph(handles);
set(handles.listbox_zero,'String',tempstring,'Value',1);

guidata(handles.figure_pez, handles);
% ================================================================== %
function handles = refresh_Callback(h,eventdata,handles,varargin)
% ================================================================== %
%replaced str2num(get(handles.imp.pole_edit,'String')
if (~isempty(handles.a) & ~isempty(handles.b))
    tempa =  roots(handles.a);
    if ~isempty(find(abs((real(tempa)).^2 + (imag(tempa)).^2 - 1) < 10^(-3)))
        errordlg('Fourier Transform Does Not Exist');
        handles.a = 1;
        handles.b = 1;
    else
        handles.k = handles.b(1)/handles.a(1);
        handles.a = poly(handles.poleloc);
        handles.b = poly(handles.zeroloc);
        handles = recal(handles, 'poly_to_pole');
        
        ptpole = length(handles.poleloc);
        
        tempa = []; tempb = [];
        for i = 1:ptpole
            tempa = strvcat(tempa, ['( ',num2str(real(handles.poleloc(i))),', ',num2str(imag(handles.poleloc(i))),' )']);
        end
        
        pt = length(handles.zeroloc);
        for i = 1:pt
            tempb = strvcat(tempb, ['( ',num2str(real(handles.zeroloc(i))),', ',num2str(imag(handles.zeroloc(i))),' )']);
            %temp = length(handles.connecttype);
        end
        
        set(handles.listbox_pole,'String',tempa);
        set(handles.listbox_zero,'String',tempb);
        set(handles.edit_gain,'String',handles.k);
        
        handles = pezdemo('check_connection',handles.figure_pez,eventdata,handles,varargin);
        handles = plot_gph(handles);
        
        if isempty(varargin)
            pezdemo('resetclickpt',[],[],handles);
        end
    end
    guidata(handles.figure_pez,handles);
else
    errordlg('Must Enter A Number');
end
% ================================================================== %
function varargout = getclickpt(h,eventdata,handles,varargin)
% ================================================================== %
eval([mfilename '(''getcurrentpt'',handles.axes_pzplot,eventdata,handles,varargin)']);

currentpt = get(handles.axes_pzplot,'userdata');
clicktype = get(handles.figure_pez,'SelectionType');

if ~isempty(currentpt);
    x = currentpt(1);
    y = currentpt(2);
    
    if handles.real_motion, y = 0; end
    if handles.circular_motion
        handles.circular_radius = sqrt(x*x+y*y);
        theta = atan2(y,x);
        x = handles.circular_radius*cos(theta);
        y = handles.circular_radius*sin(theta);
    end
    if handles.radial_motion
        handles.radial_theta = atan2(y,x);
    end
    temppair = 0;
    if get(handles.tb_addconjugate,'value')
        temppair = 1;
    end
    
    switch varargin{1}
        case 'addpole'
            if strcmp(clicktype,'normal')
                handles.poleloc = [handles.poleloc, x+y*i];
                set(handles.listbox_pole,'String',strvcat(get(handles.listbox_pole,'String'),...
                    ['( ',num2str(x),', ',num2str(y),' )']));
                temp = length(handles.connecttype);
                handles.connection = [handles.connection, zeros(temp,1); zeros(1,temp), 1];
                handles.connecttype = [handles.connecttype; 'x'];
                
                if temppair
                    handles.poleloc = [handles.poleloc, x-y*i];
                    set(handles.listbox_pole,'String',strvcat(get(handles.listbox_pole,'String'),...
                        ['( ',num2str(x),', ',num2str(-y),' )']));
                    temp = length(handles.connecttype);
                    handles.connection = [handles.connection, [zeros(temp-1,1); 1]; zeros(1,temp-1), 1, 1];
                    handles.connecttype = [handles.connecttype; 'x'];
                end
                
                %% Update edit_poleloc
                tempvalue = get(handles.listbox_pole,'value');
                list_str = [num2str(real(handles.poleloc(tempvalue))) ' , ' num2str(imag(handles.poleloc(tempvalue)))];
                set(handles.edit_poleloc,'string',list_str);
                %%
                handles = recal(handles, 'pole_to_poly');
                handles = plot_gph(handles);
                
                handles.changed = 'on';
                guidata(handles.figure_pez, handles);
            end
        case 'addzero'
            if strcmp(clicktype,'normal')
                handles.zeroloc = [handles.zeroloc, x+y*i];
                set(handles.listbox_zero,'String',strvcat(get(handles.listbox_zero,'String'),...
                    ['( ',num2str(x),', ',num2str(y),' )']));
                
                temp = length(handles.connecttype);
                handles.connection = [handles.connection, zeros(temp,1); zeros(1,temp), 1];
                handles.connecttype = [handles.connecttype; 'o'];
                
                if temppair
                    handles.zeroloc = [handles.zeroloc, x-y*i];
                    set(handles.listbox_zero,'String',strvcat(get(handles.listbox_zero,'String'),...
                        ['( ',num2str(x),', ',num2str(-y),' )']));
                    temp = length(handles.connecttype);
                    handles.connection = [handles.connection, [zeros(temp-1,1); 1]; zeros(1,temp-1), 1, 1];
                    handles.connecttype = [handles.connecttype; 'o'];
                end
                
                %% Update edit_zeroloc
                tempvalue = get(handles.listbox_zero,'value');
                list_str = [num2str(real(handles.zeroloc(tempvalue))) ' , ' num2str(imag(handles.zeroloc(tempvalue)))];
                set(handles.edit_zeroloc,'string',list_str);
                %%
                handles = recal(handles, 'pole_to_poly');
                handles = plot_gph(handles);
                
                handles.changed = 'on';
                guidata(handles.figure_pez, handles);
            end
        case 'addpez'
            switch clicktype
                case 'normal'
                    tempx = real(1/(x+y*i));
                    tempy = imag(1/(x+y*i));
                    if temppair
                        set(handles.listbox_pole,'String',...
                            strvcat(get(handles.listbox_pole,'String'),...
                            ['( ',num2str(x),', ',num2str(y),' )'],...
                            ['( ',num2str(x),', ',num2str(-y),' )']));
                        set(handles.listbox_zero,'String',...
                            strvcat(get(handles.listbox_zero,'String'),...
                            ['( ',num2str(tempx),', ',num2str(tempy),' )'],...
                            ['( ',num2str(tempx),', ',num2str(-tempy),' )']));
                        
                        handles.poleloc = [handles.poleloc, x+y*i, x-y*i];
                        handles.zeroloc = [handles.zeroloc, tempx+tempy*i, tempx-tempy*i];
                        
                        temp = length(handles.connecttype);
                        handles.connection = [handles.connection, zeros(temp,4);...
                            zeros(1,temp), 1, 1, 1, 1; zeros(1,temp), 1, 1, 1, 1;...
                            zeros(1,temp), 1, 1, 1, 1; zeros(1,temp), 1, 1, 1, 1];
                        handles.connecttype = [handles.connecttype; 'o'; 'o'; 'x'; 'x'];
                        
                    else
                        set(handles.listbox_pole,'String',...
                            strvcat(get(handles.listbox_pole,'String'),...
                            ['( ',num2str(x),', ',num2str(y),' )']));
                        set(handles.listbox_zero,'String',...
                            strvcat(get(handles.listbox_zero,'String'),...
                            ['( ',num2str(tempx),', ',num2str(-tempy),' )']));
                        
                        handles.poleloc = [handles.poleloc, x+y*i];
                        handles.zeroloc = [handles.zeroloc, tempx-tempy*i];
                        
                        temp = length(handles.connecttype);
                        handles.connection = [handles.connection, zeros(temp,2);...
                            zeros(1,temp), 1, 1; zeros(1,temp), 1, 1];
                        handles.connecttype = [handles.connecttype; 'o'; 'x'];
                    end
                    
                    %% Update edit_zeroloc/edit_poleloc
                    tempvalue_zero = get(handles.listbox_zero,'value');
                    tempvalue_pole = get(handles.listbox_pole,'value');
                    list_str_zero = [num2str(real(handles.zeroloc(tempvalue_zero))) ' , ' num2str(imag(handles.zeroloc(tempvalue_zero)))];
                    list_str_pole = [num2str(real(handles.poleloc(tempvalue_pole))) ' , ' num2str(imag(handles.poleloc(tempvalue_pole)))];
                    set(handles.edit_zeroloc,'string',list_str_zero);
                    set(handles.edit_poleloc,'string',list_str_pole);
                    %%
                    handles = recal(handles, 'pole_to_poly');
                    handles = plot_gph(handles);
                    
                    handles.changed = 'on';
                    guidata(handles.figure_pez, handles);
                case 'alt'
                    tempx = real(1/(x+y*i));
                    tempy = imag(1/(x+y*i));
                    
                    if temppair
                        set(handles.listbox_zero,'String',...
                            strvcat(get(handles.listbox_zero,'String'),...
                            ['( ',num2str(x),', ',num2str(y),' )'],...
                            ['( ',num2str(x),', ',num2str(-y),' )']));
                        set(handles.listbox_pole,'String',...
                            strvcat(get(handles.listbox_pole,'String'),...
                            ['( ',num2str(tempx),', ',num2str(tempy),' )'],...
                            ['( ',num2str(tempx),', ',num2str(-tempy),' )']));
                        
                        handles.zeroloc = [handles.zeroloc, x+y*i, x-y*i];
                        handles.poleloc = [handles.poleloc, tempx+tempy*i, tempx-tempy*i];
                        
                        temp = length(handles.connecttype);
                        handles.connection = [handles.connection, zeros(temp,4); ...
                            zeros(1,temp), 1, 1, 1, 1; zeros(1,temp), 1, 1, 1, 1;...
                            zeros(1,temp), 1, 1, 1, 1; zeros(1,temp), 1, 1, 1, 1];
                        handles.connecttype = [handles.connecttype; 'o'; 'o'; 'x'; 'x'];
                    else
                        set(handles.listbox_zero,'String',...
                            strvcat(get(handles.listbox_zero,'String'),...
                            ['( ',num2str(x),', ',num2str(y),' )']));
                        set(handles.listbox_pole,'String',...
                            strvcat(get(handles.listbox_pole,'String'),...
                            ['( ',num2str(tempx),', ',num2str(-tempy),' )']));
                        
                        handles.zeroloc = [handles.zeroloc, x+y*i];
                        handles.poleloc = [handles.poleloc, tempx-tempy*i];
                        
                        temp = length(handles.connecttype);
                        handles.connection = [handles.connection, zeros(temp,2); ...
                            zeros(1,temp), 1, 1; zeros(1,temp), 1, 1];
                        handles.connecttype = [handles.connecttype; 'o'; 'x'];
                    end
                    
                    handles = recal(handles, 'pole_to_poly');
                    handles = plot_gph(handles);
                    
                    handles.changed = 'on';
                    guidata(handles.figure_pez, handles);
                otherwise
                    error('Error in Add Callback');
            end
        otherwise
            error(['Error in ' mfilename ' "getclickpt" : can not find appropriate method']);
    end
end
guidata(handles.figure_pez,handles);
% ================================================================== %
function varargout = resetclickpt(h,eventdata,handles,varargin)
% ================================================================== %
% check if zoom enabled
if get(handles.tb_zoomenable,'value')
    string = '';
    wbuf   = '';
else
    string = [mfilename, '(''WindowButtonMotion'', [],[],guidata(gcbo))'];
    wbuf   = [mfilename, '(''resetclickpt'',[],[],guidata(gcbo))'];
end

if handles.changed
    if handles.circular_motion
        set(handles.linerc,'visible','off');
    end
    if handles.radial_motion
        set(handles.linerr,'visible','off');
    end
end

if isempty(varargin)
    if strcmp(handles.repeatedadd,'off')
        if strcmp(get(findobj(gcbo, 'Label', 'Click Enable'),'Checked'), 'on')
            set(handles.axes_pzplot,'ButtonDownFcn',[mfilename,'(''startselected'',[],[],guidata(gcbo))']);
            set(handles.figure_pez,'WindowButtonUpFcn',[mfilename, '(''resetclickpt'', [],[],guidata(gcbo))'], ...
                'WindowButtonMotionFcn',string,'pointer','arrow');
        else
            set(handles.axes_pzplot,'ButtonDownFcn',[mfilename,'(''startdrag'',[],[],guidata(gcbo))']);
            set(handles.figure_pez,'pointer','arrow','WindowButtonMotionFcn',string); %'WindowButtonUpFcn',wbuf
            set([handles.selectedpole, handles.showplot_h.selectedpole],'XData',[],'YData',[]);
            set([handles.selectedzero, handles.showplot_h.selectedzero],'XData',[],'YData',[]);
        end
    elseif strcmp(handles.changed,'off')
        if strcmp(get(findobj(gcbo, 'Label', 'Click Enable'),'Checked'), 'on')
            set(handles.axes_pzplot,'ButtonDownFcn',[mfilename,'(''startselected'',[],[],guidata(gcbo))']);
            set(handles.figure_pez,'pointer','arrow','WindowButtonMotionFcn',string, ...
                'WindowButtonUpFcn',[mfilename, '(''resetclickpt'',[],[],guidata(gcbo))']);
        else
            set(handles.figure_pez,'WindowButtonMotionFcn',string,'pointer','arrow', ...
                'WindowButtonUpFcn',[mfilename, '(''resetclickpt'',[],[], guidata(gcbo))']);
            set(handles.axes_pzplot,'ButtonDownFcn',[mfilename, '(''startdrag'',[],[],guidata(gcbo))']);
            set([handles.selectedpole, handles.showplot_h.selectedpole],'XData',[],'YData',[]);
            set([handles.selectedzero, handles.showplot_h.selectedzero],'XData',[],'YData',[]);
        end
    end
else
    set(handles.showplot_h.figure_showplot,'WindowButtonMotionFcn',string);
    set(handles.showplot_h.axes_pzplot,'ButtonDownFcn',[mfilename, '(''startdrag'',[],[],guidata(gcbo),1)']);
    set(handles.figure_pez,'WindowButtonUpFcn',[mfilename, '(''resetclickpt'', [],[],guidata(gcbo),1)']);
    set([handles.selectedpole, handles.showplot_h.selectedpole,handles.selectedzero, handles.showplot_h.selectedzero],'XData',[],'YData',[]);
    set(handles.showplot_h.figure_showplot,'Pointer','arrow');
    guidata(handles.showplot_h.figure_showplot, handles);
end

handles.changed = 'off';
guidata(handles.figure_pez,handles);
% ================================================================== %
function WindowButtonMotion(h,eventdata,handles)
% ================================================================== %
% determines when pointer chnages from arrow to open-hand
% when over 'x' and/or 'o' objects
hax = [handles.axes_pzplot,handles.axes_mag,handles.axes_phase];

% Determine if cursor is over the pzplot, mag, or phase plot
old_units = get(hax,'units');
set(hax,'units','pixels');
[mouse_xy,fig_size] = mousepos;
pos = get(hax,'position');
set(hax,{'units'},old_units);

% Cursor over object axes flag
for u = 1:length(pos)
    over_axes_flg(u) = all([mouse_xy > pos{u}(1:2) mouse_xy < pos{u}(1:2)+pos{u}(3:4)]);
end

% --------------------------
if any(over_axes_flg) % over pzplot, mag, or phase plot
    hand_flag = 0;
    toll = 0.1;
    current_pt = get(hax(find(over_axes_flg)),'CurrentPoint');
    xpt = current_pt(1,1);
    ypt = current_pt(1,2);
    
    if over_axes_flg(1) % Over PZPLOT
        % CHECK FOR POLE(S)/ZERO(S)
        if ~(isempty(handles.zeroloc) & isempty(handles.poleloc))
            
            % Tollerance as a function of X-axis, here set to 3%
            xlim = get(handles.axes_pzplot,'xlim');
            toll = xlim(2)*0.03;
            
            n = length(handles.poleloc);
            m = length(handles.zeroloc);
            
            for p=1:n
                if (abs(xpt - real(handles.poleloc(p))) < toll) &  (abs(ypt-imag(handles.poleloc(p))) < toll)
                    hand_flag = 1;
                end
            end
            
            for z=1:m
                if (abs(xpt - real(handles.zeroloc(z))) < toll) &  (abs(ypt-imag(handles.zeroloc(z))) < toll)
                    hand_flag = 1;
                end
            end
        end
        % CHECK FOR RAY
        if strcmp(get(handles.ray,'checked'),'on')
            linedata      = get(handles.lineray.main,{'xdata','ydata'});
            theta_ray     = angle(linedata{1}(2)+i*linedata{2}(2));
            theta_pointer = angle(xpt+i*ypt);
            
            if (abs(theta_pointer - theta_ray) < toll) & (abs(xpt+i*ypt) <= 1)
                hand_flag = 1;
                %set(handles.axes_pzplot,'ButtonDownFcn',[mfilename, '(''startdrag'',[],[],guidata(gcbo))']);
            end
        end
    elseif any(over_axes_flg(2:3)) % Over MAG/PHASE PLOT
        % CHECK FOR RAY
        if strcmp(get(handles.ray,'checked'),'on')
            if over_axes_flg(2)
                lineXdata = get(handles.lineray.mag,'xdata');
            elseif over_axes_flg(3)
                lineXdata = get(handles.lineray.phase,'xdata');
            end
            if abs(xpt - lineXdata) < toll
                hand_flag = 1;
            end
        end
    end
    
    % Set pointer
    if hand_flag
        setptr(gcbf,'hand');
    else
        setptr(gcbf,'arrow');
    end
else
    setptr(gcbf,'arrow');
end
% ================================================================== %
function varargout = startdrag(h,eventdata,handles,varargin)
% ================================================================== %
if isempty(varargin)
    currentplot = handles.axes_pzplot;
    currentfig = handles.figure_pez;
else
    currentplot = handles.showplot_h.axes_pzplot;
    currentfig = handles.showplot_h.figure_showplot;
end

eval([mfilename '(''getcurrentpt'',currentplot,eventdata,handles,varargin)']);
currentpt = get(currentplot,'userdata');
clicktype = get(handles.figure_pez,'SelectionType');

if strcmp(clicktype,'normal')
    
    x = currentpt(1);
    y = currentpt(2);
    
    if handles.real_motion, y = 0; end
    if handles.circular_motion
        handles.circular_radius = sqrt(x*x+y*y);
        theta = atan2(y,x);
        x = handles.circular_radius*cos(theta);
        y = handles.circular_radius*sin(theta);
        set(handles.linerc,'xdata',handles.circular_radius*sin(0:2*pi/20:2*pi),'ydata',handles.circular_radius*cos(0:2*pi/20:2*pi),'visible','on');
    end
    if handles.radial_motion
        handles.radial_theta = atan2(y,x);
        r = sqrt(x*x+y*y);
        z = [cos(handles.radial_theta) sin(handles.radial_theta)];
        set(handles.linerr,'xdata',[0 2*z(1)],'ydata',[0 2*z(2)],'visible','on');
        x = r*z(1);
        y = r*z(2);
    end
    tol = 0.05;
    tempvalue = find( abs(real([handles.poleloc(1:length(handles.poleloc)),handles.zeroloc(1:length(handles.zeroloc))]) - x) <= tol ...
        & abs(imag([handles.poleloc(1:length(handles.poleloc)),handles.zeroloc(1:length(handles.zeroloc))]) - y) <= tol);
    
    if ~isempty(tempvalue)
        if tempvalue(1) > length(handles.poleloc)
            handles.tempvalue = tempvalue(1)-length(handles.poleloc);
            zerostring = find(handles.connecttype == 'o');
            polestring = find(handles.connecttype == 'x');
            
            
            tempconnect = find(handles.connection(zerostring(handles.tempvalue),:));
            tempzero = setdiff(intersect(zerostring,tempconnect),zerostring(handles.tempvalue));
            handles.outparm.zeroconnect = [];
            if ~isempty(tempzero)
                handles.outparm.zeroconnect = find(zerostring == sort(setdiff(intersect(zerostring,tempconnect),zerostring(handles.tempvalue))));
            end
            
            temppole = sort(intersect(polestring,tempconnect));
            poleconnect = [];
            if ~isempty(temppole)
                for i = 1:length(temppole)
                    poleconnect = [poleconnect, find(polestring == temppole(i))];
                end
            else
                poleconnect = [];
            end
            
            if isempty(poleconnect)
                if isempty(varargin)
                    set(currentfig,'WindowButtonMotionFcn',[mfilename, '(''movepez'', [],[],guidata(gcbo), ''zero'')']);
                else
                    set(currentfig,'WindowButtonMotionFcn',[mfilename, '(''movepez'', [],[],guidata(gcbo), ''zero'',1)']);
                end
            else
                tol = 0.01;
                handles.outparm.poleconnect = poleconnect;
                if abs(imag(1/handles.zeroloc(handles.tempvalue)) - imag(handles.poleloc(handles.outparm.poleconnect(1)))) < tol
                    handles.outparm.type = 1;
                else
                    handles.outparm.type = 0;
                end
                
                if isempty(varargin)
                    set(currentfig,'WindowButtonMotionFcn',[mfilename, '(''movepez'', [],[],guidata(gcbo), ''z_pez'')']);
                else
                    set(currentfig,'WindowButtonMotionFcn',[mfilename, '(''movepez'', [],[],guidata(gcbo), ''z_pez'',1)']);
                end
            end
        else
            handles.tempvalue = tempvalue(1);
            zerostring = find(handles.connecttype == 'o');
            polestring = find(handles.connecttype == 'x');
            
            tempconnect = find(handles.connection(polestring(handles.tempvalue),:));
            
            temppole = setdiff(intersect(polestring,tempconnect),polestring(handles.tempvalue));
            handles.outparm.poleconnect = [];
            if ~isempty(temppole)
                handles.outparm.poleconnect = find(polestring == sort(setdiff(intersect(polestring,tempconnect),polestring(handles.tempvalue))));
            end
            
            tempzero = sort(intersect(zerostring,tempconnect));
            zeroconnect = [];
            if ~isempty(tempzero)
                for i = 1:length(tempzero)
                    zeroconnect = [zeroconnect, find(zerostring == tempzero(i))];
                end
            else
                zeroconnect = [];
            end
            
            if isempty(zeroconnect)
                if isempty(varargin)
                    set(currentfig,'WindowButtonMotionFcn',[mfilename, '(''movepez'', [],[],guidata(gcbo), ''pole'')']);
                else
                    set(currentfig,'WindowButtonMotionFcn',[mfilename, '(''movepez'', [],[],guidata(gcbo), ''pole'',1)']);
                end
            else
                tol = 0.01;
                handles.outparm.zeroconnect = zeroconnect;
                if abs(imag(1/handles.poleloc(handles.tempvalue)) - imag(handles.zeroloc(handles.outparm.zeroconnect(1)))) < tol
                    handles.outparm.type = 1;
                else
                    handles.outparm.type = 0;
                end
                if isempty(varargin)
                    set(currentfig,'WindowButtonMotionFcn',[mfilename, '(''movepez'', [],[],guidata(gcbo), ''p_pez'')']);
                else
                    set(currentfig,'WindowButtonMotionFcn',[mfilename, '(''movepez'', [],[],guidata(gcbo), ''p_pez'',1)']);
                end
            end
        end
        guidata(currentfig, handles);
    end
end
% ================================================================== %
function varargout = startdrag_RAY(h,eventdata,handles,varargin)
% ================================================================== %
hax = [handles.axes_pzplot,handles.axes_mag,handles.axes_phase];
axes_idx = find(hax == get(gcbo,'parent'));
handles.current_axes = hax(axes_idx);
guidata(gcbf, handles);

set(handles.figure_pez,'WindowButtonMotionFcn',[mfilename,'(''move_RAY'',[],[],guidata(gcbo))'], ...
    'WindowButtonUpFcn',[mfilename,'(''resetclickpt'',[],[],guidata(gcbo))']);
% ================================================================== %
function varargout = move_RAY(h,eventdata,handles,varargin)
% ================================================================== %
setptr(handles.figure_pez,'closedhand');
currentplot = handles.current_axes;

eval([mfilename '(''getcurrentpt'',currentplot,eventdata,handles,varargin)']);
currentpt = get(currentplot,'userdata');

switch get(handles.current_axes,'tag')
    case 'axes_pzplot'
        theta = angle(currentpt(1)+i*currentpt(2));
    case {'axes_mag','axes_phase'}
        theta = currentpt(1);
end
set(handles.lineray.main ,'xdata',[0 cos(theta)],'ydata',[0 sin(theta)]);
set([handles.lineray.mag,handles.lineray.phase],'xdata',[theta theta]);

% degree string formating for degree text
if  round(20*theta)/20 == 0
    deg_str = '0';
elseif round(20*pi/abs(theta))/20 == 1
    deg_str = '1';
else
    deg_str = ['$$\frac{\pi}{' num2str(round(20*pi/abs(theta))/20) '}$$'];
end
if theta > 0
    sgn = '';
else
    sgn = '--';
end

xlim = max(get(handles.axes_pzplot,'xlim'));
ex = get(handles.lineray.text,'extent');

ofs = pi/4;
if xlim >= 1.5
    set(handles.lineray.text,'pos',1.3*[cos(theta) sin(theta)],'string',[sgn deg_str])
else
    set(handles.lineray.text,'pos',0.4*[cos(theta-ofs) sin(theta-ofs)],'string',[sgn deg_str])
end
% ================================================================== %
function varargout = movepez(h,eventdata,handles,varargin)
% ================================================================== %
if length(varargin) == 1
    currentfig = handles.figure_pez;
    currentplot = handles.axes_pzplot;
else
    currentfig = handles.showplot_h.figure_showplot;
    currentplot = handles.showplot_h.axes_pzplot;
end

setptr(currentfig,'closedhand');
eval([mfilename '(''getcurrentpt'',currentplot,eventdata,handles,varargin)']);
currentpt = get(currentplot,'userdata');
handles = guidata(currentfig);

x = currentpt(1);
y = currentpt(2);
if handles.real_motion, y = 0; end
if handles.circular_motion
    theta = atan2(y,x);
    x = handles.circular_radius*cos(theta);
    y = handles.circular_radius*sin(theta);
end
if handles.radial_motion
    r = sqrt(x*x+y*y);
    x = r*cos(handles.radial_theta);
    y = r*sin(handles.radial_theta);
end

% limit x,y to 5x5 region
if abs(x) > 5
    x = sign(x)*5;
elseif abs(y) > 5
    y = sign(x)*5;
end

switch varargin{1}
    %---%----------------------------------------%
    case 'pole'
        %----------------------------------------%
        if (x^2+y^2) ~= 1
            x = x + 10^-6;
        end
        
        tempvalue = handles.tempvalue;
        handles.poleloc(tempvalue) = x+y*i;
        
        tempstring = get(handles.listbox_pole,'String');
        tempstring = strvcat(tempstring(1:tempvalue-1,:),...
            ['( ',num2str(x),', ',num2str(y),' )'],...
            tempstring(tempvalue+1:end,:));
        
        set([handles.selectedpole, handles.showplot_h.selectedpole],'XData',x,'YData',y);
        set([handles.selectedzero, handles.showplot_h.selectedzero],'XData',[],'YData',[]);
        
        if ~isempty(handles.outparm.poleconnect)
            p1 = handles.outparm.poleconnect(1);
            handles.poleloc(p1) = x-y*i;
            tempstring = strvcat(tempstring(1:p1-1,:),['( ',num2str(x),', ',num2str(-y),' )'],...
                tempstring(p1+1:size(tempstring,1),:));
            set([handles.selectedpole, handles.showplot_h.selectedpole],'XData',[x,x],'YData',[y,-y]);
        end
        set(handles.listbox_pole,'String',tempstring);
        
        %% Update edit_poleloc
        tempvalue = get(handles.listbox_pole,'value');
        list_str = [num2str(real(handles.poleloc(tempvalue))) ' , ' num2str(imag(handles.poleloc(tempvalue)))];
        set(handles.edit_poleloc,'string',list_str);
        %----------------------------------------%
    case 'zero'
        %----------------------------------------%
        tempvalue = handles.tempvalue;
        handles.zeroloc(tempvalue) = x+y*i;
        
        tempstring = get(handles.listbox_zero,'String');
        tempstring = strvcat(tempstring(1:tempvalue-1,:),...
            ['( ',num2str(x),', ',num2str(y),' )'],...
            tempstring(tempvalue+1:size(tempstring,1),:));
        
        set([handles.selectedzero, handles.showplot_h.selectedzero],'XData',x,'YData',y);
        set([handles.selectedpole, handles.showplot_h.selectedpole],'XData',[],'YData',[]);
        
        if ~isempty(handles.outparm.zeroconnect)
            z1 = handles.outparm.zeroconnect(1);
            handles.zeroloc(z1) = x-y*i;
            tempstring = strvcat(tempstring(1:z1-1,:),...
                ['( ',num2str(x),', ',num2str(-y),' )'],...
                tempstring(z1+1:size(tempstring,1),:));
            set([handles.selectedzero, handles.showplot_h.selectedzero],'XData',[x,x],'YData',[y,-y]);
        end
        
        set(handles.listbox_zero,'String',tempstring);
        
        %% Update edit_poleloc
        tempvalue = get(handles.listbox_zero,'value');
        list_str = [num2str(real(handles.zeroloc(tempvalue))) ' , ' num2str(imag(handles.zeroloc(tempvalue)))];
        set(handles.edit_zeroloc,'string',list_str);
        %----------------------------------------%
    case 'z_pez'
        %----------------------------------------%
        if (x^2+y^2) ~= 1
            x = x + 10^-6;   %y = y + 10^-6;
        end
        
        tempx = real(1/(x+y*i));
        tempy = imag(1/(x+y*i));
        
        tempvalue = handles.tempvalue;
        handles.zeroloc(tempvalue) = x+y*i;
        
        tempstring = get(handles.listbox_zero,'String');
        tempstring = strvcat(tempstring(1:tempvalue-1,:),...
            ['( ',num2str(x),', ',num2str(y),' )'],...
            tempstring(tempvalue+1:size(tempstring,1),:));
        
        set([handles.selectedzero, handles.showplot_h.selectedzero],'XData',x,'YData',y);
        
        if ~isempty(handles.outparm.zeroconnect)
            z1 = handles.outparm.zeroconnect(1);
            handles.zeroloc(z1) = x-y*i;
            tempstring = strvcat(tempstring(1:z1-1,:),...
                ['( ',num2str(x),', ',num2str(y),' )'],...
                tempstring(z1+1:size(tempstring,1),:));
            set([handles.selectedzero, handles.showplot_h.selectedzero],'XData',[x,x],'YData',[y,-y]);
        end
        set(handles.listbox_zero,'String',tempstring);
        
        tempstring = get(handles.listbox_pole,'String');
        if (handles.outparm.type == 1)
            p1 = handles.outparm.poleconnect(1);
            handles.poleloc(p1) = tempx+tempy*i;
            tempstring = strvcat(tempstring(1:p1-1,:),...
                ['( ',num2str(tempx),', ',num2str(tempy),' )'],...
                tempstring(p1+1:size(tempstring,1),:));
            
            set([handles.selectedpole, handles.showplot_h.selectedpole],'XData',tempx,'YData',tempy);
            
            if length(handles.outparm.poleconnect)>1
                p2 = handles.outparm.poleconnect(2);
                handles.poleloc(p2) = tempx-tempy*i;
                tempstring = strvcat(tempstring(1:p2-1,:),...
                    ['( ',num2str(tempx),', ',num2str(-tempy),' )'],...
                    tempstring(p2+1:size(tempstring,1),:));
                set([handles.selectedpole, handles.showplot_h.selectedpole],'XData',[tempx,tempx],'YData',[tempy,-tempy]);
            end
        else
            p1 = handles.outparm.poleconnect(1);
            handles.poleloc(p1) = tempx-tempy*i;
            tempstring = strvcat(tempstring(1:p1-1,:),...
                ['( ',num2str(tempx),', ',num2str(-tempy),' )'],...
                tempstring(p1+1:size(tempstring,1),:));
            
            set([handles.selectedpole, handles.showplot_h.selectedpole],'XData',tempx,'YData',-tempy);
            
            if length(handles.outparm.poleconnect)>1
                p2 = handles.outparm.poleconnect(2);
                handles.poleloc(p2) = tempx+tempy*i;
                tempstring = strvcat(tempstring(1:p2-1,:),...
                    ['( ',num2str(tempx),', ',num2str(tempy),' )'],...
                    tempstring(p2+1:size(tempstring,1),:));
                
                set([handles.selectedpole, handles.showplot_h.selectedpole],'XData',[tempx,tempx],'YData',[tempy,-tempy]);
            end
        end
        set(handles.listbox_pole,'String',tempstring);
        %----------------------------------------%
    case 'p_pez'
        %----------------------------------------%
        if (x^2+y^2) ~= 1
            x = x + 10^-6;   %y = y + 10^-6;
        end
        
        tempx = real(1/(x+y*i));
        tempy = imag(1/(x+y*i));
        
        tempvalue = handles.tempvalue;
        handles.poleloc(tempvalue) = x+y*i;
        
        tempstring = get(handles.listbox_pole,'String');
        tempstring = strvcat(tempstring(1:tempvalue-1,:),...
            ['( ',num2str(x),', ',num2str(y),' )'],...
            tempstring(tempvalue+1:size(tempstring,1),:));
        
        set([handles.selectedpole, handles.showplot_h.selectedpole],'XData',x,'YData',y);
        
        if ~isempty(handles.outparm.poleconnect)
            p1 = handles.outparm.poleconnect(1);
            handles.poleloc(p1) = x-y*i;
            tempstring = strvcat(tempstring(1:p1-1,:),...
                ['( ',num2str(x),', ',num2str(-y),' )'],...
                tempstring(p1+1:size(tempstring,1),:));
            set([handles.selectedpole, handles.showplot_h.selectedpole],'XData',[x,x],'YData',[y,-y]);
        end
        set(handles.listbox_pole,'String',tempstring);
        
        tempstring = get(handles.listbox_zero,'String');
        if (handles.outparm.type == 1)
            z1 = handles.outparm.zeroconnect(1);
            handles.zeroloc(z1) = tempx+tempy*i;
            tempstring = strvcat(tempstring(1:z1-1,:),...
                ['( ',num2str(tempx),', ',num2str(tempy),' )'],...
                tempstring(z1+1:size(tempstring,1),:));
            
            set([handles.selectedzero, handles.showplot_h.selectedzero],'XData',tempx,'YData',tempy);
            
            if length(handles.outparm.zeroconnect)>1
                z2 = handles.outparm.zeroconnect(2);
                handles.zeroloc(z2) = tempx-tempy*i;
                tempstring = strvcat(tempstring(1:z2-1,:),...
                    ['( ',num2str(tempx),', ',num2str(-tempy),' )'],...
                    tempstring(z2+1:size(tempstring,1),:));
                set([handles.selectedzero, handles.showplot_h.selectedzero],'XData',[tempx,tempx],'YData',[tempy,-tempy]);
            end
        else
            z1 = handles.outparm.zeroconnect(1);
            handles.zeroloc(z1) = tempx-tempy*i;
            tempstring = strvcat(tempstring(1:z1-1,:),...
                ['( ',num2str(tempx),', ',num2str(-tempy),' )'],...
                tempstring(z1+1:size(tempstring,1),:));
            
            set([handles.selectedzero, handles.showplot_h.selectedzero],'XData',tempx,'YData',-tempy);
            
            if length(handles.outparm.zeroconnect)>1
                z2 = handles.outparm.zeroconnect(2);
                handles.zeroloc(z2) = tempx+tempy*i;
                tempstring = strvcat(tempstring(1:z2-1,:),...
                    ['( ',num2str(tempx),', ',num2str(tempy),' )'],...
                    tempstring(z2+1:size(tempstring,1),:));
                
                set([handles.selectedzero, handles.showplot_h.selectedzero],'XData',[tempx,tempx],'YData',[tempy,-tempy]);
            end
        end
        
        set(handles.listbox_zero,'String',tempstring);
        %----------------------------------------%
    otherwise
        %----------------------------------------%
        error('Error in Movepez Callback');
end
handles = recal(handles, 'pole_to_poly');
handles = plot_gph(handles);

guidata(currentfig, handles);
drawnow;
% ================================================================== %
function varargout = startselected(h,eventdata,handles, varargin)
% ================================================================== %
currentpt = get(handles.axes_pzplot,'CurrentPoint');
clicktype = get(handles.figure_pez,'SelectionType');
if strcmp(clicktype,'normal')
    x = currentpt(1,1);
    y = currentpt(1,2);
    tol = 0.05;
    
    tempvalue = find( abs(real([handles.poleloc(1:length(handles.poleloc)),handles.zeroloc(1:length(handles.zeroloc))]) - x) <= tol ...
        & abs(imag([handles.poleloc(1:length(handles.poleloc)),handles.zeroloc(1:length(handles.zeroloc))]) - y) <= tol);
    
    if ~isempty(tempvalue)
        if tempvalue(1) > length(handles.poleloc)
            handles.tempvalue = tempvalue(1)-length(handles.poleloc);
            zerostring = find(handles.connecttype == 'o');
            polestring = find(handles.connecttype == 'x');
            
            
            tempconnect = find(handles.connection(zerostring(handles.tempvalue),:));
            tempzero = setdiff(intersect(zerostring,tempconnect),zerostring(handles.tempvalue));
            zeroconnect = [];
            if ~isempty(tempzero)
                zeroconnect = find(zerostring == sort(setdiff(intersect(zerostring,tempconnect),zerostring(handles.tempvalue))));
            end
            
            temppole = sort(intersect(polestring,tempconnect));
            poleconnect = [];
            if ~isempty(temppole)
                for i = 1:length(temppole)
                    poleconnect = [poleconnect, find(polestring == temppole(i))];
                end
            else
                poleconnect = [];
            end
            
            set([handles.selectedpole, handles.showplot_h.selectedpole],...
                'XData',real(handles.poleloc(poleconnect)),...
                'YData',imag(handles.poleloc(poleconnect)));
            set([handles.selectedzero, handles.showplot_h.selectedzero],...
                'XData',real(handles.zeroloc([handles.tempvalue, zeroconnect])),...
                'YData',imag(handles.zeroloc([handles.tempvalue, zeroconnect])));
            handles.tempvalue = tempvalue(1);
        else
            handles.tempvalue = tempvalue;
            zerostring = find(handles.connecttype == 'o');
            polestring = find(handles.connecttype == 'x');
            
            tempconnect = find(handles.connection(polestring(tempvalue),:));
            
            temppole = setdiff(intersect(polestring,tempconnect),polestring(tempvalue));
            poleconnect = [];
            if ~isempty(temppole)
                poleconnect = find(polestring == sort(setdiff(intersect(polestring,tempconnect),polestring(tempvalue))));
            end
            
            tempzero = sort(intersect(zerostring,tempconnect));
            zeroconnect = [];
            if ~isempty(tempzero)
                for i = 1:length(tempzero)
                    zeroconnect = [zeroconnect, find(zerostring == tempzero(i))];
                end
            else
                zeroconnect = [];
            end
            
            set([handles.selectedpole, handles.showplot_h.selectedpole],...
                'XData',real(handles.poleloc([tempvalue, poleconnect])),...
                'YData',imag(handles.poleloc([tempvalue, poleconnect])));
            set([handles.selectedzero, handles.showplot_h.selectedzero],...
                'XData',real(handles.zeroloc(zeroconnect)),...
                'YData',imag(handles.zeroloc(zeroconnect)));
        end
        guidata(handles.figure_pez, handles);
    end
end
% ================================================================== %
function varargout = cbgrid_Callback(h, eventdata, handles, varargin)
% ================================================================== %
% Stub for Callback of the uicontrol handles.checkbox1.
if get(h,'Value') == 1
    set([handles.axes_mag, handles.axes_phase, handles.showplot_h.axes_mag, handles.showplot_h.axes_phase], 'XGrid','on','YGrid','on');
else
    set([handles.axes_mag, handles.axes_phase, handles.showplot_h.axes_mag, handles.showplot_h.axes_phase], 'XGrid','off','YGrid','off');
end
% ================================================================== %
function varargout = menu_AddConjugate_Callback(h, eventdata, handles, varargin)
% ================================================================== %
hawc = findall(0,'tag','Add with Conjugate');
if strcmp(get(hawc,'checked'),'off')
    set(hawc,'checked','on');
else
    set(hawc,'checked','off');
end

if strcmp(get(h, 'tag'), 'Add with Conjugate')
    if get(findall(0,'tag','tb_addconjugate'), 'Value') == 1;
        set(findall(0,'tag','tb_addconjugate'), 'Value', 0);
    else
        set(findall(0,'tag','tb_addconjugate'), 'Value', 1);
    end
end
% ================================================================== %
function varargout = menu_Help_Callback(h,eventdata,handles,varargin)
% ================================================================== %
MATLABVER = versioncheck(6);
hBar = waitbar(0.25,'Opening internet browser...','color',get(handles.figure_pez,'color'));
DefPath = which(mfilename);
DefPath = ['file:///' strrep(DefPath,filesep,'/') ];
URL = [ DefPath(1:end-(length(mfilename)+2)) , 'help/','index.html'];
if MATLABVER >= 6
    STAT = web(URL,'-browser');
else
    STAT = web(URL);
end
waitbar(1);
close(hBar);
switch STAT
    case {1,2}
        s = {'Either your internet browser could not be launched or' , ...
            'it was unable to load the help page.  Please use your' , ...
            'browser to read the file:' , ...
            ' ', '     index.html', ' ', ...
            'which is located in the pezdemo help directory.'};
        errordlg(s,'Error launching browser.');
end
% ================================================================== %
function figure_pez_ResizeFcn(hObject,eventdata, handles)
% ================================================================== %
old_units = get(handles.figure_pez,'units');
set(handles.figure_pez,'units','pixels');
fig_pos = get(handles.figure_pez,'pos');
set(handles.figure_pez,'units',old_units);

if isunix
    fs_offset = 6;
else
    fs_offset = 0;
end
set(handles.formula_text,'fontsize',fs_offset+round(0.025*fig_pos(4)-4.65));

%--- Track Zoom buttons Position ---%
fp    = get(handles.figure_pez,'pos');
apos  = get(handles.axes_pzplot,'position');
aopos = get(handles.axes_pzplot,'outerposition');
ss    = get(0,'screensize');
zpos  = get(handles.zoomin,'position');
%tipos = get(handles.axes_pzplot,'tight');

beta  = apos(3)/fp(3);
alpha = apos(3)/fp(4);
delta = (ss(3)*fp(3))/(ss(4)*fp(4));
bb    = apos(4)/delta;
hh    = delta*apos(3);

if bb <= hh
    m = (aopos(3)-bb)/2;
    %set(handles.sliderL,'pos',[m apos(2) bb apos(4)],'vis','on');
    set(handles.zoomout,'pos',[1.01*(m+bb) apos(2)+apos(4)-zpos(4) zpos(3) zpos(4)]);
    set(handles.zoomin ,'pos',[1.01*(m+bb) apos(2)+apos(4)-2*zpos(4) zpos(3) zpos(4)]);
else
    m = (2*aopos(2)+aopos(4)-hh)/2;
    %set(handles.sliderL,'pos',[apos(1) m apos(3) hh],'vis','on');
    set(handles.zoomout,'pos',[1.01*(apos(1)+apos(3)) m+hh-zpos(4) zpos(3) zpos(4)]);
    set(handles.zoomin,'pos',[1.01*(apos(1)+apos(3)) m+hh-2*zpos(4) zpos(3) zpos(4)]);
end
% ================================================================== %
function varargout = zoombuttons_Callback(h,eventdata,handles, varargin)
% ================================================================== %
xlim = max(get(handles.axes_pzplot,'xlim'));
val = eval([num2str(xlim) get(h,'string') num2str(0.225)]);
if val > 5
    val = 5;
elseif val < 0.5
    val = 0.5;
end
update_axis_limit_check(h,eventdata,handles,val);
% ================================================================== %
function varargout = slider_Callback(h,eventdata,handles, varargin)
% ================================================================== %
val = get(handles.slider,'Value');
update_axis_limit_check(h,eventdata,handles,val);
% ================================================================== %
function varargout = axis_limit_check(h,eventdata,handles,varargin)
% ================================================================== %
distant = max(abs( [real(handles.poleloc) real(handles.zeroloc) imag(handles.poleloc) imag(handles.zeroloc)]));
xlim = get(handles.axes_pzplot,'xlim');

if distant > 5
    val = 5;
elseif (distant + 0.2) >= xlim(2)
    if (distant + 0.2) < 5
        val = distant + 0.2;
    else
        val = 5;
    end
else
    if (distant + 0.2) >= 1.5
        val = distant + 0.2;
    else
        val = 1.5;
    end
end

set(handles.slider,'Value',val);
update_axis_limit_check(h,eventdata,handles,val);
% ================================================================== %
function varargout = update_axis_limit_check(h,eventdata,handles,varargin)
% ================================================================== %
val = [-varargin{1} varargin{1}];
set(handles.axes_pzplot,'xlim',val,'ylim',val);
set(handles.showplot_h.axes_pzplot,'xlim',val,'ylim',val);

% adjust size of 'x' and/or 'o' linearly y=mx+b
marker_size = -(8/9)*val(2)+(94/9);
set([handles.linepezpole,handles.linepezzero],'MarkerSize',marker_size);
set([handles.showplot_h.linepezpole,handles.showplot_h.linepezzero],'MarkerSize',marker_size);

% adjust ray's text position (if < 1, then place text in UC)
linedata = get(handles.lineray.main,{'xdata','ydata'});
theta = angle(linedata{1}(2)+i*linedata{2}(2));
if varargin{1} < 1.5
    ofs = pi/4;
    set(handles.lineray.text,'pos',0.4*[cos(theta-ofs) sin(theta-ofs)])
else
    set(handles.lineray.text,'pos',1.3*[cos(theta) sin(theta)])
end
% ================================================================== %
function handles = check_connection(h,eventdata,handles,varargin)
% ================================================================== %
% This function links poles/zeros when importing
% Updates variables: handles.connection, handles.connecttype
ep = 1e4;   % precision epsilon

zeros = handles.zeroloc';
poles = handles.poleloc';

pL = length(poles);
zL = length(zeros);
handles.connection = eye(pL+zL,pL+zL);

% set up handles.connecttype
handles.connecttype = [];

for k=1:pL
    handles.connecttype = [handles.connecttype;'x'];
end
for k = pL+1:pL+zL
    handles.connecttype = [handles.connecttype;'o'];
end

% set up handles.conneciton
if ~isempty(poles)
    for ii = 1:pL
        conjp = find( round( ep*poles)/ep == conj( round(ep*poles(ii))/ep) );
        
        if ~isempty(conjp)
            handles.connection(ii,conjp) = 1;
            polezero1 = find(round(ep*zeros)/ep == round(ep*real(1/poles(ii)))/ep + round(ep*imag(1/poles(ii))*i)/ep);
            polezero2 = find(round(ep*zeros)/ep == round(ep*real(1/poles(ii)))/ep - round(ep*imag(1/poles(ii))*i)/ep);
            
            if ~isempty(polezero1)
                handles.connection(ii,pL+polezero1) = 1;
                handles.connection(ii,pL+polezero2) = 1;
            end
        end
    end
end

% Find conjugate zero-pairs
if ~isempty(zeros)
    for ii = pL+1:pL+zL
        conjz = find( round( ep*zeros)/ep == conj( round(ep*zeros(ii-pL))/ep) );
        if ~isempty(conjz)
            handles.connection(ii,conjz+pL) = 1;
        end
    end
end
guidata(handles.figure_pez, handles);
% ================================================================== %
function varargout = getcurrentpt(h,eventdata,handles,varargin)
% ================================================================== %
currentpt = get(h,'currentpoint');
currentpt = [currentpt(1,1) currentpt(1,2)];
clicktype = get(handles.figure_pez,'SelectionType');

if strcmp(clicktype,'normal')
    set(h,'userdata',currentpt);
else
    set(h,'userdata',[]);
end
% ================================================================== %
function menu_ray_Callback(hObject, eventdata, handles)
% ================================================================== %
if strcmp(get(handles.ray,'checked'),'off')
    set(handles.ray,'checked','on');
    set(handles.checkboxRAY,'value',1);
    set(handles.lineray.main,'ButtonDownFcn',[mfilename,'(''startdrag_RAY'',[],[],guidata(gcbo))']);
    set(handles.figure_pez,'WindowButtonMotionFcn',[mfilename,'(''WindowButtonMotion'',[],[],guidata(gcbo))']);
    set([handles.lineray.main,handles.lineray.mag ,handles.lineray.phase,handles.lineray.text],'vis','on');
else
    set(handles.ray,'checked','off');
    set(handles.checkboxRAY,'value',0);
    set([handles.lineray.main,handles.lineray.mag,handles.lineray.phase,handles.lineray.text],'vis','off');
end
guidata(handles.figure_pez, handles);
% ================================================================== %
function EBpole_Callback(hObject, eventdata, handles)
% ================================================================== %
% ================================================================== %
function EBzero_Callback(hObject, eventdata, handles)
% ================================================================== %
% ================================================================== %
function listbox_pole_Callback(hObject, eventdata, handles)
% ================================================================== %
if ~isempty(get(hObject,'string'))
    tempvalue = get(hObject,'value');
    list_str = [num2str(real(handles.poleloc(tempvalue))) ' ',' ' num2str(imag(handles.poleloc(tempvalue)))];
    set(handles.edit_poleloc,'string',list_str);
end
% ================================================================== %
function listbox_zero_Callback(hObject, eventdata, handles)
% ================================================================== %
if ~isempty(get(hObject,'string'))
    tempvalue = get(hObject,'value');
    list_str = [num2str(real(handles.zeroloc(tempvalue))) ' ', ' ' num2str(imag(handles.zeroloc(tempvalue)))];
    set(handles.edit_zeroloc,'string',list_str);
end
% ================================================================== %
function answer = getXY(h,eventdata,handles,varargin)
% ================================================================== %
% Format string: x = real, y = imag part of pole(s)/zero(s)
% answer = [x y];
if nargin == 5
    str = varargin{2};
    answer = str2num(str);
    
    if isempty(answer) & ~isempty(str)
        answer = eval(str);
    end
    
    [r,c] = size(answer);
    if c == 1
        for k = 1:r
            answer(k,2) = imag(answer(k,c));
            answer(k,1) = real(answer(k,c));
        end
    end
    
    if ~isempty(answer)
        % if pole(s)/zero(s) = 0, delete
        answer(find(sum(abs(answer)') == 0),:) = [];
        
        if any(strcmp(varargin{2},{'edit_pole';'edit_zero'}))
            if ~isempty(answer)
                answer = answer(1,:);
            end
        end
        
        % Prevent eps
        tol = 1e-5;
        answer(find(abs(answer) < tol)) = 0;
    end
end
% ================================================================== %
function answer = DoNothing(h,eventdata,handles,varargin)
% ================================================================== %
% This function does nothing -  it has been consturcted for movie-making
% purposes.  Please see pre_callbackAction.m.