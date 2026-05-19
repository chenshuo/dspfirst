function h = defaultplots(h)
% DEFAULTPLOTS Create the default plots drawn when GUI loads
%    h = DEFAULTPLOTS(h) creates the initial plots drawn in the GUI
%    from data given in structure h.  Returns the structure with new
%    fields set.
%
% Jordan Rosenthal, 22-Jun-99 adapted from original code that was in 
%                   'Initialize' case.  Made minor adjustments.
%    Rev. 27-Sep-1999 : Minor adjustment to work in Matlab 5.1
%    Rev. 18-Nov-2000 : Modified for name change to DLTIDEMO
%  Krudysz,
%    Rev. 05-Mar-2009 : Rewrote stemdata to replace depreciated 'stem' fcn

STEMPLOTMARKERSIZE = 5;  % Default marker size for stem plots
FREQMARKERSIZE     = 7;  % Default marker size for frequency markers
% Note:  LineWidth for all plots is set in 'Initialize' case of DLTIDEMO

%--------------------------------------------------------------------------------
% Input Defaults
%--------------------------------------------------------------------------------
h.Amp   = 1;
h.DC    = 0; 
h.Freq  = 1/10;
h.Phase = 0;
h.n     = [-5:30];

%--------------------------------------------------------------------------------
% Filter Defaults
%--------------------------------------------------------------------------------
% Initial Filter is set to Averager
h.Filter.ImpResp     = [1,1,1]/3;        % Impulse response of the averager
h.Filter.bk          = '[1,1,1,1]/4';    % Impulse response for user input
h.Filter.Freq1       = 0.2;
h.Filter.PhaseShift  = 0;
h.Filter.BW          = 0.2;
h.Filter.freqzMethod = 'freqz';
if exist('freqz','file')~=2
   if exist('freekz','file')==2, h.Filter.freqzMethod = 'freekz';
   else, error('Need freqz.m or freekz.m to compute H(w)'), end
end
h.Filter.FFT      = [];
h.Filter.Mag      = [];
h.Filter.Phase    = [];
h.PopUpValue      = 1;    % Corresponds to first value in popupmenu = Averager
h.Averager.Length = 3;

%--------------------------------------------------------------------------------
% Output Defaults
%--------------------------------------------------------------------------------
h.Output.Mag   = [];
h.Output.Phase = [];
h.Output.DC    = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Do not change code below this point.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%--------------------------------------------------------------------------------
% Set default values for input sliders and edit boxes
%--------------------------------------------------------------------------------
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
set(h.Text.Amp,         'String', ['Amplitude = ' num2str(h.Amp)]);
set(h.Text.DC,          'String', ['DC Level = ' num2str(h.DC)]);
set(h.Text.Freq,        'String', ['Frequency = 2\pi ' num2str(h.Freq)]);
set(h.Text.Phase,       'String', ['Phase = ' num2str(h.Phase)]);  

%--------------------------------------------------------------------------------
% Set default values for Filter sliders and edit boxes
%--------------------------------------------------------------------------------
set(h.PopUpMenu.Filter, 'Value', h.PopUpValue);
set(h.Slider.Averager, 'SliderStep', [0.1 0.2]);
set(h.Slider.FilterFreq1, ...
   'Min',   0.01, ...
   'Max',   0.4, ...
   'Value', h.Filter.Freq1);      
set(h.Edit.FilterFreq1, ...
   'CallBack', 'dltidemo FilterFreq1E', ...
   'String',   num2str(h.Filter.Freq1));
set(h.FreqGroup, 'Visible', 'On');
if 1
   set(h.UserhnGroup,   'Visible', 'Off');
   set(h.PhaseGroup,    'Visible', 'Off');
   set(h.AveragerGroup, 'Visible', 'On');
   set(h.Slider.FilterFreq1,'Visible','Off');
   set(h.Slider.Averager,  'Value',    h.Averager.Length);      
   set(h.Edit.FilterFreq1, ...
      'CallBack', 'dltidemo AveragerLengthE', ...
      'String',   num2str(h.Averager.Length));
   set(h.Text.FilterFreq1, 'String', ['Length = ' num2str(h.Averager.Length) ' pts']);
end

%--------------------------------------------------------------------------------
% Create initial Input plot
%--------------------------------------------------------------------------------
set(h.Figure,'currentAxes',h.Axis.Input);
if h.MATLABVER >= 7
  h.InputPlot = stemdata(h.n, h.DC + h.Amp*cos(2*h.Freq*pi*h.n + h.Phase*pi),{'o','r'});
else
  h.InputPlot = stem(h.n, h.DC + h.Amp*cos(2*h.Freq*pi*h.n + h.Phase*pi),'r','filled');
end
if h.MATLABVER > 5.1
   stemvalue(h.InputPlot,'n','y');
end
set(h.InputPlot,'MarkerSize',STEMPLOTMARKERSIZE,'LineWidth',h.LineWidth);
set(h.Text.InputTitle,'String',cosinestring(h.Amp, 2*h.Freq, h.Phase, 0, h.DC));
if h.n(1)<0, hold on, htmp = plot([0,0],[-5,5],'r-');  hold off, end
axis([ h.n([1 end]) h.Amp*[-5 5] ]);
set(gca,'YTick',[-5 -2.5 0 2.5 5]);
grid on;

