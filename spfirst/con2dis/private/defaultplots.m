function h = defaultplots(h)
% DEFAULTPLOTS Create the default plots drawn when GUI loads
%    h = DEFAULTPLOTS(h) creates the initial plots drawn in the GUI
%    from data given in structure h.  Returns the structure with new
%    fields set.

% Gregory Krudysz, 15-Oct-01 adapted from original code from 
%                   'Initialize' case.  Made minor adjustments.
%    Rev. 15-Oct-01: Minor adjustment to work in Matlab 5.1
%    Rev. 21-Nov-01: Commented out uistack so it will work on MAC
%====================================================
% DEFINITIONS
%====================================================
Xlimit = 0.50;	 % x-axis limits for Axes 1 and 2
YSPMAX = 1.05;   % max height of the spectrum display
xMAX   = 1.05;

Fo     = 8;      % continuous freq
Fs     = 20;     % sampling freq: Fo <Fs< 3*Fo
Xsp    = 1/2;    % make this P = pi; for the FOURIER TRANSFORM CASE
R      = Fo/Fs;

set(gcf,'menubar','none');
deffontsize = get(0,'DefaultAxesFontSize');
set(0,'UserData',[deffontsize 0]);

% DEFINITIONS
h.time1 = 0:0.0001:Xlimit;			
c1 = cos(2*pi*Fo*h.time1);
h.wflag = 0;                     % RADIAN FREQ FLAG
h.w_hat_flag  = 0;               % DISCRETE RADIAN FREQ FLAG
h.LineWidth   = 3;  	         % LINE PROPERTIES
h.Fourier     = 0;               % if TRUE scale spectrum by 2*pi
h.MarkerSize  = 10;
h.FontSize    = 11;				 % AXES PROPERTIES 
h.FontSizeSym = h.FontSize + 0.2*h.FontSize;
h.phaseN      = 0;			     % Note: Assume initial phase = 0

% OS-dependent units
if (ismac | isunix)
    Text_font       = 18;
    Edit_font       = 12;
    LineWidthDel    = 0;
    h.FontSizeLabel = 16;
    h.MarkerSize    = 8;
elseif ispc
    Text_font       = 15;
    Edit_font       = 9;
    LineWidthDel    = 1;
    h.FontSizeLabel = 12;
    h.MarkerSize    = 7;
else
    disp('Platform not supported')
end

set(h.Editbox1,'String',Fo);     % EDIT BOX 
set(h.Editbox2,'String',Fs);
set(h.Editbox3,'String',0);
set([h.Editbox1,h.Editbox2,h.Editbox3],'FontSize',Edit_font,'fontweight','bold');
if isunix
    set([h.Editbox1,h.Editbox2,h.Editbox3],'fontweight','bold');
end

MaxS1 = 1.49*Fs;                  % SLIDERS
MaxS2 = 1.5*Fs;
set(h.Slider1,'Min',0,'Max',MaxS1,'Value',Fo);
set(h.Slider2,'Min',0.5*Fs,'Max',MaxS2,'Value',Fs);
set([h.RButton2,h.RButton22],'Value',0);
set([h.ShowLF,h.ShowW,h.ShowW_hat],'Checked','off');
set(h.Text,'String',Fs);

% PLOT AXIS 
set(gcf,'CurrentAxes',h.AxisRef);
h.TextPh = text(6.5,1.8,'','units','normalized','Fontweight','bold');
h.TextFo = text(0,1.8,'','units','normalized','Fontweight','bold');
h.TextFs = text(11.5,1.8,'','units','normalized','Fontweight','bold');

if h.MATLABVER>=8.4
    set(h.TextPh,'Interpreter','latex','string',['\bf Phase = $$' sprintf('%.2f',h.phaseN) '$$'],'FontSize',Text_font);
    set(h.TextFo,'Interpreter','latex','string',['\bf $$f_o = ' sprintf('%.1f',Fo) '$$ (Hz)'],'FontSize',Text_font);
    set(h.TextFs,'Interpreter','latex','string',['\bf $$f_s = ' sprintf('%.1f',Fs) '$$ (Hz)'],'FontSize',Text_font);
