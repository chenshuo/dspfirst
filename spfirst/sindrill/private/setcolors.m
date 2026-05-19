function h = setcolors(h)
%SETCOLORS Set the colors for the GUI

% Jordan Rosenthal, 29-Jan-2000
%------------------------------------------------------------------------
% Data Colors
%------------------------------------------------------------------------
h.Colors.Line.True  = 'r';
h.Colors.Line.Guess = 'b';
%---  Set the foreground colors for the header  ---%
Foreground.YourGuess = 'w';

%------------------------------------------------------------------------
% Frame and Label Colors
%------------------------------------------------------------------------
FrameColor = [0.65 0.65 0.65];
TextColor  = 'k';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Do not change code below this point.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%------------------------------------------------------------------------
% Set Frame color
%------------------------------------------------------------------------
hObj = [h.Frame, h.Checkbox.ShowGuess, h.Text.AmplitudeLabel, ...
      h.Text.FrequencyLabel, h.Text.PhaseLabel, h.Text.Period];
set(hObj, 'BackgroundColor', FrameColor);

%------------------------------------------------------------------------
% Set Label colors
%------------------------------------------------------------------------
hObj = [h.Text.AmplitudeLabel, h.Text.FrequencyLabel, ...
      h.Text.PhaseLabel, h.Text.Period];
set(hObj, 'ForegroundColor', TextColor);
set(h.Text.YourGuessLabel, 'ForegroundColor', Foreground.YourGuess, ...
   'BackgroundColor',h.Colors.Line.Guess);

