function h = defaultplots(h)

% DEFAULTPLOTS Create the default plots drawn when GUI loads
%    h = DEFAULTPLOTS(h) creates the initial plots drawn in the GUI
%    from data given in structure h.  Returns the structure with new
%    fields set.

% Jordan Rosenthal, 22-Jun-99 adapted from original code that was in 
%                   'Initialize' case.  Made minor adjustments.
%                 , 27-Sep-99 Minor adjustment to work in Matlab 5.1
% Rajbabu, 27-Apr-2005, changed context menu label from 'Norm Freq' to 'Freq'
% Krudysz, 26-Nov-2005, adapted for 7.1

STEMPLOTMARKERSIZE = 5;  % Default marker size for stem plots
FREQMARKERSIZE     = 7;  % Default marker size for frequency markers

% Note:  LineWidth for all plots is set in 'Initialize' case of CLTIDEMO

%-------------------------------------------------------------------------------
% Input Defaults
%-------------------------------------------------------------------------------
h.Amp   = 1;
h.DC    = 0; 
h.Freq  = 20;
h.Phase = 0;
h.t = -1:1/(100*h.Freq):1;

%-------------------------------------------------------------------------------
% Filter Defaults
%-------------------------------------------------------------------------------
% Initial Filter is set to First-order Lowpass
h.Filter.Freq1       = 10;
h.Filter.ImpResp     = [1/(2*pi*h.Filter.Freq1) 1];% Impulse response of 

						   % low-pass filter 
h.Filter.PhaseShift  = 0;
h.Filter.BW          = 20;
h.Filter.FFT      = [];
h.Filter.Mag      = [];
h.Filter.Phase    = [];
h.PopUpValue      = 5;    % Corresponds to First-order Lowpass filter

%-------------------------------------------------------------------------------
% Output Defaults
%-------------------------------------------------------------------------------
h.Output.Mag   = [];
h.Output.Phase = [];
h.Output.DC    = [];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Do not change code below this point.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-------------------------------------------------------------------------------
% Set default values for input sliders and edit boxes
%-------------------------------------------------------------------------------
set(h.Slider.Amp,         'Value', h.Amp);      
set(h.Slider.DC,          'Value', h.DC);      
set(h.Slider.Freq,        'Value', h.Freq);      
set(h.Slider.Phase,       'Value', h.Phase);      
set(h.Slider.FilterFreq1, 'Value', h.Filter.Freq1);      
set(h.Slider.FilterPhase, 'Value', h.Filter.PhaseShift);      

set(h.Edit.Amp,         'String', num2str(h.Amp));
set(h.Edit.DC,          'String', num2str(h.DC));
set(h.Edit.Freq,        'String', num2str(h.Freq));
set(h.Edit.Phase,       'String', num2str(h.Phase));
set(h.Edit.FilterFreq1, 'String', num2str(h.Filter.Freq1));
set(h.Edit.FilterPhase, 'String', num2str(h.Filter.PhaseShift));
set(h.Text.Amp,   'String', ['Amplitude = ' num2str(h.Amp,3)]);
set(h.Text.DC,    'String', ['DC Level = ' num2str(h.DC,3)]);
set(h.Text.Freq,  'String', ['Frequency = ' num2str(h.Freq,3)]);
set(h.Text.Phase, 'String', ['Phase = ' num2str(h.Phase,3)]);

%-------------------------------------------------------------------------------
% Set default values for Filter sliders and edit boxes
%-------------------------------------------------------------------------------
set(h.PopUpMenu.Filter, 'Value', h.PopUpValue);

set(h.Slider.FilterFreq1, ...
    'Min',   10.0, ...
    'Value', h.Filter.Freq1);
set(h.Edit.FilterFreq1, ...
    'CallBack', 'cltidemo FilterFreq1E', ...
    'String',   num2str(h.Filter.Freq1));
set(h.Text.FilterFreq1, 'String', ['Cutoff Freq = ' num2str(h.Filter.Freq1)]);
set(h.Text.FilterPhase, 'String', ['Phase Slope = ' ,...
		    num2str(h.Filter.PhaseShift) '*pi']);
set(h.UserhnGroup,     'Visible', 'Off');
set(h.IntegratorGroup, 'Visible', 'Off');
set(h.FilterSpecs,     'Visible',  'On');
set(h.PhaseGroup,      'Visible', 'Off');
%-------------------------------------------------------------------------------
% Create initial Input plot
%-------------------------------------------------------------------------------
set(h.Figure,'currentAxes',h.Axis.Input);
h.InputPlot = plot(h.t, h.DC + h.Amp*cos(2*h.Freq*pi*h.t + h.Phase*pi),'r');