else
    set(h.TextFo,'string',sprintf('Phase = %.2f',h.phaseN),'FontSize',0.75*Text_font);
    set(h.TextFo,'string',sprintf('f_o = %.1f (Hz)',Fo),'FontSize',0.75*Text_font);
    set(h.TextFs,'string',sprintf('f_s = %.1f (Hz)',Fs),'FontSize',0.75*Text_font);
end
%====================================================================
% Axis 1
set(gcf,'CurrentAxes',h.Axis1);
h.Line1 = plot(h.time1,c1,'linewidth',h.LineWidth);
set(gca,'NextPlot','ReplaceChildren' ...
    ,'FontSize',h.FontSize,'FontWeight','bold'...
    ,'YLim',xMAX*[-1 1],'XLim',[0 Xlimit]);
h.TextIn = text(Xlimit/2,1.25,'','FontWeight','bold','Color',[0 0 1],'HorizontalAlignment','center');

if h.MATLABVER>=8.4
    set(h.TextIn,'Interpreter','latex','string',['Input: $$\bf x(t)=\cos\left(2\pi(' sprintf('%.1f',Fo) ')t\right)$$'],'FontSize',Text_font);
else
    set(h.TextIn,'string',sprintf('Input: x(t) = cos(2%s %.1f t)','\pi',Fo),'FontSize',0.75*Text_font);
