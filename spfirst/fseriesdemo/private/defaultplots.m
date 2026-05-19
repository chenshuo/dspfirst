function h = defaultplots(h)
% DEFAULTPLOTS Create the default plots drawn when GUI loads
%    h = DEFAULTPLOTS(h) creates the initial plots drawn in the GUI
%    from data given in structure h.  Returns the structure with new
%    fields set.

% Mustayeen Nayeem, July 15, 2002
% G Krudysz, Dec 14, 2003 - Added marker for DC
% Rajbabu, Dec 14, 2004 - Fixed stem for version 7.0
% JMc, 25-Nov-2011 - Made T=10s the default period; 0.1 fundamental freq

%--------------------------------------------------------------------------------
% Default Settings
%--------------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Do not change code below this point.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h.NumCoeff = 0;
h.SignalVal = 1;
h.timeaxis = -30:0.1:30;
h.freq = 0.10;      %-  default fundamental frequency (JMc, 25-Nov-2011)
h.yval = sqar(2*pi*h.freq*h.timeaxis);

set(h.Edit.NumCoeff, 'Value', h.NumCoeff);
set(h.Slider.NumCoeff,'Value', h.NumCoeff);
set(h.PopUpMenu.Signal,'Value', h.SignalVal);

axes(h.Axis.Waveform);
h.Signal.Waveform = plot(h.timeaxis, h.yval,'k');
hold on;
h.recFinal = zeros(1,length(h.timeaxis));
h.Signal.RecWaveform = plot(h.timeaxis,zeros(1,length(h.timeaxis)),'r');
h.DCtext = text(0.4,0.3,sprintf('%s \n %s','DC','\downarrow'),'color','r');
h.Signal.ErrorWaveform = plot(h.timeaxis,h.yval-h.recFinal,'b','visible','off');
hold off;
% Axis Legends
Props_Common = {'VerticalAlignment','Top','FontAngle','Italic', ...
    'FontUnits','Normalized','FontSize',0.1,'Units','Normalized'};
PropNames_Unique = {'tag','String','Color','Parent','Position','Visible'};
PropVals_Unique = { ...
    'origsig','Original Signal','k',h.Axis.Waveform,[0.04 0.99],'on'; ...
    'syntsig','Synthesized Signal','r',h.Axis.Waveform,[0.7 0.99],'on'; ...
    'errosig','Error Signal','b',h.Axis.Waveform,[0.04 0.99],'off'};

hAxisLegendsText = text(0.01*ones(3,1), 0.99*ones(3,1),'', Props_Common{:});
set(hAxisLegendsText,PropNames_Unique,PropVals_Unique);

axes(h.Axis.Magnitude);

if h.MATLABVER >= 7
    h.Line.Magnitude     = stemdata(1,1,{'o','r'});
    h.Spectrum.Magnitude = stemdata(0,0,{'o','b'});
else
    hold on
    h.Line.Magnitude     = stem(1,1,'r.');
    h.Spectrum.Magnitude = stem(0,0,'b.');
    hold off
end

h.Text.Magnitude      = text(0,0,'','fontweight','bold');
set(h.Line.Magnitude,'vis','off');
set(h.Axis.Magnitude,'children',[h.Line.Magnitude,h.Text.Magnitude,h.Spectrum.Magnitude]');
axes(h.Axis.Phase);

h.Line.PhaseBase = line([-15 15],[0 0],'color',[0.7 0.7 0.7],'linestyle','--');

if h.MATLABVER >= 7
    h.Line.Phase     = stemdata(1,1,{'o','r'});
    h.Spectrum.Phase = stemdata(0,0,{'o','b'});
else
    hold on
    h.Line.Phase     = stem(1,1,'r.');
    h.Spectrum.Phase = stem(0,0,'b.');
    hold off
end

h.Text.Phase     = text(0,0,'','horiz','center','vert','middle','fontweight','bold');
set(h.Line.Phase,'vis','off');
set(h.Axis.Phase,'children',[h.Line.Phase,h.Text.Phase,h.Spectrum.Phase,h.Line.PhaseBase]');