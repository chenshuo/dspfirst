function h = defaultplots(h)
% DEFAULTPLOTS Create the default plots drawn when GUI loads
%    h = DEFAULTPLOTS(h) creates the initial plots drawn in the GUI
%    from data given in structure h.  Returns the structure with new
%    fields set.

% Jordan Rosenthal, 04-Oct-1999

%STEMPLOTMARKERSIZE = 5;  % Default marker size for stem plots
%FREQMARKERSIZE     = 7;  % Default marker size for frequency markers
% Note:  LineWidth for all plots is set in 'Initialize' case of LTIDEMO

%--------------------------------------------------------------------------------
% Default Settings
%--------------------------------------------------------------------------------
AXISXLIM       = [-10 10];
TRESETVALUE    = -2;    % The x axis value at which t starts in linear convolution
MAXPLOTPOINTS  = 10000; % The highest number of points allowed in a line plot.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Do not change code below this point.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
NO = 0; YES = 1; OFF = 0; ON = 1;
h.Graphics.Signal            = [];
h.Graphics.FlippedSig        = [];
h.Lines.MultiplyZeroLine     = [];
h.Patch.MultipliedSig        = [];
h.Lines.TotalOutput          = [];
h.Lines.CurrentOutput        = [];
h.Text.ImpulseText.Multiply  = [];
h.Text.ImpulseText.Output    = [];
h.Text.Arrows                = [];
h.Text.OutputLabel           = [];
% Data
h.Data.Input.x          = [];
h.Data.Input.h          = [];
h.Data.Output           = [];
% State Info
h.State.AxisXLim           = AXISXLIM;
h.State.DataInitialized    = NO;
h.State.LineWidth          = 2;
h.State.t                  = TRESETVALUE;
h.State.tResetValue        = TRESETVALUE;
h.State.tArrowOffset       = 0.01*diff(h.State.AxisXLim);
h.State.SignalToFlip       = 'Flip h(t)';
h.State.TutorialMode       = NO;
h.State.MaxPlotPoints      = MAXPLOTPOINTS;

set(h.Axis.Big,'XLim',AXISXLIM);

%If running in R12 or later, the arrow keys work so replace the openinge message
if h.MATLABVER >= 6
    oldText = {'Pick both an input signal',...
            'and an impulse response.', ...
            ' ', ...
            'Then drag pointers or use the', ...
            '4 and 6 keys to slide the', ...
            'flipped signal around.'};
    newText = {'Pick both an input signal',...
            'and an impulse response.', ...
            ' ', ...
            'Then drag pointers or use the', ...
            'arrow keys to slide the', ...
            'flipped signal around.'};
    hText = findobj(gcf,'type','text','string',oldText);
    set(hText,'string',newText);
end