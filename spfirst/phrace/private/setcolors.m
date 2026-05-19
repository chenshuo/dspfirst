function h = setcolors(h)
%SETCOLORS Set the colors for the GUI

% Jordan Rosenthal, 02-Feb-2000

%------------------------------------------------------------------------
% Data Colors
%------------------------------------------------------------------------
h.Colors.Title  = 'b';%[0 1 1];%'k';
h.Colors.Timer  = [0.5 0 0];%'r';
h.Colors.Question = 'r';
h.Colors.Answer = [0.5 0 0.5];

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
%hObj1 = [h.Frame.Main, h.Checkbox.ShowRectForm, ...
%      h.Checkbox.ShowVectorSum, h.Checkbox.ShowAnswer, ...
%      h.Text.RectForm.z1, h.Text.RectForm.z2];
%hObj2 = [h.Frame.Center, h.Text.Operation, h.Text.GuessRadiusLabel, ...
%      h.Text.GuessAngleLabel, h.Text.RectForm.Guess];
%hObj3 = [h.Frame.Legend, h.Text.LegendLabel.z1, h.Text.LegendLabel.z2, ...
%      h.Text.LegendLabel.Guess, h.Text.LegendLabel.Answer];
%set(hObj1, 'BackgroundColor', FrameColors.Main);
%set(hObj2, 'BackgroundColor', FrameColors.Center);
%set(hObj3, 'BackgroundColor', FrameColors.Legend);

%------------------------------------------------------------------------
% Set Label colors
%------------------------------------------------------------------------
set(h.Text.Title, 'Color', h.Colors.Title);
set(h.Text.Timer, 'Color', h.Colors.Timer);
set([h.Text.Question, h.Text.Questionline, h.Text.Questionden], ...
    'Color', h.Colors.Question); 
set(h.Text.Answer, 'Color', h.Colors.Answer);