if h.MATLABVER > 5.1
   plotvalue(h.InputPlot,'t','y');
end

set(h.InputPlot,'MarkerSize',STEMPLOTMARKERSIZE,'LineWidth',h.LineWidth);
set(h.Text.InputTitle,'String',cosinestring(h.Amp, h.Freq, h.Phase, 0, h.DC));

if h.t(1)<0, hold on, htmp = plot([0,0],[-5,5],'r-');  hold off, end

axis([ h.t([1 end])/10 h.Amp*[-5 5] ]);
set(gca,'YTick',[-5 -2.5 0 2.5 5]);
grid on;

%-------------------------------------------------------------------------------
% Create initial Filter plot
%-------------------------------------------------------------------------------
[h.Filter.Range, h.Filter.FFT]=ctfirstorderfilter('Lowpass', h.Filter.Freq1,'');
h.Filter.Mag   = abs(h.Filter.FFT);
h.Filter.Phase = angle(h.Filter.FFT);

%---  Magnitude Plot  ---%
set(h.Figure,'currentAxes',h.Axis.Mag);
h.FilterMagPlot = plot(h.Filter.Range, h.Filter.Mag,'LineWidth',h.LineWidth);
Hmax = max(abs(h.Filter.Mag));

%---  Phase Plot  ---%
set(h.Figure,'currentAxes',h.Axis.Phase);
h.FilterPhasePlot = plot(h.Filter.Range, h.Filter.Phase,...
			 'LineWidth',h.LineWidth);
%-------------------------------------------------------------------------------
% Initial Output plot
%-------------------------------------------------------------------------------
[qq,k0]    = min(abs(h.Filter.Range));         %<-- find DC
[qq,kMag]  = min(abs(h.Filter.Range-h.Freq));  %<-- find "positive" freq
[qq,kMag2] = min(abs(h.Filter.Range+h.Freq));  %<-- find "negative" freq

set(h.Figure,'currentAxes',h.Axis.Output);
h.Output.Mag = h.Amp * h.Filter.Mag(kMag);
h.Output.Phase = h.Phase + h.Filter.Phase(kMag)/pi;
h.Output.DC = h.DC*h.Filter.FFT(k0);

h.OutputPlot = plot(h.t, h.Output.DC + ...
   h.Output.Mag*cos(2*pi*h.Freq*h.t + h.Output.Phase*pi),'m');

if h.MATLABVER > 5.1
   plotvalue(h.OutputPlot,'t','y');
end

set(h.OutputPlot,'MarkerSize',STEMPLOTMARKERSIZE,'LineWidth',h.LineWidth);
if h.t(1)<0, hold on, htmp = plot([0,0],[-5,5],'m-'); hold off, end
axis([ h.t([1 end])/10 [-5 5] ]);
set(gca,'YTick',[-5 -2.5 0 2.5 5]);
grid on;
set(h.Text.OutputTitle,'String','');

%-------------------------------------------------------------------------------
% Frequency Marker
%-------------------------------------------------------------------------------
[qq,kMag] = min(abs(h.Filter.Range-h.Freq));
h.Line.FreqMagMark0 = line(0, h.Filter.Mag(1),'Parent',h.Axis.Mag);
h.Line.FreqPMark0 = line(0,h.Filter.Phase(1),'Parent',h.Axis.Phase);
set([h.Line.FreqMagMark0; h.Line.FreqPMark0], ...
   'Color','r','Marker','o','MarkerFaceColor', 'r', 'MarkerSize', FREQMARKERSIZE);

if h.DC==0
   set([h.Line.FreqMagMark0,h.Line.FreqPMark0], 'Visible', 'Off');  
end

h.Line.FreqMagMark1 = line(h.Freq,h.Filter.Mag(kMag),'Parent',h.Axis.Mag);
h.Line.FreqMagMark2 = line(-h.Freq,h.Filter.Mag(kMag),'Parent',h.Axis.Mag);
h.Line.FreqPMark1 = line(h.Freq,h.Filter.Phase(kMag),'Parent',h.Axis.Phase);

set([ h.Line.FreqMagMark1; h.Line.FreqPMark1; h.Line.FreqMagMark2], ...
   'Color','r','Marker','o',...
    'MarkerFaceColor', 'r', 'MarkerSize', FREQMARKERSIZE);

if h.MATLABVER > 5.1
   stemvalue(h.Line.FreqMagMark0,'Freq','Mag');
   stemvalue(h.Line.FreqMagMark1,'Freq','Mag');
   stemvalue(h.Line.FreqMagMark2,'Freq','Mag');
   stemvalue(h.Line.FreqPMark0,'Freq','Phase');
   stemvalue(h.Line.FreqPMark1,'Freq','Phase');
end
% eof: defaultplots.m