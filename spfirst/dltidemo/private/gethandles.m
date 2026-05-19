function h = gethandles(h)
%GETHANDLES Get all the handles used in the GUI
%   h = GETHANDLES(h) finds the handles used in the GUI and assigns them
%   to elements of the structure h

% Jordan Rosenthal, 14-Jun-99: Extracted original code from ltidemo 'Initialize' case
%                            : and created separate function.
h.Figure      = gcf;
h.Axis.Input  = findobj(gcf, 'Tag', 'InputAxis');
h.Axis.Mag    = findobj(gcf, 'Tag', 'MagAxis');   
h.Axis.Phase  = findobj(gcf, 'Tag', 'PhaseAxis');   
h.Axis.Output = findobj(gcf, 'Tag', 'OutputAxis');

h.Slider.Amp         = findobj(gcf, 'Tag', 'SAmplitude');
h.Slider.DC          = findobj(gcf, 'Tag', 'SDC');
h.Slider.Freq        = findobj(gcf, 'Tag', 'SFreq');
h.Slider.Phase       = findobj(gcf, 'Tag', 'SPhase');
h.Slider.FilterFreq1 = findobj(gcf, 'Tag', 'FilterSFreq1');
h.Slider.FilterPhase = findobj(gcf, 'Tag', 'FilterSPhase');
h.Slider.Averager    = findobj(gcf, 'Tag', 'AveragerSLength');

h.Edit.Amp         = findobj(gcf, 'Tag', 'EdAmplitude');
h.Edit.DC          = findobj(gcf, 'Tag', 'EdDC');
h.Edit.Freq        = findobj(gcf, 'Tag', 'EdFreq');
h.Edit.Phase       = findobj(gcf, 'Tag', 'EdPhase');
h.Edit.FilterFreq1 = findobj(gcf, 'Tag', 'FilterEdFreq1');
h.Edit.FilterPhase = findobj(gcf, 'Tag', 'FilterEdPhase');
h.Edit.bk          = findobj(gcf, 'Tag', 'FilterEdUserhn');

h.Text.Amp         = findobj(gcf, 'Tag', 'TextAmplitude');   
h.Text.DC          = findobj(gcf, 'Tag', 'TextDC');   
h.Text.Freq        = findobj(gcf, 'Tag', 'TextFreq');
h.Text.Freq1       = findobj(gcf, 'Tag', 'TextFreq1');
h.Text.Phase       = findobj(gcf, 'Tag', 'TextPhase');
h.Text.Phase1       = findobj(gcf, 'Tag', 'TextPhase1');
h.Text.FilterFreq1 = findobj(gcf, 'Tag', 'FilterTextFreq1');
h.Text.FilterPhase = findobj(gcf, 'Tag', 'FilterTextPhase');
h.Text.InputTitle  = findall(gcf, 'Tag', 'InputAxisTitle');
h.Text.OutputTitle = findall(gcf, 'Tag', 'OutputAxisTitle');

h.Button.Ans       = findobj(gcf, 'Tag', 'PushButton1');

h.PopUpMenu.Filter = findobj(gcf, 'Tag', 'FilterPopUp');

% Groups of Control Handles
h.UserhnGroup   = [h.Text.FilterFreq1; h.Edit.bk; ];
h.PhaseGroup    = [h.Slider.FilterPhase; h.Edit.FilterPhase; h.Text.FilterPhase];
h.FreqGroup     = [h.Slider.FilterFreq1; h.Edit.FilterFreq1; h.Text.FilterFreq1 ];
h.AveragerGroup = [h.Slider.Averager;    h.Edit.FilterFreq1; h.Text.FilterFreq1 ];
h.FilterSpecs   = [h.PhaseGroup; h.FreqGroup; h.Slider.Averager];
