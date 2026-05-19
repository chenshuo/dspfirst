function varargout = cspin(varargin)
% CSPIN GUI: Visualize phasors spinning in the complex plane and the
%            resulting real and imaginary parts of the signal, together
%            with the corresponding spectral lines.
%
% Shows the initial state (t=0) when called, then select "Play" to start rolling.
%
% CASES:
%           * Single Phasor
%           * Phasors: same frequency
%           * Spectral lines: different frequencies
%           * Beat
%           * Harmonics of a periodic signal

% Arie Yeredor, Feb. 2016
%=========================================================================%
gui_Singleton = 1;
gui_State = struct('gui_Name', mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @cspin_OpeningFcn, ...
    'gui_OutputFcn',  @cspin_OutputFcn, ...
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
function cspin_OpeningFcn(hObject, eventdata, handles, varargin)
% --------------------------------------------------------------------
Ver = 'cspin ver. 1.49';      % Version string for figure title

ver = version;
handles.MATLABVER = str2double(ver(1:3));

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

%--- DEBUG ------------------------------------%
handles.debug = false;

%--- INIT -------------------------------------%
T   = 10;
scl = 1;

if ismac | isunix       % Mac/Linux
    handles.fontsize = 16;
    handles.latex.fontsize = 22;
    renderer = 'opengl';
elseif ispc             % Windows
    handles.fontsize = 12;
    handles.latex.fontsize = 16;
    renderer = 'painters';
end

handles.skyblue  = [0.8 0.85 0.9];
handles.N0 = 2;

%--- GUI: Initial -----------------------------%
set(handles.edit_T,'string',num2str(T));

set(gcf,'color',handles.skyblue,'WindowStyle','normal','units','norm','renderer',renderer); % 'vis','on'
set([handles.checkbox_conjugate,handles.msg,handles.t,handles.text_speed],'backgroundcolor',handles.skyblue);
handles.tb.F  = text(0.1,0.4,'f','fontsize',handles.fontsize,'parent',handles.table_fields);
handles.tb.A  = text(0.25,0.4,'A','fontsize',handles.fontsize,'parent',handles.table_fields);
handles.tb.P  = text(0.4,0.4,'\phi','fontsize',handles.fontsize,'parent',handles.table_fields);
set([handles.tb.F,handles.tb.A,handles.tb.P],'vis','off');

% unit circle axes
set(handles.axis_uc,'color',[0.95 0.95 0.7],'box','on','xtick',[],'ytick',[]);
handles.uc.xline = line([-1 1],[0 0],'linestyle',':','color','k','parent',handles.axis_uc);
handles.uc.yline = line([0 0],[-1 1],'linestyle',':','color','k','parent',handles.axis_uc);

% imag axis
set(handles.axis_imag,'color',[0.95 0.9 0.9],'box','on','ytick',[],'ylim',[-scl scl],'xlim',[0 T]);
set(handles.axis_imag,'xtick',[0 T],'xticklabel',{'0';num2str(T)});

handles.imag.baseline = line([0 T],[0 0],'linestyle',':','color','k','parent',handles.axis_imag);
xlabel(handles.axis_imag,['\fontsize{' num2str(handles.latex.fontsize) '}\Im\{\fontsize{' num2str(0.7*handles.latex.fontsize) '}\bfz(t)\rm\fontsize{' num2str(handles.latex.fontsize) '}\}']);

% real axis
set(handles.axis_real,'color',[0.9 0.95 0.9],'box','on','xtick',[],'xlim',[-scl scl],'ylim',[0 T],'ydir','reverse');
set(handles.axis_real,'ytick',[0 T],'yticklabel',{'0';num2str(T)});

handles.real.baseline = line([0 0],[0 T],'linestyle',':','color','k','parent',handles.axis_real);
handles.real.title = text(0.3,0.5,['\fontsize{' num2str(handles.latex.fontsize) '}\Re\{\fontsize{' num2str(0.7*handles.latex.fontsize) '}\bfz(t)\rm\fontsize{' num2str(handles.latex.fontsize) '}\}'],'parent',handles.axis_Re);

% spectrum axis
set(handles.axis_spec,'color',[1 1 1],'box','on','xtick',[],'ytick',[]);

handles.spec.x = line([-1 1],[-1 -1],'color','k','marker','>','markerfacecolor','k','parent',handles.axis_spec);
handles.spec.y = line([0 0],[-1 1],'color','k','marker','^','markerfacecolor','k','parent',handles.axis_spec);

if handles.MATLABVER>9.0    
    set([handles.spec.x,handles.spec.y],'MarkerIndices',2);
end
handles.spec.f = text(0,0,'f','parent',handles.axis_spec);

th = [0:100]/100*2*pi;
line(cos(th),sin(th),'color','k','parent',handles.axis_uc);

col = [0 0.2 0.8];
bro = [0.7 0.3 0];
handles.ph1  = line([0 1],[0 1],'color',bro,'parent',handles.axis_uc);
handles.pv1  = line([0 1],[0 1],'color',col,'parent',handles.axis_uc);
handles.ph2  = line([0 0],[0 1],'color',bro,'parent',handles.axis_imag);
handles.pim  = line(0,0,'color',bro,'linewidth',2,'parent',handles.axis_imag);
handles.pv2  = line([0 0],[0 0],'color',col,'parent',handles.axis_real);
handles.pre  = line(0,0,'color','b','linewidth',2,'parent',handles.axis_real);

% equation axis
handles.tb.eq = text(0.25,0,'','Interpreter','latex','parent',handles.axis_eq,'fontsize',handles.fontsize);

if handles.MATLABVER < 7.0
    set([handles.ph1,handles.pv1,handles.ph2,handles.pim,handles.pv2,handles.pre],'erasemode','xor');
end
%=====================================================================
handles.conjugate = get(handles.checkbox_conjugate,'value');
handles.T         = str2num(get(handles.edit_T,'string'));
handles           = popup_cases_Callback(hObject, eventdata, handles);

% === GUI
SCALE = getfontscale;          % Platform dependent code to determine SCALE parameter
setfonts(gcf,SCALE);           % Setup fonts: override default fonts used
configresize(gcf);             % Change all 'units'/'font units' to normalized

set(gcf,'units','norm');
FigSize = get(gcf,'Position');
FigSizeNew = [(1-FigSize(3))/2 (1-FigSize(4))/2 FigSize(3) FigSize(4)];
set(gcf,'Name',Ver,'Position',FigSizeNew,'HandleVisibility','callback'); % Make figure inaccessible from command line

% Choose default command line output for cspin
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
% --------------------------------------------------------------------
function varargout = cspin_OutputFcn(hObject, eventdata, handles)
% --------------------------------------------------------------------
varargout{1} = handles.output;
% --------------------------------------------------------------------
function handles = popup_cases_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
if (handles.debug) [ST,I] = dbstack; disp([ST(1).name]);end

type = get(handles.popup_cases,'string');
handles.pop_case = type{get(handles.popup_cases,'value')};

switch handles.pop_case
    case 'Phasor'
        X = 1*exp(j*0.4*pi);
        F = 0.8;
    case 'Phasors: same frequency'
        X = [0.5*exp(j*0.6*pi) 1.1*exp(j*0.2*pi) 0.7*exp(-j*0.2*pi)];
        F = [0.6 0.6 0.6];
    case 'Spectral lines: different frequencies'
        X = [1.5 0.5j];
        F = [0.2 1.8];
    case 'Beat'
        X = [0.8 0.8*exp(j*0.4*pi)];
        F = [1.9 2.1];
    case 'Harmonics of a periodic signal'
        k = 7;
        X = [sin([1:k]*0.5*pi)./([1:k]*0.5*pi)];
        F = 0.4*[1:k];
    case 'User Defined'
end

if handles.conjugate
    X = [X conj(X)];
    F = [F -F];
end

scl = 1.1*sum(abs(X));
switch handles.pop_case
    case 'Phasors: same frequency'
        scl = 0.7*scl;
    case 'Harmonics of a periodic signal'
        if handles.conjugate
            scl = 0.6*scl;
        end
end

set([handles.axis_uc,handles.axis_real],'xlim',[-scl scl]);
set([handles.axis_uc,handles.axis_imag],'ylim',[-scl scl]);

handles.scl = scl;
handles = update(X,F,handles.T,handles);
guidata(gcf,handles);
% --------------------------------------------------------------------
function handles = update(X,F,T,handles)
% --------------------------------------------------------------------
if (handles.debug) [ST,I] = dbstack; disp([ST(1).name]);end

if any(size(X)~=size(F))
    set(handles.msg,'string','X and F must have the same size');
end

X = X(:);
F = F(:);

if ~exist('T')
    T = 10;               % default
end

maxx   = max(abs(X));
maxlen = sum(abs(X));
scl    = handles.scl;   % 1.2*ceil(maxlen);
maxf   = max(abs(F));

handles.dt = 10^(-0)*max(0.001,min(T/4000,1/4/maxf));
if handles.dt>1/2/maxf
    set(handles.msg,'string','Max freq. too high - aliasing');
else
    set(handles.msg,'string','');
end

tt = 0:handles.dt:T;
NT = length(tt);
handles.N0 = 2;
handles.xr = zeros(1,NT);
handles.xi = zeros(1,NT);
%===============================================
%--- GUI: Update ------------------------------%
set(handles.axis_uc,'xlim',[-scl scl],'ylim',[-scl scl]);
set(handles.uc.xline,'xdata',scl*[-1 1],'ydata',[0 0]);
set(handles.uc.yline,'xdata',[0 0],'ydata',scl*[-1 1]);

% imag part axes
set(handles.axis_imag,'xlim',[0 T],'xtick',[0 T],'xticklabel',{'0';num2str(T)});
set(handles.imag.baseline,'xdata',[0 T]);
% text(T/20,0.9*scl,'Imag\{z(t)\}','parent',handles.axis_imag)

% real part axes
set(handles.axis_real,'ylim',[0 T],'ytick',[0 T],'yticklabel',{'0';num2str(T)});
set(handles.real.baseline,'ydata',[0 T]);

% spectrum axes
set(handles.axis_spec,'xlim',maxf*[-1.3 1.3],'ylim',maxx*[-0.1 1.1]);

set(handles.spec.x,'xdata',maxf*1.5*[-1 1],'ydata',[0 0]);
set(handles.spec.y,'xdata',[0 0],'ydata',[0 maxx]);
set(handles.spec.f,'position',[maxf*1.2 -maxx*0.05]);

% line(maxf*1.05*[-1 1],[0 0],'color','k','parent',handles.axis_spec)
% line([0 0],[0 maxx],'color','k','parent',handles.axis_spec)
% text(maxf*1.2,-maxx*0.05,'f','parent',handles.axis_spec)

N   = length(X);
hph = zeros(N,1);
sx  = 0;
xp  = 0.39;
yp  = 0.72;
ht  = 0.05;
wt  = 0.05;
handles.tol = 0.0001;

param_table = findall(gcf,'userdata','param_table');
delete(param_table);
spectrum_objs = findall(gcf,'userdata','spectrum');
delete(spectrum_objs);

% Table VIEW
VIEW = 5;
switch VIEW
    case 1
        set([handles.tb.A,handles.tb.F,handles.tb.P,handles.table_fields],'visible','on');
    case 2
        tb_axes = axes('units','norm','position',[0.55 0.2 0.2 0.5],'color','w','visible','off','userdata','param_table');
        eqtb    = '\begin{tabular}{|c|c|c||l|}\hline\bf $f_k$ &\bf $a_k$ &\bf$\phi_k$ &$\qquad z_k$\\\hline\hline';
    case 3
        tb_axes = axes('units','norm','position',[0.55 0.2 0.4 0.8],'color','w','visible','off','userdata','param_table');
        eqtb    = '\begin{tabular}{|r|r|r||l|}\hline f_k & a_k &\phi_k&\ z_k \\\hline\hline';
    case 4
        if (get(handles.popup_cases,'value')==5) & handles.conjugate
            newline1 = '\newcommand{\N}{\\}';
            newline2 = '\newcommand{\N}{\\}';
        else
            newline1 = '\newcommand{\N}{\\&&\\}';
            newline2 = '\newcommand{\N}{\\\\}';
        end
        
        tb_axes1 = axes('units','norm','position',[0.55 0.1 0.2 0.8],'color','w','visible','off','userdata','param_table');
        tb_axes2 = axes('units','norm','position',[0.75 0.1 0.4 0.8],'color',[0.9 0.9 1],'visible','off','userdata','param_table');
        eqtb1    = [newline1 '\begin{tabular}{|r|r|r|}\hline&&\\\bf $f_k$&\bf $a_k$&\bf$\phi_k$\quad\qquad\N\hline\hline\,'];
        eqtb2    = [newline2 '\begin{tabular}{|l|}\hline\\\qquad\bf z_k \N\hline\hline\,'];
    case 5
        eqtb   = '\begin{tabular}{p{1cm} p{0.5cm} p{1cm} p{4cm}}$\quad f_k$ &$\, a_k$ &$\quad\phi_k$&$z_k(t)=\left(a_k e^{j\phi_k}\right)e^{j2\pi f_kt}$\\\hline\hline\end{tabular}';
        e_axes = axes('units','norm','position',[xp+3*wt yp wt ht],'visible','off','userdata','param_table');
        e_text = text(0.2,0.5,['$$' eqtb '$$'],'interpreter','latex','fontweight','bold','fontsize',handles.fontsize,'parent',e_axes,'userdata','param_table');
    otherwise
        disp('other value')
end

for n=1:N
    fn = F(n);
    xn = X(n);
    
    % X=0
    if abs(xn) < handles.tol
        axn = 0;
    else
        axn = round(100*abs(xn))/100;
    end
    
    % Conjugate?
    if handles.conjugate
        k=round(mod(n,(N+1)/2));
        if n>(N/2)
            ks = '^*';
        else
            ks = '';
        end
    else
        k  = n;
        ks = '';
    end
    
    [x_str,f_str,eq] = update_z(xn,fn,ks,k);
    
    switch VIEW
        case 1
            f_edit = uicontrol('style','edit','string',num2str(fn),'fontweight','bold','backgroundcolor',handles.skyblue,'units','norm','position',[0.55 0.81-ht*n wt ht],'enable','off','Callback',@setmap,'userdata','param_table');
            x_edit = uicontrol('style','edit','string',num2str(axn),'fontweight','bold','backgroundcolor',handles.skyblue,'fontsize',0.7*handles.fontsize,'units','norm','position',[0.55+wt 0.81-ht*n wt ht],'enable','off','Callback',@setmap,'userdata','param_table');
            p_edit = uicontrol('style','edit','string',num2str(angle(xn)/pi),'fontweight','bold','backgroundcolor',handles.skyblue,'fontsize',0.7*handles.fontsize,'units','norm','position',[0.55+2*wt 0.81-ht*n wt ht],'enable','off','Callback',@setmap,'userdata','param_table');
            e_axes = axes('units','norm','position',[0.55+3*wt 0.81-ht*n wt ht],'visible','off','userdata','param_table');
            e_text = text(0.25,0.5,['$$' eq '$$'],'interpreter','latex','fontweight','bold','fontsize',handles.fontsize,'parent',e_axes,'userdata','param_table');
        case 4
            eqtb1  = [eqtb1 num2str(fn) '&' num2str(axn) '&' num2str(angle(xn)/pi) '\N'];
            eqtb2  = [eqtb2 '$' eq '$\N'];
        case 5
            if axn==0
                Asgn = '$\hphantom{0.}$';
            else
                Asgn = '';
            end
            if fn>0
                Fsgn = '$\hphantom{-}$';
            else
                Fsgn = '$-$';
            end
            if (angle(xn)/pi)>=0
                Psgn = '$\hphantom{-}$';
            else
                Psgn = '$-$';
            end
            if abs(angle(xn)/pi)<handles.tol   % display pi symbol?
                Pistr = '';
            else
                Pistr = '$\pi$';
            end
            
            eqtb   = ['\begin{tabular}{p{1cm} p{0.5cm} p{1cm} p{4.5cm}}' Fsgn num2str(abs(fn)) '&' Asgn num2str(axn) '&' Psgn num2str(abs(angle(xn)/pi)) Pistr '&$' eq '$\\\hline\end{tabular}'];
            e_axes = axes('units','norm','position',[xp+3*wt yp-ht*n wt ht],'visible','off','userdata','param_table');
            e_text = text(0.2,0.5,['$$' eqtb '$$'],'interpreter','latex','fontweight','bold','fontsize',handles.fontsize,'parent',e_axes,'userdata','param_table');
        otherwise
            eqtb   = [eqtb num2str(fn) '&' num2str(axn) '&' num2str(angle(xn)/pi) '&$' eq '$\\'];
    end

    switch handles.pop_case
        case 'Phasors: same frequency'
            hal   = 'left';
            mured = (fn/maxf+1)/2;
        case 'Beat'
            adjust = [-0.3 0 0.3 0];
            mured  = (fn/maxf+1)/2+adjust(n);
            %[fn mured]
            haln = [1 0 0 1];
            if haln(n)
                hal = 'right';
            else
                hal = 'left';
            end
        otherwise
            mured = (fn/maxf+1)/2;
            hal   = 'center';
    end

    clr    = [mured 1-mured 0];
    hph(n) = line(real(sx)+[0 real(xn)],imag(sx)+[0 imag(xn)],'color',clr,'linewidth',2,'parent',handles.axis_uc,'userdata','spectrum');
    sx     = sx + xn; 
    
    fnmax = 1.8*fn;
    hl1 = line(handles.axis_spec,[fn fn],[0 axn],'color',clr,'linewidth',2,'userdata','spectrum');
    hl1 = line(handles.axis_spec,[fn fn],[axn axn],'color',clr,'linewidth',2,'marker','^','markerfacecolor',clr,'userdata','spectrum');
    text(fn,-maxx*0.08,f_str,'HorizontalAlignment',hal,'fontsize',0.7*handles.fontsize,'parent',handles.axis_spec,'userdata','spectrum');

    if length(x_str)
        text(fn+maxf/20,axn+maxx*0.07,['$$' x_str '$$'],'HorizontalAlignment',hal,'fontsize',0.9*handles.fontsize,'interpreter','latex','rotation',0,'parent',handles.axis_spec,'userdata','spectrum');
    end
end

switch VIEW
    case 1
    case 2
        eqtb = [eqtb '\hline\end{tabular}'];
        eqtb_text = text(0,0.5,['$$' eqtb '$$'],'interpreter','latex','fontweight','bold','fontsize',handles.fontsize,'parent',tb_axes,'userdata','param_table');
    case 3
        eqtb = [eqtb '\hline\end{tabular}'];
        eqtb_text = text(0.1,0.5,['$$' eqtb '$$'],'interpreter','latex','fontweight','bold','fontsize',handles.fontsize,'parent',tb_axes,'userdata','param_table');
    case 4
        eqtb1 = [eqtb1 '\hline\end{tabular}'];
        eqtb2 = [eqtb2 '\hline\end{tabular}'];
        eqtb_text1 = text(0.3,0.5,['$$' eqtb1 '$$'],'interpreter','latex','fontweight','bold','fontsize',handles.fontsize,'parent',tb_axes1,'userdata','param_table');
        eqtb_text2 = text(0,0.5,['$$' eqtb2 '$$'],'interpreter','latex','fontweight','bold','fontsize',handles.fontsize,'parent',tb_axes2,'userdata','param_table');
    otherwise
        eqtb = [eqtb '\hline\end{tabular}'];
end

handles.xr(1) = real(sx);
handles.xi(1) = imag(sx);
handles.ph    = hph;

set(handles.ph1,'xdata',[real(sx) scl],'ydata',[imag(sx) imag(sx)]);
set(handles.pv1,'xdata',[real(sx) real(sx)],'ydata',[imag(sx) -scl]);
set(handles.ph2,'xdata',[0 0],'ydata',[imag(sx) imag(sx)]);
set(handles.pim,'xdata',tt,'ydata',handles.xi);
set(handles.pv2,'xdata',[real(sx) real(sx)],'ydata',[0 0]);
set(handles.pre,'xdata',handles.xr,'ydata',tt);

%--- 2. SIGNAL ---------------------------%
handles.maxf = maxf;
handles.maxx = maxx;

handles.T   = T;
handles.NT  = NT;
handles.tt  = tt;
handles.N   = N;
handles.X   = X;
handles.F   = F;
handles.scl = scl;

handles = update_equations(handles);
guidata(gcf,handles);
% --------------------------------------------------------------------
function handles = update_equations(handles)
% --------------------------------------------------------------------
if (handles.debug) [ST,I] = dbstack; disp([ST(1).name]);end

type = get(handles.popup_cases,'string');
switch type{get(handles.popup_cases,'value')}
    case 'Phasor'
        eq = ['\bf z(t) = z_1(t)'];
        if handles.conjugate
            eq = [eq ' +  z^*_1(t)'];
        end
    otherwise
        if handles.conjugate
            eq = ['\bf z(t) = \sum_{k=1}^' num2str(handles.N/2) '\bigg(z_k(t) +  z^*_k(t)\bigg)'];
        else
            eq = ['\bf z(t) = \sum_{k=1}^' num2str(handles.N) 'z_k(t)'];
        end
end

set(handles.tb.eq,'string',['$$' eq '$$']);
% --------------------------------------------------------------------
function [x_str,f_str,eq] = update_z(xn,fn,ks,k)
% --------------------------------------------------------------------
% z = (Astr Pstr) Fstr
%     (Xstr)      Fstr

tol = 1e-4;
an  = round(100*abs(xn))/100;
pn  = angle(xn)/pi;

if sign(pn)>0
    sgn_pn = '';
else
    sgn_pn = '-';
end

if sign(fn)>0
    sgn_fn = '';
else
    sgn_fn = '-';
end

% Xstr
if abs(an)<tol       % A=0
    x_str = '';
    f_str = '';
    EQstr = '0';
else
    if abs(pn)<tol   % phi=0
        Pstr = '';
    else
        Pstr = ['e^{' sgn_pn 'j' num2str(abs(pn)) '\pi}'];
    end
    
    Xstr  = [num2str(an) Pstr];
    x_str = Xstr;
    
    % Fstr
    if abs(fn)<tol
        Fstr  = '';
    else
        Fstr  = ['e^{' sgn_fn 'j2\pi(' num2str(abs(fn)) ')t}']; % j2\pi(
        Xstr  = ['(' Xstr ')'];
    end
    
    f_str = num2str(fn);
    EQstr = [Xstr Fstr];
end

% z_i equation
% eq = ['$$ z' ks '_' num2str(k) '(t) = ' EQstr ' $$'];
eq = ['z' ks '_' num2str(k) '(t)=' EQstr];
% --------------------------------------------------------------------
function play_button_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
if (handles.debug) [ST,I] = dbstack; disp([ST(1).name]); end

action = get(gcbo,'String');
switch action
    case 'Play'
        set(gcbo,'String','Pause');
    case 'Pause'
        set(gcbo,'String','Play');
    case 'Replay'
        handles = update(handles.X,handles.F,handles.T,handles);
        guidata(gcf,handles);
        set(gcbo,'String','Pause');
end

% start rolling
for nt=handles.N0:handles.NT
    if strcmp(get(gcbo,'String'),'Pause')
        s = round(get(handles.slider_speed,'value'));
        if nt<s
            s=1;
        elseif nt>(handles.NT-s+1)
            s=1;
        end
            
        % Debug: disp([num2str(nt) ' = ' num2str(s) ' | ' num2str(nt<s) ' | ' num2str(nt>handles.NT-s) ' | ' num2str(~mod(nt,s))]);
        if ~mod(nt,s)
            tic;
            t  = handles.tt(nt);
            xe = handles.X.*exp(1j*2*pi*handles.F*t);
            sx = 0;
            for n=1:handles.N
                xn = xe(n);
                set(handles.ph(n),'xdata',real(sx)+[0 real(xn)],'ydata',imag(sx)+[0 imag(xn)]);
                sx = sx + xn;
            end
            % Debug: set(handles.msg,'str',[num2str(nt) ' / ' num2str(handles.NT)]);
            
            handles.xr(nt-1:nt+s-1) = real(sx);
            handles.xi(nt-1:nt+s-1) = imag(sx);
            set(handles.ph1,'xdata',[real(sx) handles.scl],'ydata',[imag(sx) imag(sx)]);
            set(handles.pv1,'xdata',[real(sx) real(sx)],'ydata',[imag(sx) -handles.scl]);
            set(handles.ph2,'xdata',[0 t],'ydata',[imag(sx) imag(sx)]);
            set(handles.pim,'ydata',handles.xi);
            set(handles.pv2,'xdata',[real(sx) real(sx)],'ydata',[0 t]);
            set(handles.pre,'xdata',handles.xr);
            
            drawnow
            
            % disp([toc get(handles.slider_speed,'value') toc*4*(3-get(handles.slider_speed,'value'))])
            % toc*10*(3-get(handles.slider_speed,'value'))
            % pause(toc*15*(3-get(handles.slider_speed,'value')))
            
            if nt==handles.NT
                set(gcbo,'String','Replay');
            end
        end
    elseif strcmp(get(gcbo,'String'),'Play')
        handles.N0 = nt;
        guidata(gcf,handles);
        break
    end
end
% --------------------------------------------------------------------
function handles = checkbox_conjugate_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
if (handles.debug) [ST,I] = dbstack; disp([ST(1).name]);end

handles.conjugate = get(hObject,'value');
handles = popup_cases_Callback(hObject, eventdata, handles);
guidata(gcf,handles);
% --------------------------------------------------------------------
function edit_T_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
if (handles.debug) [ST,I] = dbstack; disp([ST(1).name]);end

handles.T = str2num(get(hObject,'string'));
handles = popup_cases_Callback(hObject, eventdata, handles);
guidata(gcf,handles);
% --------------------------------------------------------------------
function default_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% MENUS ==============================================================
% --------------------------------------------------------------------
function take_screenshot_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
if (handles.debug) [ST,I] = dbstack; disp([ST(1).name]);end

screenshotdlg(gcbf);
% --------------------------------------------------------------------
function help_menu_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
function contents_menu_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
if (handles.debug) [ST,I] = dbstack; disp([ST(1).name]);end

hBar    = waitbar(0.25,'Opening internet browser...');
DefPath = which(mfilename);
DefPath = ['file:///' strrep(DefPath,filesep,'/') ];
URL     = [ DefPath(1:end-9) , 'help/','index.html'];
STAT    = web(URL,'-browser');
waitbar(1);
close(hBar);
switch STAT
    case {1,2}
        s = {'Either your internet browser could not be launched or' , ...
            'it was unable to load the help page.  Please use your' , ...
            'browser to read the file:' , ...
            ' ', '     index.html', ' ', ...
            'which is located in the cspin help directory.'};
        errordlg(s,'Error launching browser.');
end
% --------------------------------------------------------------------
function show_menu_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
if (handles.debug) [ST,I] = dbstack; disp([ST(1).name]);end

check = get(hObject,'Checked');
if strcmp(check,'off')
    set(gcbf,'MenuBar','figure');
    set(hObject,'Checked','On');
else
    set(gcbf,'MenuBar','none');
    set(hObject,'Checked','Off');
end
% --------------------------------------------------------------------
function exit_menu_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
if (handles.debug) [ST,I] = dbstack; disp([ST(1).name]);end
close(gcbf);
% --------------------------------------------------------------------