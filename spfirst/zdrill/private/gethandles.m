function h = gethandles(h)
%GETHANDLES Get all the handles used in the GUI
%   h = GETHANDLES(h) finds the handles used in the GUI and assigns them
%   to elements of the structure h

% Jordan Rosenthal, 11-Sep-1999
%    Adapted from LTIDEMO-V111/GETHANDLES (14-Jun-1999)
%             rev., 27-Jan-2000

h.Figure                  = gcf;
h.Frame.Main              = findobj(gcf, 'Tag', 'FrameMain');
h.Frame.Center            = findobj(gcf, 'Tag', 'FrameCenter');
h.Frame.Legend            = findobj(gcf, 'Tag', 'FrameLegend');

h.Axis.Input              = findobj(gcf, 'Tag', 'InputAxis');
h.Axis.Answer             = findobj(gcf, 'Tag', 'AnswerAxis');

h.Menu.Radius             = findobj(gcf, 'Tag', 'AnswerRadius');
h.Menu.Angle              = findobj(gcf, 'Tag', 'AnswerAngle');
h.Menu.RectForm           = findobj(gcf, 'Tag', 'AnswerRectForm');
  
h.Edit.Radius             = findobj(gcf, 'Tag', 'GuessRadius');
h.Edit.Angle              = findobj(gcf, 'Tag', 'GuessAngle');

h.Popup.Operation         = findobj(gcf, 'Tag', 'Operation');

h.Checkbox.ShowRectForm   = findobj(gcf, 'Tag', 'ShowRectForm');
h.Checkbox.ShowVectorSum  = findobj(gcf, 'Tag', 'ShowVectorSum');
h.Checkbox.ShowAnswer     = findobj(gcf, 'Tag', 'ShowAnswer');

%---  Input # 1 Related Text ---%
h.Text.z1.Header          = findobj(gcf, 'Tag', 'Z1Header');
h.Text.z1.Radius          = findobj(gcf, 'Tag', 'Z1Radius');
h.Text.z1.Angle           = findobj(gcf, 'Tag', 'Z1Angle');
h.Text.RectForm.z1        = findobj(gcf, 'Tag', 'Z1RectForm');
h.Text.Legendz1           = findobj(gcf, 'Tag', 'Legendz1');
h.Text.LegendLabel.z1     = findobj(gcf, 'Tag', 'LegendLabelz1');

%---  Input # 2 Related Text ---%
h.Text.z2.Header          = findobj(gcf, 'Tag', 'Z2Header');
h.Text.z2.Radius          = findobj(gcf, 'Tag', 'Z2Radius');
h.Text.z2.Angle           = findobj(gcf, 'Tag', 'Z2Angle');
h.Text.RectForm.z2        = findobj(gcf, 'Tag', 'Z2RectForm');
h.Text.Legendz2           = findobj(gcf, 'Tag', 'Legendz2');
h.Text.LegendLabel.z2     = findobj(gcf, 'Tag', 'LegendLabelz2');

%---  Operation and Guess Related Text ---%
h.Text.Operation          = findobj(gcf, 'Tag', 'OperationLabel');
h.Text.YourGuess          = findobj(gcf, 'Tag', 'YourGuessLabel');
h.Text.GuessRadiusLabel   = findobj(gcf, 'Tag', 'GuessRadiusLabel');
h.Text.GuessAngleLabel    = findobj(gcf, 'Tag', 'GuessAngleLabel');
h.Text.RectForm.Guess     = findobj(gcf, 'Tag', 'GuessRectForm');
h.Text.LegendGuess        = findobj(gcf, 'Tag', 'LegendGuess');
h.Text.LegendAnswer       = findobj(gcf, 'Tag', 'LegendAnswer');
h.Text.LegendLabel.Guess  = findobj(gcf, 'Tag', 'LegendLabelGuess');
h.Text.LegendLabel.Answer = findobj(gcf, 'Tag', 'LegendLabelAnswer');


h.Group.z2 = [h.Text.RectForm.z2 h.Text.z2.Radius ...
      h.Text.z2.Angle h.Text.z2.Header]';

