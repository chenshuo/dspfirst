function h = setcolors(h)
%SETCOLORS Set the colors for the GUI

% Jordan Rosenthal, 02-Feb-2000

%------------------------------------------------------------------------
% Data Colors
%------------------------------------------------------------------------
h.Colors.Input1 = 'r';
h.Colors.Input2 = 'm'; 
h.Colors.Guess  = 'b';
h.Colors.Answer = 'k';
%---  Set the foreground colors for the headers  ---%
Foreground.Input1    = 'w';
Foreground.Input2    = 'w';
Foreground.YourGuess = 'w';

%------------------------------------------------------------------------
% Frame Colors
%------------------------------------------------------------------------
FrameColors.Main   = [0.65 0.65 0.65];
FrameColors.Center = [0.8 0.8 0.8];
FrameColors.Legend = [0.8 0.8 0.8];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Do not change code below this point.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%------------------------------------------------------------------------
% Set Frame colors
%------------------------------------------------------------------------
hObj1 = [h.Frame.Main, h.Checkbox.ShowRectForm, ...
      h.Checkbox.ShowVectorSum, h.Checkbox.ShowAnswer, ...
      h.Text.RectForm.z1, h.Text.RectForm.z2];
hObj2 = [h.Frame.Center, h.Text.Operation, h.Text.GuessRadiusLabel, ...
      h.Text.GuessAngleLabel, h.Text.RectForm.Guess];
hObj3 = [h.Frame.Legend, h.Text.LegendLabel.z1, h.Text.LegendLabel.z2, ...
      h.Text.LegendLabel.Guess, h.Text.LegendLabel.Answer];
set(hObj1, 'BackgroundColor', FrameColors.Main);
set(hObj2, 'BackgroundColor', FrameColors.Center);
set(hObj3, 'BackgroundColor', FrameColors.Legend);

%------------------------------------------------------------------------
% Set Label colors
%------------------------------------------------------------------------
set(h.Text.z1.Header, 'ForegroundColor', Foreground.Input1);
set([h.Text.z1.Header, h.Text.Legendz1], 'BackgroundColor', h.Colors.Input1);
set(h.Text.z2.Header, 'ForegroundColor', Foreground.Input2);
set([h.Text.z2.Header, h.Text.Legendz2], 'BackgroundColor', h.Colors.Input2);
set(h.Text.YourGuess, 'ForegroundColor', Foreground.YourGuess);
set([h.Text.YourGuess, h.Text.LegendGuess], 'BackgroundColor', h.Colors.Guess);
set(h.Text.LegendAnswer, 'BackgroundColor', h.Colors.Answer);

