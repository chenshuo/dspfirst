function h = defaultplots(h)
% DEFAULTPLOTS Create the default plots drawn when GUI loads
%    h = DEFAULTPLOTS(h) creates the initial plots drawn in the GUI
%    from data given in structure h.  Returns the structure with new
%    fields set.

% Jordan Rosenthal, 11-Sep-1999
%             Rev., 02-Feb-2000
%    Adpated from LTIDEMOV11/DEFAULTPLOTS (22-Jun-99)

STEMPLOTMARKERSIZE = 5;  % Default marker size for stem plots
FREQMARKERSIZE     = 7;  % Default marker size for frequency markers
% Note:  LineWidth for all plots is set in 'Initialize' case of LTIDEMO

%--------------------------------------------------------------------------------
% Input Choices: lists for possible answers.
%--------------------------------------------------------------------------------
h.Choices.Novice.Amplitude = [1 2];
h.Choices.Novice.Frequency = [500 1000];
h.Choices.Novice.Phase     = [-pi/2 0 pi/2];
h.Choices.Pro.Amplitude    = [1 5 10 25 100];
h.Choices.Pro.Frequency    = [60 100 250 500 1000];
h.Choices.Pro.Phase        = pi/24*[-30:30];
h.Choices.StartPoint       = [-2 -1 0];  % Will gets divided by h.Frequency
h.Choices.EndPoint         = [1 2];
h.UserLevel = 'Novice';

%--------------------------------------------------------------------------------
% Guess Defaults
%--------------------------------------------------------------------------------
% Enter these as the string representation of the number.
h.DefaultString.Amplitude = '0';
h.DefaultString.Frequency = '0';
h.DefaultString.Phase     = 'pi/4';  

h = newquiz(h);