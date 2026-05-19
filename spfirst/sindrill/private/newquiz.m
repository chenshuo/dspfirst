function h = newquiz(h)
%NEWQUIZ Create a new quiz question.

% Jordan Rosenthal, 02/02/2000
% jr@ece.gatech.edu
%  Rev. Krudysz 11/25/2005 : problems with axes() in 7.1 (?)
%-------------------------------------------------------------------
% Pick an new answer from the list of choices.
%-------------------------------------------------------------------
switch h.UserLevel
case 'Novice'
   A   = pickone(h.Choices.Novice.Amplitude);
   f0  = pickone(h.Choices.Novice.Frequency);
   phi = pickone(h.Choices.Novice.Phase);
case 'Pro'
   A   = pickone(h.Choices.Pro.Amplitude);
   f0  = pickone(h.Choices.Pro.Frequency);
   phi = pickone(h.Choices.Pro.Phase);
end
h.Amplitude = A;
h.Frequency = f0;
h.Phase     = phi;

start = pickone(h.Choices.StartPoint) / h.Frequency;
stop  = pickone(h.Choices.EndPoint) / h.Frequency;
h.t = start:1/(100*h.Frequency):stop;

%-------------------------------------------------------------------
% Reset guess strings to initial values.
%-------------------------------------------------------------------
set(h.Edit.Amplitude,   'String', h.DefaultString.Amplitude);
set(h.Edit.Frequency,   'String', h.DefaultString.Frequency);
set(h.Edit.Phase,       'String', h.DefaultString.Phase);
h.Default.Amplitude = str2num(h.DefaultString.Amplitude);
h.Default.Frequency = str2num(h.DefaultString.Frequency);
h.Default.Phase     = str2num(h.DefaultString.Phase);

%---  Change Period string  ---%
if h.Default.Frequency == 0
   s = ['Period = Inf'];
else
   s = ['Period = ' num2str(abs(1/h.Default.Frequency*1000),'%5.3g'),' ms'];
end
set(h.Text.Period,'String',s);
set(gcbf,'UserData',h);
%--------------------------------------------------------------------------------
% Create the line plots
%--------------------------------------------------------------------------------

set(gcbf,'currentAxes',h.Axis); %axes(h.Axis);
h.Line.True = plot(h.t, h.Amplitude*cos(2*pi*h.Frequency*h.t + h.Phase), ...
   'Color',h.Colors.Line.True, 'LineWidth',h.LineWidth);
grid on;

set(h.Checkbox.ShowGuess,'Value',0);
hold on;
h.Line.Guess = plot(h.t, ...
   h.Default.Amplitude*cos(2*pi*h.Default.Frequency*h.t+h.Default.Phase), ...
   h.Colors.Line.Guess, 'LineWidth', h.LineWidth+1 , 'Visible', 'off');
hold off;
h.Title = title(cosinestring(0,0,1/2,0,0), ...
   'Color',h.Colors.Line.Guess,'Visible','off');

setaxislimits(h);

%-------------------------------------------------------------------
% Set answer menus to correct values.
%-------------------------------------------------------------------
set(h.Menu.Amplitude,   'Label', ['A = ' num2str(h.Amplitude)]);
set(h.Menu.Frequency,   'Label', ['f_0 = ' num2str(h.Frequency)]);
set(h.Menu.Phase,       'Label', ['phi = ' phasestring(h.Phase)]);
%-------------------------------------------------------------------
% Finish up by setting axis limits and data.
%-------------------------------------------------------------------
set(gcbf,'UserData',h);

%sindrill('ChangeValue');
