function varargout = strobedemo(varargin)
% Last Modified by GUIDE v2.6 7-Jul-2005 21:22:57
%=============================================================
% StrobeDemo Version 1.43
%
% Akshai Parthasarathy and Dr. Mark Smith
% I would like to thank Prof. McClellan, Dr. Smith, Greg Krudysz, and
% Rajbabu Velmurugan for their help in making the GUI. The driver part of
% this project was implemented by Dr. Smith.
%
% This GUI simulates a rotating disc with an arrow, being flashed by a
% strobe light. The frequency of the motor is constant, and upon
% varying the flash rate, concepts such as aliasing can be observed.
%
% The GUI can be used with or without the connection to the actual strobe.
% Run the code by adding to the Matlab Path, and typing "strobedemo".
%=============================================================

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @strobedemo_OpeningFcn, ...
    'gui_OutputFcn',  @strobedemo_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end
if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
%=============================================================

%=============================================================
function strobedemo_OpeningFcn(hObject, eventdata, h, varargin)
%=============================================================
%---  Check the installation, the Matlab Version, and the Screen Size  ---%
set(gcf,'Name','StrobeDemo v1.43');
errCmd = 'errordlg(lasterr,''Error Initializing Figure'');error(lasterr);';
cmdCheck1 = 'installcheck;';
cmdCheck2 = 'h.MATLABVER = versioncheck(6.5);';
cmdCheck3 = 'screensizecheck([800 600]);';
cmdCheck4 = ['adjustpath(''' mfilename ''');'];
eval(cmdCheck1,errCmd);       % Simple installation check
eval(cmdCheck2,errCmd);       % Check Matlab Version
eval(cmdCheck3,errCmd);       % Check Screen Size
eval(cmdCheck4,errCmd);       % Adjust path if necessary

h.output = hObject;

%center in the screen
OldUnits = get([0; gcf], 'units');
set([0; gcf],'units','pixels');
ScreenSize = get(0,'ScreenSize');
FigPos = get(gcf,'Position');
newFigPos = [ (ScreenSize(3)-FigPos(3))/2  (ScreenSize(4)-FigPos(4))/2  FigPos(3:4) ];
set(gcf,'Pos',newFigPos);
set([0; gcf],{'units'},OldUnits);

% Axis numbered as follows:     1 |   | 3
%                              -----------
%                               2 | 4 | 5
%-------------------------------------------------------------------------
%AXES 1
%-------------------------------------------------------------------------
% lines: circle, limits
axes(h.axes1);
a=1;
h.line1d = arrow(pi,'patch',1.2,0.3,0.1,-0.32,0.2);

%placing the arrow
phi = pi/4; % change initial loc as needed
%loc = exp(j * phi);
h.line1v = arrow(phi,'line',0.25,0.1);

xcirc = -a:.0001:a;
ycirc =  sqrt(a^2 - xcirc.^2);
ycirc2 = -sqrt(a^2 - xcirc.^2);
h.line1c = line(xcirc,ycirc);
h.line1c = line(xcirc,ycirc2);

yd = -a/3:.0001:a/3;
xd =  sqrt((a/3)^2 - yd.^2);
h.semic = line(xd,yd);

set(h.axes1,'xlim',[-a,a],'ylim',[-a,a],'xtick',[],'ytick',[]);
%set(h.axes1,'vis','off');
%-------------------------------------------------------------------------
%AXES 2
%-------------------------------------------------------------------------
axes(h.axes2);
rpmstr = get(h.edit1,'String');
h.rpm = str2double(rpmstr);
h.fm = h.rpm/60; %rotations per second initially is 12.5 = 750/60
fm = h.fm;
h.fs = get (h.slider2,'value')/60;
fs = h.fs;
if h.MATLABVER >= 7
    h.line2 = stemdata(-h.fm,a,{'o','k'});
else
    h.line2 = stem(-h.fm,a,'filled');
end

set(h.axes2,'xlim',[-1.5*fs,1.5*fs],'xtick',(-fs:fs:fs),'XTickLabel',{-fs,0,fs}, 'ylim',[0 1.5]);
YMAX2 = 1.5;
zero2 = line([0,0],[0,YMAX2]);
set(zero2,'color','k','linestyle',':');

h.p2 = patch([-fs/2 fs/2 fs/2 -fs/2],[0 0 1.5 1.5],'y');
chil = get(h.axes2,'children');
set(h.axes2,'children',[chil(2:end);chil(1)]);
xlabel('frequency (Hz)','fontsize',10)
%
% initialize the strobe light (Hardware Option)
%system ('strobe.exe init');
%%% system(strcat('strobe',[32],num2str(fs)));
%system(['strobe',' ',num2str(fs)]);
%-------------------------------------------------------------------------
%AXES 4
%-------------------------------------------------------------------------
axes(h.axes4);
YMAX4 = 1.5;
XMAX4 = 3*pi;

h.what = 2*pi*-h.fm/h.fs;
what = h.what;
% if h.what < -pi
%     h.what = h.what + 2*pi;
% end

% lines
if h.MATLABVER >= 7
    h.line4w = stemdata(what,1,{'o','b'});
else
    h.line4w = stem(what,1,'filled');               %non aliased line
end
h.line4wa1 = line([what-2*pi,what-2*pi],[0,1]); %non aliased line
h.line4wa2 = line([what+2*pi,what+2*pi],[0,1]); %non aliased line
set([h.line4wa1,h.line4wa2],'color','r');
zero4 = line([0,0],[0,YMAX4]);
set(zero4,'color','k','linestyle',':');
h.line4a = line([pi,-pi],[0,1]);
set(h.line4a,'visible','off','color','r');
xlabel('\omega = 2\pi (f_o/f_s)','fontsize',10);

% patch
h.p4 = patch([-pi pi pi -pi],[0 0 YMAX4 YMAX4],'y');
chil = get(h.axes4,'children');
set(h.axes4,'children',[chil(2:end);chil(1)]);

% text
h.text11 = text(0,1.3,'A L I A S I N G!');
set(h.text11,'Horiz','center','color','r','FontSize',12,'FontWeight','bold','vis','off');
fs = h.fs;

set(h.axes4,'fontname','Symbol');
set(h.axes4,'xlim',[-XMAX4, XMAX4],'ylim',[0,YMAX4],'xtick',(-2*pi:pi:2*pi),'XTickLabel',{'-2p','p','0','p','2p'});

%-------------------------------------------------------------------------
%AXES 3
%-------------------------------------------------------------------------
axes(h.axes3);

% circle lines and arrows
h.line3d = arrow(pi,'patch',1.2,0.3,0.1,-0.32,0.2);
h.line3dalias = arrow(pi,'patch',1.2,0.3,0.1,0.32,0.2,'r');
set(h.line3dalias,'visible','off');
set(h.axes3,'xlim',[-a,a],'ylim',[-a,a],'xtick',[],'ytick',[]);
h.line3c = line(xcirc,ycirc);
h.line3c = line(xcirc,ycirc2);
h.semi3c = line(xd,yd);

% initial phase arrow
h.line3v = arrow(phi,'line',0.25,0.1);

% current phase arrow
phin = pi/4 - (2*pi*fm/fs); % change initial loc as needed
locn = exp(j * phin);
h.line3n = arrow(phin,'line',0.25,0.1);

% delta theta text
delt = (phin - phi) * 180/pi;
deltstr = sprintf('%.1f',delt);
set(h.text13,'String',deltstr);

locn2 = locn*exp(j*delt*pi/180);
locn3 = locn2*exp(j*delt*pi/180);
phin2 = phin + delt*pi/180;
phin3 = phin2 + delt*pi/180;
h.line3n2 = arrow(phin2,'line',0.25,0.1);
h.line3n3 = arrow(phin3,'line',0.25,0.1);

set([h.line3n,h.line3n2,h.line3n3],'visible','on');
set(h.line3n,'color','k');
set(h.line3n2,'color','g');
set(h.line3n3,'color','m');

%-------------------------------------------------------------------------
% AXES 5
%-------------------------------------------------------------------------
axes(h.axes5);
XMAX5 = 1.5*fs;

% lines
if h.MATLABVER >= 7
    h.line5 = stemdata(-fm,1,{'o','b'});
else
    h.line5 = stem(-fm,1,'filled');
end
zero5 = line([0,0],[0,YMAX4]);
set(zero5,'color','k','linestyle',':');
xlabel('frequency (Hz)','fontsize',10)

% patch
h.p5 = patch([-fs/2 fs/2 fs/2 -fs/2],[0 0 YMAX4 YMAX4],'y');
chil = get(h.axes5,'children');
set(h.axes5,'children',[chil(2:end);chil(1)],'box','on');

set(h.axes5,'xlim',[-XMAX5, XMAX5],'ylim',[0,YMAX4],'xtick',(-fs:fs:fs),'XTickLabel',{-fs,0,fs});
%-------------------------------------------------------------------------
%text: "Flash Frequency"
fsstr = sprintf('%.1f',h.fs);
% set(h.text9,'String',fsstr);

%Line Width
h.LineWidth = 1.75;
set(findobj(gcf,'type','line'),'linewidth',h.LineWidth);

FigSize = [0.10 0.10 0.55 0.80];
set(gcbf, 'Units', 'Normalized','Position', FigSize);

guidata(hObject, h); % Update h structure

%=============================================================
function varargout = strobedemo_OutputFcn(hObject, eventdata, h)
%=============================================================
varargout{1} = h.output;
%=============================================================
function slider1_Callback(hObject, eventdata, h)
%=============================================================
s1e1_Callback('s',h,1);
h = fig4update(h);
guidata(hObject, h); % Update h structure
%=============================================================
function edit1_Callback(hObject, eventdata, h)
%=============================================================
s1e1_Callback('e1',h,1);
h = fig4update(h);
guidata(hObject, h); % Update h structure
%=============================================================
function edit2_Callback(hObject, eventdata, h)
%=============================================================
s1e1_Callback('e2',h,1);
h = fig4update(h);
guidata(hObject, h); % Update h structure
%=============================================================
function slider2_Callback(hObject, eventdata, h)
%=============================================================
[fm,fs] = s1e1_Callback('s',h,0);
h = fig4update(h);
% system(strcat('strobe',[32],num2str(fs)));
%system(['strobe',' ',num2str(fs)]);
guidata(hObject, h); % Update h structure
%=============================================================
function edit6_Callback(hObject, eventdata, h)
%=============================================================
[fm,fs] = s1e1_Callback('e1',h,0);
h = fig4update(h);
% system(strcat('strobe',[32],num2str(fs)));
%system(['strobe',' ',num2str(fs)]);
guidata(hObject, h); % Update h structure
%=============================================================
function edit7_Callback(hObject, eventdata, h)
%=============================================================
[fm,fs] = s1e1_Callback('e2',h,0);
h = fig4update(h);
% system(strcat('strobe',[32],num2str(fs)));
%system(['strobe',' ',num2str(fs)]);
guidata(hObject, h); % Update h structure
%=============================================================
%=============================================================
function edit2_CreateFcn(hObject, eventdata, handles)
%=============================================================
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
%=============================================================
function slider2_CreateFcn(hObject, eventdata, handles)
%=============================================================
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
%=============================================================
function slider3_CreateFcn(hObject, eventdata, handles)
%=============================================================
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
%=============================================================
function edit1_CreateFcn(hObject, eventdata, h)
%=============================================================
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
%=============================================================
function slider1_CreateFcn(hObject, eventdata, h)
%=============================================================
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
%=============================================================
function setLwidth_Callback(hObject, eventdata, h)
%=============================================================
newLineWidth = linewidthdlg(h.LineWidth);
h.LineWidth = newLineWidth;
set(findobj(gcbf,'type','line'),'linewidth',h.LineWidth);
%h.MarkerSize = h.MarkerSize + (newLineWidth - h.LineWidth);
% Update h structure
guidata(gcbf, h);   
%=============================================================
function figure1_ResizeFcn(hObject, eventdata, handles)
%=============================================================

%=============================================================
function edit6_CreateFcn(hObject, eventdata, handles)
%=============================================================
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
%=============================================================
function edit7_CreateFcn(hObject, eventdata, handles)
%=============================================================
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
%=============================================================
function radiobutton1_Callback(hObject, eventdata, h)
%=============================================================
tmp = get(h.slider2,'SliderStep');
if get(hObject,'Value') %returns toggle state of radiobutton1
    set(h.slider2,'SliderStep',[tmp(1)/60,tmp(2)/60]);
else
    set(h.slider2,'SliderStep',[tmp(1)*60,tmp(2)*60]);
end
%=============================================================
function radiobutton2_Callback(hObject, eventdata, h)
%=============================================================
tmp = get(h.slider1,'SliderStep');
if get(hObject,'Value') %returns toggle state of radiobutton1
    set(h.slider1,'SliderStep',[tmp(1)/2,tmp(2)/60]);
else
    set(h.slider1,'SliderStep',[tmp(1)*2,tmp(2)*60]);
end
%=============================================================
function key_Callback(hObject, eventdata, h)
%=============================================================
key = get(hObject,'currentcharacter');
if any(strcmp(key,{'a','s','A','S'}))
    value = get(h.slider1,'value');
    step = get(h.slider1, 'sliderstep');
    step = step(1);
    Max = get(h.slider1,'Max');
    Min = get(h.slider1,'Min');
    inc = step* (Max-Min);
elseif any(strcmp(key,{'k','K','l','L'}))
    value = get(h.slider2,'value');
    step = get(h.slider2, 'sliderstep');
    step = step(1);
    Max = get(h.slider2,'Max');
    Min = get(h.slider2,'Min');
    inc = step* (Max-Min);
end

if or(strcmp(key,'a') , strcmp(key,'A'))
    value = value-inc;
    if value < Min
        value = Min;
    end
    set(h.slider1,'value',value);
    slider1_Callback(hObject, eventdata, h)
elseif or(strcmp(key,'s') , strcmp(key,'S'))
    value = value+inc;
    if value > Max
        value = Max;
    end
    set(h.slider1,'value',value);
    slider1_Callback(hObject, eventdata, h)
elseif or(strcmp(key,'l') , strcmp(key,'L'))
    value = value+inc;
    if value > Max
        value = Max;
    end
    set(h.slider2,'value',value);
    slider2_Callback(hObject, eventdata, h)
elseif or(strcmp(key,'k') , strcmp(key,'K'))
    value = value-inc;
    if value < Min
        value = Min;
    end
    set(h.slider2,'value',value);
    slider2_Callback(hObject, eventdata, h)
else
    %do nothing
end
%=============================================================
function Help_Callback(hObject,eventdata,h)
%=============================================================
hBar = waitbar(0.25,'Opening internet browser...','color',get(gcbf,'color'));
DefPath = which(mfilename);
DefPath = ['file:///' strrep(DefPath,filesep,'/') ];
URL = [ DefPath(1:end-(length(mfilename)+2)) , 'help/','index.html'];
if h.MATLABVER >= 6
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
            'which is located in the StrobeDemo help directory.'};
        errordlg(s,'Error launching browser.');
end