end
xlabel('Time (sec)')
%====================================================================
% Axis 2
time2i  = 0:1/Fs:Xlimit;
set(gcf,'CurrentAxes',h.Axis2);
set(gca,'XLimMode','manual' ... %PROBLEM (BLACK SPOT)% ,'FontSize',h.FontSize ... %
    ,'FontWeight','bold'...
    ,'XLim',[0 Xlimit] ...
    ,'YLim',xMAX*[-1 1] ...
    ,'XTick',time2i ...
    ,'XTickLabel',(0:length(time2i)-1)');
h.TextMiddle = text(Xlimit/2,1.25,'','FontWeight','bold' ...
    ,'Color',[0 0 0],'HorizontalAlignment','center');

if h.MATLABVER>=8.4
    set(h.TextMiddle,'Interpreter','latex','string',['$$\bf x[n] = \cos\left(2\pi(' sprintf('%.2f',R) ')n\right)$$'],'FontSize',Text_font);
else
    set(h.TextMiddle,'string',sprintf('x[n] = cos(2%s %.2f n)','\pi',R),'FontSize',0.75*Text_font);
end

xlabel('Time (samples)','FontSize',11)
hold on
h.Line11 = plot(h.time1,c1,'linewidth',h.LineWidth,'Color',[0.77 0.77 1]); 
h.Line52 = plot(h.time1,c1,'linewidth',h.LineWidth,...
    'visible','off','Color',[0.77 0.77 1]); 

if h.MATLABVER >= 7
    h.Line2 = stemdata(time2i,cos(2*pi*Fo*time2i) + h.phaseN,{'o','k'}); 
else
    h.Line2 = stem(time2i,cos(2*pi*Fo*time2i) + h.phaseN,'k','filled'); 
end

%ln2Prop.MarkerSize = h.MarkerSize;
%ln2Prop.MarkerFaceColor = 'y';
%ln2Prop.MarkerEdgeColor = 'b';
%set(h.Line2(1),lnl2Prop);

set(h.Line2(1),'markersize',h.MarkerSize,'markerfacecolor','k','markeredgecolor','k');
set(h.Line2(2),'LineWidth',h.LineWidth+LineWidthDel,'clipping','on');
%%% uistack(h.Line2(1),'top');
hold off
set([h.Line52,h.Line11],'ButtonDownFcn','con2dis showLF')
set(h.Line2,'ButtonDownFcn','con2dis showLF')
h.TextClick = text(Xlimit/2, 0, 'Click on this plot to see aliases',...
    'Visible', 'Off', 'Rotation', 30, 'FontSize', 12, 'FontWeight', 'bold',...
    'Color',[0,0,0.4],'HorizontalAlignment','center');
set(h.TextClick,'ButtonDownFcn','con2dis showLF')
%====================================================================
% Axis 4
set(gcf,'CurrentAxes',h.Axis4);
hold on
h.Patch4 = patch([-Fs/2 Fs/2 Fs/2 -Fs/2],[0 0 YSPMAX YSPMAX],'y');
h.Line4d = line([-Fs -Fs nan 0 0 nan Fs Fs],...
    [0 YSPMAX nan 0 YSPMAX nan 0 YSPMAX],'LineStyle',':');
if h.MATLABVER >= 7
    h.Line4  = stemdata(Fo,Xsp,{'.','b'});
    h.Line4c = stemdata(-Fo,Xsp,{'x','b'});
else
    h.Line4  = stem(Fo,Xsp,'.b');
    h.Line4c = stem(-Fo,Xsp,'xb');
end
XMarkerSize = 1.5*get(h.Line4c(1),'MarkerSize');
set(h.Line4c(1),'MarkerSize',XMarkerSize);

set([h.Line4,h.Line4c],'ButtonDownFcn','con2dis LineDragStart','linewidth',h.LineWidth);
hold off
set(h.Axis4,'NextPlot','ReplaceChildren'...
    ,'FontSize',h.FontSize,'FontWeight','bold'...
    ,'XLim',[-1.5*Fs 1.5*Fs] ...
    ,'YLim',[0 YSPMAX] ...
    ,'XTick',Fs*(-1:0.5:1) ...
    ,'XTickLabel',Fs*(-1:0.5:1) );

if h.MATLABVER>=8.4
    xlabel('\bf $$f$$ (Hz)','Interpreter','Latex','fontsize',h.FontSizeLabel)
else
    xlabel('f (Hz)','fontsize',h.FontSizeLabel)
end
title('Continuous Time Spectrum','FontWeight','bold')
%====================================================================
% Axis 3
set(gcf,'CurrentAxes',h.Axis3);
hold on
h.Patch3 = patch([-0.5 0.5 0.5 -0.5],[0 0 YSPMAX YSPMAX],'y');              
if h.MATLABVER >= 7
    h.Line3in   = stemdata(R,Xsp,{'.','b'});
    h.Line3inC  = stemdata(-R,Xsp,{'x','b'});
    h.Line3out  = stemdata([-2+R -1+R 1+R 2+R],Xsp*[1,1,1,1],{'.','r'});
    h.Line3outC = stemdata([-2-R -1-R 1-R 2-R],Xsp*[1,1,1,1],{'x','r'});
else
    h.Line3in   = stem(R,Xsp,'.b');
    h.Line3inC  = stem(-R,Xsp,'xb');
    h.Line3out  = stem([-2+R -1+R 1+R 2+R],Xsp*[1,1,1,1],'.r');
    h.Line3outC = stem([-2-R -1-R 1-R 2-R],Xsp*[1,1,1,1],'xr');
end  

set([h.Line3in,h.Line3inC,h.Line3out,h.Line3outC],'linewidth',h.LineWidth);
set(h.Axis3,'NextPlot','ReplaceChildren' ...
    ,'FontWeight','bold'...
    ,'FontSize',h.FontSize...
    ,'XLim',[-1.5 1.5] ...
    ,'YLim',[0 YSPMAX] ...
    ,'XTick',[-1 -0.5 0 0.5 1] ...
    ,'XTickLabel',[-1 -0.5 0 0.5 1]);
set([h.Line3inC(1),h.Line3outC(1)],'MarkerSize',XMarkerSize);
hold off

ht = title('Discrete Time Spectrum','FontWeight','bold');

% Get Reference Positions
A1pos = get(h.Axis1,'position');
A3pos = get(h.Axis3,'position');
%====================================================================
% Axis 5
A5pos = A1pos + [(2*(A3pos(1)-A1pos(1))) 0 0 0];
h.Axis5 = axes('units','normalized','position',A5pos, ...
    'NextPlot','ReplaceChildren'...
    ,'FontSize',h.FontSize,'FontWeight','bold'...
    ,'box','on','YLim',xMAX*[-1 1],'XLim',[0 0.5]);
h.Line5 = plot(h.time1,c1,'linewidth',h.LineWidth);
h.TextOut = text(Xlimit/2,1.25,'','FontWeight', 'bold','Color',[0 0 1],'HorizontalAlignment','center');

if h.MATLABVER>=8.4
    set(h.TextOut,'Interpreter','latex','string',['Output: $$\bf y(t)=\cos\left(2\pi(' sprintf('%.1f',Fo) ')t\right)$$'],'FontSize',Text_font);
else
    set(h.TextOut,'string',sprintf('Output: y(t) = cos(2%s %.1f t)','\pi',Fo),'FontSize',0.75*Text_font);
end
xlabel('Time (sec)')
%====================================================================
% Axis 6
A6pos = A3pos + [(A3pos(1)-A1pos(1)) 0 0 0];
h.Axis6 = axes('units','normalized','position',A6pos);
set(h.Axis6,'NextPlot','ReplaceChildren' ...
    ,'FontSize',h.FontSize,'FontWeight','bold'...
    ,'Box','On' ...
    ,'XLim',[-1.5*Fs 1.5*Fs] ...
    ,'YLim',[0, YSPMAX] ...
    ,'XTick',Fs*(-1:0.5:1) ...
    ,'XTickLabel',Fs*(-1:0.5:1) );
ht6 = title('Continuous Time Spectrum','FontWeight','bold');     
set(ht6,'fontsize',get(ht,'fontsize'));
if h.MATLABVER>=8.4
    xlabel('\bf $$f$$ (Hz)','Interpreter','Latex','fontsize',h.FontSizeLabel)
else
    xlabel('f (Hz)','fontsize',h.FontSizeLabel)
end
hold on        
h.Patch6 = patch([-0.5*Fs 0.5*Fs 0.5*Fs -0.5*Fs],[0 0 YSPMAX YSPMAX],'y');
if h.MATLABVER >= 7
    h.Line6  = stemdata(Fo,Xsp,{'.','b'});
    h.Line6c = stemdata(-Fo,Xsp,{'x','b'});
else
    h.Line6  = stem(Fo,Xsp,'.b');
    h.Line6c = stem(-Fo,Xsp,'xb');
end
set(h.Line6c(1),'MarkerSize',XMarkerSize);
hold off

h.TextAlie = text(0,0.85,'A L I A S I N G !','Visible','Off', ...
    'FontSize',14,'FontWeight','Bold','HorizontalAlignment','center','Color','r');
%====================================================================
h.Hide = [h.Axis5,h.Axis6,h.Line5,h.Patch6,h.TextOut];
set([h.Line6,h.Line6c],'LineWidth',h.LineWidth);
h.Group = [h.AxisRef,h.Axis1,h.Axis2,h.Axis3,h.Axis4,h.Editbox1,h.Editbox2, ...
        h.Editbox3,h.Slider1,h.Slider2,h.Text,h.TextFo,h.TextFs,h.TextRB1,h.TextRB12, ... 
        h.Check,h.UnfoldB,h.Axis5,h.Axis6,...
        h.RButton2,h.RButton22];

set(h.AllMenu,'Checked','on');
set(h.Group,'Units','Characters');
FigSize = get(gcf,'Position');
FigSizeNew = [1 1 1.5 1].* FigSize;
set(gcf, 'Position', FigSizeNew);

%set(h.Group,'Units','normalized'); % MAC
%set(h.Hide,'Visible','On');
%set([h.Line6,h.Line6c],'Visible','On');
%------------------------------------
set(h.ShowW_hat,'Checked','on');
% change text labels
set(gcf,'CurrentAxes',h.Axis3);
%xlabel('{}_{^{\fontsize{11}\omega = 2\pi (f_o / f_s)}}^{\^}')
%set(h.hat,'position',[-0.24 -0.12]);
set(h.Axis3,'XTick',0.5*(-2:2),'FontSize',h.FontSizeSym,'FontWeight','bold');

if h.MATLABVER<8.4
    xlabel('\omega = 2\pi (f_o / f_s)','Interpreter','tex','color','b','fontsize',h.FontSizeLabel);
    set(h.Axis3,'FontName','Symbol','XTickLabel',{'-2p';'-p';'0';'p';'2p'});
else
    xlabel('\bf $$\hat\omega = 2\pi\left({f_o}/{f_s}\right)$$','Interpreter','Latex','color','b','fontsize',h.FontSizeLabel);
    set(h.Axis3,'XTickLabel',{'-2\pi';'-\pi';'0';'\pi';'2\pi'});
end

set(h.RButton22,'Value',1);
h.w_hat_flag = 1;

set(gcf,'WindowButtonMotionFcn','con2dis WindowButtonMotionFcn');
