function h = gethandles(h)
%GETHANDLES Get all the handles used in the GUI
%   h = GETHANDLES(h) finds the handles used in the GUI and assigns them
%   to elements of the structure h

% Jordan Rosenthal, 04-Oct-1999

h.Axis.x              = findobj(gcf, 'Tag', 'xAxis');
h.Axis.h              = findobj(gcf, 'Tag', 'hAxis');
h.Axis.Signal         = findobj(gcf, 'Tag', 'SignalAxis');
h.Axis.Multiply       = findobj(gcf, 'Tag', 'MultiplyAxis');
h.Axis.Output         = findobj(gcf, 'Tag', 'OutputAxis');
h.Axis.Text           = findobj(gcf, 'Tag', 'TextAxis');
h.Axis.Hideable       = [ h.Axis.x; h.Axis.h; h.Axis.Text ];
h.Axis.Big            = [ h.Axis.Signal; h.Axis.Multiply; h.Axis.Output ];

h.Menu.PlotOptions             = findobj(gcf, 'Tag', 'Plot Options');
h.Menu.ConserveSpace           = findobj(gcf, 'Tag', 'Conserve Space');
h.Menu.Help                    = findobj(gcf, 'Tag', 'Help');

h.Button.Tutorial              = findobj(gcf, 'Tag', 'TutorialButton');
h.Button.Radio                 = findobj(gcf, 'Style', 'radiobutton');
h.Button.Hideable              = setdiff( ...
   [h.Button.Radio; findobj(gcf,'Style','pushbutton') ], ...
   h.Button.Tutorial);

% For some reason setdiff command returns a row vector above in Matlab 5.3,
% but a column vector in R12.  Make sure it is a column vector.
h.Button.Hideable = h.Button.Hideable(:);  % Insure column vector
