function varargout = specgramdemo(varargin)
% specgramdemo MATLAB code for specgramdemo.fig
%      SPECGRAMDEMO, by itself, creates a new SPECGRAMDEMO or raises the existing
%      singleton*.
%
%      H = SPECGRAMDEMO returns the handle to a new SPECGRAMDEMO or the handle to
%      the existing singleton*.
%
%      SPECGRAMDEMO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SPECGRAMDEMO.M with the given input arguments.
%
%      SPECGRAMDEMO('Property','Value',...) creates a new SPECGRAMDEMO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before specgramdemo_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to specgramdemo_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help specgramdemo

% Last Modified by GUIDE v2.5 05-Nov-2015 17:48:36

% Begin initialization code - DO NOT EDIT
%-------------------------------------------------------------------------%
% PSEUDO CODE:
%   1. FT
%           a) parameters
%   2. Signal
%           a) type         ( LinearChirp | SumOfSinusoids | UserAudio )
%           b) parameters
%   3. Plot
%-------------------------------------------------------------------------%
gui_Singleton = 1;
gui_State = struct('gui_Name', mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @specgramdemo_OpeningFcn, ...
    'gui_OutputFcn',  @specgramdemo_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% --------------------------------------------------------------------
function specgramdemo_OpeningFcn(hObject, eventdata, handles, varargin)
% --------------------------------------------------------------------
Ver = 'specgramdemo ver. 2.82';  % Version string for figure title

%---  Check the installation, the Matlab Version, and the Screen Size  ---%
errCmd    = 'errordlg(lasterr,''Error Initializing Figure'');error(lasterr);';
cmdCheck1 = 'installcheck;';
cmdCheck2 = 'h.MATLABVER = versioncheck(8.4);';
cmdCheck3 = 'screensizecheck([800 600]);';
cmdCheck4 = ['adjustpath(''' mfilename ''');'];
eval(cmdCheck1,errCmd);       % Simple installation check
eval(cmdCheck2,errCmd);       % Check Matlab Version
eval(cmdCheck3,errCmd);       % Check Screen Size
eval(cmdCheck4,errCmd);       % Adjust path if necessary

%--- DEBUG -------------------------------%
handles.debug = false;

%--- 1. PARAMETERS -----------------------%
% Fs
handles.param.fs = 8000;

% Window
handles.windowType = 'hann';
handles.param.nfft = 512;

%--- size
handles.param.windowsize = round(0.5*handles.param.nfft);
set(handles.win_slider,'Value',handles.param.windowsize,'Min',1,'Max',handles.param.nfft-1);
set(handles.win_box,'String',num2str(handles.param.windowsize));

%--- overlap
handles.param.noverlap = round(0.25*handles.param.nfft);
set(handles.noverlap_box,'String',num2str(handles.param.noverlap));
set(handles.noverlap_menu,'Value',3);

handles.param.drange = 50;
handles.param.window = hann(handles.param.windowsize);

%--- 2. SIGNAL ---------------------------%
% a) h.signal.type = LinearChirp | SumOfSinusoids | UserAudio

handles.begin = 0;
handles.end = 4.04;
handles.t = handles.begin:1/handles.param.fs:handles.end;

% Linear-Chirp
handles.chirp_rate = 500;
handles.f0 = 100;
handles.signal.data = chirp_spec(handles.t,1,handles.f0,handles.chirp_rate);
handles.signal.type = 'LinearChirp';

% Sum-Of-Sinusoids
handles.amplitude = [1 1];
handles.sinufreq = [500 1500];
handles.phase = [0 0];
handles.sinu = SumOfSinusoids(handles.amplitude,handles.sinufreq,handles.phase,handles.t);

% User-Audio
handles.pathname = [pwd filesep];
handles.filename = 'voice.wav';

%--- 3. PLOT -----------------------------%
handles.rotation = rotate3d;

handles.az = 0;
handles.el = 90;
handles.b = [];
handles.F = [];
handles.FT = false;
handles.FT_time = 0;

set([handles.ColorMap,handles.Drange,handles.windows],'Value',3);

% User-Audio
handles.record_time = 3;

% Plotting
handles.ONcolor = 'w';
handles.color1 = [0.9412 0.9412 0.9412];
handles.color2 = [0.84 0.84 0.84];
handles.colourmap = 'gray';

plt(handles);

% GUI
ver = version;
h.MATLABVER = str2double(ver(1:3));

handles.signal_position = get(handles.LinearChirp_panel,'position');
set([handles.SumOfSinusoids_panel,handles.UserAudio_panel],'position',handles.signal_position,'visible','off');
set(handles.LinearChirp_panel,'visible','on');

%SCALE = getfontscale;          % Platform dependent code to determine SCALE parameter
%setfonts(gcf,SCALE);           % Setup fonts: override default fonts used
%configresize(gcf);             % Change all 'units'/'font units' to normalized

set(gcf,'units','norm');
FigSize = get(gcf,'Position');
FigSizeNew = [(1-FigSize(3))/2 (1-FigSize(4))/2 FigSize(3) FigSize(4)];
set(gcf,'Name',Ver,'Position',FigSizeNew,'HandleVisibility','callback'); % Make figure inaccessible from command line

% Choose default command line output for specgramdemo
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
% --------------------------------------------------------------------
function varargout = specgramdemo_OutputFcn(hObject, eventdata, handles)
% --------------------------------------------------------------------
varargout{1} = handles.output;
% --------------------------------------------------------------------
function SignalType_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
if (handles.debug) [ST,I] = dbstack; disp([ST(1).name]);end

set(hObject,'fontweight','bold','back',handles.ONcolor);
handles.signal.type = get(hObject,'tag');

switch handles.signal.type
    case 'LinearChirp'
        set([handles.SumOfSinusoids,handles.UserAudio],'back',handles.color2,'fontweight','normal');
        set(handles.LinearChirp_panel,'visible','on');
        set([handles.SumOfSinusoids_panel,handles.UserAudio_panel],'visible','off');      
        set(handles.error_box,'ForegroundColor','b','String','Spectrogram of Linear Chirp');
    case 'SumOfSinusoids'
        set([handles.LinearChirp,handles.UserAudio],'back',handles.color2,'fontweight','normal');
        set(handles.SumOfSinusoids_panel,'visible','on');
        set([handles.LinearChirp_panel,handles.UserAudio_panel],'visible','off');
        set(handles.error_box,'ForegroundColor','b','String','Spectrogram of Sum of Sinusoids');
    case 'UserAudio'
        set([handles.LinearChirp,handles.SumOfSinusoids],'back',handles.color2,'fontweight','normal');
        set(handles.UserAudio_panel,'visible','on');
        set([handles.LinearChirp_panel,handles.SumOfSinusoids_panel],'visible','off');             
end
renewSignalSpect(hObject, eventdata, handles);
% --------------------------------------------------------------------
function renewSignalSpect(hObject, eventdata, handles)
% --------------------------------------------------------------------
if (handles.debug) [ST,I] = dbstack; disp([ST(1).name]);end

switch handles.signal.type
    case {'LinearChirp','SumOfSinusoids'}
        handles.begin = 0;
        handles.end = 4.04;
        handles.t = handles.begin:1/handles.param.fs:handles.end;
        if (~get(handles.threeD_button,'value'))
            handles.az = 0;
            handles.el = 90;
        end
        handles.FT = false;
        handles = renewSignal(hObject,eventdata,handles);
    case 'UserAudio'
        handles = renewSignal(hObject,eventdata,handles);
        [handles.b,handles.f,handles.t] = find_b_and_t(handles);
        %record_zoom(handles);
end
guidata(hObject, handles);
% --------------------------------------------------------------------
function handles = renewSignal(hObject,eventdata, handles)
% --------------------------------------------------------------------
if (handles.debug) [ST,I] = dbstack; disp([ST(1).name]);end
try
    handles.t = handles.begin:1/handles.param.fs:handles.end;
    
    switch handles.signal.type
        case 'LinearChirp'
            handles.signal.data = chirp_spec(handles.t,1,handles.f0,handles.chirp_rate);
        case 'SumOfSinusoids'
            if(length(handles.sinufreq)~=length(handles.amplitude) || length(handles.amplitude)...
                    ~=length(handles.phase) || length(handles.phase)~=length(handles.sinufreq))
                set(handles.error_box,'ForegroundColor','r','String','The lengths of "Amplitudes", "Frequencies", and "Phases" must match.');
            else
                handles.signal.data = SumOfSinusoids(handles.amplitude,handles.sinufreq,handles.phase,handles.t);
            end
        case 'UserAudio'
            handles = userAudio(hObject,eventdata,handles); 
    end
    plt(handles);
catch
    set(handles.error_box,'String','Error. Please reset the signal');
end
% --------------------------------------------------------------------
function plt(handles)
% --------------------------------------------------------------------
if (handles.debug) [ST,I] = dbstack; disp([ST(1).name]);end

three_d = get(handles.threeD_button,'value');
spectgr_RWS_GUI(handles.signal.data,handles.param.nfft,handles.param.fs,handles.param.window,handles.param.noverlap,three_d,handles.param.drange,handles.t);
plt_update(handles);
% --------------------------------------------------------------------
function plt_update(handles)
% --------------------------------------------------------------------
if (handles.debug) [ST,I] = dbstack; disp([ST(1).name]);end

%--- Update plot view + color
hold on
ax = gca;
ax.FontSize = 14;
colorbar;
if (strcmp(handles.colourmap,'gray'))
    handles.colourmap = '(1-gray)';
    grid on;
else
    grid off;
end
eval(['colormap ' handles.colourmap]);
view([handles.az, handles.el]);
hold off
% --------------------------------------------------------------------
function play_button_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
if (handles.debug) [ST,I] = dbstack; disp([ST(1).name]);end

handles.t = handles.begin:1/handles.param.fs:handles.end;

switch handles.signal.type
    case 'LinearChirp'
        handles.signal.data = chirp_spec(handles.t,1,handles.f0,handles.chirp_rate);
    case 'SumOfSinusoids'
        if(length(handles.sinufreq)~=length(handles.amplitude) || length(handles.amplitude)...
                ~=length(handles.phase) || length(handles.phase)~=length(handles.sinufreq))
            set(handles.error_box,'ForegroundColor','b','String','The lengths of "Amplitudes", "Frequencies", and "Phases" must match.');
        else
            handles.signal.data = SumOfSinusoids(handles.amplitude,handles.sinufreq,handles.phase,handles.t);
        end
    case 'UserAudio'
        if (handles.begin == 0)
            handles.begin = 0.01;
        end
        handles.signal.data = handles.signal.data(round(handles.begin*handles.param.fs):round(handles.end*handles.param.fs));   
end

sound(handles.signal.data,handles.param.fs);
% --------------------------------------------------------------------
function windows_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
if (handles.debug) [ST,I] = dbstack; disp([ST(1).name]);end

options = get(hObject,'String');
handles.windowType = lower(strtrim(options{get(hObject,'Value')}));

switch handles.windowType
    case 'bartlett'
        handles.param.window = bartlett(handles.param.windowsize);
    case 'hamming'
        handles.param.window = hamming(handles.param.windowsize);
    case 'hann'
        handles.param.window = hann(handles.param.windowsize);
    case 'rectangular'
        handles.param.window = rectwin(handles.param.windowsize);
end

handles = ft_update(hObject,eventdata,handles);
guidata(hObject,handles);
% --------------------------------------------------------------------
function threeD_button_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
if (handles.debug) [ST,I] = dbstack; disp([ST(1).name]);end

handles.FT = false;

if get(hObject,'Value')
    set(hObject,'Back',handles.ONcolor,'fontweight','bold');
    set([handles.FT_Button,handles.play_button,handles.zoom_button],'vis','off');
    set(handles.rotate_button,'vis','on');
    
    handles.az = -25;
    handles.el = 60;
else
    set(hObject,'Back',handles.color1,'fontweight','normal');
    set([handles.FT_Button,handles.play_button],'vis','on'); % handles.zoom_button
    set(handles.rotate_button,'vis','off');

    handles.az = 0;
    handles.el = 90;
end

handles = renewSignal(hObject,eventdata,handles);

h = rotate3d;
h.Enable = 'off';
set(handles.rotate_button,'Back',handles.color1,'fontweight','normal','value',0);
set(handles.error_box,'String','');

handles = ft_update(hObject,eventdata,handles); 
guidata(hObject,handles);
% --------------------------------------------------------------------
function fs_box_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
if (handles.debug) [ST,I] = dbstack; disp([ST(1).name]);end

switch handles.signal.type
    case {'LinearChirp','SumOfSinusoids'}
        handles.param.fs = str2double(get(hObject,'String'));
        handles = renewSignal(hObject,eventdata, handles);
        handles = ft_update(hObject,eventdata,handles);
        guidata(hObject,handles);
    case 'UserAudio'
        % do nothing
end
% --------------------------------------------------------------------
function noverlap_menu_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
if (handles.debug) [ST,I] = dbstack; disp([ST(1).name]);end

% extract percent value from menu option
options = get(hObject,'String');
optionStr = options{get(hObject,'Value')}(1:3);
overlapPerc = str2num(deblank(optionStr))/100;

noverlap = round(overlapPerc*handles.param.windowsize);
set(handles.noverlap_box,'String', num2str(noverlap));

if (noverlap < handles.param.windowsize)
    handles.param.noverlap = noverlap;
    handles = ft_update(hObject,eventdata,handles);
    guidata(hObject,handles);
else
    set(handles.error_box,'fore','r','String','Noverlap < Window Size');
end
% --------------------------------------------------------------------
function noverlap_box_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
if (handles.debug) [ST,I] = dbstack; disp([ST(1).name]);end

noverlap = round(str2double(get(hObject,'String')));
if (noverlap <= handles.param.windowsize - 1)
    handles.param.noverlap = noverlap;
    set(handles.noverlap_slider,'Value',noverlap);
    handles = ft_update(hObject,eventdata,handles);
    guidata(hObject,handles);
else
    set(handles.error_box,'fore','r','String','Noverlap < Window Size');
end
% --------------------------------------------------------------------
function win_slider_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
if (handles.debug) [ST,I] = dbstack; disp([ST(1).name]);end

win_size = round(get(hObject,'Value'));
if (win_size > 512)
    set(handles.error_box,'String','This value is too high');
elseif (win_size > handles.param.nfft)
    set(handles.error_box,'String','This value must be less than the nfft');
    set(handles.win_box,'String',num2str(win_size));
else
    set(handles.error_box,'String','');
    handles.param.windowsize = win_size;
    set(handles.win_box,'String',num2str(win_size));
    
    % extract percent value from menu option
    options = get(handles.noverlap_menu,'String');
    optionStr = options{get(handles.noverlap_menu,'Value')}(1:3);
    overlapPerc = str2num(deblank(optionStr))/100;
    
    handles.param.noverlap = round(overlapPerc*win_size);
    set(handles.noverlap_box,'String',num2str(handles.param.noverlap));
    
    handles = changeWindowLength(hObject,eventdata,handles);
    guidata(hObject,handles);
end
% --------------------------------------------------------------------
function win_box_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
if (handles.debug) [ST,I] = dbstack; disp([ST(1).name]);end

win_size = round(str2double(get(hObject,'String')));
if (win_size > 512)
    set(handles.error_box,'fore','r','String','Window size is too big');
elseif (win_size >= handles.param.nfft)
    set(handles.error_box,'fore','r','String','Window size must be less than the NFFT');
else
    set(handles.error_box,'String','');
    handles.param.windowsize = win_size;
    set(handles.win_slider,'Value',win_size);
    
    % extract percent value from menu option
    options = get(handles.noverlap_menu,'String');
    optionStr = options{get(handles.noverlap_menu,'Value')}(1:3);
    overlapPerc = str2num(deblank(optionStr))/100;
    
    handles.param.noverlap = round(overlapPerc*win_size);
    set(handles.noverlap_box,'String',num2str(handles.param.noverlap));
 
    handles = changeWindowLength(hObject,eventdata,handles);
    guidata(hObject,handles);
end
% --------------------------------------------------------------------
function handles = changeWindowLength(hObject,eventdata,handles)
% --------------------------------------------------------------------
if (handles.debug) [ST,I] = dbstack; disp([ST(1).name]);end

switch handles.windowType
    case 'bartlett'
        handles.param.window = bartlett(handles.param.windowsize);
    case 'hamming'
        handles.param.window = hamming(handles.param.windowsize);
    case 'hann'
        handles.param.window = hann(handles.param.windowsize);
    case 'rectangular'
        handles.param.window = rectwin(handles.param.windowsize);
end
handles = ft_update(hObject,eventdata,handles);
% --------------------------------------------------------------------
function noverlap_box_KeyPressFcn(hObject, eventdata, handles)
% --------------------------------------------------------------------
function nfft_box_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
if (handles.debug) [ST,I] = dbstack; disp([ST(1).name]);end

handles.param.nfft = round(str2double(get(hObject,'String')));
%if (handles.param.windowsize > handles.param.nfft)
    
    % window size
    handles.param.windowsize = round(0.5*handles.param.nfft);
    set(handles.win_slider,'Value',handles.param.windowsize,'Max',handles.param.nfft-1);
    set(handles.win_box,'String',num2str(handles.param.windowsize));
    
    % extract percent value from menu option
    options = get(handles.noverlap_menu,'String');
    optionStr = options{get(handles.noverlap_menu,'Value')}(1:3);
    overlapPerc = str2num(deblank(optionStr))/100;
    
    handles.param.noverlap = round(overlapPerc*handles.param.windowsize);
    set(handles.noverlap_box,'String',num2str(handles.param.noverlap));    
%end

handles = ft_update(hObject,eventdata,handles);
guidata(hObject,handles);
% --------------------------------------------------------------------
function rotate_button_Callback(hObject, eventdata, handles)
%---------------------------------------------------------------------
if (handles.debug) [ST,I] = dbstack; disp([ST(1).name]);end

if get(hObject,'Value')
    set(hObject,'back',handles.ONcolor,'fontweight','bold');
    h = rotate3d;
    h.Enable = 'on';
else
    set(hObject,'back',handles.color1,'fontweight','normal');
    h = rotate3d;
    h.Enable = 'off';
end
% --------------------------------------------------------------------
function ColorMap_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
if (handles.debug) [ST,I] = dbstack; disp([ST(1).name]);end

n = get(hObject,'Value');
options = get(hObject,'String');
handles.colourmap = lower(strtrim(options{n}));

handles = ft_update(hObject,eventdata,handles);
guidata(hObject,handles);
% --------------------------------------------------------------------
function Drange_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
if (handles.debug) [ST,I] = dbstack; disp([ST(1).name]);end

n = get(hObject,'Value');
handles.param.drange = 10*(2+get(hObject,'Value'));

handles = ft_update(hObject,eventdata,handles);
guidata(hObject,handles);
% --------------------------------------------------------------------
function self_record_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
if (handles.debug) [ST,I] = dbstack; disp([ST(1).name]);end

handles.recorded = true;
myRecObj = audiorecorder(handles.param.fs, 16, 1);
set(handles.error_box,'String','Start Speaking');
set(handles.fs_box,'String',num2str(handles.param.fs));
recordblocking(myRecObj, handles.record_time);
set(handles.error_box,'String','End of Recording');

handles.windowType = 'Bartlett';
handles.signal.data = bartlett(handles.param.windowsize);

handles.begin = 0;
handles.end = handles.record_time;
handles.t = handles.begin:1/handles.param.fs:handles.end;

three_d = get(handles.threeD_button,'value');
[handles.b,handles.F,handles.t] = spectgr_RWS_GUI(handles.signal.data,handles.param.nfft,handles.param.fs,handles.param.window,handles.param.noverlap,three_d,handles.param.drange,handles.t);
record_zoom(handles);
guidata(hObject,handles);
% --------------------------------------------------------------------
function wav_box_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
if (handles.debug) [ST,I] = dbstack; disp([ST(1).name]);end

try
    handles.recorded = true;
    filename = get(hObject,'String');
    [y,handles.fs] = audioread(filename);
    handles.signal.data = y(:,1);
    set(handles.fs_box,'String',num2str(handles.fs));
    set(handles.error_box,'String','');
    handles.begin = 0;
    info = audioinfo(filename);
    handles.end = getfield(info,'Duration');
    handles.t = handles.begin:1/handles.fs:handles.end;
    
    three_d = get(handles.threeD_button,'value');
    [handles.b,handles.F,handles.t] = spectgr_RWS_GUI(handles.signal.data,handles.param.nfft,handles.fs,handles.param.window,handles.param.noverlap,three_d,handles.param.drange,handles.t);
    record_zoom(handles);
    guidata(hObject,handles);
catch
    set(handles.error_box,'String','Please enter a valid filename');
end
% --------------------------------------------------------------------
function amplitude_box_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
if (handles.debug) [ST,I] = dbstack; disp([ST(1).name]);end

handles.amplitude = eval(get(hObject,'String'));
view_props = get(gca,'view');
handles.az = view_props(1);
handles.el = view_props(2);
handles = renewSignal(hObject,eventdata,handles);
guidata(hObject,handles);
% --------------------------------------------------------------------
function chirp_box_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
if (handles.debug) [ST,I] = dbstack; disp([ST(1).name]);end

handles.chirp_rate = str2double(get(hObject,'String'));
handles = ft_update(hObject,eventdata,handles);
guidata(hObject,handles);
% --------------------------------------------------------------------
function save_wav_box_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
if (handles.debug) [ST,I] = dbstack; disp([ST(1).name]);end

try
    filename = get(hObject,'String');
    if (exist(filename, 'file'))
        set(handles.error_box,'String','There is already a file with this name.');
    else
        audiowrite(filename,handles.signal.data,handles.param.fs);
        set(handles.error_box,'String','');
    end
catch
    set(handles.error_box,'String','Please enter a valid filename');
end
% --------------------------------------------------------------------
function sinusoid_frequency_box_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
if (handles.debug) [ST,I] = dbstack; disp([ST(1).name]);end

handles.sinufreq = eval(get(hObject,'String'));
t = handles.begin:1/handles.param.fs:handles.end;

if(length(handles.sinufreq)~=length(handles.amplitude) || length(handles.amplitude)...
        ~=length(handles.phase) || length(handles.phase)~=length(handles.sinufreq))
    set(handles.error_box,'ForegroundColor','r','String','The lengths of "Amplitudes", "Frequencies", and "Phases" must match.');
else
    set(handles.error_box,'String','');
    handles.signal.data = SumOfSinusoids(handles.amplitude,handles.sinufreq,handles.phase,handles.t);
end

handles = ft_update(hObject,eventdata,handles);
guidata(hObject,handles);
% --------------------------------------------------------------------
function start_freq_box_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
if (handles.debug) [ST,I] = dbstack; disp([ST(1).name]);end

handles.f0 = str2double(get(hObject,'String'));
handles = ft_update(hObject,eventdata,handles);
guidata(hObject,handles);
% --------------------------------------------------------------------
function sinusoid_phase_box_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
if (handles.debug) [ST,I] = dbstack; disp([ST(1).name]);end

handles.phase = eval(get(hObject,'String'));
t = handles.begin:1/handles.param.fs:handles.end;
if(length(handles.sinufreq)~=length(handles.amplitude) || length(handles.amplitude)...
        ~=length(handles.phase) || length(handles.phase)~=length(handles.sinufreq))
    set(handles.error_box,'String','The lengths of "Amplitudes", "Frequencies", and "Phases" must match.');
else
    set(handles.error_box,'String','');
    handles.signal.data = SumOfSinusoids(handles.amplitude,handles.sinufreq,handles.phase,handles.t);
end
handles = ft_update(hObject,eventdata,handles);
guidata(hObject,handles);
% --------------------------------------------------------------------
function zoom_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
if (handles.debug) [ST,I] = dbstack; disp([ST(1).name]);end

handles.param.drange = 10*(2+get(hObject,'Value'));
handles = ft_update(hObject,eventdata,handles);
guidata(hObject,handles);
% --------------------------------------------------------------------
function record_time_box_Callback(hObject, eventdata, handles)

if (handles.debug) [ST,I] = dbstack; disp([ST(1).name]);end
handles.record_time = str2double(get(hObject,'String'));
guidata(hObject,handles);
% --------------------------------------------------------------------
function zoom_button_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
if (handles.debug) [ST,I] = dbstack; disp([ST(1).name]);end

if (handles.FT == false)
    set(handles.error_box,'String','Click on the first point. Note: the x axis will be zero indexed.');
    [x1,y1] = ginput(1);
    while (x1 < handles.begin || x1 > handles.end)
        set(handles.error_box,'String','Click inside the axes');
        [x1,y1] = ginput(1);
    end
    set(handles.error_box,'String','Click on the second point');
    [x2,y2] = ginput(1);
    while (x2 > handles.end || x2 < handles.begin)
        set(handles.error_box,'String','Please make sure you click inside the axes after the first point.');
        [x2,y2] = ginput(1);
    end
    if x1<x2
        handles.begin = x1; handles.end = x2;
    else
        handles.end = x1; handles.begin = x2;
    end
    view_props = get(gca, 'view');
    handles.az = view_props(1);
    handles.el = view_props(2);
    [handles.b,handles.F,handles.t] = find_b_and_t(handles);
    
    if (handles.recorded == false)
        handles = renewSignal(hObject,eventdata,handles);
    else
        handles = record_zoom(handles);
    end
    set(handles.error_box,'String','To reset, click on the signal in the popdown menu');
    guidata(hObject, handles);
else
    set(handles.error_box,'String','You must first go back to the spectrogram. To do so, click on the "Click for 2D" button.');
end
% --------------------------------------------------------------------
function [b,f,t] = find_b_and_t(handles)
% --------------------------------------------------------------------
if (handles.debug) [ST,I] = dbstack; disp([ST(1).name]);end

three_d = get(handles.threeD_button,'value');
[B,F,T] = spectgr_RWS_GUI(handles.signal.data,handles.param.nfft,handles.param.fs,handles.param.window,handles.param.noverlap,three_d,handles.param.drange,handles.t);
t0 = T(1);
curr  = 1;
b0 = B(1);
t = [];
b = [];
f = F;
try
    jkl= find( (T >= handles.begin) & (T <= handles.end));
    b = B(:,jkl);
    t = T(jkl);
    %     while (round(t0,2)-round(T(1),2)) ~= round(handles.begin,2)
    %         curr = curr + 1;
    %         t0 = T(curr);
    %     end
    %     t = [t, t0];
    %     b0 = B(:,curr);
    %     b = [b, b0];
    %     while (round(t0,2)+round(T(1),2)) ~= round(handles.end,2)
    %         curr = curr + 1;
    %         t0 = T(curr);
    %         t = [t, t0];
    %         b0 = B(:,curr);
    %         b = [b, b0];
    %     end
catch
    set(handles.error_box,'String','This is not a valid operation with this audio file. Please reload the file.');
end
% --------------------------------------------------------------------
function record_zoom(handles)
% --------------------------------------------------------------------
if (handles.debug) [ST,I] = dbstack; disp([ST(1).name]);end

ba = 20*log10(abs(handles.b));
bam = max(ba);
BAmax = max(bam);
ba(find(ba < BAmax-handles.param.drange))=BAmax-handles.param.drange;

if get(handles.threeD_button,'value')
    surf(handles.t,handles.F,ba);
    shading interp;
    zlabel('Amplitude');
else
    imagesc(handles.t,handles.F,ba);
    axis 'xy';
end

xlabel('Time (sec)');
ylabel('Frequency');
plt_update(handles)
% --------------------------------------------------------------------
function FT_Button_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
if (handles.debug) [ST,I] = dbstack; disp([ST(1).name]);end

if get(hObject,'value')
    set([handles.play_button,handles.zoom_button,handles.rotate_button,handles.threeD_button,handles.colormap_text,handles.ColorMap],'vis','off');
    set(hObject,'backgroundcolor',handles.ONcolor,'fontweight','bold');
    handles.FT = true;
    set(handles.error_box,'String','Please click on one point on the graph to see the FT at that time.');
    [x1,y1] = ginput(1);
    
    while (x1 >= handles.end || x1 <= handles.begin)
        set(handles.error_box,'String','Please click inside the axes');
        [x1,y1] = ginput(1);
    end
    
    handles.FT_time = x1;
    ft(handles);
else
    set(handles.error_box,'String','');
    set([handles.play_button,handles.threeD_button,handles.colormap_text,handles.ColorMap],'vis','on'); % handles.zoom_button
    set(hObject,'backgroundcolor',handles.color1,'fontweight','normal');
    renewSignalSpect(hObject, eventdata, handles);
end
guidata(hObject, handles);
% --------------------------------------------------------------------
function handles = ft_update(hObject,eventdata,handles)
% --------------------------------------------------------------------
if (handles.debug) [ST,I] = dbstack; disp([ST(1).name]);end

view_props = get(gca,'view');
handles.az = view_props(1);
handles.el = view_props(2);

if (handles.FT == true)
    ft(handles);
else
    switch handles.signal.type
        case {'LinearChirp','SumOfSinusoids'}
            handles = renewSignal(hObject,eventdata,handles);
        case 'UserAudio'
            [handles.b,handles.F,handles.t] = find_b_and_t(handles);
            record_zoom(handles);
    end
end
guidata(hObject, handles);
% --------------------------------------------------------------------
function ft(handles)
% --------------------------------------------------------------------
if (handles.debug) [ST,I] = dbstack; disp([ST(1).name]);end

try
    three_d = get(handles.threeD_button,'value');
    [B,F,T] = spectgr_RWS_GUI(handles.signal.data,handles.param.nfft,handles.param.fs,handles.param.window,handles.param.noverlap,three_d,handles.param.drange,handles.t);
    %     t0 = T(1);
    %     curr = 1;
    %     b0 = B(:,1);
    %     while round(t0,2) ~= round(handles.FT_time,2)
    %         curr = curr + 1;
    %         t0 = T(curr);
    %         b0 = B(:,curr);
    %     end
    [tDiffMin,tDindx] = min(abs(T-handles.FT_time));
    ba = 20*log10(abs(B(:,tDindx)));
    bam=max(ba);
    BAmax=max(bam);
    ba(find(ba < BAmax-handles.param.drange))=BAmax-handles.param.drange;
    plot(F,ba); grid on
    xlabel('Frequency (Hz)');
    ylabel('log Magnitude (dB)');
    ax = gca;
    ax.FontSize = 14;
    set(handles.error_box,'ForegroundColor','b','String',sprintf('Fourier Transform at time = %.2f (sec)',handles.FT_time));
catch
    set(handles.error_box,'String','This function is invalid under these parameters. Please reload the signal.');
end
% --------------------------------------------------------------------
function take_screenshot_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
screenshotdlg(gcbf);
% --------------------------------------------------------------------
function help_menu_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
function contents_menu_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
hBar = waitbar(0.25,'Opening internet browser...');
DefPath = which(mfilename);
DefPath = ['file:///' strrep(DefPath,filesep,'/') ];
URL = [ DefPath(1:end-9) , 'help/','index.html'];
STAT = web(URL,'-browser');
waitbar(1);
close(hBar);
switch STAT
    case {1,2}
        s = {'Either your internet browser could not be launched or' , ...
            'it was unable to load the help page.  Please use your' , ...
            'browser to read the file:' , ...
            ' ', '     index.html', ' ', ...
            'which is located in the specgramdemo help directory.'};
        errordlg(s,'Error launching browser.');
end
% --------------------------------------------------------------------
function exit_menu_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
close(gcbf);
% --------------------------------------------------------------------
function show_menu_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
check = get(hObject,'Checked');
if strcmp(check,'off')
    set(gcbf,'MenuBar','figure');
    set(hObject,'Checked','On');
else
    set(gcbf,'MenuBar','none');
    set(hObject,'Checked','Off');
end
% --------------------------------------------------------------------
function upload_audio_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
[handles.filename, handles.pathname] = uigetfile('*.wav','File Selector');
handles = userAudio(hObject,eventdata,handles);
guidata(hObject, handles);
% --------------------------------------------------------------------
function handles = userAudio(hObject, eventdata, handles)
% --------------------------------------------------------------------
if (handles.debug) [ST,I] = dbstack; disp([ST(1).name]);end

try
    handles.recorded = true;
    set(handles.wav_box,'string',handles.filename);
    
    if exist([handles.pathname handles.filename])
        [y,handles.param.fs] = audioread([handles.pathname handles.filename]);
        handles.signal.data = y(:,1);
        set(handles.fs_box,'String',num2str(handles.param.fs));
        handles.begin = 0;
        info = audioinfo([handles.pathname handles.filename]);
        handles.end = getfield(info,'Duration');
        handles.t = handles.begin:1/handles.param.fs:handles.end;
        
        %three_d = get(handles.threeD_button,'value');
        %[handles.b,handles.F,handles.t] = spectgr_RWS_GUI(handles.signal.data,handles.param.nfft,handles.param.fs,handles.param.window,handles.param.noverlap,three_d,handles.param.drange,handles.t);
        %record_zoom(handles);
        set(handles.error_box,'ForegroundColor','b','String',sprintf('Spectrogram of Recorded Signal: %s',handles.filename));
        guidata(hObject, handles);
    else
        set(handles.error_box,'ForegroundColor','r','String','File does not exist on the path!');
    end
catch
    set(handles.error_box,'ForegroundColor','r','String','Please enter a valid filename');
end
% --------------------------------------------------------------------
function save_audio_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
function sinu = SumOfSinusoids(A,F,P,t)
% --------------------------------------------------------------------
sinu = 0;
for i=1:length(F)
    sinu = A(i)*sin(2*pi*F(i)*t+P(i)) + sinu;
end
% --------------------------------------------------------------------
