function h = defaultplots(h,AXISXLIM)
% DEFAULTPLOTS Create the default plots drawn when GUI loads
%    h = DEFAULTPLOTS(h) creates the initial plots drawn in the GUI
%    from data given in structure h.  Returns the structure with new
%    fields set.

% Jordan Rosenthal, 26-Mar-1999
% Jim McClellan, 31-Aug-2001

NO = 0; YES = 1; OFF = 0; ON = 1;
%--------------------------------------------------------------------------------
% Default Settings
%--------------------------------------------------------------------------------
%AXISXLIM       = [-25 25];  % now defined in dconvdemo_callbacks.m (JMc)
CIRCCONVLENGTH = 10; 
NRESETVALUE    = -5;         % The x axis value at which n starts in linear convolution

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Do not change code below this point.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h.Lines.Signal              = [];
h.Lines.FlippedSig          = [];
h.Lines.MultipliedSig       = [];
h.Lines.TotalOutput         = [];
h.Lines.CurrentOutput       = [];
h.Lines.CircularOutput      = [];
h.Lines.AliasSections       = [];
h.Text.Arrows               = [];
h.Text.CircularConvLength   = [];
h.Text.OutputLabel          = [];
h.Text.CircularOutputLabel  = [];
% Data
h.Data.Input.x          = [];
h.Data.Input.h          = [];
h.Data.Output           = [];
h.Data.CircularOutput   = [];
% State Info
h.State.AxisXLim           = AXISXLIM;
h.State.CircularConvLength = CIRCCONVLENGTH;
h.State.CConvResetValue    = CIRCCONVLENGTH;
h.State.CircularMode       = NO;
h.State.DataInitialized    = NO;
h.State.LineWidth          = 2;
h.State.n                  = NRESETVALUE;
h.State.nResetValue        = NRESETVALUE;
h.State.nArrowOffset       = 0.01*diff(h.State.AxisXLim);
h.State.SignalToFlip       = 'Flip h[n]';
h.State.TutorialMode       = NO;

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
