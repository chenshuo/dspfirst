function varargout = filterdesign(varargin)
% FILTERDESIGN Application M-file for filterdesign.fig
%    FIG = FILTERDESIGN launch filterdesign GUI.
%    FILTERDESIGN('callback_name', ...) invoke the named callback.
spfirstVer =  'Revision: 2.86, Oct-27-2017';
% --------------------------------------------------------------------
if nargin == 0  % LAUNCH GUI
    %---  Check the installation, the Matlab Version, and the Screen Size
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

    fig = openfig(mfilename,'new','invisible');
    eval(cmdCheck5,errCmd);       % check system display

    configresize(fig);            % Change all 'units'/'font units' to normalized
    % Re-center and normalize figure
    % Assume that all figure objects are in "pixels" units
    op = get(fig,'pos');
    ss = get(0,'ScreenSize');
    set(fig,'pos',[(ss(3)-op(3))/2 (ss(4)-op(4))/2 op(3) op(4)]);
    set(findobj(fig,'units','pixels'),'units','norm');

    % Generate a structure of handles to pass to callbacks, and store it.
    handles = guihandles(fig);

    handles.LineWidth = get(0,'defaultLineLineWidth');	% storing default Line Width
    handles.fontname = get(handles.Plot1,'fontname');
    handles.KaiserR = '';                           	% Rpass or Rstop indicator for Kaiser plotting
    
    ver = version;
    handles.MATLABVER =str2double(ver(1:3));
    
    % Suppress warnings:
    warning off MATLAB:nearlySingularMatrix;
    warning off MATLAB:divideByZero;
    warning('off','MATLAB:logofzero');      % does not work, need a substitute
    
    % Bug fix
    set(findobj(handles.figure1,'tag','menu_exit'),'callback','filterdesign(''menu_exit_Callback'',gcbo,[],guidata(gcbo))');
    % --------------------------------------------------------------------
    % INITIALIZE GUI - Set Default Plot
    % --------------------------------------------------------------------
    mvup = 0.02;
    pos  = get(handles.Plot1,'pos');
    posT = get(handles.PlotTitle,'pos');
    set(handles.PlotTitle,'pos',[posT(1)-0.05 posT(2)+mvup posT(3)+0.1 posT(4)],'fontsize',0.8);
    % Specify default filter type
    handles.filt_type = 'FIR';
    set(handles.Filter,'value',1);          % plot FIR filter

    handles.filt_name = 'Lowpass';
    handles.design_name = 'Window';

    % Specify default window name
    handles.win_name = 'Hamming';
    set(handles.WindowsMenu,'value',4);     % plot Hamming window
    
    % Fix figure properties:
    set(handles.Plot1,'nextplot','replacechildren','box','on','UIContextMenu',[],'pos',pos+[0 mvup 0 0]);
    set(get(handles.Plot1,'Xlabel'),'Units','normalized','position',[0.5 -0.1],'string','Frequency (Hz)','ButtonDownFcn',[ mfilename '(''menu_x_scale_Callback'',gcbo,[],guidata(gcbo))']);
    set(get(handles.Plot1,'Ylabel'),'Units','normalized','position',[-0.1 0.5],'string','Magnitude','ButtonDownFcn',[ mfilename '(''menu_y_scale_Callback'',gcbo,[],guidata(gcbo))']);

    % Set Line properties
    handles.Line1a = line('parent',handles.Plot1,'ButtonDownFcn',[ mfilename ' LineDragStart'],'Color','r','tag','Line1a');
    handles.Line1b = line('parent',handles.Plot1,'ButtonDownFcn',[ mfilename ' LineDragStart'],'Color','r','tag','Line1b');
    handles.Line3  = line('parent',handles.Plot1,'ButtonDownFcn',[ mfilename ' LineDragStart'],'Color','r','tag','Line3');

    handles.Line2  = line('parent',handles.Plot1,'xdata',[0 0],'ydata',[0 1],'ButtonDownFcn',[ mfilename ' LineDragStart'],'Color','r','tag','Line2','vis','off');
    handles.Line4a = line('parent',handles.Plot1,'xdata',[0 0],'ydata',[0 1],'ButtonDownFcn',[ mfilename ' LineDragStart'],'Color','r','tag','Line4a','vis','off');
    handles.Line4b = line('parent',handles.Plot1,'xdata',[0 0],'ydata',[0 1],'ButtonDownFcn',[ mfilename ' LineDragStart'],'Color','r','tag','Line4b','vis','off');
    handles.Line5a = line('parent',handles.Plot1,'xdata',[0 0],'ydata',[0 1],'ButtonDownFcn',[ mfilename ' LineDragStart'],'Color','r','tag','Line5a','vis','off');
    handles.Line5b = line('parent',handles.Plot1,'xdata',[0 0],'ydata',[0 1],'ButtonDownFcn',[ mfilename ' LineDragStart'],'Color','r','tag','Line5b','vis','off');
    handles.Line6  = line('parent',handles.Plot1,'xdata',[0 0],'ydata',[0 1],'ButtonDownFcn',[ mfilename ' LineDragStart'],'Color','r','tag','Line6','vis','off');
    handles.LineNs = [handles.Line1a,handles.Line1b,handles.Line2,handles.Line3,handles.Line4a,handles.Line4b,handles.Line5a,handles.Line5b,handles.Line6];

    handles.LineCirc   = line('parent',handles.Plot1,'xdata',cos(0:0.01:2*pi),'ydata',sin(0:0.01:2*pi),'linestyle',':','vis','off','color','k');
    handles.HorzLine   = line('parent',handles.Plot1,'xdata',[0 0],'ydata',[0 0],'vis','off','linestyle',':','color','k');
    handles.VertLine   = line('parent',handles.Plot1,'xdata',[0 0],'ydata',[0 0],'vis','off','linestyle',':','color','k');
    handles.PoleLine   = line('parent',handles.Plot1,'xdata',0,'ydata',0,'vis','off','marker','x','markersize',12,'color','b','linewidth',1.5,'linestyle','none');
    handles.WindowLine = line('parent',handles.Plot1,'xdata',[0 0],'ydata',[0 0],'vis','off','linestyle',':');

    handles.RemezHorz1  = line('parent',handles.Plot1,'xdata',[0 0],'ydata',[0 0],'vis','off','linestyle','--');
    handles.RemezHorz2  = line('parent',handles.Plot1,'xdata',[0 0],'ydata',[0 0],'vis','off','linestyle','--');
    handles.RemezHorz3  = line('parent',handles.Plot1,'xdata',[0 0],'ydata',[0 0],'vis','off','linestyle','--');
    handles.RemezExtre1 = line('parent',handles.Plot1,'xdata',[0 0],'ydata',[0 0],'vis','off','linestyle','none','marker','x','color','k','markersize',12,'linewidth',2);
    handles.RemezExtre2 = line('parent',handles.Plot1,'xdata',[0 0],'ydata',[0 0],'vis','off','linestyle','none','linewidth',1,'marker','o','color','r','linewidth',2);
    
    if handles.MATLABVER < 8.4
        set(handles.LineNs,'EraseMode','Xor');
    end
    
    %%%----
    fsz = 0.044;
    handles.DesMethod = text('parent',handles.ref,'pos',[0.6 1  0],'fontunits','norm','fontsize',fsz,'str','Design Method');
    handles.FsampTag  = text('parent',handles.ref,'pos',[0 0.74 0],'fontunits','norm','fontsize',fsz,'str','F_{samp}');
    handles.Fpass1Tag = text('parent',handles.ref,'pos',[0 0.65 0],'fontunits','norm','fontsize',fsz,'str','F_{pass}');
    handles.Fstop1Tag = text('parent',handles.ref,'pos',[0 0.57 0],'fontunits','norm','fontsize',fsz,'str','F_{stop}','vis','off');
    handles.Fpass2Tag = text('parent',handles.ref,'pos',[0 0.47 0],'fontunits','norm','fontsize',fsz,'str','F_{pass 2}','vis','off');
    handles.Fstop2Tag = text('parent',handles.ref,'pos',[0 0.38 0],'fontunits','norm','fontsize',fsz,'str','F_{stop2}','vis','off');
    handles.RpassTag  = text('parent',handles.ref,'pos',[0 0.26 0],'fontunits','norm','fontsize',fsz,'str','\delta_{pass}','vis','off');
    handles.RstopTag  = text('parent',handles.ref,'pos',[0 0.17 0],'fontunits','norm','fontsize',fsz,'str','\delta_{stop}','vis','off');
    handles.OrderTag  = text('parent',handles.ref,'pos',[0 0    0],'fontunits','norm','fontsize',fsz,'str','Order');
    handles.Windows   = text('parent',handles.ref,'pos',[-0.1 -0.1 0],'fontunits','norm','fontsize',fsz,'str','Window');
    handles.KaiserB   = text('parent',handles.ref,'pos',[0.5 -0.2  0],'fontunits','norm','fontsize',fsz,'vis','off');

    handles.wFpass1Tag = text('parent',handles.ref,'units','data','interpreter','latex','str','$$\widehat{\omega}$$','pos',[0 0.65 0],'vis','off');
    handles.wFstop1Tag = text('parent',handles.ref,'units','data','interpreter','latex','str','$$\widehat{\omega}$$','pos',[0 0.57 0],'vis','off');
    handles.wFpass2Tag = text('parent',handles.ref,'units','data','interpreter','latex','str','$$\widehat{\omega}$$','pos',[0 0.47 0],'vis','off');
    handles.wFstop2Tag = text('parent',handles.ref,'units','data','interpreter','latex','str','$$\widehat{\omega}$$','pos',[0 0.38 0],'vis','off');
    %%%----
    % Transform unicontrol to text, since Symbol font is no longer
    % supported
    if handles.MATLABVER > 8.4
        handles.refUnits = axes('parent',handles.figure1,'units','normalized','pos',[0 0.05 1 0.95],'vis','off');
        set([handles.unitsFsamp,handles.unitsFpass1,handles.unitsFstop1,handles.unitsFpass2,handles.unitsFstop2,handles.unitsRpass,handles.unitsRstop],'vis','off');
        
        unitsFsamp_pos  = get(handles.unitsFsamp,'position');
        unitsFpass1_pos = get(handles.unitsFpass1,'position');
        unitsFstop1_pos = get(handles.unitsFstop1,'position');
        unitsFpass2_pos = get(handles.unitsFpass2,'position');
        unitsFstop2_pos = get(handles.unitsFstop2,'position');
        unitsRpass_pos  = get(handles.unitsRpass,'position');
        unitsRstop_pos  = get(handles.unitsRstop,'position');
        
        handles.unitsFsamp  = text('parent',handles.refUnits,'pos',[unitsFsamp_pos(1) unitsFsamp_pos(2)],'fontunits','norm','str',get(handles.unitsFsamp,'str'));
        handles.unitsFpass1 = text('parent',handles.refUnits,'pos',[unitsFpass1_pos(1) unitsFpass1_pos(2)],'fontunits','norm','str',get(handles.unitsFpass1,'str'));
        handles.unitsFstop1 = text('parent',handles.refUnits,'pos',[unitsFstop1_pos(1) unitsFstop1_pos(2)],'fontunits','norm','str',get(handles.unitsFstop1,'str'));
        handles.unitsFpass2 = text('parent',handles.refUnits,'pos',[unitsFpass2_pos(1) unitsFpass2_pos(2)],'fontunits','norm','str',get(handles.unitsFpass2,'str'),'vis','off');
        handles.unitsFstop2 = text('parent',handles.refUnits,'pos',[unitsFstop2_pos(1) unitsFstop2_pos(2)],'fontunits','norm','str',get(handles.unitsFstop2,'str'),'vis','off');
        handles.unitsRpass  = text('parent',handles.refUnits,'pos',[unitsRpass_pos(1) unitsRpass_pos(2)],'fontunits','norm','str',get(handles.unitsRpass,'str'));
        handles.unitsRstop  = text('parent',handles.refUnits,'pos',[unitsRstop_pos(1) unitsRstop_pos(2)],'fontunits','norm','str',get(handles.unitsRstop,'str'));
    end
    %%%----
    
    handles.LineMain  = line('parent',handles.Plot1,'Color','b','marker','none','linestyle','-');
    handles.LineGreen = line('parent',handles.Plot1,'Color','g');

    %-- Register spfirst class object(s) --%
    handles.note = spfirst_obj(handles.Plot1,'note','vis','off');
    fs = str2double(get(handles.Fsamp,'string'));
    handles.XaxisT = spfirst_axis(handles.LineMain,'x',2*pi/fs,'Frequency (rad)','Show Radian Frequency', ...
        'ButtonDownFcn',[mfilename '(''menu_x_scale_Callback'',gcbo,[],guidata(gcbo))']);
    handles.menu_x_scale = get(handles.XaxisT,'Submenu');
    handles.YaxisT = spfirst_axis(handles.LineMain,'y',1,'Magnitude (dB)','Show Magnitude (dB)', ...
        'ButtonDownFcn',[mfilename '(''menu_y_scale_Callback'',gcbo,[],guidata(gcbo))']);
    handles.menu_y_scale = get(handles.YaxisT,'Submenu');
    handles.dialog = spfirst_dialog(handles.figure1,[0.15 0.01 0.5 0.07],'help','Right-click on the plot to view additional plots');
    handles.coord  = spfirst_coord(handles.LineMain);
    %----------------------------------------%

    handles.TextPole   = text('parent',handles.Plot1,'vis','off','fontunits','norm');
    set(handles.PMFIter,'vis','off','min',1,'max',9,'sliderstep',[1/8 1/8],'val',9);

    [handles.LineStem1,handles.LineStem2] = stemdata(1,1,handles.Plot1);
    set([handles.LineStem1,handles.LineStem2,handles.WindowsMenu,handles.Windows,handles.alpha,handles.RemezText],'vis','off');
    set(handles.LineStem2,'markerfacecolor',[0 0 1]);

    % Specify parameter values
    handles.params.Fsamp  = str2double(get(handles.Fsamp,'string'));
    handles.params.Fpass1 = str2double(get(handles.Fpass1,'string'));
    handles.params.Fstop1 = str2double(get(handles.Fstop1,'string'));
    handles.params.Fpass2 = str2double(get(handles.Fpass2,'string'));
    handles.params.Fstop2 = str2double(get(handles.Fstop2,'string'));
    handles.params.Order  = str2double(get(handles.Order,'string'));
    handles.params.Rpass  = str2double(get(handles.Rpass,'string'));
    handles.params.Rstop  = str2double(get(handles.Rstop,'string'));

    % Run above specified filter
    handles = Filter_Callback(handles.Filter,[],handles);
    % --------------------------------------------------------------------
    % Context menu info text
    % handles.Infotext = text('parent',handles.Plot1,'pos',[0.5 0.95],'color','m','Horiz','center', ...
    %      'units','norm','fontunits','norm','string','Right-click to view additional plots');

    % Use system color scheme for figure:
    % Style: {pushbutton} | togglebutton | radiobutton | checkbox | edit |
    % text | slider | frame | listbox | popupmenu
    defColor = get(fig,'Color');
    set([findall(fig,'style','text');findall(fig,'style','radiobutton')],'back',defColor);
    set([findall(fig,'style','slider');findall(fig,'style','popupmenu')],'back','w');
    set(handles.dialog,'visible','on');
    set(fig,'units','pixels','Color',defColor,'menubar','none', ...
        'ResizeFcn',[mfilename '(''Resize'',gcbf,[],guidata(gcbo))'], ...
        'WindowButtonMotionFcn',[mfilename ' WindowButtonMotion'],'visible','on', ...
        'Name',[mfilename spfirstVer(10:14)]);
    
    if handles.MATLABVER < 8.4
        set(fig,'DoubleBuffer','on');
    end
    guidata(fig,handles);

    % ====================================================================;findall(fig,'style','radiobutton')
    if nargout > 0
        varargout{1} = fig;
    end
elseif strcmp(varargin{1},'--version')
    disp(spfirstVer);
elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK
    %varargin{1}
    try
        if (nargout)
            [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
        else
            feval(varargin{:}); % FEVAL switchyard;findall(fig,'style','radiobutton')
        end
    catch
        disp(lasterr);
    end
end

%| ABOUT CALLBACKS:
%| GUIDE automatically appends subfunction prototypes to this file, and
%| sets objects' callback properties to call them through the FEVAL
%| switchyard above. This comment describes that mechanism.
%|
%| Each callback subfunction declaration has the following form:
%| <SUBFUNCTION_NAME>(H, EVENTDATA, HANDLES, VARARGIN)
%|
%| The subfunction name is composed using the object's Tag and the
%| callback type separated by '_', e.g. 'PMFiter_Callback',
%| 'figure1_CloseRequestFcn', 'axis1_ButtondownFcn'.
%|
%| H is the callback object's handle (obtained using GCBO).
%|
%| EVENTDATA is empty, but reserved for future use.
%|
%| HANDLES is a structure containing handles of components in GUI using
%| tags as fieldnames, e.g. handles.figure1, handles.PMFiter. This
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
%=====================================================================
%====================================================================
function Resize(hObject,eventdata,handles)
%====================================================================
% ppm = findall(handles.figure1,'style','popupmenu');
% set([0,handles.figure1,ppm(1)],'units','pixels');
% fp = get(handles.figure1,'pos');
% sp = get(0,'screensize');
% 
% poS = get(ppm(1),'pos');
% %pos = cell2mat(poS).*(ones(4,1)*[fp(3) fp(4) fp(3) fp(4)]);
% pos = poS.*[fp(3) fp(4) fp(3) sp(4)];
% set(ppm(1),'units','pixels');
% for n=1:1%length(poS)
%     set(ppm(n),'pos',pos(n,:),'back','r');
% end
%set([handles.figure1,ppm],'units','pixels');

% change omega units
if strcmp(get(handles.menu_x_scale,'checked'),'on')
    set(handles.Fpass1Tag,'fontunits','points');
    fz = get(handles.Fpass1Tag,'fontsize');
    set([handles.wFpass1Tag,handles.wFstop1Tag,handles.wFpass2Tag,handles.wFstop2Tag], ...
        'fontsize',fz);
    set(handles.Fpass1Tag,'fontunits','norm');
end
% guidata(handles.figure1,handles);

% --------------------------------------------------------------------
%====================================================================
function Screenshot_Callback(hObject, eventdata, handles)
%====================================================================
screenshotdlg(gcbf);
%====================================================================
function ShowMenu_Callback(hObject, eventdata, handles)
%====================================================================
check = get(gcbo,'Checked');
if strcmp(check,'off')
    set(gcbf,'MenuBar','figure');
    set(gcbo,'Checked','On');
else
    set(gcbf,'MenuBar','none');
    set(gcbo,'Checked','Off');
end
%====================================================================
function Filter_Type(hObject, eventdata, handles)
%====================================================================
mp = get(handles.DesignMenu,'pos');
fp = get(handles.Filter,'pos');
switch get(hObject,'tag')
    case 'FIR'
        set(handles.Filter,'value',1,'string',{'Lowpass','Highpass','Bandpass','Bandreject'},'pos',[mp(1) fp(2) mp(3) mp(4)]);
        set([handles.FIR,handles.IIR],{'value'},{1,0}');
        handles.filt_type = 'FIR';
    case 'IIR'
        set(handles.note,'vis','off');
        set(handles.Filter,'value',1,'pos',[mp(1)-0.4*mp(3) fp(2) 1.4*mp(3) fp(4)],'string', ...
            {'Butterworth Lowpass','Butterworth Highpass','Butterworth Bandpass','Butterworth Bandreject'});
        set([handles.FIR,handles.IIR],{'value'},{0,1}');
        handles.filt_type = 'IIR';
end
handles = Filter_Callback([],eventdata,handles);
guidata(handles.figure1,handles);
%====================================================================
function handles = Filter_Callback(h, eventdata, handles, varargin)
%====================================================================
filt_names = get(handles.Filter,{'string','value'});
handles.filt_name = filt_names{1}{filt_names{2}};

switch handles.filt_type
    case 'FIR'
        handles = SetFIRMenu(handles);
    case 'IIR'
        handles = SetIIRMenu(handles);
end

handles = chooseFilter(handles,[]);
guidata(handles.figure1,handles);
%====================================================================
function varargout = Fsamp_Callback(h,eventdata,handles,varargin)
%====================================================================
[params,Wpass1,Wstop1,Wpass2,Wstop2,Rp_dB,Rs_dB,order_type,xscale,yscale,omega] = user(handles);
error_flag = 1;  % variable to check for error

if isempty(params.Fsamp) | isnan(params.Fsamp)
    set(handles.dialog,'type','error','message','F_{samp}  cannot be empty');
    set(handles.Fsamp,'string',num2str(handles.params.Fsamp))
else
    switch handles.filt_type
        %---%---------------------
        case 'FIR'
            %---------------------
            switch handles.filt_name
                case {'Lowpass','Highpass'}
                    if strcmp(handles.win_name,'Kaiser')
                        nyquist_check = 2*max([params.Fpass1,params.Fstop1]);
                    else
                        nyquist_check = 2*params.Fpass1;
                    end
                case {'Bandpass','Bandreject'}
                    if strcmp(handles.win_name,'Kaiser')
                        nyquist_check = 2*max([params.Fpass1,params.Fstop1,params.Fpass2,params.Fstop2]);
                    else
                        nyquist_check = 2*max([params.Fpass1,params.Fpass2]);
                    end
            end
            if params.Fsamp > nyquist_check
                handles.params.Fsamp = params.Fsamp;

                switch handles.design_name
                    case 'Window'
                        handles = PlotFIR(handles);
                    case 'Parks-McClellan'
                        handles = PlotFIRPM(handles,-1);
                end
            else
                set(handles.Fsamp,'string',num2str(handles.params.Fsamp));
                set(handles.dialog,'type','error','message','F_{samp} > 2*F_{max}');
            end
            %---------------------
        case 'IIR'
            %---------------------
            switch handles.filt_name
                case {'Butterworth Lowpass','Butterwoth Highpass'}
                    if params.Fsamp > 2*max([params.Fpass1,params.Fstop1])
                        error_flag = 0;
                    end
                case {'Butterwoth Bandpass','Butterworth Bandreject'}
                    if params.Fsamp > 2*max([params.Fpass1,params.Fstop1,params.Fpass2,params.Fstop2])
                        error_flag = 0;
                    end
            end
            if error_flag == 0
                handles.params.Fsamp = params.Fsamp;
                handles = PlotIIR(h, eventdata, handles, varargin);
            else
                set(handles.dialog,'type','error','message','F_{samp} > 2*F_{max}');
                set(handles.Fsamp,'string',num2str(handles.params.Fsamp));
            end
            %---------------------
    end
    guidata(handles.figure1,handles);
end
%====================================================================
function varargout = Fpass1_Callback(h,eventdata,handles,varargin)
%====================================================================
[params,Wpass1,Wstop1,Wpass2,Wstop2,Rp_dB,Rs_dB,order_type,xscale,yscale,omega] = user(handles);

if isempty(params.Fpass1) | isnan(params.Fpass1)
    set(handles.dialog,'type','error','message',[omega strtrim(get(handles.Fpass1Tag,'str')) ' cannot be empty']);
    if xscale == 1
        set(handles.Fpass1,'string',num2str(handles.params.Fpass1));
    else
        set(handles.Fpass1,'string',num2str(handles.params.Fpass1/handles.params.Fsamp*2));
    end
else
    error_flag = 0; % variable to check for error

    if strcmp(handles.filt_type,'IIR')
        filt_name = handles.filt_name;
    else
        filt_name = [handles.win_name ' ' handles.filt_name];
    end

    switch filt_name
        %---%---------------------
        case {'Butterworth Lowpass','Kaiser Lowpass'}
            %---------------------
            if ~(params.Fpass1>0 && params.Fpass1<params.Fstop1)
                error_flag = '0 < F_{pass} < F_{stop}';
            end
            %---------------------
        case {'Butterworth Highpass','Kaiser Highpass'}
            %---------------------
            if ~(params.Fpass1>params.Fstop1 && params.Fpass1<params.Fsamp/2)
                error_flag = 'F_{stop} < F_{pass} < 0.5*F_{samp}';
            end
            %---------------------
        case {'Butterworth Bandpass','Kaiser Bandpass'}
            %---------------------
            if ~(params.Fpass1<params.Fpass2 && params.Fpass1>params.Fstop1)
                error_flag = 'F_{stop1} < F_{pass1} < F_{pass2}';
            end
            %---------------------
        case {'Butterworth Bandreject','Kaiser Bandreject'}
            %---------------------
            if ~(params.Fpass1<params.Fstop1 && params.Fpass1>0)
                error_flag = '0 < F_{pass1} < F_{stop1}';
            end
            %---------------------
        otherwise
            %---------------------
            switch handles.filt_name
                %---------------------
                case {'Lowpass','Highpass'}
                    %---------------------
                    if ~(params.Fpass1 > 0 && params.Fpass1 < params.Fsamp/2)
                        error_flag = '0 < F_{cutoff} < 0.5*F_{samp}';
                    end
                    %---------------------
                case {'Bandpass','Bandreject'}
                    %---------------------
                    if ~(params.Fpass1 > 0 && params.Fpass1 < params.Fpass2)
                        error_flag = '0 < F_{cutoff1} < F_{cutoff2}';
                    end
                    %---------------------
            end
    end
    if error_flag
        if xscale == 2
            error_flag = strrep(error_flag,'0.5*F_{samp}','\pi');
            error_flag = strrep(error_flag,'F','\omega');
            set(handles.Fpass1,'string',num2str(handles.params.Fpass1/params.Fsamp*2));
        else
            set(handles.Fpass1,'string',num2str(handles.params.Fpass1));
        end
        set(handles.dialog,'type','error','message',error_flag);
    else
        handles.params = params;
        handles = chooseFilter(handles,params);
    end
    guidata(handles.figure1,handles);
end
%====================================================================
function varargout = Fpass2_Callback(h,eventdata,handles,varargin)
%====================================================================
[params,Wpass1,Wstop1,Wpass2,Wstop2,Rp_dB,Rs_dB,order_type,xscale,yscale,omega] = user(handles);

if isempty(params.Fpass2) | isnan(params.Fpass2)
    set(handles.dialog,'type','error','message',[omega strtrim(get(handles.Fpass2Tag,'str')) ' cannot be empty']);
    if xscale == 1
        set(handles.Fpass2,'string',num2str(handles.params.Fpass2));
    else
        set(handles.Fpass2,'string',num2str(handles.params.Fpass2/handles.params.Fsamp*2));
    end
else
    error_flag = 0; % variable to check for error

    if strcmp(handles.filt_type,'IIR')
        filt_name = handles.filt_name;
    else
        filt_name = [handles.win_name ' ' handles.filt_name];
    end

    switch filt_name
        %---%---------------------
        case {'Butterworth Bandpass','Kaiser Bandpass'}
            %---------------------
            if ~(params.Fpass2 > params.Fpass1 && params.Fpass2 < params.Fstop2)
                error_flag = 'Fpass1 < F_{pass2} < F_{stop2}';
            end
            %---------------------
        case {'Butterworth Bandreject','Kaiser Bandreject'}
            %---------------------
            if ~(params.Fpass2 > params.Fstop2 && params.Fpass2 < params.Fsamp/2)
                error_flag = 'F_{stop2} < F_{pass2} < 0.5*F_{samp}';
            end
            %---------------------
        otherwise
            %---------------------
            switch handles.filt_name
                case {'Bandpass','Bandreject'}
                    if ~(params.Fpass2>params.Fpass1 && params.Fpass2<params.Fsamp/2)
                        error_flag = 'F_{cutoff1} < F_{cutoff2} < 0.5*F_{samp}';
                    end
            end
    end
    if error_flag
        if xscale == 2
            error_flag = strrep(error_flag,'0.5*F_{samp}','\pi');
            error_flag = strrep(error_flag,'F','\omega');
            set(handles.Fpass2,'string',num2str(handles.params.Fpass2/params.Fsamp*2));
        else
            set(handles.Fpass2,'string',num2str(handles.params.Fpass2));
        end
        set(handles.dialog,'type','error','message',error_flag);
    else
        handles = chooseFilter(handles,params);
    end
    guidata(handles.figure1,handles);
end
%====================================================================
function varargout = Fstop1_Callback(h,eventdata,handles,varargin)
%====================================================================
[params,Wpass1,Wstop1,Wpass2,Wstop2,Rp_dB,Rs_dB,order_type,xscale,yscale,omega] = user(handles);

if isempty(params.Fstop1) | isnan(params.Fstop1)
    set(handles.dialog,'type','error','message',[omega strtrim(get(handles.Fstop1Tag,'str')) ' cannot be empty']);
    if xscale == 1
        set(handles.Fstop1,'string',num2str(handles.params.Fstop1));
    else
        set(handles.Fstop1,'string',num2str(handles.params.Fstop1/handles.params.Fsamp*2));
    end
else
    error_flag = 0; % variable to check for error

    if strcmp(handles.design_name,'Parks-McClellan')
        switch handles.filt_name
            %---%---------------------
            case 'Lowpass'
                %---------------------
                if ~(params.Fstop1<params.Fsamp/2 && params.Fstop1>params.Fpass1)
                    error_flag = 'F_{pass} < F_{stop} < 0.5*F_{samp}';
                end
                %---------------------
            case 'Highpass'
                %---------------------
                if ~(params.Fstop1>0 && params.Fstop1<params.Fpass1)
                    error_flag = '0 < F_{stop} < F_{pass}';
                end
                %---------------------
            case 'Bandpass'
                %---------------------
                if ~(params.Fstop1>0 && params.Fstop1<params.Fpass1)
                    error_flag = '0 < F_{stop1} < F_{pass1}';
                end
                %---------------------
            case 'Bandreject'
                %---------------------
                if ~(params.Fpass1>0 && params.Fpass1<params.Fstop1)
                    error_flag = '0 < F_{pass1} < F_{stop1}';
                end
                %---------------------
        end
    end

    if strcmp(handles.filt_type,'IIR')
        filt_name = handles.filt_name;
    else
        filt_name = [handles.win_name ' ' handles.filt_name];
    end

    switch filt_name
        %---%---------------------
        case {'Butterworth Lowpass','Kaiser Lowpass'}
            %---------------------
            if ~(params.Fstop1<params.Fsamp/2 && params.Fstop1>params.Fpass1)
                error_flag = 'F_{pass} < F_{stop} < 0.5*F_{samp}';
            end
            %---------------------
        case {'Butterworth Highpass','Kaiser Highpass'}
            %---------------------
            if ~(params.Fstop1>0 && params.Fstop1<params.Fpass1)
                error_flag = '0 < F_{stop} < F_{pass}';
            end
            %---------------------
        case {'Butterworth Bandpass','Kaiser Bandpass'}
            %---------------------
            if ~(params.Fstop1>0 && params.Fstop1<params.Fpass1)
                error_flag = '0 < F_{stop1} < F_{pass1}';
            end
            %---------------------
        case {'Butterworth Bandreject','Kaiser Bandreject'}
            %---------------------
            if ~(params.Fstop1>params.Fpass1 && params.Fstop1<params.Fstop2)
                error_flag = 'F_{pass1} < F_{stop1} < F_{stop}';
            end
            %---------------------
    end
    if error_flag
        if xscale == 2
            error_flag = strrep(error_flag,'0.5*F_{samp}','\pi');
            error_flag = strrep(error_flag,'F','\omega');
            set(handles.Fstop1,'string',num2str(handles.params.Fstop1/params.Fsamp*2));
        else
            set(handles.Fstop1,'string',num2str(handles.params.Fstop1));
        end
        set(handles.dialog,'type','error','message',error_flag);
    else
        handles = chooseFilter(handles,params);
    end
    guidata(handles.figure1,handles);
end
%====================================================================
function varargout = Fstop2_Callback(h, eventdata, handles, varargin)
%====================================================================
[params,Wpass1,Wstop1,Wpass2,Wstop2,Rp_dB,Rs_dB,order_type,xscale,yscale,omega] = user(handles);

if isempty(params.Fstop2) | isnan(params.Fstop2)
    set(handles.dialog,'type','error','message',[omega strtrim(get(handles.Fstop2Tag,'str')) ' cannot be empty']);
    if xscale == 1
        set(handles.Fstop2,'string',num2str(handles.params.Fstop2));
    else
        set(handles.Fstop2,'string',num2str(handles.params.Fstop2/handles.params.Fsamp*2));
    end
else
    error_flag = 0; % variable to check for error

    switch handles.filt_name
        case {'Butterworth Bandpass','Bandpass'}
            if ~(params.Fstop2>params.Fpass2 && params.Fstop2<params.Fsamp/2)
                error_flag = 'F_{pass2} < F_{stop2} < 0.5*F_{samp}';
            end
        case {'Butterworth Bandreject','Bandreject'}
            if ~(params.Fstop2>params.Fstop1 && params.Fstop2<params.Fpass2)
                error_flag = 'F_{stop1} < F_{stop2} < F_{pass2}';
            end
    end
    if error_flag
        if xscale == 2
            error_flag = strrep(error_flag,'0.5*F_{samp}','\pi');
            error_flag = strrep(error_flag,'F','\omega');
            set(handles.Fstop2,'string',num2str(handles.params.Fstop2/params.Fsamp*2));
        else
            set(handles.Fstop2,'string',num2str(handles.params.Fstop2));
        end
        set(handles.dialog,'type','error','message',error_flag);
    else
        handles = chooseFilter(handles,params);
    end
    guidata(handles.figure1,handles);
end
%====================================================================
function varargout = Rpass_Callback(h, eventdata, handles, varargin)
%====================================================================
[params,Wpass1,Wstop1,Wpass2,Wstop2,Rp_dB,Rs_dB,order_type,xscale,yscale,omega] = user(handles);

if isempty(params.Rpass) | isnan(params.Rpass)
    set(handles.dialog,'type','error','message',[get(handles.RpassTag,'str') ' cannot be empty']);
    if yscale == 1
        set(handles.Rpass,'string',num2str(handles.params.Rpass));
    else
        set(handles.Rpass,'string',num2str(20*log10(1-handles.params.Rpass)));
    end
else
    error_flag = 0; %
    if yscale == 2     % mag in dB
        if ~(Rp_dB < 0 && Rp_dB > -6)                     % check for constraints
            error_flag = '-6 dB < R_{pass} < 0 dB';
        end
    else
        if ~(params.Rpass < 0.5 && params.Rpass > 0)                                % check for constraints
            error_flag = '0 < R_{pass} < 0.5';
        end
    end
    if error_flag
        if yscale == 2
            set(handles.Rpass,'string',num2str(20*log10(1-handles.params.Rpass)));
        else
            set(handles.Rpass,'string',num2str(handles.params.Rpass));
        end
        set(handles.dialog,'type','error','message',error_flag);
    else
        handles = chooseFilter(handles,params);
        guidata(handles.figure1,handles);
    end
end
%====================================================================
function varargout = Rstop_Callback(h,eventdata,handles,varargin)
%====================================================================
[params,Wpass1,Wstop1,Wpass2,Wstop2,Rp_dB,Rs_dB,order_type,xscale,yscale,omega] = user(handles);

if isempty(params.Rstop) | isnan(params.Rstop)
    set(handles.dialog,'type','error','message',[get(handles.RstopTag,'str') '  cannot be empty']);
    if yscale == 1
        set(handles.Rstop,'string',num2str(handles.params.Rstop));
    else
        set(handles.Rstop,'string',num2str(20*log10(handles.params.Rstop)));
    end
else
    error_flag = 0;
    if yscale == 2 % mag in dB
        if ~(Rs_dB < -6 && Rs_dB > -60)                          % check for constraints
            error_flag = '-60 dB < R_{stop} < -6 dB';
        end
    else
        if ~(params.Rstop < 0.5 && params.Rstop > 0)                           % check for constraints
            error_flag = '0 < R_{stop} < 0.5';
        end
    end
    if error_flag
        if yscale == 2
            set(handles.Rstop,'string',num2str(20*log10(handles.params.Rstop)));
        else
            set(handles.Rstop,'string',num2str(handles.params.Rstop));
        end
        set(handles.dialog,'type','error','message',error_flag);
    else
        handles.KaiserR = 'Rstop';
        handles = chooseFilter(handles,params);
    end
    guidata(handles.figure1,handles);
end
%====================================================================
function varargout = Order_Callback(h, eventdata, handles, varargin)
%====================================================================
[params,Wpass1,Wstop1,Wpass2,Wstop2,Rp_dB,Rs_dB,order_type,xscale,yscale,omega] = user(handles);

if isempty(params.Order) | isnan(params.Order)
    set(handles.dialog,'type','error','message','Order cannot be empty');
    set(handles.Order,'string',num2str(handles.params.Order));
else
    error_flag = 0;
    if strcmp(handles.filt_type,'IIR')
        filt_name = handles.filt_name;
    else
        filt_name = [handles.win_name ' ' handles.filt_name];
    end

    if params.Order <= 0
        switch filt_name
            %---------------------
            case {'Butterworth Bandpass','Kaiser Bandpass'} % for BPF, need to check whether order is even
                %---------------------
                if mod(handles.params.Order,2) ~= 0
                    set(handles.Order,'string',num2str(handles.params.Order+1));
                else
                    set(handles.Order,'string',num2str(handles.params.Order));
                end
            otherwise                                       % all other filters
                set(handles.Order,'string',num2str(handles.params.Order));
        end
        error_flag = 'Order must be positive';
    else
        switch filt_name
            %---------------------
            case  {'Butterworth Lowpass','Butterworth Highpass','Kaiser Lowpass','Kaiser Bandpass'}
                %---------------------
                if mod(params.Order,1) == 0       % order is an integer
                    error_flag = 0;
                else
                    set(handles.Order,'String',num2str(ceil(params.Order)));
                    error_flag = 'Order must be an Integer';
                end
                % For Butterworth LP|HP - order cannot be greater than 20
                if any(strcmp(filt_name,{'Butterworth Lowpass','Butterworth Highpass'}))
                    if params.Order > 20
                        set(handles.Order,'str',handles.params.Order);
                        error_flag = 'Order cannot be greater than 20';
                    end
                end
                %---------------------
            case {'Butterworth Bandpass','Butter Bandreject'}
                %---------------------
                if mod(params.Order,2) == 0       % order is an even integer
                    error_flag = 0;
                else
                    params.Order = ceil(params.Order);                          % use ceiling function to remove fractional part
                    if mod(params.Order,2) ~= 0
                        params.Order = params.Order + 1;
                    end
                    set(handles.Order,'String',num2str(ceil(params.Order)));
                    error_flag = 'Order must be an even Integer';
                end
                %---------------------
            case 'Kaiser Bandreject'
                %---------------------
                if mod(params.Order,2) == 1       % order is an odd integer
                    error_flag = 0;
                else
                    params.Order = ceil(params.Order); % use ceiling function to remove fractional part
                    if mod(params.Order,2) ~= 1
                        params.Order = params.Order + 1;
                    end
                    set(handles.Order,'String',num2str(ceil(params.Order)));
                    error_flag = 'Order must be an Odd Integer';
                end
                %---------------------
        end
    end
    if error_flag
        set(handles.dialog,'type','error','message',error_flag);
    end
    handles = chooseFilter(handles,params);
    guidata(handles.figure1,handles);
end
%====================================================================
function handles = PlotIIR(h,eventdata,handles,varargin)
%====================================================================
% generates the plot for the IIR filter
[params,Wpass1,Wstop1,Wpass2,Wstop2,Rp_dB,Rs_dB,order_type,xscale,yscale,omega] = user(handles); % get user values
error_flag = 0;
Wc1 = (Wpass1 + Wpass2)/2;	% use mean of passband edge and stopband edge for first critical frequency
Wc2 = (Wpass2 + Wstop2)/2;	% use mean of passband edge and stopband edge for second critical frequency
MagMode = strcmp(get(handles.MagResp,'vis'),'off');

switch handles.filt_name
    %---%-----------------------------------
    case 'Butterworth Lowpass'                	% if lowpass
        %-----------------------------------
        if order_type == 1                      % if auto order
            params.Order = ceil(log10(((1/params.Rstop)^2-1)/((1/(1-params.Rpass))^2-1))/(2*log10(tan(Wstop1*pi/2)/tan(Wpass1*pi/2))));    % formula for order estimation (pg 455 in DTSP)
            set(handles.Order,'string',num2str(params.Order));
        end

        [b,a,error_flag] = butterworth(params.Order,Wpass1,params.Rpass);
        if ~isempty(b)
            [h,w] = freekz(b,a,512);                % determine frequency response
            max_h = max(abs(h));
            h = h/max_h;
            handles.b = b/a(1)/max_h;               % save values of filter coeffs
            handles.a = a/a(1);

            % initializing ideal filter lines: x/yscale can be either 1 or 2
            xdata1 = [0 params.Fpass1]*(2-xscale)               + [0 Wpass1]*(xscale-1);
            xdata2 = [params.Fstop1 params.Fsamp/2]*(2-xscale)  + [Wstop1 1]*(xscale-1);
            ydata1 = [1+params.Rpass,1+params.Rpass]*(2-yscale) + [20*log10(1+params.Rpass) 20*log10(1+params.Rpass)]*(yscale-1);
            ydata2 = [1-params.Rpass 1-params.Rpass]*(2-yscale) + [20*log10(1-params.Rpass) 20*log10(1-params.Rpass)]*(yscale-1);
            ydata3 = [params.Rstop params.Rstop]*(2-yscale)     + [20*log10(params.Rstop) 20*log10(params.Rstop)]*(yscale-1);

            set(handles.Line1a,'xdata',xdata1,'ydata',ydata1);
            set(handles.Line1b,'xdata',xdata1,'ydata',ydata2);
            set(handles.Line3,'xdata', xdata2,'ydata',ydata3);

            if MagMode
                set([handles.Line1a,handles.Line1b,handles.Line3],'visible','on');
                set([handles.Line2,handles.Line4a,handles.Line4b,handles.Line5a,handles.Line5b,handles.Line6],'visible','off');
            end
            set(handles.PlotTitle, 'string', ['Butterworth Lowpass Filter of Order ' num2str(params.Order)]);
        end
        %-----------------------------------
    case 'Butterworth Highpass'                % if highpass
        %-----------------------------------
        theta_p = 1 - Wpass1;
        if order_type == 1                      % if auto order
            [theta,omega] = hp_mapping(Wpass1*pi);
            theta_s = theta(floor(Wstop1*pi*100+1))/pi;
            params.Order = ceil(log10(((1/params.Rstop)^2-1)/((1/(1-params.Rpass))^2-1))/(2*log10(tan(theta_s*pi/2)/tan(theta_p*pi/2))));    % formula for order estimation (pg 455 in DTSP) modified for HPF
            set(handles.Order,'string',num2str(params.Order));
        end

        [b,a,error_flag] = butterworth(params.Order,theta_p,params.Rpass);
        if ~isempty(b) && ~error_flag
            alpha = -cos((theta_p+Wpass1)*pi/2)/cos((theta_p-Wpass1)*pi/2);
            flip_b = fliplr(b);						% since b & a are coeffs in increasing order of z^(-1)
            flip_a = fliplr(a);
            % they need to be flipped around for computation
            try
                roots_b = roots(flip_b);
            catch
                error_flag = 'Unable to computer poles/zeros';
                b = []; h = 0;
            end
            try
                roots_a = roots(flip_a);
            catch
                error_flag = 'Unable to computer poles/zeros';
                b = []; h = 0;
            end
            if ~error_flag
                i = 1:length(roots_b);
                roots_B =-(roots_b(i)+alpha)./(roots_b(i)*alpha+1);		%mapping
                roots_A =-(roots_a(i)+alpha)./(roots_a(i)*alpha+1);

                flip_B = poly(roots_B);
                flip_A = poly(roots_A);
                A = fliplr(flip_A);
                B = fliplr(flip_B);

                [h,w] = freekz(B,A,512);                 % determine frequency response
                max_h = max(abs(h));
                h = h/max_h;
                handles.b = B/A(1)/max_h;
                handles.a = A/A(1);

                % initializing ideal filter lines
                xdata1 = [params.Fpass1 params.Fsamp/2]*(2-xscale)  + [Wpass1 1]*(xscale-1);
                xdata2 = [0 params.Fstop1]*(2-xscale)               + [0 Wstop1]*(xscale-1);
                ydata1 = [1+params.Rpass,1+params.Rpass]*(2-yscale) + [20*log10(1+params.Rpass) 20*log10(1+params.Rpass)]*(yscale-1);
                ydata2 = [1-params.Rpass 1-params.Rpass]*(2-yscale) + [20*log10(1-params.Rpass) 20*log10(1-params.Rpass)]*(yscale-1);
                ydata3 = [params.Rstop params.Rstop]*(2-yscale)     + [20*log10(params.Rstop) 20*log10(params.Rstop)]*(yscale-1);

                set(handles.Line1a,'xdata',xdata1,'ydata',ydata1);
                set(handles.Line1b,'xdata',xdata1,'ydata',ydata2);
                set(handles.Line2,'xdata', xdata2,'ydata',ydata3);

                if MagMode
                    set([handles.Line1a,handles.Line1b,handles.Line2],'visible','on');
                    set([handles.Line3,handles.Line4a,handles.Line4b,handles.Line5a,handles.Line5b,handles.Line6],'visible','off');
                end
                set(handles.PlotTitle, 'string', ['Butterworth Highpass Filter of Order ' num2str(params.Order)]);
            end
        end
        %-----------------------------------
    case 'Butterworth Bandpass'               % if bandpass
        %-----------------------------------
        theta_p = Wpass2 - Wpass1;          %   added

        if order_type == 1                      % if auto order
            [theta,omega]=bp_mapping(Wpass1*pi,Wpass2*pi);   	% obtain the maping between theta and omega
            theta_s1 = theta(floor(Wstop1*pi*100+1))/pi;   	% obtain particular theta values that map to particular stop band frequencies
            theta_s2 = theta(floor(Wstop2*pi*100+1))/pi;
            theta_s  = min([theta_s1 theta_s2]);     	% smaller value of theta should be used as stop band frequency for original filter

            N = ceil(log10(((1/params.Rstop)^2-1)/((1/(1-params.Rpass))^2-1))/(2*log10(tan(theta_s*pi/2)/tan(theta_p*pi/2))));          %   added
            params.Order = 2*N;
            set(handles.Order,'string',num2str(params.Order));
        end

        [b,a,error_flag] = butterworth(params.Order/2,theta_p,params.Rpass);    	% find butterworth filter coefficients
        if ~isempty(b)
            alpha = cos((Wpass2+Wpass1)*pi/2)/cos((Wpass2-Wpass1)*pi/2);    % find constants
            k = cot((Wpass2-Wpass1)*pi/2)*tan(theta_p*pi/2);
            flip_b = fliplr(b);						% since b & a are coeffs in increasing order of z^(-1)
            flip_a = fliplr(a);						% they need to be flipped around for computation
            roots_b = roots(flip_b);
            roots_a = roots(flip_a);
            C1 = 2*alpha*k/(k+1);					% constants for mapping
            C2 = (k-1)/(k+1);

            for i = 1:length(roots_b)   			% calculations from old Oppenheim & Schafer pg 434
                ba = 1+roots_b(i)*C2;
                aa = 1+roots_a(i)*C2;
                bb = -(C1+roots_b(i)*C1);
                ab = -(C1+roots_a(i)*C1);
                bc = roots_b(i)+C2;
                ac = roots_a(i)+C2;
                roots_B(2*i) = (-bb+sqrt(bb^2-4*ba*bc))/(2*ba);
                roots_B(2*i-1) = (-bb-sqrt(bb^2-4*ba*bc))/(2*ba);
                roots_A(2*i) = (-ab+sqrt(ab^2-4*aa*ac))/(2*aa);
                roots_A(2*i-1)=(-ab-sqrt(ab^2-4*aa*ac))/(2*aa);
            end

            flip_B = poly(roots_B);
            flip_A = poly(roots_A);
            A = fliplr(flip_A);
            B = fliplr(flip_B);

            [h,w] = freekz(B,A,512);                   % determine frequency response
            max_h = max(abs(h));
            h = h/max_h;
            handles.b = B/A(1)/max_h;           % save coefficients
            handles.a = A/A(1);

            % initializing ideal filter lines
            xdata1 = [params.Fpass1 params.Fpass2]*(2-xscale)   + [Wpass1 Wpass2]*(xscale-1);
            xdata2 = [0 params.Fstop1]*(2-xscale)               + [0 Wstop1]*(xscale-1);
            xdata3 = [params.Fstop2 params.Fsamp/2]*(2-xscale)  + [Wstop2 1]*(xscale-1);
            ydata1 = [1+params.Rpass,1+params.Rpass]*(2-yscale) + [20*log10(1+params.Rpass) 20*log10(1+params.Rpass)]*(yscale-1);
            ydata2 = [1-params.Rpass 1-params.Rpass]*(2-yscale) + [20*log10(1-params.Rpass) 20*log10(1-params.Rpass)]*(yscale-1);
            ydata3 = [params.Rstop params.Rstop]*(2-yscale)     + [20*log10(params.Rstop) 20*log10(params.Rstop)]*(yscale-1);

            set(handles.Line1a,'xdata',xdata1,'ydata',ydata1);
            set(handles.Line1b,'xdata',xdata1,'ydata',ydata2);
            set(handles.Line2,'xdata', xdata2,'ydata',ydata3);
            set(handles.Line3,'xdata', xdata3,'ydata',ydata3);

            if MagMode
                set([handles.Line1a,handles.Line1b,handles.Line2,handles.Line3],'visible','on');
                set([handles.Line4a,handles.Line4b,handles.Line5a,handles.Line5b,handles.Line6],'visible','off');
            end
            set(handles.PlotTitle, 'string', ['Butterworth Bandpass Filter of Order ' num2str(params.Order)]);
        end
        %-----------------------------------
    case 'Butterworth Bandreject'
        %-----------------------------------
        theta_p = Wpass2 - Wpass1;          %   added

        if order_type == 1                      % if auto order
            [theta,omega] = br_mapping(Wpass1*pi,Wpass2*pi);          % obtain the maping between theta and omega
            theta_s1 = theta(floor(Wstop1*pi*100+1))/pi;          % obtain particular theta values that map to particular stop band frequencies
            theta_s2 = theta(floor(Wstop2*pi*100+1))/pi;
            theta_s  = min([theta_s1 theta_s2]);               % smaller value of theta should be used as stop band frequency for original filter

            N = ceil(log10(((1/params.Rstop)^2-1)/((1/(1-params.Rpass))^2-1))/(2*log10(tan(theta_s*pi/2)/tan(theta_p*pi/2))));          %   added
            params.Order = 2*N;
            set(handles.Order,'string',num2str(params.Order));
        end

        [b,a,error_flag] = butterworth(params.Order/2,theta_p,params.Rpass);        % find butterworth filter coefficients
        if ~isempty(b)
            alpha = cos((Wpass2+Wpass1)*pi/2)/cos((Wpass2-Wpass1)*pi/2);  % find constants
            k = tan((Wpass2-Wpass1)*pi/2)*tan(theta_p*pi/2);
            flip_b = fliplr(b);						% since b & a are coeffs in increasing order of z^(-1)
            flip_a = fliplr(a);						% they need to be flipped around for computation
            roots_b = roots(flip_b);
            roots_a = roots(flip_a);
            C1 = 2*alpha/(k+1);					% constants for mapping
            C2 = (1-k)/(k+1);

            for i = 1:length(roots_b),			% calculations from old Oppenheim & Schafer pg 434
                ba = 1-roots_b(i)*C2;
                aa = 1-roots_a(i)*C2;
                bb = roots_b(i)*C1-C1;
                ab = roots_a(i)*C1-C1;
                bc = C2-roots_b(i);
                ac = C2-roots_a(i);
                roots_B(2*i)    = (-bb+sqrt(bb^2-4*ba*bc))/(2*ba);
                roots_B(2*i-1)  = (-bb-sqrt(bb^2-4*ba*bc))/(2*ba);
                roots_A(2*i)    = (-ab+sqrt(ab^2-4*aa*ac))/(2*aa);
                roots_A(2*i-1)  = (-ab-sqrt(ab^2-4*aa*ac))/(2*aa);
            end

            flip_B = poly(roots_B);
            flip_A = poly(roots_A);
            A = fliplr(flip_A);
            B = fliplr(flip_B);

            [h,w] = freekz(B,A,512);                % determine frequency response
            max_h = max(abs(h));
            h = h/max_h;
            handles.b = B/A(1)/max_h;               % save coefficients
            handles.a = A/A(1);

            % initializing ideal filter lines
            xdata1 = [0 params.Fpass1]*(2-xscale)      + [0 Wpass1]*(xscale-1);
            xdata2 = [params.Fpass2 params.Fsamp/2]*(2-xscale)   + [Wpass2 1]*(xscale-1);
            xdata3 = [params.Fstop1 params.Fstop2]*(2-xscale)     + [Wstop1 Wstop2]*(xscale-1);
            ydata1 = [1+params.Rpass,1+params.Rpass]*(2-yscale) + [20*log10(1+params.Rpass) 20*log10(1+params.Rpass)]*(yscale-1);
            ydata2 = [1-params.Rpass 1-params.Rpass]*(2-yscale) + [20*log10(1-params.Rpass) 20*log10(1-params.Rpass)]*(yscale-1);
            ydata3 = [params.Rstop params.Rstop]*(2-yscale)     + [20*log10(params.Rstop) 20*log10(params.Rstop)]*(yscale-1);

            set(handles.Line4a,'xdata',xdata1,'ydata',ydata1);
            set(handles.Line4b,'xdata',xdata1,'ydata',ydata2);
            set(handles.Line5a,'xdata',xdata2,'ydata',ydata1);
            set(handles.Line5b,'xdata',xdata2,'ydata',ydata2);
            set(handles.Line6,'xdata', xdata3,'ydata',ydata3);

            if MagMode
                set([handles.Line4a,handles.Line4b,handles.Line5a,handles.Line5b,handles.Line6],'visible','on');
                set([handles.Line1a,handles.Line1b,handles.Line2,handles.Line3],'visible','off');
            end
            set(handles.PlotTitle, 'string', ['Butterworth Bandreject Filter of Order ' num2str(params.Order)]);
        end
end
if ~isempty(b)
    handles.w = w;
    handles.h = h;
    guidata(handles.figure1,handles);

    %-- find impulse response: h[n] --%
    L = 30;
    a_fill = [handles.a zeros(1,L)];
    b_fill = [handles.b zeros(1,L)];

    hh(1) = 0;
    for k = 2:L
        hh(k) = b_fill(k-1) - sum(hh.*a_fill(length(hh)+1:-1:2));
    end
    handles.total_res = hh(2:end);
    %handles.h = total_res;
    %--------------------------------%

    set(handles.LineMain,'linestyle','-','marker','none');
    set([handles.RemezHorz1,handles.RemezHorz2,handles.RemezExtre1,handles.RemezExtre2, ...
        handles.RemezHorz3,handles.PMFIter, handles.WindowLine],'vis','off');
    if (yscale-1)
        set([handles.unitsRpass,handles.unitsRstop],'vis','on');
    else
        set([handles.unitsRpass,handles.unitsRstop],'vis','off');
    end

    SetXY(handles,handles.w,handles.h,params.Fsamp,xscale,yscale);
end
% update parameters

if ~any(h)
    error_flag = 'Cannot design filter - last stable configuration';
    % replot according to old parameters which worked
    set(handles.Fsamp,'string',num2str(handles.params.Fsamp'));
    set(handles.Fpass1,'string',num2str(handles.params.Fpass1));
    set(handles.Fstop1,'string',num2str(handles.params.Fstop1));
    set(handles.Fpass2,'string',num2str(handles.params.Fpass2));
    set(handles.Fstop2,'string',num2str(handles.params.Fstop2));
    set(handles.Order,'string',num2str(handles.params.Order));
    set(handles.Rpass,'string',num2str(handles.params.Rpass));
    set(handles.Rstop,'string',num2str(handles.params.Rstop));
    if isempty(varargin)
        count = 1;
    else
        count = varargin
    end
    handles = PlotIIR(h,eventdata,handles,count+1);
end
handles = choosePlot(handles);
if error_flag
    set(handles.dialog,'type','error','message',error_flag);
elseif ~strcmp(get(handles.dialog,'type'),'help');
    set(handles.dialog,'vis','off');
end
guidata(handles.figure1,handles);
%====================================================================
function varargout = SetOrder_Callback(h, eventdata, handles, varargin)
%====================================================================
% sets the Order menu options depending on whether auto or manual setting
% of the filter order is selected
if get(handles.SetOrder,'value') == 1
    set(handles.Order,'Enable','off');
else
    set(handles.Order,'Enable','on');
end
guidata(handles.figure1,handles);
%====================================================================
function handles = SetIIRMenu(handles)
%====================================================================
%[params,Wpass1,Wstop1,Wpass2,Wstop2,Rp_dB,Rs_dB,order_type,xscale,yscale] = user(handles);
order_type = get(handles.SetOrder,'value');
params.Order = str2double(get(handles.Order,'string'));
params.Fsamp = str2double(get(handles.Fsamp,'string'));

set([handles.WindowsMenu,handles.Windows,handles.LineCirc,handles.HorzLine,handles.VertLine, ...
    handles.PoleLine,handles.LineStem1,handles.LineStem2,handles.WindowPlot,handles.TextPole, ...
    handles.alpha,handles.DesignMenu,handles.DesMethod,handles.KaiserB],'vis','off');
set([handles.RemezHorz1,handles.RemezHorz2,handles.RemezHorz3,handles.PMFIter, handles.RemezText],'vis','off');
set([handles.Fstop1,handles.Fpass2,handles.Fstop2,handles.Rpass,handles.Rstop, handles.Fstop1Tag,handles.unitsFstop1, ...
    handles.Fpass2Tag,handles.unitsFpass2, handles.Fstop2Tag,handles.unitsFstop2, ...
    handles.RpassTag,handles.RstopTag,handles.SetOrder,handles.LineMain],'vis','on');
set(handles.Order,'enable','off');
set(handles.SetOrder,'enable','on');
SetOrder_Callback([],[],handles);

switch handles.filt_name
    %---%-----------------------------------
    case 'Butterworth Lowpass'
        %-----------------------------------
        set([handles.Fpass2,handles.Fstop2,handles.Fpass2Tag,handles.Fstop2Tag,handles.unitsFpass2,handles.unitsFstop2],'vis','off');
        set([handles.Fpass1Tag,handles.Fstop1Tag],{'string'},{'F_{pass}';'F_{stop}'});

        if strcmp(get(handles.menu_x_scale,'checked'),'on')         % normalized freq
            set(handles.Fpass1,'string', num2str(4/16) );           % set default values
            set(handles.Fstop1,'string', num2str(6/16) );
        else
            set(handles.Fpass1,'string', num2str(ceil(2*params.Fsamp/16)));   % set default values
            set(handles.Fstop1,'string', num2str(ceil(3*params.Fsamp/16)));
        end
        %-----------------------------------
    case 'Butterworth Highpass'
        %-----------------------------------
        set([handles.Fpass2,handles.Fstop2,handles.Fpass2Tag,handles.Fstop2Tag,handles.unitsFpass2,handles.unitsFstop2],'visible','off');
        set([handles.Fpass1Tag,handles.Fstop1Tag],{'string'},{'F_{pass}';'F_{stop}'});

        if strcmp(get(handles.menu_x_scale,'checked'),'on')         % normalized freq
            set(handles.Fpass1,'string', num2str(6/16));
            set(handles.Fstop1,'string', num2str(4/16));
        else
            set(handles.Fpass1,'string', num2str(ceil(3*params.Fsamp/16)) ); % set default values
            set(handles.Fstop1,'string', num2str(ceil(2*params.Fsamp/16)) );
        end
        %-----------------------------------
    case 'Butterworth Bandpass'
        %-----------------------------------
        set([handles.Fpass2,handles.Fstop2,handles.Fpass2Tag,handles.Fstop2Tag],'Visible','on');
        set([handles.Fpass1Tag,handles.Fstop1Tag],{'string'},{'F_{pass 1}';'F_{stop 1}'});
        set([handles.Fpass2Tag,handles.Fstop2Tag],{'string'},{'F_{pass 2}';'F_{stop 2}'});

        if strcmp(get(handles.menu_x_scale,'checked'),'on')         % normalized freq
            set(handles.Fpass1, 'string', num2str(6/16));           % set default values
            set(handles.Fstop1, 'string', num2str(4/16));
            set(handles.Fpass2, 'string', num2str(10/16));
            set(handles.Fstop2, 'string', num2str(14/16));
        else
            set(handles.Fpass1, 'string', num2str(ceil(3*params.Fsamp/16))); 	% set default values
            set(handles.Fstop1, 'string', num2str(ceil(2*params.Fsamp/16)));
            set(handles.Fpass2, 'string', num2str(ceil(5*params.Fsamp/16)));
            set(handles.Fstop2, 'string', num2str(ceil(7*params.Fsamp/16)));
            % update unit texts
            set([handles.unitsFpass2,handles.unitsFstop2],'vis','on');
        end

        if order_type==2 & mod(params.Order,2)~=0,   % if BPF in 'set order' mode and order is not even
            set(handles.Order,'string',num2str(params.Order+1));
        end
        %-----------------------------------
    case 'Butterworth Bandreject'
        %-----------------------------------
        set([handles.Fpass2,handles.Fstop2,handles.Fpass2Tag,handles.Fstop2Tag],'visible','on');
        set([handles.Fpass1Tag,handles.Fstop1Tag],{'string'},{'F_{pass 1}';'F_{stop 1}'});
        set([handles.Fpass2Tag,handles.Fstop2Tag],{'string'},{'F_{pass 2}';'F_{stop 2}'});

        if strcmp(get(handles.menu_x_scale,'checked'),'on')         % normalized freq
            set(handles.Fpass1, 'string', num2str(4/16));           % set default values
            set(handles.Fstop1, 'string', num2str(6/16));
            set(handles.Fpass2, 'string', num2str(14/16));
            set(handles.Fstop2, 'string', num2str(10/16));
        else
            set(handles.Fpass1, 'string', num2str(ceil(2*params.Fsamp/16)));  % set default values
            set(handles.Fstop1, 'string', num2str(ceil(3*params.Fsamp/16)));
            set(handles.Fpass2, 'string', num2str(ceil(7*params.Fsamp/16)));
            set(handles.Fstop2, 'string', num2str(ceil(5*params.Fsamp/16)));
            set([handles.unitsFpass2,handles.unitsFstop2],'Vis','on'); % update unit texts
        end

        if order_type==2 & mod(params.Order,2)~=0,   % if BRF in 'set order' mode and order is not even
            set(handles.Order,'string',num2str(params.Order+1));
        end
        %-----------------------------------
end
params = user(handles);
handles.params = params;
guidata(handles.figure1,handles);
%====================================================================
function WindowButtonMotion()
%====================================================================
% Policy 1: In Mag OR Phase plot mode? - check for cursor over the x/y-axis label
% Policy 2: In Mag plot mode? - only Mag filter lines can be detected
% Policy 3: In FIR:Window:Kaiser OR IIR mode? - filter lines can only there be detected

policy1 = ( strcmp(get(findobj(gcbf,'tag','MagResp'),'vis'),'off') | strcmp(get(findobj(gcbf,'tag','PhaseResp'),'vis'),'off') ) ;
policy2 = strcmp(get(findobj(gcbf,'tag','MagResp'),'vis'),'off');
policy3 = ( get(findobj(gcbf,'tag','FIR'),'value') & ...
    (get(findobj(gcbf,'tag','DesignMenu'),'value') == 1) & ...
    (get(findobj(gcbf,'tag','WindowsMenu'),'value') == 9) ) |  get(findobj(gcbf,'tag','IIR'),'value');

if policy1
    hax = findobj(gcbf,'tag','Plot1');
    %-----------------------------------
    % Determine if cursor is over Plot
    old_units = get(hax,'units');
    set(hax,'units','pixels');
    [mouse_x,mouse_y,fig_size] = mousepos;
    ax = get(hax,'position');

    % Cursor over object axes flag
    over_axes_flg = any( (mouse_x > ax(1)) & (mouse_x < ax(1)+ax(3)) &  ...
        (mouse_y > ax(2)) & (mouse_y < ax(2)+ax(4)) );
    %-----------------------------------
    if over_axes_flg
        buttonfcns(getappdata(gcbf,'spfirst_coord_DATA'),'WindowMotion');
        
        if policy2 & policy3
            % Find obj handles for red_lines (if they exist)
            redLines = findobj(gcbf,'parent',hax,'type','line','vis','on','color','r');

            if ~isempty(redLines)
                current_pt = get(hax,'currentpoint');
                xpt = current_pt(1,1);
                ypt = current_pt(1,2);
                % specify handle tolerance whithin 1% of y-axis limits
                axis_ylim = get(hax,'ylim');
                toll = diff(axis_ylim)*0.01;

                % Red Line object extend and over object flag
                % preallocate for speed/memory
                L = length(redLines);
                Lines_red_Xdata = zeros(L,2);
                Lines_red_Ydata = zeros(L,2);
                over_obj_flg = zeros(1,L);
                for ii = 1:L
                    Lines_red_Xdata(ii,:) = get(redLines(ii),'xdata');
                    Lines_red_Ydata(ii,:) = get(redLines(ii),'ydata');
                    over_obj_flg(ii) = (xpt >= Lines_red_Xdata(ii,1)) & (xpt <= Lines_red_Xdata(ii,2)) & ...
                        ( abs(ypt - Lines_red_Ydata(ii,1)) < toll );
                end

                if any(over_obj_flg);
                    setptr(gcbf,'hand');
                else
                    setptr(gcbf,'arrow');
                end
            else
                setptr(gcbf,'arrow');
            end
        end
    else % cursor is not over the axes, hence check cursor over the x/y-axis label
         % add motion over @spfirst_axis object(s)
        buttonfcns(getappdata(gcbf,'spfirst_axisx_DATA'),'WindowMotion');
        if strcmp(get(findobj(gcbf,'tag','MagResp'),'vis'),'off') % only for magnitude
            buttonfcns(getappdata(gcbf,'spfirst_axisy_DATA'),'WindowMotion');
        end
    end
    set(hax,'units',old_units);
else
    setptr(gcbf,'arrow');
end
%====================================================================
function LineDragStart()
%====================================================================
handles = guidata(gcbf);
setptr(gcbf,'closedhand');
CurrentPoint = get(gca,'CurrentPoint');
setappdata(gcbf, 'CurrentXY', CurrentPoint(1,1:2) );
%
set(gcbf,'WindowButtonUpFcn',[ mfilename ' LineDragStop'],'WindowButtonMotionFcn',[ mfilename ' MoveLine']);
% DEB set(gcbf,'WindowButtonUpFcn','','WindowButtonMotionFcn',[ mfilename ' MoveLine']);
%====================================================================
function LineDragStop()
%====================================================================
handles = guidata(gcbf);
rmappdata(gcbf,'CurrentXY');
set(gcbf,'WindowButtonMotionFcn','','WindowButtonUpFcn','');
setptr(gcbf,'arrow');
Line1aXData = get(handles.Line1a,'XData');      % find xdata for both lines
Line1bXData = get(handles.Line1b,'XData');      % find xdata for both lines
Line4aXData = get(handles.Line4a,'XData');      % find xdata for both lines
Line4bXData = get(handles.Line4b,'XData');      % find xdata for both lines
Line5aXData = get(handles.Line5a,'XData');      % find xdata for both lines
Line5bXData = get(handles.Line5b,'XData');      % find xdata for both lines
Line2XData  = get(handles.Line2,'XData');
Line3XData  = get(handles.Line3,'XData');
Line6XData  = get(handles.Line6,'XData');
Line1aYData = get(handles.Line1a,'YData');      % find ydata for both lines
Line1bYData = get(handles.Line1b,'YData');      % find ydata for both lines
Line4aYData = get(handles.Line4a,'YData');      % find xdata for both lines
Line4bYData = get(handles.Line4b,'YData');      % find xdata for both lines
Line5aYData = get(handles.Line5a,'YData');      % find xdata for both lines
Line5bYData = get(handles.Line5b,'YData');      % find xdata for both lines
Line2YData  = get(handles.Line2,'YData');
Line3YData  = get(handles.Line3,'YData');
Line6YData  = get(handles.Line6,'YData');

yscale = strcmp(get(handles.menu_y_scale,'checked'),'on') + 1; % 1-Mag, 2-Mag (dB)
xscale = strcmp(get(handles.menu_x_scale,'checked'),'on') + 1; % 1-Hz, 2-Norm
fs = str2double(get(handles.Fsamp,'string'));

switch handles.filt_type
    case 'FIR'
        filt_name = [handles.win_name ' ' handles.filt_name];
    case 'IIR'
        filt_name = handles.filt_name;
end
switch filt_name
    %---%-----------------------------------
    case {'Butterworth Lowpass','Kaiser Lowpass'}
        %-----------------------------------
        set(handles.Fpass1,'string',num2str(Line1aXData(2)));
        set(handles.Fstop1,'string',num2str(Line3XData(1)));
        set(handles.Rstop,'string',num2str(Line3YData(1)));

        if yscale==1        % if yscale is linear
            set(handles.Rpass,'string',num2str((abs(Line1aYData(1)-Line1bYData(1)))/2));
        else                % if yscale is in dB
            y1 = abs(10^(Line1aYData(1)/20)-1);
            set(handles.Rpass,'string',num2str(20*log10(1-y1)));
            %set(handles.Rstop,'string',num2str(10^(Line3YData(1)/20)));
        end
        %-----------------------------------
    case {'Butterworth Highpass','Kaiser Highpass'}                                                     % HPF
        %-----------------------------------
        set(handles.Fpass1,'string',num2str(Line1aXData(1)));
        set(handles.Fstop1,'string',num2str(Line2XData(2)));
        set(handles.Rstop,'string',num2str(Line2YData(1)));

        if yscale == 1      % if yscale is linear
            set(handles.Rpass,'string',num2str((abs(Line1aYData(1)-Line1bYData(1)))/2));
        else                % if yscale is in dB
            y1 = abs(10^(Line1aYData(1)/20)-1);
            set(handles.Rpass,'string',num2str(20*log10(1-y1)));
        end
        %-----------------------------------
    case {'Butterworth Bandpass','Kaiser Bandpass'}
        %-----------------------------------%
        set(handles.Fpass1,'string',num2str(Line1aXData(1)));
        set(handles.Fstop1,'string',num2str(Line2XData(2)));
        set(handles.Fpass2,'string',num2str(Line1aXData(2)));
        set(handles.Fstop2,'string',num2str(Line3XData(1)));

        set(handles.Rstop,'string',num2str(Line2YData(1)));
        if yscale == 1      % if yscale is linear
            set(handles.Rpass,'string',num2str((abs(Line1aYData(1)-Line1bYData(1)))/2));
        else                % if yscale is in dB
            y1 = abs(10^(Line1aYData(1)/20)-1);
            set(handles.Rpass,'string',num2str(20*log10(1-y1)));
        end
        %-----------------------------------
    case {'Butterworth Bandreject','Kaiser Bandreject'}
        %-----------------------------------%
        set(handles.Fpass1,'string',num2str(Line4aXData(2)));
        set(handles.Fstop1,'string',num2str(Line6XData(1)));
        set(handles.Fpass2,'string',num2str(Line5aXData(1)));
        set(handles.Fstop2,'string',num2str(Line6XData(2)));
        set(handles.Rstop, 'string',num2str(Line6YData(1)));

        if yscale == 1      % if yscale is linear
            set(handles.Rpass,'string',num2str((abs(Line4aYData(1)-Line4bYData(1)))/2));
        else                % if yscale is in dB
            y1 = abs(10^(Line4aYData(1)/20)-1);
            set(handles.Rpass,'string',num2str(20*log10(1-y1)));
        end
        %-----------------------------------
end
set(gcbf,'WindowButtonMotionFcn',[ mfilename ' WindowButtonMotion']);
handles = chooseFilter(handles,[]);
guidata(handles.figure1,handles);
%====================================================================
function MoveLine()
%====================================================================
handles = guidata(gcbf);
OldXY = getappdata(gcbf, 'CurrentXY');       % get old coordinates
CurrentPoint = get(gca, 'CurrentPoint');     % get current coordinates
CurrentXY = CurrentPoint(1,1:2);
DistanceMoved = CurrentXY - OldXY;           % find distance moved
Line1aXData = get(handles.Line1a,'XData');   % find xdata for both lines
Line1bXData = get(handles.Line1b,'XData');   % find xdata for both lines
Line4aXData = get(handles.Line4a,'XData');   % find xdata for both lines
Line4bXData = get(handles.Line4b,'XData');   % find xdata for both lines
Line5aXData = get(handles.Line5a,'XData');   % find xdata for both lines
Line5bXData = get(handles.Line5b,'XData');   % find xdata for both lines
Line2XData  = get(handles.Line2,'XData');
Line3XData  = get(handles.Line3,'XData');
Line6XData  = get(handles.Line6,'XData');
line_name   = get(gco,'tag');                % determine which line is moved

yscale = strcmp(get(handles.menu_y_scale,'checked'),'on') + 1; % yscale linear or dB: 1-Mag, 2-Mag (dB)
xscale = strcmp(get(handles.menu_x_scale,'checked'),'on') + 1; % 1-Hz, 2-Norm

switch handles.filt_type
    case 'FIR'
        filt_name = [handles.win_name ' ' handles.filt_name];
    case 'IIR'
        filt_name = handles.filt_name;
end

switch line_name
    case 'Line1a'
        switch filt_name
            %---------------------------------------
            case 'Butterworth Lowpass'
                %-----------------------------------
                NewData=get(handles.Line1a,'XData');  % get data to manipulate

                if yscale == 1    	% linear
                    if (get(handles.Line1a,'YData') + DistanceMoved(2)) <= 1.5 & (get(handles.Line1a,'YData')+DistanceMoved(2))>=0.5 % make sure passband error =+/- 0.5
                        set(handles.Line1a,'YData',get(handles.Line1a,'YData')+DistanceMoved(2));
                    end
                else              	% dB
                    if (get(handles.Line1a,'YData')+DistanceMoved(2))<=20*log10(1.5) & (get(handles.Line1a,'YData')+DistanceMoved(2))>=20*log10(0.5)  % make sure passband error =+/- 0.5
                        set(handles.Line1a,'YData', get(handles.Line1a,'YData')+DistanceMoved(2));
                    end
                end

                if Line1aXData(2) <= Line3XData(1)   % check for constraints
                    NewData(2) = NewData(2)+DistanceMoved(1);
                elseif xscale == 1
                    NewData(2) = NewData(2)-10;
                else
                    NewData(2) = NewData(2)-.01;
                end
                set(handles.Line1a,'XData',NewData);
                if yscale == 1      % linear
                    set(handles.Line1b,'XData', get(handles.Line1a,'XData'),'YData', 2-get(handles.Line1a,'YData'));
                else                % dB
                    dB = get(handles.Line1a,'YData');
                    lin = 10^(dB(1)/20);
                    lin = 2-lin;
                    dB = [20*log10(lin),20*log10(lin)];
                    set(handles.Line1b,'XData', get(handles.Line1a,'XData'),'YData', dB);
                end%-----------------------------------
            case 'Butterworth Highpass'
                %-----------------------------------
                NewData = get(handles.Line1a,'XData');                 % get data to manipulate
                if yscale == 1                % linear
                    if (get(handles.Line1a,'YData')+DistanceMoved(2))<=1.5 & (get(handles.Line1a,'YData')+DistanceMoved(2))>=0.5       % make sure passband error =+/- 0.5
                        set(handles.Line1a,'YData', get(handles.Line1a,'YData')+DistanceMoved(2));
                    end
                else                 % dB
                    if (get(handles.Line1a,'YData')+DistanceMoved(2))<=20*log10(1.5) & (get(handles.Line1a,'YData')+DistanceMoved(2))>=20*log10(0.5)       % make sure passband error =+/- 0.5
                        set(handles.Line1a,'YData', get(handles.Line1a,'YData')+DistanceMoved(2));
                    end
                end
                %set(handles.Line1a,'YData', get(handles.Line1a,'YData')+DistanceMoved(2));
                if Line1aXData(1)>=Line2XData(2)   % check for constraints
                    NewData(1)=NewData(1)+DistanceMoved(1);
                elseif xscale == 1
                    NewData(1) = NewData(1)+10;
                else
                    NewData(1) = NewData(1)+.01;
                end
                set(handles.Line1a,'XData',NewData);
                if yscale == 1      % linear
                    set(handles.Line1b,'XData', get(handles.Line1a,'XData'),'YData', 2-get(handles.Line1a,'YData'));
                else                % dB
                    dB = get(handles.Line1a,'YData');
                    lin = 10^(dB(1)/20);
                    lin = 2-lin;
                    dB = [20*log10(lin),20*log10(lin)];
                    set(handles.Line1b,'XData', get(handles.Line1a,'XData'),'YData', dB);
                end
                %-----------------------------------
            case 'Butterworth Bandpass'
                %-----------------------------------
                NewData = get(handles.Line1a,'XData');	% get data to manipulate
                if yscale == 1      % linear
                    if (get(handles.Line1a,'YData')+DistanceMoved(2))<=1.5 & (get(handles.Line1a,'YData')+DistanceMoved(2))>=0.5       % make sure passband error =+/- 0.5
                        set(handles.Line1a,'YData', get(handles.Line1a,'YData')+DistanceMoved(2));
                    end
                else                % dB
                    if (get(handles.Line1a,'YData')+DistanceMoved(2))<=20*log10(1.5) & (get(handles.Line1a,'YData')+DistanceMoved(2))>=20*log10(0.5)       % make sure passband error =+/- 0.5
                        set(handles.Line1a,'YData', get(handles.Line1a,'YData')+DistanceMoved(2));
                    end
                end
                %set(handles.Line1a,'YData', get(handles.Line1a,'YData')+DistanceMoved(2));
                if abs(OldXY(1)-NewData(1)) < abs(OldXY(1)-NewData(2))  % if left point on Line1a is moved
                    if Line1aXData(1) >= Line2XData(2)   % check for constraints
                        NewData(1)=NewData(1)+DistanceMoved(1);
                    elseif xscale == 1
                        NewData(1) = NewData(1) + 10;
                    else
                        NewData(1) = NewData(1) + 0.01;
                    end
                else                                                    % if right point on Line1a is moved
                    if Line1aXData(2)<=Line3XData(1)   % check for constraints
                        NewData(2) = NewData(2) + DistanceMoved(1);
                    elseif xscale == 1
                        NewData(2)=NewData(2) - 10;
                    else
                        NewData(2) = NewData(2) - 0.01;
                    end
                end
                set(handles.Line1a,'XData',NewData);
                if yscale == 1  % linear
                    set(handles.Line1b,'XData', get(handles.Line1a,'XData'),'YData', 2-get(handles.Line1a,'YData'));
                else            % dB
                    dB = get(handles.Line1a,'YData');
                    lin = 10^(dB(1)/20);
                    lin = 2-lin;
                    dB = [20*log10(lin),20*log10(lin)];
                    set(handles.Line1b,'XData', get(handles.Line1a,'XData'),'YData', dB);
                end
                %-----------------------------------
            case 'Kaiser Lowpass'
                %-----------------------------------
                NewData = get(handles.Line1a,'XData');	% get data to manipulate
                if yscale == 1	% linear
                    if (get(handles.Line1a,'YData')+DistanceMoved(2))<=1.5 & (get(handles.Line1a,'YData')+DistanceMoved(2))>=0.5       % make sure passband error =+/- 0.5
                        set(handles.Line1a,'YData', get(handles.Line1a,'YData')+DistanceMoved(2));
                    end
                else            % dB
                    if (get(handles.Line1a,'YData')+DistanceMoved(2))<=20*log10(1.5) & (get(handles.Line1a,'YData')+DistanceMoved(2))>=20*log10(0.5)       % make sure passband error =+/- 0.5
                        set(handles.Line1a,'YData', get(handles.Line1a,'YData')+DistanceMoved(2));
                    end
                end
                %set(handles.Line1a,'YData', get(handles.Line1a,'YData')+DistanceMoved(2));
                if Line1aXData(2)<=Line3XData(1)   % check for constraints
                    NewData(2)=NewData(2)+DistanceMoved(1);
                elseif xscale == 1
                    NewData(2)=NewData(2) - 10;
                else
                    NewData(2)=NewData(2) - 0.01;
                end
                set(handles.Line1a,'XData',NewData);
                if yscale == 1	% linear
                    set(handles.Line1b,'XData', get(handles.Line1a,'XData'),'YData', 2-get(handles.Line1a,'YData'));
                else            % dB
                    dB=get(handles.Line1a,'YData');
                    lin = 10^(dB(1)/20);
                    lin = 2-lin;
                    dB  = [20*log10(lin),20*log10(lin)];
                    set(handles.Line1b,'XData', get(handles.Line1a,'XData'),'YData', dB);
                end

                %-- delete this if you dont want lines moving together in Kaiser --%
                if yscale == 1
                    set(handles.Line3,'YData', abs(1-get(handles.Line1a,'YData')));
                else
                    dB  = get(handles.Line1b,'YData');
                    lin = 10^(dB(1)/20);
                    lin = abs(1-lin);
                    dB  = [20*log10(lin),20*log10(lin)];
                    set(handles.Line3,'YData', dB);
                end
                %-------------------------------------------------------------------%
                %-----------------------------------
            case 'Kaiser Highpass'
                %-----------------------------------
                NewData = get(handles.Line1a,'XData');	% get data to manipulate
                if yscale == 1	% linear
                    if (get(handles.Line1a,'YData')+DistanceMoved(2))<=1.5 & (get(handles.Line1a,'YData')+DistanceMoved(2))>=0.5       % make sure passband error =+/- 0.5
                        set(handles.Line1a,'YData', get(handles.Line1a,'YData')+DistanceMoved(2));
                    end
                else            % dB
                    if (get(handles.Line1a,'YData')+DistanceMoved(2))<=20*log10(1.5) & (get(handles.Line1a,'YData')+DistanceMoved(2))>=20*log10(0.5)       % make sure passband error =+/- 0.5
                        set(handles.Line1a,'YData', get(handles.Line1a,'YData')+DistanceMoved(2));
                    end
                end
                %set(handles.Line1a,'YData', get(handles.Line1a,'YData')+DistanceMoved(2));

                if Line2XData(2) <= Line1aXData(1)   % check for constraints
                    NewData(1) = NewData(1) + DistanceMoved(1);
                elseif xscale == 1
                    NewData(1) = NewData(1) + 10;
                else
                    NewData(1) = NewData(1) + 0.01;
                end
                set(handles.Line1a,'XData',NewData);
                if yscale == 1	% linear
                    set(handles.Line1b,'XData', get(handles.Line1a,'XData'),'YData', 2-get(handles.Line1a,'YData'));
                else            % dB
                    dB = get(handles.Line1a,'YData');
                    lin = 10^(dB(1)/20);
                    lin = 2-lin;
                    dB  = [20*log10(lin),20*log10(lin)];
                    set(handles.Line1b,'XData', get(handles.Line1a,'XData'),'YData', dB);
                end

                %-- delete this if you dont want lines moving together in Kaiser --%
                if yscale == 1
                    set(handles.Line2,'YData', abs(1-get(handles.Line1a,'YData')));
                else
                    dB  = get(handles.Line1b,'YData');
                    lin = 10^(dB(1)/20);
                    lin = abs(1-lin);
                    dB  = [20*log10(lin),20*log10(lin)];
                    set(handles.Line2,'YData', dB);
                end
                %-------------------------------------------------------------------%
                %-----------------------------------
            case 'Kaiser Bandpass'
                %-----------------------------------
                NewData = get(handles.Line1a,'XData');	% get data to manipulate
                if yscale == 1	% linear
                    if (get(handles.Line1a,'YData')+DistanceMoved(2))<=1.5 & (get(handles.Line1a,'YData')+DistanceMoved(2))>=0.5       % make sure passband error =+/- 0.5
                        set(handles.Line1a,'YData', get(handles.Line1a,'YData')+DistanceMoved(2));
                    end
                else            % dB
                    if (get(handles.Line1a,'YData')+DistanceMoved(2))<=20*log10(1.5) & (get(handles.Line1a,'YData')+DistanceMoved(2))>=20*log10(0.5)       % make sure passband error =+/- 0.5
                        set(handles.Line1a,'YData', get(handles.Line1a,'YData')+DistanceMoved(2));
                    end
                end
                %set(handles.Line1a,'YData', get(handles.Line1a,'YData')+DistanceMoved(2));
                if abs(OldXY(1)-NewData(1)) < abs(OldXY(1)-NewData(2))  % if left point on Line1a is moved
                    if Line1aXData(1)>=Line2XData(2)   % check for constraints
                        NewData(1) = NewData(1) + DistanceMoved(1);
                    elseif xscale == 1
                        NewData(1) = NewData(1) + 10;
                    else
                        NewData(1) = NewData(1) + 0.01;
                    end
                else                                    % if right point on Line1a is moved
                    if Line1aXData(2) <= Line3XData(1)  % check for constraints
                        NewData(2) = NewData(2)+DistanceMoved(1);
                    elseif xscale == 1
                        NewData(2) = NewData(2) - 10;
                    else
                        NewData(2) = NewData(2) - 0.01;
                    end
                end
                set(handles.Line1a,'XData',NewData);
                if yscale == 1	% linear
                    set(handles.Line1b,'XData', get(handles.Line1a,'XData'),'YData', 2-get(handles.Line1a,'YData'));
                else            % dB
                    dB  = get(handles.Line1a,'YData');
                    lin = 10^(dB(1)/20);
                    lin = 2-lin;
                    dB  = [20*log10(lin),20*log10(lin)];
                    set(handles.Line1b,'XData', get(handles.Line1a,'XData'),'YData', dB);
                end

                %-- delete this if you dont want lines moving together in Kaiser --%
                if yscale == 1
                    set([handles.Line2,handles.Line3],'YData', abs(1-get(handles.Line1a,'YData')));
                else
                    dB  = get(handles.Line1b,'YData');
                    lin = 10^(dB(1)/20);
                    lin = abs(1-lin);
                    dB  = [20*log10(lin),20*log10(lin)];
                    set([handles.Line2,handles.Line3],'YData', dB);
                end
                %-------------------------------------------------------------------%
        end
        %-----------------------------------
    case 'Line1b'
        %-----------------------------------
        switch filt_name
            %-----------------------------------
            case 'Butterworth Lowpass'
                %-----------------------------------
                NewData = get(handles.Line1b,'XData');	% get data to manipulate
                if yscale == 1	% linear
                    if (get(handles.Line1b,'YData')+DistanceMoved(2))>=0.5 & (get(handles.Line1b,'YData')+DistanceMoved(2))<=1.5       % make sure passband error =+/- 0.5
                        set(handles.Line1b,'YData', get(handles.Line1b,'YData')+DistanceMoved(2));
                    end
                else         	% dB
                    if (get(handles.Line1b,'YData')+DistanceMoved(2))>=20*log10(0.5) & (get(handles.Line1b,'YData')+DistanceMoved(2))<=20*log10(1.5)       % make sure passband error =+/- 0.5
                        set(handles.Line1b,'YData', get(handles.Line1b,'YData')+DistanceMoved(2));
                    end
                end
                %set(handles.Line1b,'YData', get(handles.Line1b,'YData')+DistanceMoved(2));
                if Line1bXData(2)<=Line3XData(1)        % make sure lines do not cross
                    NewData(2) = NewData(2)+DistanceMoved(1);
                elseif xscale == 1
                    NewData(2) = NewData(2) - 10;
                else
                    NewData(2) = NewData(2) - 0.01;
                end
                set(handles.Line1b,'XData',NewData);
                if yscale == 1	% linear
                    set(handles.Line1a,'XData', get(handles.Line1b,'XData'),'YData', 2-get(handles.Line1b,'YData'));
                else            % dB
                    dB  = get(handles.Line1b,'YData');
                    lin = 10^(dB(1)/20);
                    lin = 2-lin;
                    dB  = [20*log10(lin),20*log10(lin)];
                    set(handles.Line1a,'XData', get(handles.Line1b,'XData'),'YData', dB);
                end
                %-----------------------------------
            case 'Butterworth Highpass'
                %-----------------------------------
                NewData=get(handles.Line1b,'XData');	% get data to manipulate
                if yscale == 1	% linear
                    if (get(handles.Line1b,'YData')+DistanceMoved(2))>=0.5 & (get(handles.Line1b,'YData')+DistanceMoved(2))<=1.5       % make sure passband error =+/- 0.5
                        set(handles.Line1b,'YData', get(handles.Line1b,'YData')+DistanceMoved(2));
                    end
                else          	% dB
                    if (get(handles.Line1b,'YData')+DistanceMoved(2))>=20*log10(0.5) & (get(handles.Line1b,'YData')+DistanceMoved(2))<=20*log10(1.5)       % make sure passband error =+/- 0.5
                        set(handles.Line1b,'YData', get(handles.Line1b,'YData')+DistanceMoved(2));
                    end
                end
                if Line1bXData(1)>=Line2XData(2)    	% make sure lines dont cross
                    NewData(1)=NewData(1)+DistanceMoved(1);
                elseif xscale == 1
                    NewData(1)=NewData(1)+10;
                else
                    NewData(1)=NewData(1)+.01;
                end
                set(handles.Line1b,'XData',NewData);
                if yscale == 1	% linear
                    set(handles.Line1a,'XData', get(handles.Line1b,'XData'),'YData', 2-get(handles.Line1b,'YData'));
                else            % dB
                    dB=get(handles.Line1b,'YData');
                    lin=10^(dB(1)/20);
                    lin = 2-lin;
                    dB=[20*log10(lin),20*log10(lin)];
                    set(handles.Line1a,'XData', get(handles.Line1b,'XData'),'YData', dB);
                end
                %-----------------------------------
            case 'Butterworth Bandpass'
                %-----------------------------------
                NewData = get(handles.Line1b,'XData');	% get data to manipulate
                if yscale == 1	% linear
                    if (get(handles.Line1b,'YData')+DistanceMoved(2))>=0.5 & (get(handles.Line1b,'YData')+DistanceMoved(2))<=1.5       % make sure passband error =+/- 0.5
                        set(handles.Line1b,'YData', get(handles.Line1b,'YData')+DistanceMoved(2));
                    end
                else            % dB
                    if (get(handles.Line1b,'YData')+DistanceMoved(2))>=20*log10(0.5) & (get(handles.Line1b,'YData')+DistanceMoved(2))<=20*log10(1.5)       % make sure passband error =+/- 0.5
                        set(handles.Line1b,'YData', get(handles.Line1b,'YData')+DistanceMoved(2));
                    end
                end
                if abs(OldXY(1)-NewData(1)) < abs(OldXY(1)-NewData(2))  % if left point on Line1b is moved
                    if Line1bXData(1)>=Line2XData(2)                    % make sure lines dont cross
                        NewData(1)=NewData(1)+DistanceMoved(1);
                    elseif xscale == 1
                        NewData(1) = NewData(1) + 10;
                    else
                        NewData(1) = NewData(1) + 0.01;
                    end
                else                                                    % if right point on Line1b is moved
                    if Line1bXData(2)<=Line3XData(1)                    % make sure lines dont cross
                        NewData(2)=NewData(2)+DistanceMoved(1);
                    elseif xscale == 1
                        NewData(2) = NewData(2) - 10;
                    else
                        NewData(2) = NewData(2) - 0.01;
                    end
                end
                set(handles.Line1b,'XData',NewData);
                if yscale == 1	% linear
                    set(handles.Line1a,'XData', get(handles.Line1b,'XData'),'YData', 2-get(handles.Line1b,'YData'));
                else            % dB
                    dB= get(handles.Line1b,'YData');
                    lin = 10^(dB(1)/20);
                    lin = 2-lin;
                    dB  = [20*log10(lin),20*log10(lin)];
                    set(handles.Line1a,'XData', get(handles.Line1b,'XData'),'YData', dB);
                end
                %-----------------------------------
            case 'Kaiser Lowpass'
                %-----------------------------------
                NewData = get(handles.Line1b,'XData');                 % get data to manipulate
                if yscale == 1                % linear
                    if (get(handles.Line1b,'YData')+DistanceMoved(2))>=0.5 & (get(handles.Line1b,'YData')+DistanceMoved(2))<=1.5       % make sure passband error =+/- 0.5
                        set(handles.Line1b,'YData', get(handles.Line1b,'YData')+DistanceMoved(2));
                    end
                else
                    if (get(handles.Line1b,'YData')+DistanceMoved(2))>=20*log10(0.5) & (get(handles.Line1b,'YData')+DistanceMoved(2))<=20*log10(1.5)       % make sure passband error =+/- 0.5
                        set(handles.Line1b,'YData', get(handles.Line1b,'YData')+DistanceMoved(2));
                    end
                end
                if Line1bXData(2)<=Line3XData(1)                    % make sure lines dont cross
                    NewData(2) = NewData(2)+DistanceMoved(1);
                elseif xscale == 1
                    NewData(2) = NewData(2) - 10;
                else
                    NewData(2) = NewData(2) - 0.01;
                end
                set(handles.Line1b,'XData',NewData);
                if yscale == 1	% linear
                    set(handles.Line1a,'XData', get(handles.Line1b,'XData'),'YData', 2-get(handles.Line1b,'YData'));
                else            % dB
                    dB  = get(handles.Line1b,'YData');
                    lin = 10^(dB(1)/20);
                    lin = 2-lin;
                    dB  = [20*log10(lin),20*log10(lin)];
                    set(handles.Line1a,'XData', get(handles.Line1b,'XData'),'YData', dB);
                end

                %-- delete this if you dont want lines moving together in Kaiser --%
                if yscale == 1
                    set(handles.Line3,'YData', abs(1-get(handles.Line1b,'YData')));
                else
                    dB  = get(handles.Line1b,'YData');
                    lin = 10^(dB(1)/20);
                    lin = abs(1-lin);
                    dB  = [20*log10(lin),20*log10(lin)];
                    set(handles.Line3,'YData', dB);
                end
                %-------------------------------------------------------------------%
                %-----------------------------------
            case 'Kaiser Highpass'  % CHECK THIS
                %-----------------------------------
                NewData = get(handles.Line1b,'XData');             % get data to manipulate
                if yscale == 1                % linear
                    if (get(handles.Line1b,'YData')+DistanceMoved(2))>=0.5 & (get(handles.Line1b,'YData')+DistanceMoved(2))<=1.5       % make sure passband error =+/- 0.5
                        set(handles.Line1b,'YData', get(handles.Line1b,'YData')+DistanceMoved(2));
                    end
                else
                    if (get(handles.Line1b,'YData')+DistanceMoved(2))>=20*log10(0.5) & (get(handles.Line1b,'YData')+DistanceMoved(2))<=20*log10(1.5)       % make sure passband error =+/- 0.5
                        set(handles.Line1b,'YData', get(handles.Line1b,'YData')+DistanceMoved(2));
                    end
                end

                if Line2XData(2) <= Line1bXData(1)   % make sure lines dont cross
                    NewData(1) = NewData(1) + DistanceMoved(1);
                elseif xscale == 1
                    NewData(1) = NewData(1) + 10;
                else
                    NewData(1) = NewData(1) + 0.01;
                end

                set(handles.Line1b,'XData',NewData);
                if yscale == 1	% linear
                    set(handles.Line1a,'XData', get(handles.Line1b,'XData'),'YData',2-get(handles.Line1b,'YData'));
                else            % dB
                    dB  = get(handles.Line1b,'YData');
                    lin = 2 - (10^(dB(1)/20));
                    dB  = [20*log10(lin),20*log10(lin)];
                    set(handles.Line1a,'XData',get(handles.Line1b,'XData'),'YData',dB);
                end

                %-- delete this if you dont want lines moving together in Kaiser --%
                if yscale == 1
                    set(handles.Line2,'YData',abs(1-get(handles.Line1b,'YData')));
                else
                    dB  = get(handles.Line1b,'YData');
                    lin = abs(1 - 10^(dB(1)/20));
                    dB  = [20*log10(lin),20*log10(lin)];
                    set(handles.Line2,'YData', dB);
                end
                %-------------------------------------------------------------------%
                %-----------------------------------
            case 'Kaiser Bandpass'
                %-----------------------------------
                NewData = get(handles.Line1b,'XData');                 % get data to manipulate
                if yscale == 1	% linear
                    if (get(handles.Line1b,'YData')+DistanceMoved(2))>=0.5 & (get(handles.Line1b,'YData')+DistanceMoved(2))<=1.5       % make sure passband error =+/- 0.5
                        set(handles.Line1b,'YData', get(handles.Line1b,'YData')+DistanceMoved(2));
                    end
                else
                    if (get(handles.Line1b,'YData')+DistanceMoved(2))>=20*log10(0.5) & (get(handles.Line1b,'YData')+DistanceMoved(2))<=20*log10(1.5)	% make sure passband error =+/- 0.5
                        set(handles.Line1b,'YData', get(handles.Line1b,'YData')+DistanceMoved(2));
                    end
                end
                if abs(OldXY(1)-NewData(1)) < abs(OldXY(1)-NewData(2))  % if left point on Line1b is moved
                    if Line1bXData(1)>=Line2XData(2)                    % make sure lines dont cross
                        NewData(1) = NewData(1)+DistanceMoved(1);
                    elseif xscale == 1
                        NewData(1) = NewData(1) + 10;
                    else
                        NewData(1)= NewData(1) + 0.01;
                    end
                else                                                    % if right point on Line1b is moved
                    if Line1bXData(2) <= Line3XData(1)                    % make sure lines dont cross
                        NewData(2) = NewData(2)+DistanceMoved(1);
                    elseif xscale == 1
                        NewData(2) = NewData(2) - 10;
                    else
                        NewData(2) = NewData(2) - 0.01;
                    end
                end
                set(handles.Line1b,'XData',NewData);
                if yscale == 1	% linear
                    set(handles.Line1a,'XData', get(handles.Line1b,'XData'),'YData', 2-get(handles.Line1b,'YData'));
                else            % dB
                    dB = get(handles.Line1b,'YData');
                    lin = 10^(dB(1)/20);
                    lin = 2-lin;
                    dB = [20*log10(lin),20*log10(lin)];
                    set(handles.Line1a,'XData', get(handles.Line1b,'XData'),'YData', dB);
                end

                %-- delete this if you dont want lines moving together in Kaiser --%
                if yscale == 1
                    set(handles.Line3,'YData',abs(1-get(handles.Line1b,'YData')));
                    set(handles.Line2,'YData',abs(1-get(handles.Line1b,'YData')));
                else
                    dB = get(handles.Line1b,'YData');
                    lin = 10^(dB(1)/20);
                    lin = abs(1-lin);
                    dB = [20*log10(lin),20*log10(lin)];
                    set([handles.Line2,handles.Line3],'YData',dB);
                end
                %-------------------------------------------------------------------%
        end
        %-----------------------------------
    case 'Line2'
        %-----------------------------------
        NewData = get(handles.Line2,'XData');
        if yscale == 1 	% linear
            if (get(handles.Line2,'YData')+DistanceMoved(2))>0 & (get(handles.Line2,'YData')+DistanceMoved(2))<.5
                set(handles.Line2,'YData', get(handles.Line2,'YData')+DistanceMoved(2));
            end
        else            % dB
            if (get(handles.Line2,'YData')+DistanceMoved(2))>-80 & (get(handles.Line2,'YData')+DistanceMoved(2))<20*log10(.5)
                set(handles.Line2,'YData', get(handles.Line2,'YData')+DistanceMoved(2));
            end
        end
        if Line1aXData(1)>=Line2XData(2)
            NewData(2)=NewData(2)+DistanceMoved(1);
        elseif xscale == 1
            NewData(2)=NewData(2)-10;
        else
            NewData(2)=NewData(2)-.01;
        end
        set(handles.Line2,'XData',NewData);

        if strcmp(filt_name,'Butterworth Bandpass')                  % BPF case
            set(handles.Line3,'YData', get(handles.Line2,'YData'));
            %-- delete this if you dont want lines moving together in Kaiser --%
        elseif strcmp(filt_name,'Kaiser Highpass')
            if yscale == 1        % linear scale
                set(handles.Line1a,'YData', 1+get(handles.Line2,'YData'));
                set(handles.Line1b,'YData', 1-get(handles.Line2,'YData'));
            else
                dB = get(handles.Line2,'YData');
                lin = 10^(dB(1)/20);
                lin1 = 1+lin;
                lin2 = 1-lin;
                dB1 = [20*log10(lin1),20*log10(lin1)];
                dB2 = [20*log10(lin2),20*log10(lin2)];
                set(handles.Line1a,'YData', dB1);
                set(handles.Line1b,'YData', dB2);
            end
        elseif strcmp(filt_name,'Kaiser Bandpass')                    % KaiserBP case
            if yscale == 1        % linear scale
                set(handles.Line1a,'YData', 1+get(handles.Line2,'YData'));
                set(handles.Line1b,'YData', 1-get(handles.Line2,'YData'));
                set(handles.Line3,'YData', get(handles.Line2,'YData'));
            else
                dB = get(handles.Line2,'YData');
                lin = 10^(dB(1)/20);
                lin1 = 1+lin;
                lin2 = 1-lin;
                dB1 = [20*log10(lin1),20*log10(lin1)];
                dB2 = [20*log10(lin2),20*log10(lin2)];
                set(handles.Line1a,'YData', dB1);
                set(handles.Line1b,'YData', dB2);
                set(handles.Line3,'YData', dB);
            end
            %-------------------------------------------------------------------%
        end
        %-----------------------------------
    case 'Line3'
        %-----------------------------------
        NewData = get(handles.Line3,'XData');
        if yscale==1	% linear
            if (get(handles.Line3,'YData')+DistanceMoved(2))>0 & (get(handles.Line3,'YData')+DistanceMoved(2))<.5
                set(handles.Line3,'YData', get(handles.Line3,'YData')+DistanceMoved(2));
            end
        else
            if (get(handles.Line3,'YData')+DistanceMoved(2))>-80 & (get(handles.Line3,'YData')+DistanceMoved(2))<20*log10(.5)
                set(handles.Line3,'YData', get(handles.Line3,'YData')+DistanceMoved(2));
            end
        end
        if Line1aXData(2) <= Line3XData(1)
            NewData(1) = NewData(1) + DistanceMoved(1);
        elseif xscale == 1
            NewData(1) = NewData(1) + 10;
        else
            NewData(1) = NewData(1) + 0.01;
        end
        set(handles.Line3,'XData',NewData);
        if strcmp(filt_name,'Butterworth Bandpass')  % BPF case
            set(handles.Line2,'YData', get(handles.Line3,'YData'));

            %-- delete this if you dont want lines moving together in Kaiser --%
        elseif strcmp(filt_name,'Kaiser Lowpass')                    % Kaiser Lowpass case
            if yscale == 1        % linear scale
                set(handles.Line1a,'YData', 1+get(handles.Line3,'YData'));
                set(handles.Line1b,'YData', 1-get(handles.Line3,'YData'));
            else
                dB = get(handles.Line3,'YData');
                lin = 10^(dB(1)/20);
                lin1 = 1+lin;
                lin2 = 1-lin;
                dB1 = [20*log10(lin1),20*log10(lin1)];
                dB2 = [20*log10(lin2),20*log10(lin2)];
                set(handles.Line1a,'YData', dB1);
                set(handles.Line1b,'YData', dB2);
            end
        elseif strcmp(filt_name,'Kaiser Bandpass')                    % Kaiser Bandpass case
            if yscale == 1        % linear scale
                set(handles.Line1a,'YData', 1+get(handles.Line3,'YData'));
                set(handles.Line1b,'YData', 1-get(handles.Line3,'YData'));
                set(handles.Line2,'YData', get(handles.Line3,'YData'));
            else
                dB = get(handles.Line3,'YData');
                lin = 10^(dB(1)/20);
                lin1 = 1+lin;
                lin2 = 1-lin;
                dB1 = [20*log10(lin1),20*log10(lin1)];
                dB2 = [20*log10(lin2),20*log10(lin2)];
                set(handles.Line1a,'YData', dB1);
                set(handles.Line1b,'YData', dB2);
                set(handles.Line2,'YData', dB);
            end
            %-------------------------------------------------------------------%
        end
        %-----------------------------------
    case 'Line4a'
        %-----------------------------------
        NewData = get(handles.Line4a,'XData');                 % get data to manipulate
        if yscale == 1                % linear
            if (get(handles.Line4a,'YData')+DistanceMoved(2))<=1.5 & (get(handles.Line4a,'YData')+DistanceMoved(2))>=0.5       % make sure passband error =+/- 0.5
                set(handles.Line4a,'YData', get(handles.Line4a,'YData')+DistanceMoved(2));
            end
        else                        % dB
            if (get(handles.Line4a,'YData')+DistanceMoved(2))<=20*log10(1.5) & (get(handles.Line4a,'YData')+DistanceMoved(2))>=20*log10(0.5)       % make sure passband error =+/- 0.5
                set(handles.Line4a,'YData', get(handles.Line4a,'YData')+DistanceMoved(2));
            end
        end
        if Line4aXData(2)<=Line6XData(1)   % check for constraints
            NewData(2) = NewData(2)+DistanceMoved(1);
        elseif xscale == 1
            NewData(2) = NewData(2) - 10;
        else
            NewData(2) = NewData(2) - 0.01;
        end
        set(handles.Line4a,'XData',NewData);
        if yscale == 1    % linear
            set(handles.Line4b,'XData', get(handles.Line4a,'XData'),'YData', 2-get(handles.Line4a,'YData'));    % makes passband lines move together
            set(handles.Line5a,'YData', get(handles.Line4a,'YData'));
            set(handles.Line5b,'YData', 2-get(handles.Line4a,'YData'));
        else            % dB
            dB = get(handles.Line4a,'YData');
            set(handles.Line5a,'YData', dB);                                        % passband lines move together
            lin = 10^(dB(1)/20);
            lin = 2-lin;
            dB = [20*log10(lin),20*log10(lin)];
            set(handles.Line4b,'XData', get(handles.Line4a,'XData'),'YData', dB);
            set(handles.Line5b,'YData', dB);
        end
        switch filt_name
            %-----------------------------------
            case 'Kaiser Bandreject'
                %-----------------------------------
                %-- delete this if you dont want lines moving together in Kaiser --%
                if yscale == 1
                    set(handles.Line6,'YData', abs(1-get(handles.Line4a,'YData')));
                else
                    dB = get(handles.Line4a,'YData');
                    lin = 10^(dB(1)/20);
                    lin = abs(1-lin);
                    dB = [20*log10(lin),20*log10(lin)];
                    set(handles.Line6,'YData', dB);
                end
                %-------------------------------------------------------------------%
        end
        %-----------------------------------
    case 'Line4b'
        %-----------------------------------
        NewData = get(handles.Line4b,'XData');                 % get data to manipulate
        if yscale == 1                % linear
            if (get(handles.Line4b,'YData')+DistanceMoved(2))<=1.5 & (get(handles.Line4b,'YData')+DistanceMoved(2))>=0.5       % make sure passband error =+/- 0.5
                set(handles.Line4b,'YData', get(handles.Line4b,'YData')+DistanceMoved(2));
            end
        else                        % dB
            if (get(handles.Line4b,'YData')+DistanceMoved(2))<=20*log10(1.5) & (get(handles.Line4b,'YData')+DistanceMoved(2))>=20*log10(0.5)       % make sure passband error =+/- 0.5
                set(handles.Line4b,'YData', get(handles.Line4b,'YData')+DistanceMoved(2));
            end
        end
        if Line4bXData(2)<=Line6XData(1)   % check for constraints
            NewData(2)=NewData(2)+DistanceMoved(1);
        elseif xscale == 1
            NewData(2) = NewData(2) - 10;
        else
            NewData(2) = NewData(2) - 0.01;
        end
        set(handles.Line4b,'XData',NewData);
        if yscale == 1    % linear
            set(handles.Line4a,'XData', get(handles.Line4b,'XData'),'YData', 2-get(handles.Line4b,'YData'));    % makes passband lines move together
            set(handles.Line5a,'YData', get(handles.Line4b,'YData'));
            set(handles.Line5b,'YData', 2-get(handles.Line4b,'YData'));
        else            % dB
            dB = get(handles.Line4b,'YData');
            set(handles.Line5a,'YData', dB);                                        % passband lines move together
            lin = 10^(dB(1)/20);
            lin = 2-lin;
            dB = [20*log10(lin),20*log10(lin)];
            set(handles.Line4a,'XData', get(handles.Line4b,'XData'),'YData', dB);
            set(handles.Line5b,'YData', dB);
        end
        switch filt_name
            case 'Kaiser Bandreject'
                %-- delete this if you dont want lines moving together in Kaiser --%
                if yscale == 1
                    set(handles.Line6,'YData', abs(1-get(handles.Line4b,'YData')));
                else
                    dB = get(handles.Line4b,'YData');
                    lin = 10^(dB(1)/20);
                    lin = abs(1-lin);
                    dB = [20*log10(lin),20*log10(lin)];
                    set(handles.Line6,'YData', dB);
                end
                % -------------------------------------------------------------------%
        end
        %-----------------------------------
    case 'Line5a'
        %-----------------------------------
        NewData = get(handles.Line5a,'XData');                 % get data to manipulate
        if yscale == 1                % linear
            if (get(handles.Line5a,'YData')+DistanceMoved(2))<=1.5 & (get(handles.Line5a,'YData')+DistanceMoved(2))>=0.5       % make sure passband error =+/- 0.5
                set(handles.Line5a,'YData', get(handles.Line5a,'YData')+DistanceMoved(2));
            end
        else                        % dB
            if (get(handles.Line5a,'YData')+DistanceMoved(2))<=20*log10(1.5) & (get(handles.Line5a,'YData')+DistanceMoved(2))>=20*log10(0.5)       % make sure passband error =+/- 0.5
                set(handles.Line5a,'YData', get(handles.Line5a,'YData')+DistanceMoved(2));
            end
        end
        if Line5aXData(1) >= Line6XData(2)   % check for constraints
            NewData(1)=NewData(1)+DistanceMoved(1);
        elseif xscale == 1
            NewData(1) = NewData(1) + 10;
        else
            NewData(1) = NewData(1) + 0.01;
        end
        set(handles.Line5a,'XData',NewData);
        if yscale == 1    % linear
            set(handles.Line5b,'XData', get(handles.Line5a,'XData'),'YData', 2-get(handles.Line5a,'YData'));    % makes passband lines move together
            set(handles.Line4a,'YData', get(handles.Line5a,'YData'));
            set(handles.Line4b,'YData', 2-get(handles.Line5a,'YData'));
        else            % dB
            dB = get(handles.Line5a,'YData');
            set(handles.Line4a,'YData', dB);                                        % passband lines move together
            lin = 10^(dB(1)/20);
            lin = 2-lin;
            dB = [20*log10(lin),20*log10(lin)];
            set(handles.Line5b,'XData', get(handles.Line5a,'XData'),'YData', dB);
            set(handles.Line4b,'YData', dB);
        end

        switch filt_name
            case 'Kaiser Bandreject'
                %-- delete this if you dont want lines moving together in Kaiser --%
                if yscale == 1
                    set(handles.Line6,'YData', abs(1-get(handles.Line5a,'YData')));
                else
                    dB = get(handles.Line5a,'YData');
                    lin = 10^(dB(1)/20);
                    lin = abs(1-lin);
                    dB = [20*log10(lin),20*log10(lin)];
                    set(handles.Line6,'YData', dB);
                end
                %------------------------------------------------------------------%
        end
        %-----------------------------------
    case 'Line5b'
        %-----------------------------------
        NewData = get(handles.Line5b,'XData'); % get data to manipulate
        if yscale == 1              % linear
            if (get(handles.Line5b,'YData')+DistanceMoved(2))<=1.5 & (get(handles.Line5b,'YData')+DistanceMoved(2))>=0.5       % make sure passband error =+/- 0.5
                set(handles.Line5b,'YData', get(handles.Line5b,'YData')+DistanceMoved(2));
            end
        else                        % dB
            if (get(handles.Line5b,'YData')+DistanceMoved(2))<=20*log10(1.5) & (get(handles.Line5b,'YData')+DistanceMoved(2))>=20*log10(0.5)       % make sure passband error =+/- 0.5
                set(handles.Line5b,'YData', get(handles.Line5b,'YData')+DistanceMoved(2));
            end
        end

        if Line5bXData(1) >= Line6XData(2)   % check for constraints
            NewData(1) = NewData(1)+DistanceMoved(1);
        elseif xscale == 1
            NewData(1) = NewData(1) + 10;
        else
            NewData(1) = NewData(1) + 0.01;
        end
        set(handles.Line5b,'XData',NewData);
        if yscale == 1    % linear
            set(handles.Line5a,'XData', get(handles.Line5b,'XData'),'YData',2-get(handles.Line5b,'YData'));    % makes passband lines move together
            set(handles.Line4a,'YData', 2-get(handles.Line5b,'YData'));
            set(handles.Line4b,'YData', get(handles.Line5b,'YData'));
        else            % dB
            dB = get(handles.Line5b,'YData');
            set(handles.Line4b,'YData', dB);                                        % passband lines move together
            lin = 10^(dB(1)/20);
            lin = 2-lin;
            dB = [20*log10(lin),20*log10(lin)];
            set(handles.Line5a,'XData', get(handles.Line5b,'XData'),'YData', dB);
            set(handles.Line4a,'YData', dB);
        end

        switch filt_name
            case 'Kaiser Bandreject'
                %-- delete this if you dont want lines moving together in Kaiser --%
                if yscale == 1
                    set(handles.Line6,'YData', abs(1-get(handles.Line5b,'YData')));
                else
                    dB = get(handles.Line5b,'YData');
                    lin = 10^(dB(1)/20);
                    lin = abs(1-lin);
                    dB = [20*log10(lin),20*log10(lin)];
                    set(handles.Line6,'YData', dB);
                end
                %-------------------------------------------------------------------%
        end
        %-----------------------------------
    case 'Line6'
        %-----------------------------------
        NewData = get(handles.Line6,'XData');                 % get data to manipulate
        if yscale == 1                % linear
            if (get(handles.Line6,'YData')+DistanceMoved(2))<0.5 & (get(handles.Line6,'YData')+DistanceMoved(2))>0       % make sure stopband error <= 0.5
                set(handles.Line6,'YData', get(handles.Line6,'YData')+DistanceMoved(2));
            end
        else                        % dB
            if (get(handles.Line6,'YData')+DistanceMoved(2))<20*log10(0.5) & (get(handles.Line6,'YData')+DistanceMoved(2))>-80       % make sure stopband error <= 0.5
                set(handles.Line6,'YData', get(handles.Line6,'YData')+DistanceMoved(2));
            end
        end
        if abs(OldXY(1) - NewData(1)) < abs(OldXY(1) - NewData(2))  % if left point on Line6 is moved
            if Line6XData(1) >= Line4aXData(2)                    % make sure lines dont cross
                NewData(1) = NewData(1) + DistanceMoved(1);
            elseif xscale == 1
                NewData(1) = NewData(1) + 10;
            else
                NewData(1) = NewData(1) + 0.01;
            end
        else                                                    % if right point on Line1b is moved
            if Line6XData(2) <= Line5aXData(1)                    % make sure lines dont cross
                NewData(2) = NewData(2) + DistanceMoved(1);
            elseif xscale == 1
                NewData(2) = NewData(2) - 10;
            else
                NewData(2) = NewData(2) - 0.01;
            end
        end
        set(handles.Line6,'XData',NewData);

        switch filt_name
            case 'Kaiser Bandreject'
                %-- delete this if you dont want lines moving together in Kaiser --%
                if yscale == 1
                    set([handles.Line4a,handles.Line5a],'YData', 1+get(handles.Line6,'YData'));
                    set([handles.Line4b,handles.Line5b],'YData', 1-get(handles.Line6,'YData'));
                else
                    dB = get(handles.Line6,'YData');
                    lin = 10^(dB(1)/20);    %lin=abs(1-lin);
                    dB1 = [20*log10(1+lin),20*log10(1+lin)];
                    dB2 = [20*log10(1-lin),20*log10(1-lin)];
                    set([handles.Line4a,handles.Line5a],'YData', dB1);
                    set([handles.Line4b,handles.Line5b],'YData', dB2);
                end
                %-------------------------------------------------------------------%
                %-----------------------------------
        end
end
setappdata(gcbf,'CurrentXY',CurrentXY);
%====================================================================
% --------------------------- M E N U --------------------------------
%====================================================================
function varargout = menu_export_to_workspace_Callback(h, eventdata, handles, varargin)
%====================================================================
%Call for "Export > To Workspace"
cdhandles = fd_coeffdlg(handles);

if cdhandles.export
    num_name = cdhandles.num;
    den_name = cdhandles.den;

    assignin('base',num_name,handles.b );
    assignin('base',den_name,handles.a );

    disp(['"' num_name '"' ' and ' '"' den_name '"' ' have been added to workspace'])
end
%====================================================================
function varargout = menu_export_to_file_Callback(h, eventdata, handles, varargin)
%====================================================================
%Call for "Export > To File"
[fname, pname] = uiputfile('*.mat','Choose File to Save Filter Coefficients');

if pname ~= 0
    a = handles.a;
    b = handles.b;
    save ([pname,fname], 'a','b');
end
%====================================================================
function varargout = menu_exit_Callback(h, eventdata, handles, varargin)
%====================================================================
delete(handles.figure1);    % Call for "Exit"
%====================================================================
function varargout = menu_set_line_width_Callback(h, eventdata, handles, varargin)
%====================================================================
handles.LineWidth = linewidthdlg(get(handles.Line1a,'linewidth'));
set([handles.Line1a,handles.Line1b,handles.Line2,handles.Line3,handles.Line4a,handles.Line4b, ...
    handles.Line5a,handles.Line5b,handles.Line6,handles.LineMain,handles.LineGreen,...
    handles.PoleLine,handles.LineStem1,handles.LineStem2, handles.RemezHorz1, ...
    handles.RemezHorz2, handles.RemezHorz3, handles.RemezExtre1,...
    handles.RemezExtre2],'linewidth',handles.LineWidth);
guidata(handles.figure1,handles);
%setappdata(gcbf,'DataStructure',handles);
%====================================================================
function varargout = menu_x_scale_Callback(h, eventdata, handles, varargin)
%====================================================================
if strcmp(get(findobj(gcbf,'tag','MagResp'),'vis'),'off') | strcmp(get(findobj(gcbf,'tag','PhaseResp'),'vis'),'off')
    [params,Wpass1,Wstop1,Wpass2,Wstop2,Rp_dB,Rs_dB,order_type,xscale,yscale,omega] = user(handles);

    % Register @spfirst_axis object
    buttonfcns(handles.XaxisT,'ButtonDown');

    design_num = get(handles.DesignMenu,'value');
    names      = get(handles.DesignMenu,'string');
    handles.design_name = names{design_num};

    if strcmp(get(handles.menu_x_scale,'checked'),'on')
        % Radian frequencies
        set(handles.Fpass1,'string',num2str(Wpass1));
        set(handles.Fstop1,'string',num2str(Wstop1));
        set(handles.Fpass2,'string',num2str(Wpass2));
        set(handles.Fstop2,'string',num2str(Wstop2));

        % rescale omega_hat font    
        set(handles.Fpass1Tag,'fontunits','points');
        set([handles.wFpass1Tag,handles.wFstop1Tag,handles.wFpass2Tag,handles.wFstop2Tag], ...
            'fontsize',get(handles.Fpass1Tag,'fontsize'));
        set(handles.Fpass1Tag,'fontunits','norm');
    else
        % Hz frequencies
        set(handles.Fpass1,'string',num2str(params.Fpass1));
        set(handles.Fstop1,'string',num2str(params.Fstop1));
        set(handles.Fpass2,'string',num2str(params.Fpass2));
        set(handles.Fstop2,'string',num2str(params.Fstop2));
    end % chk
    % update units
    filt_num = get(handles.Filter,'value');
    switch handles.filt_type
        case 'FIR'
            switch filt_num
                case {1,2}
                    set([handles.unitsFpass2,handles.unitsFstop2],'vis','off');
                    set(handles.unitsFpass1,'vis','on');
                    if strcmp(handles.win_name,'Kaiser') % Kaiser
                        set(handles.unitsFstop1,'vis','on');
                    end
                case {3,4}
                    set([handles.unitsFpass1,handles.unitsFpass2],'vis','on');
                    if strcmp(handles.design_name,'Window')
                        if strcmp(handles.win_name,'Kaiser') % Kaiser
                            set([handles.unitsFstop1,handles.unitsFstop2],'vis','on');
                        else
                            set([handles.unitsFstop1,handles.unitsFstop2],'vis','off');
                        end
                    else
                        set([handles.unitsFstop1,handles.unitsFstop2],'vis','on');
                    end
            end
        case 'IIR'
            switch filt_num
                case {1,2,5}
                    set([handles.unitsFpass1,handles.unitsFstop1],'vis','on');
                case {3,4,6,7}
                    set([handles.unitsFpass1,handles.unitsFstop1,handles.unitsFpass2,handles.unitsFstop2],'vis','on');
            end
    end
    % end chk
    handles = chooseFilter(handles,params);
    guidata(handles.figure1,handles);
end
%====================================================================
function varargout = menu_y_scale_Callback(h,eventdata,handles, varargin)
%====================================================================
if strcmp(get(findobj(gcbf,'tag','MagResp'),'vis'),'off')
    % y scale (magnitude in dB) button in menu
    [params,Wpass1,Wstop1,Wpass2,Wstop2,Rp_dB,Rs_dB,order_type,xscale,yscale,omega] = user(handles);
    design_num  = get(handles.DesignMenu,'value');
    names       = get(handles.DesignMenu,'string');
    handles.design_name = names{design_num};

    if strcmp(get(handles.menu_y_scale,'checked'),'off')            % in dB
        set(handles.menu_y_scale,'checked','on');
        set([handles.Rpass,handles.Rstop,handles.RpassTag,handles.RstopTag],{'str'},{num2str(Rp_dB);num2str(Rs_dB);'R_{pass}';'R_{stop}'});

        if strcmp(handles.filt_type,'IIR')
            set([handles.unitsRpass,handles.unitsRstop],'vis','on'); % update units to (dB)
        end
    else
        set(handles.menu_y_scale,'checked','off');
        set([handles.Rpass,handles.Rstop,handles.RpassTag,handles.RstopTag],{'str'},{num2str(params.Rpass);num2str(params.Rstop);'\delta_{pass}';'\delta_{stop}'});
        set([handles.unitsRpass,handles.unitsRstop],'vis','off');    % update units, no (dB)
    end
    handles = chooseFilter(handles,params);
    guidata(handles.figure1,handles);
end
%====================================================================
function varargout = menu_grid_Callback(h, eventdata, handles, varargin)
%====================================================================
axes(handles.Plot1);
if strcmp(get(h,'checked'),'on')
    grid off;
    set(gcbo,'checked','off');
else
    grid on;
    set(gcbo,'checked','on');
end
%====================================================================
function varargout = menu_zoom_Callback(h, eventdata, handles, varargin)
%====================================================================
% zoom button in menu
axes(handles.Plot1);
if strcmp(get(h,'checked'),'on')
    set(handles.zoomText,'visible','off');
    zoom off;
    set(gcbo,'checked','off');
else
    set(handles.zoomText,'visible','on');
    zoom on;
    set(gcbo,'checked','on');
end
%====================================================================
function varargout = menu_help_Callback(h, eventdata, handles, varargin)
%====================================================================
MATLABVER = versioncheck(6);
hBar = waitbar(0.25,'Opening internet browser...','color',get(handles.figure1,'color'));
DefPath = which(mfilename);
DefPath = ['file:///' strrep(DefPath,filesep,'/') ];
URL = [ DefPath(1:end-length(mfilename)-2) , 'help/','index.html'];
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
            'which is located in the filter help directory.'};
        errordlg(s,'Error launching browser.');
end
%====================================================================
function Rpass_ButtonDownFcn(hObject, eventdata, handles)
function FilterMenu_CreateFcn(hObject, eventdata, handles)
function WindowsMenu_CreateFcn(hObject, eventdata, handles)
%====================================================================
function handles = SetFIRMenu(handles)
%====================================================================
fs = str2double(get(handles.Fsamp,'string'));
design_num = get(handles.DesignMenu,'value');

% Added Design Menu and design method for remez
% Enables Windows and Filter Type menus
set([handles.WindowsMenu,handles.Windows,handles.DesMethod,handles.DesignMenu],'visible','on');
set([handles.Fstop1,handles.Fpass2,handles.Fstop2,handles.Rpass,handles.Rstop,handles.Fstop1Tag, ...
    handles.Fpass2Tag,handles.Fstop2Tag,handles.RpassTag,handles.RstopTag,handles.SetOrder],'visible','off');
set([handles.Order,handles.WindowsMenu,handles.DesignMenu],'enable','On'); % set(handles.Order,'string','20');
SetOrder_Callback([],[],handles);

if design_num == 1
    set([handles.Windows,handles.WindowsMenu],'vis','on');
    set(handles.note,'vis','off');

    if strcmp(handles.win_name,'Kaiser') % KAISER
        set([handles.SetOrder,handles.Fstop1,handles.Fstop1Tag,handles.unitsFstop1,handles.Rpass,handles.Rstop],'vis','on');
        set([handles.unitsRpass,handles.unitsRstop,handles.KaiserB],'vis','on');
    else
        set(handles.Order,'enable','on');
        set([handles.SetOrder,handles.Rpass,handles.Rstop,handles.unitsRstop,handles.unitsRpass,handles.KaiserB],'vis','off');
        set(handles.Plot1,'UIContextMenu',handles.VariousResp);

        if strcmp(handles.win_name,'Gaussian')
            set(handles.alpha,'str',2.5);
        elseif strcmp(handles.win_name,'Dolph-Chebyshev')
            set(handles.alpha,'str',3);
        end
    end
elseif design_num == 2
    set(handles.SetOrder,'vis','on');
    set([handles.Windows,handles.WindowsMenu,handles.KaiserB,handles.alpha],'vis','off');
end

switch handles.filt_name
    %---%---------------------
    case 'Lowpass'
        %---------------------
        if design_num == 1  % Design Method: Window
            if strcmp(handles.win_name,'Kaiser') % KAISER
                set(handles.Fpass1Tag,'string','F_{pass}');
                set(handles.Fstop1Tag,'string','F_{stop}');
                set([handles.Fpass2,handles.Fstop2,handles.Fpass2Tag,handles.Fstop2Tag, ...
                    handles.unitsFpass2,handles.unitsFstop2],'vis','off');
                set(handles.SetOrder,'enable','on');
            else
                set(handles.Fpass1Tag,'string','F_{cutoff}');
                set([handles.Fpass2Tag,handles.Fpass2,handles.unitsFstop1,handles.unitsFpass2,handles.unitsFstop2],'vis','off');
            end
        elseif design_num == 2 % Design Method: PM filter
            set(handles.Fpass1Tag,'string','F_{pass}');
            set(handles.Fstop1Tag,'string','F_{stop}');
            set([handles.Fpass1Tag, handles.Fstop1Tag,handles.Fpass1,handles.Fstop1],'vis', 'on');
            set([handles.unitsFpass1,handles.unitsFstop1],'vis','on');
            set([handles.unitsFpass2,handles.unitsFstop2],'vis','off');
        end
        if strcmp(get(handles.menu_x_scale,'checked'),'on')     % normalized freq
            if design_num == 1
                set(handles.Fpass1,'string', num2str(4/16) );   % set default values
                if strcmp(handles.win_name,'Kaiser')
                    set(handles.Fstop1,'string', num2str(6/16) );
                end
            elseif design_num == 2
                set(handles.Fpass1,'string', num2str(4/16) );
                set(handles.Fstop1,'string', num2str(6/16) );
            end
            %% set([handles.unitsFpass1,handles.unitsFstop1],'vis','off');
        else
            if design_num == 1
                set(handles.Fpass1,'string',num2str(ceil(2*fs/16)));
                set(handles.unitsFpass1,'vis','on');  % set default values

                if strcmp(handles.win_name,'Kaiser')
                    set(handles.Fstop1, 'string', num2str(ceil(3*fs/16)) );
                end
            elseif design_num == 2
                set(handles.Fpass1,'string', num2str(2*fs/16) );
                set(handles.Fstop1,'string', num2str(3*fs/16) );
                set([handles.unitsFpass1, handles.unitsFstop1],'vis','on'); %U
            end
        end
        %---------------------
    case 'Highpass'
        %---------------------
        if design_num == 1
            if strcmp(handles.win_name,'Kaiser')
                set(handles.Fpass1Tag,'string','F_{pass}');
                set(handles.Fstop1Tag,'string','F_{stop}');
                set([handles.Fpass2,handles.Fstop2,handles.Fpass2Tag,handles.Fstop2Tag,handles.unitsFpass2,handles.unitsFstop2],'Visible','off');
                set(handles.SetOrder, 'Enable','on');
            else
                set(handles.Fpass1Tag,'string','F_{cutoff}');
                set([handles.Fpass2Tag,handles.Fpass2,handles.unitsFstop1,handles.unitsFpass2],'vis','off');
            end
        elseif design_num == 2
            set(handles.Fpass1Tag,'string','F_{pass}');
            set(handles.Fstop1Tag,'string','F_{stop}');
            set([handles.Fpass1Tag, handles.Fstop1Tag,handles.Fpass1,handles.Fstop1],'vis','on');
            set([handles.unitsFpass1,handles.unitsFstop1],'vis','on'); %U
            set([handles.unitsFpass2,handles.unitsFstop2],'vis','off');
        end

        if strcmp(get(handles.menu_x_scale,'checked'),'on')     % normalized freq
            if design_num == 1
                set(handles.Fpass1,'string',num2str(6/16) );   % set default values
                if strcmp(handles.win_name,'Kaiser')
                    set(handles.Fstop1,'string', num2str(4/16) );
                end
            elseif design_num == 2
                set(handles.Fpass1,'string', num2str(6/16) );
                set(handles.Fstop1,'string', num2str(4/16) );
            end
            %% set(handles.unitsFpass1,'vis','off'); %U
        else
            if design_num == 1
                set(handles.Fpass1,'string',num2str(ceil(3*fs/16)) );
                set(handles.unitsFpass1,'vis','on');            % set default values

                if strcmp(handles.win_name,'Kaiser')
                    set(handles.Fstop1,'string', num2str(ceil(2*fs/16)) );
                end
            elseif design_num == 2
                set(handles.Fpass1,'string', num2str(3*fs/16) );
                set(handles.Fstop1,'string', num2str(2*fs/16) );
                set([handles.unitsFpass1, handles.unitsFstop1],'vis','on');
            end
            %% set(handles.unitsFpass1,'vis','on'); %U
        end
        %---------------------
    case 'Bandpass'
        %---------------------
        if design_num == 1
            if strcmp(handles.win_name,'Kaiser')
                set(handles.Fpass1Tag,'string','F_{pass 1}');
                set(handles.Fstop1Tag,'string','F_{stop 1}');
                set(handles.Fstop2Tag,'string','F_{stop 2}');
                set(handles.SetOrder, 'Enable','on');
                set([handles.Fpass2,handles.Fstop2,handles.Fpass2Tag,handles.Fstop2Tag],'vis','on');
                set([handles.unitsFpass2,handles.unitsFstop2],'vis','on');
            else
                set(handles.Fpass1Tag,'string','F_{cutoff 1}');
                set(handles.Fpass2Tag,'string','F_{cutoff 2}');
                set([handles.Fstop1Tag,handles.Fstop2Tag,handles.unitsFstop1,handles.unitsFstop2],'vis','off');
                set([handles.Fpass2Tag,handles.Fpass2,handles.unitsFpass2],'vis','on');
            end
        elseif design_num == 2
            set(handles.Fpass1Tag,'string','F_{pass 1}');
            set(handles.Fstop1Tag,'string','F_{stop 1}');
            set(handles.Fpass2Tag,'string','F_{pass 2}');
            set(handles.Fstop2Tag,'string','F_{stop 2}');
            set([handles.Fpass1Tag,handles.Fstop1Tag,handles.Fpass1,handles.Fstop1, ...
                handles.Fpass2Tag,handles.Fstop2Tag,handles.Fpass2,handles.Fstop2],'vis','on');
            set([handles.unitsFpass1,handles.unitsFpass2,handles.unitsFstop2,handles.unitsFstop1],'vis','on'); %U
        end
        if strcmp(get(handles.menu_x_scale,'checked'),'on')     % normalized freq
            set(handles.Fpass1, 'string', num2str(6/16));       % set default values
            set(handles.Fstop1, 'string', num2str(4/16));
            set(handles.Fpass2, 'string', num2str(10/16));
            set(handles.Fstop2, 'string', num2str(12/16));
        else
            if strcmp(handles.win_name,'Kaiser')
                set(handles.Fpass1, 'string', num2str(ceil(3*fs/16)));
                set(handles.Fstop1, 'string', num2str(ceil(2*fs/16)));
                set(handles.Fpass2, 'string', num2str(ceil(5*fs/16)));
                set(handles.Fstop2, 'string', num2str(ceil(7*fs/16)));
                set([handles.unitsFpass2,handles.unitsFstop2],'vis','on');
            else
                set(handles.Fpass1,'string',num2str(3*fs/16));
                set(handles.Fstop1,'string',num2str(2*fs/16));
                set(handles.Fpass2,'string',num2str(5*fs/16));
                set(handles.Fstop2,'string',num2str(6*fs/16));
            end
        end
        %---------------------
    case 'Bandreject'
        %---------------------
        if design_num == 1
            if strcmp(handles.win_name,'Kaiser')
                set(handles.Fpass1Tag,'string','F_{pass 1}');
                set(handles.Fstop1Tag,'string','F_{stop 1}');
                set(handles.Fpass2Tag,'string','F_{pass 2}');
                set(handles.Fstop2Tag,'string','F_{stop 2}');
                set(handles.SetOrder, 'Enable','on');
                set([handles.Fpass2,handles.Fstop2,handles.Fpass2Tag,handles.Fstop2Tag],'vis','on');
                set([handles.unitsFstop2,handles.unitsFpass2],'vis','on');

                order_type = get(handles.SetOrder,'value');
                % if KaiserBR in 'set order' mode and order is not even
                params.Order = str2double(get(handles.Order,'string'));
                if order_type==2 & mod(params.Order,2)~=1
                    set(handles.Order,'string',num2str(params.Order+1));
                end
            else
                set(handles.Fpass1Tag,'string','F_{cutoff 1}');
                set(handles.Fpass2Tag,'string','F_{cutoff 2}');
                set([handles.Fpass2Tag,handles.Fpass2,handles.unitsFpass2],'vis','on');
                set([handles.unitsFstop1,handles.unitsFstop2],'vis','off');
            end
        elseif design_num == 2
            set(handles.Fpass1Tag,'string','F_{pass 1}');
            set(handles.Fstop1Tag,'string','F_{stop 1}');
            set(handles.Fpass2Tag,'string','F_{pass 2}');
            set(handles.Fstop2Tag,'string','F_{stop 2}');
            set([handles.Fpass1Tag,handles.Fstop1Tag,handles.Fpass1,handles.Fstop1,...
                handles.Fpass2Tag,handles.Fstop2Tag,handles.Fpass2,handles.Fstop2],'vis','on');
            set([handles.unitsFpass1,handles.unitsFpass2,handles.unitsFstop2,handles.unitsFstop1],'vis', 'on'); %U
        end
        if strcmp(get(handles.menu_x_scale,'checked'),'on') 	% normalized freq
            set(handles.Fpass1, 'string', num2str(4/16));       % set default values
            set(handles.Fstop1, 'string', num2str(6/16));
            set(handles.Fpass2, 'string', num2str(12/16));
            set(handles.Fstop2, 'string', num2str(10/16));
            %% set([handles.unitsFpass1,handles.unitsFpass2,handles.unitsFstop1,handles.unitsFstop2],'vis','off'); %U
        else
            if strcmp(handles.win_name,'Kaiser') % KAISER
                set(handles.Fpass1, 'string', num2str(ceil(2*fs/16)));      % set default values
                set(handles.Fstop1, 'string', num2str(ceil(3*fs/16)));
                set(handles.Fpass2, 'string', num2str(ceil(7*fs/16)));
                set(handles.Fstop2, 'string', num2str(ceil(5*fs/16)));
                % update unit texts
                set([handles.unitsFpass2,handles.unitsFstop2],'vis','on');
            else
                set(handles.Fpass1,'string',num2str(2*fs/16));
                set(handles.Fstop1,'string',num2str(3*fs/16));
                set(handles.Fpass2,'string',num2str(6*fs/16));
                set(handles.Fstop2,'string',num2str(5*fs/16));
            end
        end
        %---------------------
end
params = user(handles);
handles.params = params;
guidata(handles.figure1,handles);
%====================================================================
function WindowsMenu_Callback(hObject, eventdata, handles)
%====================================================================
win_names = get(handles.WindowsMenu,{'string','value'});
handles.win_name = win_names{1}{win_names{2}};
handles = SetFIRMenu(handles);
handles = PlotFIR(handles);
guidata(handles.figure1,handles);
%====================================================================
function FilterMenu_Callback(hObject, eventdata, handles)
%====================================================================
handles = SetFIRMenu(handles);
handles = PlotFIR(handles);
guidata(handles.figure1,handles);
%====================================================================
function handles = chooseFilter(handles,params)
%====================================================================
% Chose Filter Type from: {FIR:Window} | FIR:Parks-McClellan | IIR
if ~isempty(params)
    handles.params = params;
    guidata(handles.figure1,handles);
    handles = guidata(handles.figure1);
end
switch handles.filt_type
    case 'FIR'
        if strcmp(handles.design_name,'Window')
            handles = PlotFIR(handles);
        else % 'Parks-McClellan'
            handles = PlotFIRPM(handles,-1);
        end
    case 'IIR'
        handles = PlotIIR([],[],guidata(gcbf));
end
%====================================================================
function handles = choosePlot(handles)
%====================================================================
% Chose Plot Type from: {Magnitude} | Phase | Impulse | Pole-Zero
if strcmp(get(handles.MagResp,'vis'),'off')
    MagResp_Callback(handles.figure1,[],handles);
elseif strcmp(get(handles.PhaseResp,'vis'),'off')
    PhaseResp_Callback(handles.figure1,[],handles);
elseif strcmp(get(handles.PoleZero,'vis'),'off')
    PoleZero_Callback(handles.figure1,[],handles);
elseif strcmp(get(handles.ImpResp,'vis'),'off')
    ImpResp_Callback(handles.figure1,[],handles);
end
%====================================================================
function handles = PlotFIR(handles)
%====================================================================
M = str2double(get(handles.Order,'string'));
alpha = M/2;
n = 0:M;
error_flag = 0;

[params,Wpass1,Wstop1,Wpass2,Wstop2,Rp_dB,Rs_dB,order_type,xscale,yscale,omega] = user(handles);

handles.imp_res = [];
handles.winfun  = [];

% WINDOW
switch handles.win_name
    %---%---------------------
    case 'Rectangular'
        %---------------------
        handles.winfun = ones(1,M+1);
        %---------------------
    case 'Bartlett'
        %---------------------
        if rem(M+1,2) == 0
            k = 0:(M+1)/2-1;
            handles.winfun(k+1)=(2*k/M);
            k = (M+1)/2:M;
            handles.winfun(k+1) = 2*(M-k)/M;
        else
            k = 0:M/2;
            handles.winfun(k+1) = 2.*k./M;
            k = M/2:M;
            handles.winfun(k+1)=2-(2*k)/M;
        end
        %---------------------
    case 'Hann'
        %---------------------
        k = 0:M;
        handles.winfun = 0.5-0.5*cos(2*pi*k/M);
        %---------------------
    case 'Hamming'
        %---------------------
        k = 0:M;
        handles.winfun = 0.54-0.46.*cos(2*pi.*k./M);
        %---------------------
    case 'Blackmann'
        %---------------------
        k = 0:M;
        handles.winfun = 0.42-(0.5.*cos(2.*k*pi./M))+(0.08.*cos(4*pi.*k./M));
        %---------------------
    case 'Gaussian'
        %---------------------
        k = 0:M;
        alpha_win = str2double(get(handles.alpha,'string'));
        handles.winfun = exp(-0.5.*(((alpha_win.*(k-M/2))./(M/2)).^2));
        %---------------------
    case 'Dolph-Chebyshev'
        %---------------------
        k = 0:M-1;
        alpha_win = str2double(get(handles.alpha,'string'));
        beta = cosh((acosh(10^alpha_win)/(M-1)));
        num = cos((M)*acos((beta*cos(pi*k/(M-1)))));
        den = cosh((M).*acosh(beta));
        win = ((-1).^k).*num./den;
        win = abs(ifft(win));
        win = win/max(win);
        win(M+1) = win(1);
        handles.winfun = win;
        %---------------------
    case 'BarcTemes'
        %---------------------
        k = 0:M;
        alpha = 3.0;
        C = acosh(10^alpha);
        beta = cosh(C/M);
        A = sinh(C);
        B = cosh(C);

        y = (M+1)*acos(beta*cos(pi*k/M));
        num = (A.*cos(y)) + (B*(y.*sin(y)/C));
        den = (C+A*B)*((y/C).^2 +1);

        win = ((-1).^k).*num./den;
        handles.winfun = (abs(ifft(win)))/max(win);;
        %---------------------
    case 'Lanczos'
        %---------------------
        k = 0:M;
        handles.winfun(k+1) = (sin((k-(M)./2).*pi./(M+1)))./((k-M/2).*pi/(M+1));
        handles.winfun(round(M/2)+1) = 1;
        %---------------------
    case 'Kaiser'
        %---------------------
        % for formulae, refer to pg 474 in Oppenheim & Schafer book
        if strcmp('Rpass',handles.KaiserR)
            delta = params.Rpass;
        elseif strcmp('Rstop',handles.KaiserR)
            delta = params.Rstop;
        else
            delta = min(params.Rstop,params.Rpass);
        end

        A = -20*log10(delta);
        Wc1 = (Wpass1+Wstop1)/2;        % use mean of passband edge and stopband edge for first critical frequency
        Wc2 = (Wpass2+Wstop2)/2;        % use mean of passband edge and stopband edge for second critical frequency

        MagMode = strcmp(get(handles.MagResp,'vis'),'off');
        switch handles.filt_name
            %---%---------------------
            case 'Lowpass'
                %---------------------
                if order_type-1
                    M = params.Order-1;
                else % fix to max delta such that Kaiser evaluates
                    if A < 8
                        delta = 0.398;
                        A = -20*log10(delta);
                    end
                    M = ceil((A-8)/(2.285*abs(Wpass1-Wstop1)*pi));
                end

                % initialize ideal filter lines
                xdata1 = [0 params.Fpass1]*(2-xscale) + [0 Wpass1]*(xscale-1);
                xdata2 = [params.Fstop1 params.Fsamp/2]*(2-xscale) + [Wstop1 1]*(xscale-1);
                ydata1 = [1+params.Rpass,1+params.Rpass]*(2-yscale) + [20*log10(1+params.Rpass) 20*log10(1+params.Rpass)]*(yscale-1);
                ydata2 = [1-params.Rpass 1-params.Rpass]*(2-yscale) + [20*log10(1-params.Rpass) 20*log10(1-params.Rpass)]*(yscale-1);
                ydata3 = [params.Rstop params.Rstop]*(2-yscale) + [20*log10(params.Rstop) 20*log10(params.Rstop)]*(yscale-1);

                set(handles.Line1a,'xdata',xdata1,'ydata',ydata1);
                set(handles.Line1b,'xdata',xdata1,'ydata',ydata2);
                set(handles.Line3,'xdata', xdata2,'ydata',ydata3);

                if MagMode
                    set([handles.Line1a,handles.Line1b,handles.Line3],'visible','on');
                    set([handles.Line2,handles.Line4a,handles.Line4b,handles.Line5a,handles.Line5b,handles.Line6],'visible','off');
                end
                %---------------------
            case 'Highpass'
                %---------------------
                if order_type-1
                    M = params.Order-1;
                else % fix to max delta such that Kaiser evaluates
                    if A < 8
                        delta = 0.398;
                        A = -20*log10(delta);
                    end
                    M = ceil((A-8)/(2.285*abs(Wpass1-Wstop1)*pi));
                end

                if mod(params.Order,2)~=0
                    if order_type-1
                        error_flag = 'Order must be even';
                    end
                    M = M + 1;
                    alpha = M/2;
                    set(handles.Order,'string',num2str(M));
                end

                % initialize ideal filter lines
                xdata1 = [params.Fpass1 params.Fsamp/2]*(2-xscale) + [Wpass1 1]*(xscale-1);
                xdata2 = [0 params.Fstop1]*(2-xscale) + [0 Wstop1]*(xscale-1);
                ydata1 = [1+params.Rpass,1+params.Rpass]*(2-yscale) + [20*log10(1+params.Rpass) 20*log10(1+params.Rpass)]*(yscale-1);
                ydata2 = [1-params.Rpass 1-params.Rpass]*(2-yscale) + [20*log10(1-params.Rpass) 20*log10(1-params.Rpass)]*(yscale-1);
                ydata3 = [params.Rstop params.Rstop]*(2-yscale) + [20*log10(params.Rstop) 20*log10(params.Rstop)]*(yscale-1);

                set(handles.Line1a,'xdata',xdata1,'ydata',ydata1);
                set(handles.Line1b,'xdata',xdata1,'ydata',ydata2);
                set(handles.Line2,'xdata', xdata2,'ydata',ydata3);

                if MagMode
                    set([handles.Line1a,handles.Line1b],'visible','on');
                    set([handles.Line3,handles.Line4a,handles.Line4b,handles.Line5a,handles.Line5b,handles.Line6],'visible','off');
                end
                if strcmp(get(handles.ImpResp,'vis'),'off')
                    set(handles.Line2,'vis','off');
                else
                    set(handles.Line2,'vis','on');
                end
                %---------------------
            case 'Bandpass'
                %---------------------
                if order_type-1
                    M = params.Order-1;
                else % fix to max delta such that Kaiser evaluates
                    if A < 8
                        delta = 0.398;
                        A = -20*log10(delta);
                    end
                    M = ceil((A-8)/(2.285*min([abs(Wpass1-Wstop1),abs(Wpass2-Wstop2)])*pi));
                end

                % initialize ideal filter lines
                xdata1 = [params.Fpass1 params.Fpass2]*(2-xscale) + [Wpass1 Wpass2]*(xscale-1);
                xdata2 = [0 params.Fstop1]*(2-xscale) + [0 Wstop1]*(xscale-1);
                xdata3 = [params.Fstop2 params.Fsamp/2]*(2-xscale) + [Wstop2 1]*(xscale-1);
                ydata1 = [1+params.Rpass,1+params.Rpass]*(2-yscale) + [20*log10(1+params.Rpass) 20*log10(1+params.Rpass)]*(yscale-1);
                ydata2 = [1-params.Rpass 1-params.Rpass]*(2-yscale) + [20*log10(1-params.Rpass) 20*log10(1-params.Rpass)]*(yscale-1);
                ydata3 = [params.Rstop params.Rstop]*(2-yscale) + [20*log10(params.Rstop) 20*log10(params.Rstop)]*(yscale-1);

                set(handles.Line1a,'xdata',xdata1,'ydata',ydata1);
                set(handles.Line1b,'xdata',xdata1,'ydata',ydata2);
                set(handles.Line2,'xdata', xdata2,'ydata',ydata3);
                set(handles.Line3,'xdata', xdata3,'ydata',ydata3);

                %set(handles.Fstop2Tag,'str','F_{stop 2}');
                if MagMode
                    set([handles.Line1a,handles.Line1b,handles.Line3],'visible','on');
                    set([handles.Line4a,handles.Line4b,handles.Line5a,handles.Line5b,handles.Line6],'visible','off');
                end
                if strcmp(get(handles.ImpResp,'vis'),'off')
                    set(handles.Line2,'vis','off');
                else
                    set(handles.Line2,'vis','on');
                end
                %---------------------
            case 'Bandreject'
                %---------------------
                if order_type-1
                    M = params.Order-1;
                else
                    M = ceil((A-8)/(2.285*min([abs(Wpass1-Wstop1),abs(Wpass2-Wstop2)])*pi));
                end

                if mod(M,2)~=0                  % make sure M is even (order is odd)
                    M = M + 1;
                end

                % initialize ideal filter lines
                xdata1 = [0 params.Fpass1]*(2-xscale)      + [0 Wpass1]*(xscale-1);
                xdata2 = [params.Fpass2 params.Fsamp/2]*(2-xscale)   + [Wpass2 1]*(xscale-1);
                xdata3 = [params.Fstop1 params.Fstop2]*(2-xscale)     + [Wstop1 Wstop2]*(xscale-1);
                ydata1 = [1+params.Rpass,1+params.Rpass]*(2-yscale) + [20*log10(1+params.Rpass) 20*log10(1+params.Rpass)]*(yscale-1);
                ydata2 = [1-params.Rpass 1-params.Rpass]*(2-yscale) + [20*log10(1-params.Rpass) 20*log10(1-params.Rpass)]*(yscale-1);
                ydata3 = [params.Rstop params.Rstop]*(2-yscale)     + [20*log10(params.Rstop) 20*log10(params.Rstop)]*(yscale-1);

                set(handles.Line4a,'xdata',xdata1,'ydata',ydata1);
                set(handles.Line4b,'xdata',xdata1,'ydata',ydata2);
                set(handles.Line5a,'xdata', xdata2,'ydata',ydata1);
                set(handles.Line5b,'xdata', xdata2,'ydata',ydata2);
                set(handles.Line6,'xdata', xdata3,'ydata',ydata3);
                if MagMode
                    set([handles.Line4a,handles.Line4b,handles.Line5a,handles.Line5b,handles.Line6],'visible','on');
                    set([handles.Line1a,handles.Line1b,handles.Line2,handles.Line3],'visible','off');
                end
                %---------------------
        end

        % find beta -- Opp & Sch (eq. 7.62)
        if A > 50
            beta = 0.1102*(A-8.7);
        elseif A < 21
            beta = 0;
        else
            beta = 0.5842*(A-21)^.4 + 0.07886*(A-21);
        end
        handles.beta = beta;
        set(handles.KaiserB,'str',['\beta          ' num2str(beta)]);

        alpha = M/2;
        n = 0:M;
        handles.winfun = besseli(0,beta.*(1-((n-alpha)./alpha).^2).^0.5)./besseli(0,beta);

        params.Rpass = delta; % see L870 for definition of delta
        params.Rstop = delta;

        % update Rpass/Rstop
        if (yscale - 1) % mag in dB
            set(handles.Rpass,'string',20*log10(1-delta));
            set(handles.Rstop,'string',-A);
            set([handles.unitsRpass,handles.unitsRstop],'vis','on');
        else
            set([handles.Rpass,handles.Rstop],'string',delta);
            set([handles.unitsRpass,handles.unitsRstop],'vis','off');
        end

        set(handles.Order,'string',num2str(M+1));
        set(handles.PlotTitle,'string',[handles.win_name ' ' handles.filt_name ' Window Filter of Order ' num2str(M+1)]);
end

% Ideal filter lines have only been implemented for Kaiser
if strcmp(handles.win_name,'Kaiser')
    set([handles.SetOrder,handles.Rpass,handles.Rstop,handles.RpassTag,handles.RstopTag],'vis','on');
else
    set([handles.Line1a, handles.Line1b, handles.Line3, handles.Line4a,...
        handles.Line4b, handles.Line5a, handles.Line5b, handles.Line6,handles.Line2],'vis','off');
    set([handles.SetOrder,handles.Rpass,handles.Rstop,handles.RpassTag,handles.RstopTag],'vis','off');
end

if strcmp(handles.design_name,'Window')
    set([handles.RemezHorz1, handles.RemezHorz2,handles.RemezExtre1, handles.RemezExtre2, handles.RemezHorz3],'vis','off');
else
    set([handles.RemezHorz1, handles.RemezHorz2,handles.RemezExtre1, handles.RemezExtre2, handles.RemezHorz3],'vis','on');
end

% IDEAL IMPULSE RESPONSE
switch handles.filt_name
    case 'Lowpass'
        %---------------------
        if strcmp(handles.win_name,'Kaiser')
            wc = Wc1*pi;
        else
            wc = Wpass1*pi;
        end

        handles.imp_res = sin(wc*(n-alpha)) ./ (pi*(n-alpha));
        if mod(M,2) == 0
            handles.imp_res(M/2+1) = wc/pi;
        end
        %---------------------
    case'Highpass'
        %---------------------
        wc = Wpass1*pi;

        handles.imp_res = ((sin(pi*(n-alpha)))-(sin(wc*(n-alpha))))./(pi*(n-alpha));
        if mod(M,2) == 0
            handles.imp_res(M/2+1) = 1 - wc/pi;
        end
        %---------------------
    case 'Bandpass'
        %---------------------
        Wpass1 = Wpass1*pi;
        Wpass2 = Wpass2*pi;

        handles.imp_res = ((sin(Wpass2*(n-alpha)))-(sin(Wpass1*(n-alpha))))./(pi*(n-alpha));
        if mod(M,2) == 0
            handles.imp_res(M/2+1) = Wpass2/pi - Wpass1/pi;
        end
        %---------------------
    case 'Bandreject'
        %---------------------
        Wpass1 = Wpass1*pi;
        Wpass2 = Wpass2*pi;

        if mod(M,2) ~= 0
            error_flag = 'Order must be even';
            set(handles.Order,'string',num2str(M+1));
            M = M + 1;
            alpha = M/2;
        end

        handles.imp_res = (sin(Wpass1*(n-alpha))+sin(pi*(n-alpha))-sin(Wpass2*(n-alpha)))./(pi*(n-alpha));

        if mod(M,2) == 0
            handles.imp_res(M/2+1) = 1 - Wpass2/pi + Wpass1/pi;
        end
end

if any(strcmp(handles.win_name,{'Gaussian','Dolph-Chebyshev'}))
    set([handles.alpha,handles.Fstop2Tag],'vis','on');
    set(handles.Fstop2Tag,'str','Alpha');
elseif strcmp(handles.win_name,'Kaiser')
    set(handles.alpha,'vis','off');
else
    set([handles.alpha,handles.Fstop2Tag],'vis','off');
end

%Find the total response
handles.total_res = handles.imp_res .* handles.winfun;

%Assigns the designed filter coefficients to b(num) and a(den)
handles.b = handles.total_res;
handles.a = 1;

set(handles.PlotTitle,'string',[handles.filt_name ' Filter of Order ' num2str(get(handles.Order,'string'))]);
set([handles.RemezText,handles.PMFIter],'vis','off');

[handles.h,handles.w] = freekz(handles.total_res,1,512);

handles.params = params;
handles = choosePlot(handles);
if error_flag
    set(handles.dialog,'type','error','message',error_flag);
end
if ~strcmp(get(handles.dialog,'type'),'help');
    set(handles.dialog,'vis','off');
end
guidata(handles.figure1,handles);
%====================================================================
function VariousResp_Callback(hObject,eventdata,handles)
%====================================================================
% set([handles.menu_y_scale,handles.Infotext],'vis','off');
set(handles.dialog,'vis','off');
set(handles.VariousResp,'selected','on');
%====================================================================
function PlotType_Callback(handles)
%====================================================================
set(get(handles.VariousResp,'children'),'vis','on');
set(gcbo,'vis','off');
handles = chooseFilter(handles,[]);
guidata(handles.figure1,handles);
%====================================================================
function ImpResp_Callback(hObject,eventdata,handles)
%====================================================================
nlim = min(handles.total_res);
plim = max(handles.total_res);
lim = max(-0.2*nlim,0.2*plim);

if nlim ~= plim
    set([handles.ImpResp,handles.LineCirc,handles.HorzLine,handles.VertLine, ...
        handles.PoleLine,handles.menu_x_scale,handles.menu_y_scale, ...
        handles.LineMain,handles.TextPole,handles.RemezExtre1,handles.RemezExtre2, ...
        handles.RemezHorz1,handles.RemezHorz2,handles.RemezHorz3],'vis','off');
    set([handles.Line1a,handles.Line1b,handles.Line2],'vis','off');
    set(findobj(gcbf,'label','Edit'),'vis','off');
    set(handles.note,'vis','off');
    set([handles.PhaseResp,handles.MagResp,handles.PoleZero],'vis','on');
    N = str2double(get(handles.Order,'string'));

    set(get(handles.Plot1,'xlabel'),'fontname','Helvetica');
    set([handles.LineStem1,handles.LineStem2],'vis','on');

    switch handles.filt_type
        case 'FIR'
            set(handles.LineGreen,'xdata',[-1 N+1],'ydata',[0 0],'vis','on');
            switch handles.design_name
                %---%---------------------
                case 'Window'
                    %---------------------
                    set(handles.WindowPlot,'vis','on');
                    set(handles.Plot1,'XTickLabelMode','auto','XTickMode','auto','Ylim',[nlim-lim plim+lim],'Xlim',[-1 N+1]);

                    %%Plot the rectangular windows
                    yda1 = [0:0.01:max(handles.winfun*max(handles.imp_res))];
                    xda(1:length(yda1)) = 0;
                    yda2 = [0 max(handles.winfun*max(handles.imp_res))];
                    xda1 = [N N];

                    if get(handles.WindowsMenu,'value') == 1
                        set(handles.VertLine,'vis','on','xdata',xda,'ydata',yda1,'color','k');
                        set(handles.HorzLine,'vis','on','xdata',xda1,'ydata',yda2,'color','k');
                    else
                        set([handles.VertLine,handles.HorzLine],'vis','off','color','b');
                    end

                    stemdata((0:length(handles.total_res)-1),handles.total_res,handles.Plot1,handles.LineStem1,handles.LineStem2);

                    %%plot the windowed/unwindowed response acc. to toggle button selection
                    if get(handles.WindowPlot,'value') == 0
                        WindowPlot_Callback([],[],handles)
                        set(handles.WindowPlot,'string','Windowed');
                    else
                        set(handles.WindowPlot,'string','Unwindowed');
                    end
                    winlen = 200;
                    switch handles.win_name
                        %---%---------------------
                        case 'Rectangular'
                            %---------------------
                            set(handles.WindowLine,'xdata',[0 N],'ydata',[max(handles.imp_res) max(handles.imp_res)],'vis','on');
                            %---------------------
                        case 'Bartlett'
                            %---------------------
                            set(handles.WindowLine,'xdata',[0 N/2 N],'ydata',[0 max(handles.imp_res) 0],'vis','on');
                            %---------------------
                        case 'Hann'
                            %---------------------
                            set(handles.WindowLine,'xdata',(0:N/winlen:N),'ydata',max(handles.imp_res)*0.5*(1-cos(2*pi*((0:winlen)/winlen))),'vis','on');
                            %---------------------
                        case 'Hamming'
                            %---------------------
                            set(handles.WindowLine,'xdata',(0:N/winlen:N),'ydata',max(handles.imp_res)*(0.54-(0.46*cos(2*pi*(0:winlen)/winlen))),'vis','on');
                            %---------------------
                        case 'Blackmann'
                            %---------------------
                            set(handles.WindowLine,'xdata',(0:N/winlen:N),'ydata',max(handles.imp_res)*(0.42-(0.5*cos(2*(0:winlen)*pi/winlen))+(0.08*cos(4*pi*(0:winlen)/winlen))),'vis','on');
                            %---------------------
                        case 'Gaussian'
                            %---------------------
                            alpha = str2double(get(handles.alpha,'string'));
                            k = 0:winlen;
                            set(handles.WindowLine,'xdata',(0:N/winlen:N),'ydata',max(handles.imp_res)*(exp(-.5*(((alpha*(k-winlen/2))/(winlen/2)).^2))),'vis','on');
                            %---------------------
                        case 'Dolph-Chebyshev'
                            %---------------------
                            alpha = 3.0;
                            beta = cosh((acosh(10^alpha)/winlen));
                            num = cos((winlen+1)*acos((beta*cos(pi*(0:winlen)/winlen))));
                            den = cosh((winlen+1)*acosh(beta));
                            win = ((-1).^(0:winlen)).*num./den;
                            win = abs(ifft(win));
                            win = win/max(win);
                            win(1) = win(200);
                            set(handles.WindowLine,'xdata',0:N/winlen:N,'ydata',max(handles.imp_res)*win,'vis','on');
                            %---------------------
                        case 'BarcTemes'
                            %---------------------
                            k = 0:winlen-1;
                            alpha = 3.5;
                            C = acosh(10^alpha);
                            beta = cosh(C/winlen);
                            A = sinh(C);
                            B = cosh(C);

                            y = winlen*acos(beta*cos(pi*k/winlen));
                            num = (A.*cos(y)) + (B*(y.*sin(y)/C));
                            den = (C+A*B)*((y/C).^2 +1);

                            win = ((-1).^k).*num./den;
                            win = abs(ifft(win));
                            win = win/max(win);
                            set(handles.WindowLine,'xdata',(0:N/winlen:N-N/winlen),'ydata',max(handles.imp_res)*win,'vis','on');
                            %---------------------
                        case 'Lanczos'
                            %---------------------
                            n = winlen-1;
                            k = 0:winlen;
                            win(k+1) = (sin((k-n./2)*pi./winlen))./((k-n./2)*pi./winlen);
                            win(round(n/2+1)) = 1;
                            set(handles.WindowLine,'xdata',(0:N/winlen:N),'ydata',max(handles.imp_res)*win,'vis','on');
                            %---------------------
                        case 'Kaiser'
                            n = 0:winlen;
                            alpha = winlen/2;
                            beta = handles.beta;
                            win = besseli(0,beta.*(1-((n-alpha)./alpha).^2).^0.5)./besseli(0,beta);
                            set(handles.WindowLine,'xdata',(0:N/winlen:N),'ydata',max(handles.imp_res)*win,'vis','on');
                    end
                    %---------------------
                case 'Parks-McClellan'
                    %---------------------
                    set([handles.WindowPlot,handles.WindowLine],'vis','off');
                    set(handles.PMFIter,'vis','on');
                    nlim = min(handles.total_res);
                    plim = max(handles.total_res);
                    lim = max(-0.2*nlim,0.2*plim);
                    set(handles.Plot1,'XTickLabelMode','auto','XTickMode','auto','Ylim',[nlim-lim plim+lim],'Xlim',[-1 N+1]);
                    stemdata((0:N),handles.total_res,handles.Plot1,handles.LineStem1,handles.LineStem2);
                    %---------------------
            end
        case 'IIR'
            L = length(handles.total_res);
            set(handles.Plot1,'XTickLabelMode','auto','XTickMode','auto','Ylim',[nlim-lim plim+lim],'Xlim',[-1 L-1]);
            set(handles.LineGreen,'xdata',[-1 L-1],'ydata',[0 0],'vis','on');
            stemdata(0:L-1,[handles.total_res],handles.Plot1,handles.LineStem1,handles.LineStem2);
    end
    % set(handles.WindowLine,'xdata',(0:N),'ydata',[(handles.winfun)*max(handles.imp_res)],'vis','on')
    set(get(handles.Plot1,'Xlabel'),'string','Samples');
    set(get(handles.Plot1,'Ylabel'),'string','Magnitude','pos',[-0.1 0.5 0]);
    set(handles.PlotTitle,'string','Impulse Response of the Filter');
    guidata(handles.figure1,handles);
end
%====================================================================
function PhaseResp_Callback(hObject, eventdata, handles)
%====================================================================
fs = str2double(get(handles.Fsamp,'string'));
set([handles.LineCirc,handles.HorzLine,handles.VertLine,handles.PoleLine,handles.TextPole],'vis','off');
set([handles.RemezExtre1,handles.RemezExtre2,handles.RemezHorz1,handles.RemezHorz2,handles.RemezHorz3,handles.LineNs],'vis','off');
set(findobj(gcbf,'label','Edit'),'vis','on');
set(handles.note,'vis','off');
design_num = get(handles.DesignMenu,'val');

if design_num == 2 % if Remez make the slider visible else dont
    set(handles.PMFIter,'vis','on');
else
    set(handles.PMFIter,'vis','off');
end

set([handles.LineStem1,handles.LineStem2,handles.PhaseResp,handles.menu_y_scale],'vis','off');
set([handles.menu_x_scale,handles.ImpResp,handles.MagResp,handles.PoleZero],'vis','on');
set(handles.LineMain,'vis','on','marker','none','linestyle','-','linewidth',handles.LineWidth);

[h w] = freekz(handles.total_res,1,512);
ang = unwrap(angle(h));

if(strcmp(get(handles.menu_x_scale,'checked'),'off'));
    set(handles.LineMain,'xdata',w/pi*fs/2,'ydata',ang);
    set(handles.Plot1,'Xlim',[0 fs/2]);
else
    set(handles.LineMain,'xdata',w/pi,'ydata',ang);
    set(handles.Plot1,'Xlim',[0 1]);
end

% Account for sampling error when determining YLim
if mod(min(ang/pi),pi/2) < 0.05*pi
    Ylim_min = (mod(abs(min(ang/pi)),pi/2)-pi/2) + min(ang/pi);
else
    Ylim_min = min(ang/pi);
end
Ylim_max = max(ang/pi);

%---------
% determine new yticks (symbolic multiples of pi/2)
%handles.old_font = get(handles.Plot1,'fontname');
if length([round(Ylim_min):Ylim_max]) < 5
    ytick = [round(Ylim_min):0.5:Ylim_max];
else
    ytick = [round(Ylim_min):Ylim_max];
end

if handles.MATLABVER<8.4
    pi_str = 'p ';
else
    pi_str = '\pi';
end

for k = 1:length(ytick)
    if ytick(k) == 0
        ytickL{k} = '0';
    elseif ytick(k) == 1
        ytickL{k} = pi_str;
    elseif ytick(k) == -1
        ytickL{k} = ['-' pi_str];
    else
        ytickL{k} = sprintf('%s%s',num2str(ytick(k)),pi_str);
    end
end
%---------

set(handles.LineGreen,'xdata',[],'ydata',[]);
set(get(handles.Plot1,'ylabel'),'string','Unwraped Phase','pos',[-0.13 0.5 0]);
set(handles.PlotTitle,'string',['Phase Response of Filter of order ' num2str(get(handles.Order,'string'))]);
set([handles.WindowPlot,handles.WindowLine],'vis','off');

%-#- preserve ordering of statements -#-%
buttonfcns(getappdata(gcbf,'spfirst_axisx_DATA'),'Initialize');

if handles.MATLABVER<8.4
    set(handles.Plot1,'ylim',[Ylim_min*pi Ylim_max*pi],'ytick',pi*ytick,'yticklabel',char(ytickL'),'fontname','symbol');
else
    set(handles.Plot1,'ylim',[Ylim_min*pi Ylim_max*pi],'ytick',pi*ytick,'yticklabel',char(ytickL'));
end
%====================================================================
function MagResp_Callback(hObject,eventdata,handles)
%====================================================================
[params,Wpass1,Wstop1,Wpass2,Wstop2,Rp_dB,Rs_dB,order_type,xscale,yscale,omega] = user(handles);
%set(handles.Plot1,'YTickMode','auto','YTickLabelMode','auto','xTickMode','auto','xTickLabelMode','auto');
set(handles.LineMain,'vis','on','marker','none','linestyle','-','linewidth',handles.LineWidth);
set([handles.ImpResp,handles.PhaseResp,handles.menu_y_scale,handles.menu_x_scale,handles.PoleZero],'vis','on');
set([handles.MagResp,handles.LineStem1,handles.LineStem2,handles.WindowPlot,handles.LineCirc,handles.HorzLine, ...
    handles.VertLine,handles.PoleLine,handles.TextPole,handles.WindowPlot,handles.WindowLine],'vis','off');
set(findobj(gcbf,'label','Edit'),'vis','on');

if strcmp(handles.filt_type,'FIR') & strcmp(handles.design_name,'Parks-McClellan')
    set(handles.note,'vis','on');
end

SetXY(handles,handles.w,handles.h,params.Fsamp,xscale,yscale);
guidata(handles.figure1,handles);
buttonfcns(getappdata(hObject,'spfirst_axisx_DATA'),'Initialize');
% =====================================================================
function PoleZero_Callback(hObject,eventdata,handles)
% =====================================================================
set([handles.ImpResp,handles.MagResp,handles.LineMain,handles.PhaseResp,...
    handles.LineCirc,handles.PoleLine],'vis','on');
set([handles.menu_x_scale,handles.menu_y_scale,handles.LineStem1,handles.LineStem2, ...
    handles.WindowPlot,handles.WindowLine,handles.RemezExtre1,handles.RemezExtre2, ...
    handles.RemezHorz1,handles.RemezHorz2,handles.RemezHorz3,handles.PoleZero,handles.LineNs],'vis','off');
set(findobj(gcbf,'label','Edit'),'vis','off');
set(handles.note,'vis','off');

design_num = get(handles.DesignMenu,'val');
if design_num == 2 % if Remez make the slider visible
    set(handles.PMFIter,'vis','on');
else
    set(handles.PMFIter,'vis','off');
end

% POLES
if handles.a == 1
    set(handles.PoleLine,'xdata',0,'ydata',0);
else
    roots_a = roots(handles.a);
    real_a = real(roots_a);
    img_a = imag(roots_a);
    set(handles.PoleLine,'xdata',real_a,'ydata',img_a);
end

% ZEROS
b = handles.b;  % fliplr(handles.total_res);
roots_b = roots(b);
ind = find((abs(roots_b)>1.0e+06 | abs(roots_b)<1.0e-06));
roots_b(ind) = [];

if ~isempty(find(roots_b == 0))
    net_poles = length(roots_b)-length(find(roots_b==0));
    roots_b(find(roots_b==0)) = [];
else
    net_poles = length(roots_b);
end

%if net_poles == 0
%    errordlg('Unable to design filter')
%end
real_b = real(roots_b);
img_b = imag(roots_b);

roots_bb = roots_b(find(abs(roots_b) < 100));

% find max no out of real and img part.to keep the unit circle
% in middle of the plot
max_no = max(max(abs(real(roots_bb)),abs(imag(roots_bb))));
max_no = (ceil(10*max_no))/10;
Mu = 1.2;
xda = -Mu*max_no:max_no/100:Mu*max_no;
yda(1:length(xda)) = 0;

if isempty(max_no)
    max_no = 1;
end
set(handles.LineMain,'xdata',real_b,'ydata',img_b,'marker','o','LineStyle','none','MarkerSize',7,'linewidth',1.5);
set(handles.TextPole,'vis','on','position',[0.08 0.1 0],'string',num2str(net_poles));
set(handles.HorzLine,'xdata',xda,'ydata',yda,'vis','on');
set(handles.VertLine,'xdata',yda,'ydata',xda,'vis','on');
set(handles.LineGreen,'xdata',[],'ydata',[]);
set(handles.Plot1,'fontname',handles.fontname,'XTickMode','auto','XTickLabelMode','auto','YTickMode','auto','YTickLabelMode','auto', ...
    'XLim',[-Mu*max_no Mu*max_no],'YLim',[-Mu*max_no Mu*max_no]);
set(get(handles.Plot1,'Xlabel'),'string','Real');
set(get(handles.Plot1,'Ylabel'),'string','Imaginary','pos',[-0.1 0.5 0]);
set(handles.PlotTitle,'string',['Pole-Zero Plot of Filter of order ' num2str(get(handles.Order,'string'))]);
%=========================================================================
function WindowPlot_Callback(hObject,eventdata,handles)
%=========================================================================
N = str2double(get(handles.Order,'string'));
set([handles.LineCirc,handles.HorzLine,handles.VertLine,handles.PoleLine,handles.LineMain, ...
    handles.menu_x_scale,handles.menu_y_scale],'vis','off');
set(handles.LineGreen,'xdata',[-1 N+1],'ydata',[0 0],'vis','on');
set(get(handles.Plot1,'Xlabel'),'string','Samples');
set(get(handles.Plot1,'Ylabel'),'string','Magnitude','pos',[-0.1 0.5 0]);

yda1 = 0:0.01:max(handles.winfun*max(handles.imp_res));
xda(1:length(yda1)) = 0;
yda2 = [0 max(handles.winfun*max(handles.imp_res))];
xda1 = [N N];

nlim = min(handles.imp_res);
plim = max(handles.imp_res);
lim = max(-0.2*nlim,0.2*plim);

set([handles.LineStem1,handles.LineStem2],'vis','on');

if (get(handles.WindowsMenu,'value')==1)
    set(handles.VertLine,'vis','on','xdata',xda,'ydata',yda1,'color',[0 0 0]);
    set(handles.HorzLine,'vis','on','xdata',xda1,'ydata',yda2,'color',[0 0 0]);
else
    set(handles.VertLine,'vis','off','color','b');
end

if get(handles.WindowPlot,'value') == 0
    set(handles.WindowPlot,'string','Windowed');
    set(handles.PlotTitle,'string','Windowed Impulse Response');
    stemdata((0:length(handles.total_res)-1),handles.total_res,handles.Plot1,handles.LineStem1,handles.LineStem2);
else
    set(handles.WindowPlot,'string','Unwindowed');
    set(handles.PlotTitle,'string','Unwindowed Impulse Response');
    stemdata((0:length(handles.total_res)-1),handles.imp_res,handles.Plot1,handles.LineStem1,handles.LineStem2);
end
set(handles.Plot1,'xlim',[-1 N+1],'ylim',[nlim-lim plim+lim]);
guidata(handles.figure1,handles);
%=========================================================================
function SetXY(handles,w,h,fs,xscale,yscale)
%=========================================================================
set(handles.Plot1,'ylimmode','auto','YTickLabelMode','auto','ytickmode','auto', ...
    'xlimmode','manual','xticklabelmode','auto','xtickMode','auto');

if xscale==1 && yscale==1           % frequency in Hz, linear amplitude
    %------------------------------
    set(handles.LineGreen,'xdata',[0,fs/2],'ydata',[0,0],'color','g');
    if strcmp(get(handles.DesignMenu, 'vis'),'on') & get(handles.DesignMenu,'value') == 2
        set(handles.LineMain,'xdata',w/pi*fs/2,'ydata',h(:));
        set(handles.Plot1,'ylim',[min(h)-0.1 max(h)*1.1],'xlim',[0 fs/2]);
    else
        set(handles.Plot1,'ylim',[-0.1 1.2],'Xlim',[0 fs/2]);
        L = length(h);
        set(handles.LineMain,'xdata',linspace(0,fs/2,L),'ydata',abs(h));
        %set(handles.LineMain,'xdata',w/pi*fs/2,'ydata',abs(h));
    end
    %------------------------------
elseif xscale==2 && yscale==1       % frequency in rad, linear amplitude
    %------------------------------
    if strcmp(get(handles.DesignMenu, 'vis'),'on') & get(handles.DesignMenu,'value') == 2
        set(handles.LineMain,'xdata',w/pi,'ydata',h(:));
        set(handles.Plot1, 'ylim',[min(h)*1.8 max(h)*1.1],'xlim',[0 1]);
    else
        set(handles.LineMain,'xdata',w/pi,'ydata',abs(h) );
        set(handles.Plot1, 'ylim',[-0.1 1.2],'xlim',[0 1]);
    end

    set(handles.LineGreen,'xdata',[0 1],'ydata',[0,0],'color','g');
    %------------------------------
elseif xscale==1 && yscale==2       % frequency in Hz, dB amplitude
    %------------------------------
    idx_zero = find (abs(h) == 0 );

    if ~isempty(idx_zero)
        h(idx_zero) = sqrt(-1)*1e-15;
    end

    set(handles.LineMain,'xdata',w/pi*fs/2,'ydata',20*log10(abs(h)) );
    set(handles.LineGreen,'xdata',[],'ydata',[],'color','g');
    set(handles.Plot1,'ylim',[-80 10],'Xlim',[0 fs/2]);
    %------------------------------
else                                % frequency in rad, dB amplitude
    %------------------------------
    idx_zero = find (abs(h) == 0 );
    if ~isempty(idx_zero)
        h(idx_zero) = sqrt(-1)*1e-15;
    end

    set(handles.LineMain,'xdata',w/pi,'ydata',20*log10(abs(h)) )
    set(handles.LineGreen,'xdata',[],'ydata',[],'color','g')
    set(handles.Plot1,'ylim',[-80 10],'xlim',[0 1]);
end

if xscale == 1  % Frequency in Hz
    set([handles.unitsFpass1,handles.unitsFstop1,handles.unitsFpass2,handles.unitsFstop2],'fontname','Helvetica','string','Hz');

    if isempty(strfind(get(handles.Fpass1Tag,'str'),'F'))
        set(handles.Fpass1Tag,'interpreter','tex','str',['F' strrep(get(handles.Fpass1Tag,'str'),' ','')]);
        set(handles.Fstop1Tag,'interpreter','tex','str',['F' strrep(get(handles.Fstop1Tag,'str'),' ','')]);
        set(handles.Fpass2Tag,'interpreter','tex','str',['F' strrep(get(handles.Fpass2Tag,'str'),' ','')]);
        set(handles.Fstop2Tag,'interpreter','tex','str',['F' strrep(get(handles.Fstop2Tag,'str'),' ','')]);
    end

    set([handles.wFpass1Tag,handles.wFstop1Tag,handles.wFpass2Tag,handles.wFstop2Tag],'vis','off');
else            % Frequency in radians
    if handles.MATLABVER<8.4
        set([handles.unitsFpass1,handles.unitsFstop1,handles.unitsFpass2,handles.unitsFstop2],'fontname','symbol','string','p');
    else
        set([handles.unitsFpass1,handles.unitsFstop1,handles.unitsFpass2,handles.unitsFstop2],'string','\pi');
    end
    % -------------
    % Option 1:
    %   text('parent',handles.ref,'units','norm','pos',[0.02 0.68 0],'str','^{\wedge}');
    %   set(handles.Fpass1Tag,'str','\omega_{cutoff}');
    % Option 2:
    %   set(handles.Fpass1Tag,'interpreter','latex','str','$$\widehat{\omega}_{cutoff}$$');

    % Option 3:
    set(handles.Fpass1Tag,'str',strrep(get(handles.Fpass1Tag,'str'),'F','   '));
    set(handles.Fstop1Tag,'str',strrep(get(handles.Fstop1Tag,'str'),'F','   '));
    set(handles.Fpass2Tag,'str',strrep(get(handles.Fpass2Tag,'str'),'F','   '));
    set(handles.Fstop2Tag,'str',strrep(get(handles.Fstop2Tag,'str'),'F','   '));
    % -------------
    switch handles.filt_type
        %---%---------------------
        case 'FIR'
            %---------------------
            if strcmp(handles.design_name,'Window')
                set(handles.wFpass1Tag,'vis','on');
                switch handles.filt_name
                    case {'Lowpass','Highpass'}
                        if strcmp(handles.win_name,'Kaiser')
                            set(handles.wFstop1Tag,'vis','on');
                            set([handles.wFpass2Tag,handles.wFstop2Tag],'vis','off');
                        else
                            set([handles.wFstop1Tag,handles.wFpass2Tag,handles.wFstop2Tag],'vis','off');
                        end
                    case {'Bandpass','Bandreject'}
                        if strcmp(handles.win_name,'Kaiser')
                            set([handles.wFstop1Tag,handles.wFpass2Tag,handles.wFstop2Tag],'vis','on');
                        else
                            set(handles.wFpass2Tag,'vis','on');
                            set([handles.wFstop1Tag,handles.wFstop2Tag],'vis','off');
                        end
                end
            else % 'Parks-McClellan'
                set([handles.wFpass1Tag,handles.wFstop1Tag],'vis','on');
                switch handles.filt_name
                    case {'Lowpass','Highpass'}
                        set([handles.wFpass2Tag,handles.wFstop2Tag],'vis','off');
                    case {'Bandpass','Bandreject'}
                        set([handles.wFstop1Tag,handles.wFpass2Tag,handles.wFstop2Tag],'vis','on');
                end
            end
            %---------------------
        case 'IIR'
            %---------------------
            set([handles.wFpass1Tag,handles.wFstop1Tag],'vis','on');
            switch handles.filt_name
                case {'Butterworth Lowpass','Butterworth Highpass'}
                    set([handles.wFpass2Tag,handles.wFstop2Tag],'vis','off');
                case {'Butterworth Bandpass','Butterworth Bandreject'}
                    set([handles.wFstop1Tag,handles.wFpass2Tag,handles.wFstop2Tag],'vis','on');
            end
    end
    %---------------------
end
if yscale == 1  % Magnitude
    set(get(handles.Plot1,'Ylabel'),'string','Magnitude');
else
    set(get(handles.Plot1,'Ylabel'),'string','Magnitude (dB)');
end
guidata(handles.figure1,handles);
%=========================================================================
function alpha_Callback(hObject, eventdata, handles)
%=========================================================================
if isempty(str2double(get(handles.alpha,'string')))
    set(handles.dialog,'type','error','message','Alpha cannot be empty');
    if strcmp(handles.win_name,'Gaussian')
        set(handles.alpha,'str','2.5');
    elseif strcmp(handles.win_name,'Dolph-Chebyshev')
        set(handles.alpha,'str','3');
    end
end
handles = PlotFIR(handles);
guidata(handles.figure1,handles);
%=========================================================================
function DesignMenu_Callback(hObject, eventdata, handles)
%=========================================================================
design_names = get(handles.DesignMenu,{'string','value'});
handles.design_name = design_names{1}{design_names{2}};
handles = SetFIRMenu(handles);

switch handles.design_name
    case 'Window'
        set([handles.Windows,handles.WindowsMenu],'vis','on');
        handles = PlotFIR(handles);
    case 'Parks-McClellan'
        set([handles.Windows,handles.WindowsMenu],'vis','off');
        handles = PlotFIRPM(handles,-1);
end
guidata(handles.figure1,handles);
%=========================================================================
function handles = PlotFIRPM(handles,no_iter)
%=========================================================================
if no_iter == -1
    no_iter = 9;
end

set(handles.PMFIter,'vis','on','val',no_iter);
set([handles.Line1a,handles.Line1b,handles.Line2, handles.Line3,handles.Line4a,handles.Line4b,...
    handles.Line5a,handles.Line5b,handles.Line6],'vis','off');

% Set the slider visible and intialize it to the max value
[params,Wpass1,Wstop1,Wpass2,Wstop2,Rp_dB,Rs_dB,order_type,xscale,yscale,omega] = user(handles);
error_flag = 0;
N = str2double(get(handles.Order,'string'));
NFFT = 512;
NFFT2 = NFFT/2;
L = N+1;

if ~mod(L,2)
    error_flag = 'Order cannot be odd';
    set(handles.Order,'string',num2str(N+1));
    L = N+2;
    N = N+1;
end

r = (L+1)/2;
fpass1 = round(params.Fpass1/params.Fsamp*NFFT)/NFFT;
fstop1 = round(params.Fstop1/params.Fsamp*NFFT)/NFFT;
fpass2 = round(params.Fpass2/params.Fsamp*NFFT)/NFFT;
fstop2 = round(params.Fstop2/params.Fsamp*NFFT)/NFFT;

switch handles.filt_name
    %---%---------------------
    case 'Lowpass'
        %---------------------
        r1 = fpass1/(0.5-fstop1+fpass1);
        no_pass = ceil((r+1)*r1);
        no_stop = (r+1)-no_pass;
        fext0 = [0 (fpass1 - (fpass1/no_pass)* [no_pass-2:-1:0])...
            (fstop1 + ((0.5-fstop1)/(no_stop-0.99))*[0:no_stop-1]) ]';
        rhs = [ones(no_pass,1); zeros(no_stop,1)];
        %---------------------
    case 'Highpass'
        %---------------------
        r1 = fpass1/(0.5-fstop1+fpass1);
        no_pass = ceil((r+1)*r1);
        no_stop = (r+1)-no_pass;
        fpass1 = round(params.Fstop1/params.Fsamp*NFFT)/NFFT;
        fstop1 = round(params.Fpass1/params.Fsamp*NFFT)/NFFT;
        fext0 = [0 (fpass1 - (fpass1/no_pass)* [no_pass-2:-1:0])...
            (fstop1 + ((0.5-fstop1)/(no_stop-0.99))*[0:no_stop-1]) ]';
        rhs = [zeros(no_pass,1); ones(no_stop,1)];
        %---------------------
    case 'Bandpass'
        %---------------------
        b1 = fstop1/(fstop1+fpass2-fpass1+0.5-fstop2);
        b2 = (fpass2-fpass1)/(fstop1+fpass2-fpass1+0.5-fstop2);
        b3 = (0.5-fstop2)/(fstop1+fpass2-fpass1+0.5-fstop2);

        no_stop1 = round((r+1)*b1);
        no_stop2 = round((r+1)*b3);
        no_pass = r+1-no_stop1-no_stop2;
        fext01 = [0 fstop1-(fstop1/no_stop1)*[no_stop1-2:-1:0]];
        fext02 = [fpass1 fpass2-[(fpass2-fpass1)/no_pass]*(no_pass-2:-1:0)];
        fext03 = [fstop2 + ((0.5-fstop2)/(no_stop2-0.99))*[0:no_stop2-1]];
        fext0  = [fext01 fext02 fext03]';

        rhs = [zeros(no_stop1,1);ones(no_pass,1); zeros(no_stop2,1)];
        %---------------------
    case 'Bandreject'
        %---------------------
        b1 = fpass1/(fpass1+fstop2-fstop1+0.5-fpass2);
        b2 = (fstop2-fstop1)/(fpass1+fstop2-fstop1+0.5-fpass2);
        b3 = (0.5-fpass2)/(fpass1+fstop2-fstop1+0.5-fpass2);

        no_pass1 = round((r+1)*b1);
        no_pass2 = round((r+1)*b3);
        no_stop = r+1-no_pass1-no_pass2;

        fext01 = [0 fpass1-(fpass1/no_pass1)*[no_pass1-2:-1:0]];
        fext02 = [fstop1 fstop2-[(fstop2-fstop1)/no_stop]*(no_stop-2:-1:0)];
        fext03 = [fpass2 + ((0.5-fpass2)/(no_pass2-0.99))*[0:no_pass2-1]];
        fext0  = [fext01 fext02 fext03]';

        rhs = [ones(no_pass1,1);zeros(no_stop,1); ones(no_pass2,1)];
        %---------------------
end

set(handles.PlotTitle,'string',[handles.filt_name ' filter of order ' num2str(N)]);

M = [2*pi*fext0*[0:(r-1)] pi*([0:r]') ];  % forms a matrix as shown on pg.499 Opp. Sch.
M = cos(M);
a = M\rhs;
delta = abs(a(end));   %the last element of that vector would be delta
h1 = [a([r:-1:2])/2; a(1); a([2:r])/2]; % construct a symmetry matrix
HH = fft(circhift(zeropad(h1,NFFT-L),(-L+1)/2));
HH(NFFT2+2:NFFT)=[];
HH = real(HH);
Hdiff = diff(HH);
iext = round(NFFT*fext0) + 1;

fextremal = (1/NFFT)*(iext-1);
dp = abs(delta);
handles.dp = dp;
ds  = abs(delta);
ds1 = abs(delta);
ds2 = abs(delta);
dp1 = abs(delta);
dp2 = abs(delta);
f = (0:NFFT2)'/NFFT;

Hdiff = diff(HH);
% handles.pmf_yvals = HH;

%line 78 remezbp
jext = find(Hdiff.*circhift(Hdiff,1)<=0);
% handles.jext{1} = jext;
fnew = (1/NFFT)*(jext-1);

%function remez(iter)
%Iterations
if delta > eps*10
    for k = 1:no_iter-1
        switch handles.filt_name
            %---%---------------------
            case 'Lowpass'
                %---------------------
                jext = [1;jext(find(jext<fpass1*NFFT+1));fpass1*NFFT+1;...
                    fstop1*NFFT+1;jext(find(jext>fstop1*NFFT+1));NFFT2+1]  ;

                jext(diff(jext) == 0) = []; % remove duplicates : jext = rmvduplicate(jext);
                HE = [HH(jext(jext<=fpass1*NFFT+1))' HH(jext(jext>=fstop1*NFFT+1))'];
                D = [ones(1,length(jext(jext<=fpass1*NFFT+1)))...
                    zeros(1,length(jext(jext>=fstop1*NFFT+1)))];
                E=HE-D;
                [Enew,jext]=checkalt(E,jext);
                if length(jext)>r+1
                    if abs(HE(1)-1)<abs(HE(end))
                        HE(1)=[];
                        jext(1)=[];
                    else
                        HE(end)=[];
                        jext(end)=[];
                    end
                    no_pass = length(jext(jext<=fpass1*NFFT+1));
                    no_stop = r+1-no_pass;
                end
                %---------------------
            case 'Highpass'
                %---------------------
                jext = [1;jext(find(jext<fpass1*NFFT+1));fpass1*NFFT+1;...
                    fstop1*NFFT+1;jext(find(jext>fstop1*NFFT+1));NFFT2+1]  ;

                jext(diff(jext) == 0) = []; % remove duplicates : jext = rmvduplicate(jext);
                HE = [HH(jext(jext<=fpass1*NFFT+1))' HH(jext(jext>=fstop1*NFFT+1))'];
                D = [zeros(1,length(jext(jext<=fpass1*NFFT+1)))...
                    ones(1,length(jext(jext>=fstop1*NFFT+1)))];
                E=HE-D;
                [Enew,jext]=checkalt(E,jext);
                if length(jext)>r+1
                    if abs(HE(1))<abs(HE(end)-1)
                        HE(1)=[];
                        jext(1)=[];
                    else
                        HE(end)=[];
                        jext(end)=[];
                    end
                    no_pass = length(jext(jext<=fpass1*NFFT+1));
                    no_stop = r + 1 - no_pass;
                end
                %---------------------
            case 'Bandpass'
                %---------------------
                jext = [1;jext(find(jext<fstop1*NFFT+1));fstop1*NFFT+1;...
                    fpass1*NFFT+1;jext(find((jext>fpass1*NFFT+1)&(jext<fpass2*NFFT+1)));...
                    fpass2*NFFT+1;fstop2*NFFT+1;jext(find(jext>fstop2*NFFT+1));NFFT2+1];

                jext(diff(jext) == 0) = []; % remove duplicates :jext = rmvduplicate(jext);
                HE = [HH(jext(jext<=fstop1*NFFT+1))' HH(jext(jext>=(fpass1*NFFT+1) & (jext<=(fpass2*NFFT+1))))' ...
                    HH(jext(jext>=fstop2*NFFT+1))'];
                D = [zeros(1,length(jext(jext<=fstop1*NFFT+1))) ones(1,length(jext(jext>=(fpass1*NFFT+1) & (jext<=fpass2*NFFT+1)))) ...
                    zeros(1,length(jext(jext>=fstop2*NFFT+1)))];
                E=HE-D;
                [Enew,jext]=checkalt(E,jext);
                no_stop1 = length(find(jext<=fstop1*NFFT+1));
                no_stop2 = length(find(jext>=fstop2*NFFT+1));
                no_pass = r+1 - no_stop1 - no_stop2;
                if length(jext)==(r+2)
                    if abs(HE(1)-D(1))<abs(HE(end))
                        HE(1)=[];
                        jext(1)=[];
                        no_stop1 = no_stop1-1;
                    else
                        HE(end)   = [];
                        jext(end) = [];
                        no_stop2  = no_stop2-1;
                    end
                    no_pass = r+1 - no_stop1 - no_stop2;
                elseif length(jext)>(r+2)
                    jext = chkpair(Enew,jext);
                    no_stop1 = length(find(jext<=fstop1*NFFT+1));
                    no_stop2 = length(find(jext>=fstop2*NFFT+1));
                    no_pass = r+1 - no_stop1 - no_stop2;
                end
                %---------------------
            case 'Bandreject'
                %---------------------
                jext = [1;jext(find(jext<fpass1*NFFT+1));fpass1*NFFT+1;...
                    fstop1*NFFT+1;jext(find((jext>fstop1*NFFT+1)&(jext<fstop2*NFFT+1)));...
                    fstop2*NFFT+1;fpass2*NFFT+1;jext(find(jext>fpass2*NFFT+1));NFFT2+1];
                jext(diff(jext) == 0) = []; % remove duplicates : jext = rmvduplicate(jext);

                HE = [HH(jext(jext<=fpass1*NFFT+1))' HH(jext(jext>=(fstop1*NFFT+1) & (jext<=(fstop2*NFFT+1))))' ...
                    HH(jext(jext>=fpass2*NFFT+1))'];

                D = [ones(1,length(jext(jext<=fpass1*NFFT+1))) zeros(1,length(jext(jext>=(fstop1*NFFT+1) & (jext<=fstop2*NFFT+1)))) ...
                    ones(1,length(jext(jext>=fpass2*NFFT+1)))];
                E=HE-D;  %Error matrix
                [Enew,jext]=checkalt(E,jext);

                no_pass1 = length(find(jext<=fpass1*NFFT+1));
                no_pass2 = length(find(jext>=fpass2*NFFT+1));
                no_stop = r+1 - no_pass1 - no_pass2;

                if length(jext)==(r+2)
                    if abs(HE(1)-D(1))<abs(HE(end))
                        HE(1)=[];
                        jext(1)=[];
                        no_pass1 = no_pass1-1;
                    else
                        HE(end)=[];
                        jext(end)=[];
                        no_pass2 = no_pass2-1;
                    end
                    no_stop = r+1 - no_pass1 - no_pass2;
                elseif length(jext)>(r+2)
                    jext = chkpair(Enew,jext);
                    no_pass1 = length(find(jext<=fpass1*NFFT+1));
                    no_pass2 = length(find(jext>=fpass2*NFFT+1));
                    no_stop = r+1 - no_pass1 - no_pass2;
                end
                %---------------------
        end

        fextnew = (1/NFFT)*(jext-1);
        iext = round(NFFT*fextnew) + 1;
        M = [2*pi*fextnew*[0:(r-1)] pi*(0:r)' ];  %forms a matrix as shown on pg.499 Opp. Sch.
        M = cos(M);

        switch handles.filt_name
            case 'Lowpass'
                rhs = [ones(no_pass,1); zeros(no_stop,1)];
            case 'Highpass'
                rhs = [zeros(no_pass,1); ones(no_stop,1)];
            case 'Bandpass'
                rhs=[zeros(no_stop1,1);ones(no_pass,1); zeros(no_stop2,1)];
            case 'Bandreject'
                rhs = [ones(no_pass1,1);zeros(no_stop,1);ones(no_pass2,1)];
        end
        a = M\rhs;
        delta = abs(a(end));
        h1 = [a([r:-1:2])/2; a(1); a([2:r])/2];

        HH = fft(circhift(zeropad(h1,NFFT-L),(-L+1)/2));
        HH(NFFT2+2:NFFT)=[];
        HH = real(HH);
        Hdiff = diff(HH);
        %         handles.pmf_yvals = [handles.pmf_yvals,HH];
        %         iext = round(NFFT*fext0) + 1;
        %         fextremal = (1/NFFT)*(iext-1);
        dp = abs(delta);
        ds = abs(delta);
        ds1 = ds;
        ds2 = ds;
        dp1 = dp;
        dp2 = dp;
        Hdiff = diff(HH);
        jext = find(Hdiff.*circhift(Hdiff,1)<=0);

        % bandpass specific routine
        if get(handles.Filter, 'value') == 3
            jkl1 = find( jext<(fpass1*NFFT+1) & jext>(fstop1*NFFT+1) );
            jkl2 = find( jext>(fpass2*NFFT+1) & jext<(fstop2*NFFT+1) );
            jext(jkl1)=[];
            jext(jkl2)=[];

            D1 = [zeros(1,length(jext(jext<=fstop1*NFFT+1))) ones(1,length(jext(jext>=(fpass1*NFFT+1) & (jext<=fpass2*NFFT+1)))) ...
                zeros(1,length(jext(jext>=fstop2*NFFT+1)))];
            E = HH(jext)' - D1;
            newE = round(abs(E)*1e4)/1e4;
            newd = round(abs(delta)*1e4)/1e4;
            jkl = find(newE < newd);
            jext(jkl) = [];
            E(jkl) = [];
        elseif get(handles.Filter, 'value') == 4
            jkl1 = find( jext<(fstop1*NFFT+1) & jext>(fpass1*NFFT+1) );
            jkl2 = find( jext>(fstop2*NFFT+1) & jext<(fpass2*NFFT+1) );
            jext(jkl1)=[];
            jext(jkl2)=[];

            D1 = [ones(1,length(jext(jext<=fpass1*NFFT+1)))...
                zeros(1,length(jext(jext>=(fstop1*NFFT+1) & (jext<=fstop2*NFFT+1)))) ...
                ones(1,length(jext(jext>=fpass2*NFFT+1)))];
            E = HH(jext)' - D1;
            newE = round(abs(E)*1e4)/1e4;
            newd = round(abs(delta)*1e4)/1e4;
            jkl = find(newE < newd);
            jext(jkl) = [];
            E(jkl) = [];
        end

        fnew = (1/NFFT)*(jext-1);
    end    %%%End of all the iterations

    w = (0:NFFT2)'/NFFT;
    h = HH;
    handles.total_res = h1;
    handles.dp = dp;
    handles.noextremal = r+1;
    set(handles.RemezText,'vis','on','string' , ['Iteration : ',num2str(no_iter)]);

    switch handles.filt_name
        %---%---------------------
        case 'Lowpass'
            %---------------------
            xdata1 = [0;params.Fpass1;params.Fpass1;params.Fpass1;0]*(2-xscale) + [0;params.Fpass1*2/params.Fsamp;params.Fpass1*2/params.Fsamp;params.Fpass1*2/params.Fsamp;0]*(xscale-1);
            xdata2 = [params.Fsamp/2;params.Fstop1;params.Fstop1;params.Fsamp/2]*(2-xscale) + [1;params.Fstop1*2/params.Fsamp;params.Fstop1*2/params.Fsamp;1]*(xscale-1);
            ydata1 = [1-dp;1-dp;0;1+dp;1+dp]*(2-yscale)  ;
            ydata2 = [-ds;-ds;ds;ds]*(2-yscale);
            set(handles.note,'string',{[' Extremal Freqs = ' num2str(handles.noextremal)],'',[' \delta_{pass} = ' num2str(dp)],[' \delta_{stop } = ' num2str(ds)]});
            %---------------------
        case 'Highpass'
            %---------------------
            xdata1 = [0;params.Fstop1;params.Fstop1;params.Fstop1;0]*(2-xscale) + [0;params.Fstop1*2/params.Fsamp;params.Fstop1*2/params.Fsamp;params.Fstop1*2/params.Fsamp;0]*(xscale-1);
            xdata2 = [params.Fsamp/2;params.Fpass1;params.Fpass1;params.Fpass1;params.Fsamp/2]*(2-xscale) + [1;params.Fpass1*2/params.Fsamp;params.Fpass1*2/params.Fsamp;params.Fpass1*2/params.Fsamp;1]*(xscale-1);
            ydata1 = [-ds;-ds;0;ds;ds]*(2-yscale);
            ydata2 = [1-dp;1-dp;0;1+dp;1+dp];
            set(handles.note,'string',{[' Extremal Freqs = ' num2str(handles.noextremal)],'',[' \delta_{pass} = ' num2str(dp)],[' \delta_{stop } = ' num2str(ds)]});
            %---------------------
        case 'Bandpass'
            %---------------------
            xdata1 = [0 params.Fstop1 params.Fstop1 params.Fstop1 0]*(2-xscale) + [0 params.Fstop1*2/params.Fsamp params.Fstop1*2/params.Fsamp params.Fstop1*2/params.Fsamp 0]*(xscale-1);
            xdata2 = [params.Fpass1 params.Fpass2 params.Fpass2 params.Fpass1 params.Fpass1]*(2-xscale) + [params.Fpass1 params.Fpass2 params.Fpass2 params.Fpass1 params.Fpass1]*2/params.Fsamp*(xscale-1);
            xdata5 = [params.Fstop2 params.Fsamp/2 params.Fsamp/2 params.Fstop2 params.Fstop2]*(2-xscale) + [params.Fstop2 params.Fsamp/2 params.Fsamp/2 params.Fstop2 params.Fstop2]*2/params.Fsamp*(xscale-1);
            ydata1 = [-ds1 -ds1 0 ds1 ds1]*(2-yscale);
            ydata2 = [1+dp 1+dp 1-dp 1-dp 1+dp]*(2-yscale);
            ydata5 = [-ds2 -ds2 ds2 ds2 -ds2]*(2-yscale);
            set(handles.note,'string',{[' Extremal Freqs = ' num2str(handles.noextremal)],'',[' \delta_{pass  } = ' num2str(dp)],[' \delta_{stop1 } = ' num2str(ds1)],[' \delta_{stop2 } = ' num2str(ds2)]});
            %---------------------
        case 'Bandreject'
            %---------------------
            xdata1 = [0 params.Fpass1 params.Fpass1 params.Fpass1 0]*(2-xscale) + [0 params.Fpass1*2/params.Fsamp params.Fpass1*2/params.Fsamp params.Fpass1*2/params.Fsamp 0]*(xscale-1);
            xdata2 = [params.Fstop1 params.Fstop2 params.Fstop2 params.Fstop1 params.Fstop1]*(2-xscale) + [params.Fstop1 params.Fstop2 params.Fstop2 params.Fstop1 params.Fstop1]*2/params.Fsamp*(xscale-1);
            xdata5 = [params.Fpass2 params.Fsamp/2 params.Fsamp/2 params.Fpass2 params.Fpass2 params.Fpass2]*(2-xscale) + [params.Fpass2 params.Fsamp/2 params.Fsamp/2 params.Fpass2 params.Fpass2 params.Fpass2]*2/params.Fsamp*(xscale-1);
            ydata1 = [1+dp1 1+dp1 0 1-dp1 1-dp1]*(2-yscale);
            ydata2 = [-ds -ds ds ds -ds]*(2-yscale);
            ydata5 = [1+dp2 1+dp2 1-dp2 1-dp2 1+dp2 0]*(2-yscale);
            set(handles.note,'string',{[' Extremal Freqs = ' num2str(handles.noextremal)],'',[' \delta_{pass1 } = ' num2str(dp1)],[' \delta_{pass2 } = ' num2str(ds2)],[' \delta_{stop    } = ' num2str(ds)]});
            %---------------------
    end
    %Plots the extremal plots of the final iteration
    xdata3 = [(jext-1)/NFFT*params.Fsamp]*(2-xscale) + [(jext-1)/NFFT*2]*(xscale-1);
    xdata4 = [(iext-1)/NFFT*params.Fsamp]*(2-xscale) + [(iext-1)/NFFT*2]*(xscale-1);
    ydata3 = h(jext)*(2-yscale) + 20*log10(abs(h(jext)))*(yscale-1);
    ydata4 = h(iext)*(2-yscale) + 20*log10(abs(h(iext)))*(yscale-1);
    set(handles.RemezExtre1,'xdata',xdata3,'ydata',ydata3,'vis','on');
    set(handles.RemezExtre2,'xdata',xdata4,'ydata',ydata4,'vis','on');

    if yscale == 1
        set(handles.RemezHorz1,'xdata',xdata1,'ydata',ydata1,'vis','on');
        set(handles.RemezHorz2,'xdata',xdata2,'ydata',ydata2,'vis','on');
        if get(handles.Filter,'value') == 3
            set(handles.RemezHorz3,'xdata',xdata5,'ydata',ydata5,'vis','on');
        elseif get(handles.Filter,'value') == 4
            set(handles.RemezHorz3,'xdata',xdata5,'ydata',ydata5,'vis','on');
        else
            set(handles.RemezHorz3,'vis','off');
        end
    else
        set([handles.RemezHorz1,handles.RemezHorz2,handles.RemezHorz3], 'vis', 'off')
    end
    handles.w = w*2*pi;
    handles.h = h;
    handles.b = handles.total_res;
    handles.a = 1;
    guidata(handles.figure1,handles);
end    %% End of the condition for checking if delta < eps*10

if delta < eps*10
    error_flag = ['Resetting to default values -- Value of delta ' num2str(delta)];
    set(handles.params.Fsamp,'string', '8000');
    set(handles.Fpass1,'string','1000');
    set(handles.Fstop1,'string','1500');

    if (fir_num == 3)
        set(handles.Fpass1,'string','1500');
        set(handles.Fstop1,'string','1000');
        set(handles.Fpass2,'string','2500');
        set(handles.Fstop2,'string','3000');
    end
    set(handles.Order, 'string' , '20');
    handles = PlotFIRPM(handles,-1);
end

handles = choosePlot(handles);
if error_flag
    set(handles.dialog,'type','error','message',error_flag);
end
if ~strcmp(get(handles.dialog,'type'),'help');
    set(handles.dialog,'vis','off');
end
guidata(handles.figure1,handles);
%=====================================================================
function PMFIter_Callback(hObject, eventdata, handles)
%=====================================================================
slid_val = get(handles.PMFIter,'val');
handles = PlotFIRPM(handles,slid_val);
%=========================================================================
function Default_CreateFcn(hObject, eventdata, handles)
%=========================================================================
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
%=========================================================================