%--------------------------------------------------------------------------------
% Create initial Filter plot
%--------------------------------------------------------------------------------
[h.Filter.FFT, h.Filter.Range] = feval(h.Filter.freqzMethod,h.Filter.ImpResp, 1, 512, 'whole');
h.Filter.Range = h.Filter.Range/2/pi - 0.5;
h.Filter.FFT   = fftshift(h.Filter.FFT);
h.Filter.Mag   = abs(h.Filter.FFT);
h.Filter.Phase = angle(h.Filter.FFT);
%---  Magnitude Plot  ---%
set(h.Figure,'currentAxes',h.Axis.Mag);
h.FilterMagPlot = plot(h.Filter.Range, h.Filter.Mag,'LineWidth',h.LineWidth);
%%   axis([ -.5 .5 0 1.1]);
Hmax = max(abs(h.Filter.Mag));
axis([ -0.5, 0.5, 0, 0.1+max([1.0,ceil(Hmax-0.05)])]);

set(h.Axis.Mag,'XTick', (-.5:.05:.5),'LineWidth',1);
if h.MATLABVER < 8.4
    set(h.Axis.Mag,'FontName','Symbol', ...
        'XTickLabel',{'-p';'';'';'';'';'-0.5p';'';'';'';'';'0';'';'';'';'';'0.5p';'';'';'';'';'p'});
else
    set(h.Axis.Mag, ...
        'XTickLabel',{'-\pi';'';'';'';'';'-0.5\pi';'';'';'';'';'0';'';'';'';'';'0.5\pi';'';'';'';'';'\pi'});
end
%---  Phase Plot  ---%
set(h.Figure,'currentAxes',h.Axis.Phase);
h.FilterPhasePlot = plot(h.Filter.Range, h.Filter.Phase,'LineWidth',h.LineWidth);

set(gca,'XTick', [-.5:.05:.5], ...
    'YTick', [-3:3], 'LineWidth',1);

if h.MATLABVER < 8.4
    set(gca,'FontName','Symbol', ...
        'XTickLabel',{'-p';'';'';'';'';'-0.5p';'';'';'';'';'0';'';'';'';'';'0.5p';'';'';'';'';'p'});
else
    set(gca,'XTickLabel',{'-\pi';'';'';'';'';'-0.5\pi';'';'';'';'';'0';'';'';'';'';'0.5\pi';'';'';'';'';'\pi'});
end
axis([ -.5 .5 -3.5 3.5 ]);

%--------------------------------------------------------------------------------
% Initial Output plot
%--------------------------------------------------------------------------------
H = feval(h.Filter.freqzMethod,h.Filter.ImpResp,1,[0 2*pi*h.Freq]);
set(h.Figure,'currentAxes',h.Axis.Output);
h.Output.Mag = h.Amp * abs(H(2));
h.Output.Phase = h.Phase + angle(H(2))/pi;
h.Output.DC = h.DC*H(1);

if h.MATLABVER >= 7
  h.OutputPlot = stemdata(h.n,h.Output.DC + h.Output.Mag*cos(2*pi*h.Freq*h.n + h.Output.Phase*pi),{'o','m'});
else
  h.OutputPlot = stem(h.n, h.Output.DC + ...
		      h.Output.Mag*cos(2*pi*h.Freq*h.n + h.Output.Phase*pi),'m','filled');
end
if h.MATLABVER > 5.1
   stemvalue(h.OutputPlot,'n','y');
end
set(h.OutputPlot,'MarkerSize',STEMPLOTMARKERSIZE,'LineWidth',h.LineWidth);
if h.n(1)<0, hold on, htmp = plot([0,0],[-5,5],'m-'); hold off, end
axis([ h.n([1 end]) [-5 5] ]);
set(gca,'YTick',[-5 -2.5 0 2.5 5]);
grid on;
set(h.Text.OutputTitle,'String','');

%--------------------------------------------------------------------------------
% Frequency Marker
%--------------------------------------------------------------------------------
kMag = round( (h.Freq+0.5)*511 ) + 1;
h.Line.FreqMagMark0 = line(0,abs(H(1)),'Parent',h.Axis.Mag);
h.Line.FreqPMark0 = line(0,angle(H(1)),'Parent',h.Axis.Phase);
set([h.Line.FreqMagMark0; h.Line.FreqPMark0], ...
   'Color','r','Marker','o','MarkerFaceColor', 'r', 'MarkerSize', FREQMARKERSIZE);
if h.DC==0
   set(h.Line.FreqMagMark0, 'Visible', 'Off');  
   set(h.Line.FreqPMark0, 'Visible', 'Off');  
end
h.Line.FreqMagMark1 = line(h.Freq,h.Filter.Mag(kMag),'Parent',h.Axis.Mag);
h.Line.FreqMagMark2 = line(-h.Freq,h.Filter.Mag(kMag),'Parent',h.Axis.Mag);
h.Line.FreqPMark1 = line(h.Freq,h.Filter.Phase(kMag),'Parent',h.Axis.Phase);
set([ h.Line.FreqMagMark1; h.Line.FreqPMark1; h.Line.FreqMagMark2], ...
   'Color','r','Marker','o','MarkerFaceColor', 'r', 'MarkerSize', FREQMARKERSIZE);
if h.MATLABVER > 5.1
   stemvalue(h.Line.FreqMagMark0,'Norm Freq','Mag');
   stemvalue(h.Line.FreqMagMark1,'Norm Freq','Mag');
   stemvalue(h.Line.FreqMagMark2,'Norm Freq','Mag');
   stemvalue(h.Line.FreqPMark0,'Norm Freq','Phase');
   stemvalue(h.Line.FreqPMark1,'Norm Freq','Phase');
end