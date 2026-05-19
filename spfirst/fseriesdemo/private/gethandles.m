function h = gethandles(h)
%GETHANDLES Get all the handles used in the GUI
%   h = GETHANDLES(h) finds the handles used in the GUI and assigns them
%   to elements of the structure h

% Mustayeen Nayeem, May 23, 2002


h.Axis.Waveform        = findobj(gcf, 'Tag', 'WaveformAxis');
h.Axis.Magnitude       = findobj(gcf, 'Tag', 'MagnitudeAxis');
h.Axis.Phase           = findobj(gcf, 'Tag', 'PhaseAxis');
h.Axis.Big             = [h.Axis.Waveform; h.Axis.Magnitude; h.Axis.Phase];

h.Menu.PlotOptions     = findobj(gcf, 'Tag', 'Plot Options');
h.Menu.Help            = findobj(gcf, 'Tag', 'Help');
h.Menu.LineWidth       = findobj(gcf, 'Tag', 'LineWidth');

h.Edit.NumCoeff        = findobj(gcf, 'Tag', 'FourCoeffEdit');

h.Slider.NumCoeff      = findobj(gcf, 'Tag', 'FourCoeffSlider');

h.PopUpMenu.Signal     = findobj(gcf, 'Tag', 'SignalPopUp');

h.Text.CoeffText       = findobj(gcf, 'Tag', 'TextforCoeff');
h.Text.SignalText      = findobj(gcf, 'Tag', 'TextforSignal');
h.Text.SliderText      = findobj(gcf, 'Tag', 'TextforSlider');