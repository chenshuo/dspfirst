function h = gethandles(h)
%GETHANDLES Get all the handles used in the GUI
%   h = GETHANDLES(h) finds the handles used in the GUI and assigns them
%   to elements of the structure h

% Jordan Rosenthal, 11-Sep-1999
%             rev., 28-Jan-2000
%    Adapted from LTIDEMO-V111/GETHANDLES (14-Jun-1999)

h.Axis                = findobj(gcf, 'Tag', 'PlotAxis');

h.Menu.Amplitude      = findobj(gcf, 'Tag', 'AnswerAmplitude');
h.Menu.Frequency      = findobj(gcf, 'Tag', 'AnswerFrequency');
h.Menu.Phase          = findobj(gcf, 'Tag', 'AnswerPhase');

h.Edit.Amplitude      = findobj(gcf, 'Tag', 'Amplitude');
h.Edit.Frequency      = findobj(gcf, 'Tag', 'Frequency');
h.Edit.Phase          = findobj(gcf, 'Tag', 'Phase');

h.Checkbox.ShowGuess  = findobj(gcf, 'Tag', 'ShowGuess');

h.Frame               = findobj(gcf, 'Tag', 'Frame');

h.Text.AmplitudeLabel = findobj(gcf, 'Tag', 'AmplitudeLabel');
h.Text.FrequencyLabel = findobj(gcf, 'Tag', 'FrequencyLabel');
h.Text.AmplitudeLabel = findobj(gcf, 'Tag', 'AmplitudeLabel');
h.Text.PhaseLabel     = findobj(gcf, 'Tag', 'PhaseLabel');
h.Text.Period         = findobj(gcf, 'Tag', 'Period');
h.Text.YourGuessLabel = findobj(gcf, 'Tag', 'YourGuessLabel');