%----------------------------------------------------------------------------
%Using the SinDrill Graphical User Interface
%----------------------------------------------------------------------------
%
%----------------------------------------------------------------------------
%Overview
%----------------------------------------------------------------------------
%This program tests the users ability to determine basic parameters of a
%sinusoid.  After a plot of a sinusoid is displayed, the user must correctly
%guess its amplitude, frequency, and phase.
%
%----------------------------------------------------------------------------
%Theory
%----------------------------------------------------------------------------
%The general form for a sinusoid is:
%
%     x(t) = A*cos(2*pi*f0*t + phi)
%
%where
%
%       A = Sinusoid Amplitude
%      f0 = Sinusoid Frequency
%     phi = Sinsuoid Phase
%
%From a plot of the x(t), one can easily determine these parameters.  The 
%amplitude is simply the peak value of the plot.  The frequency is most
%easily determined by calculating 1/T where T is the period or the smallest 
%length of time between two equivalent points of the waveform.  The phase
%can be determined by calculating -2*pi*Frequency*Delay where the Delay is
%the length of time to the first peak.
%
%----------------------------------------------------------------------------
%SinDrill Controls
%----------------------------------------------------------------------------
%Creating a new question:
%
%  When the program first starts or when the 'New Quiz' button is pressed, a
%  sinusoid is drawn in the plot box.  It is your job to determine the 
%  amplitude, frequency, and phase of the sinusoid by entering your guess in
%  the appropriate boxes above the plot.  When determining your guess, keep
%  in mind the time scale of the plot is usually in the millisecond range.
%
%Changing your guess:
%
%  The amplitude, frequency, phase of the input sinusoid can be changed with 
%  by entering values in the boxes and hitting return.  You can also enter
%  any Matlab expression such as pi/2.
%
%Viewing your guess:
% 
%  When 'Show Guess' is checked, the sinusoid implied by the the amplitude, 
%  frequency, and phase you entered will be plotted and its formula displayed.
%
%Checking your answer:
%
%  Click on the 'Answer' menu to view the correct amplitude, frequency, and
%  phase of the test sinusoid.  When comparing your phase to the phase given
%  in the answer, keep in mind that any multiple of 2*pi can be added to the
%  phase.  For example, phi = -1.5*pi, 0.5*pi, and 2.5*pi are all equivalent 
%  answers.
%
%Changing the question difficulty:
%
%  Be checking either the 'Novice' or 'Pro' items in the 'Level' submenu of
%  the options menu, you can change the difficulty of the questions.
%
%Changing the line width:
%
%  By choosing 'Set line width...' in the 'Options' menu the width of the
%  displayed lines can be changed.  This can be useful, for example, to 
%  increase the linewidth if using the GUI in a presentation.
