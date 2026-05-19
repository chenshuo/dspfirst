%----------------------------------------------------------------------------
%Using the Discrete LTIDemo Graphical User Interface
%----------------------------------------------------------------------------
%
%----------------------------------------------------------------------------
%Overview
%----------------------------------------------------------------------------
%This program illustrates the relationship between the input and output of a
%linear time-invariant (LTI) filter when the input is a sinusoidal function.  
%The user is allowed to control the parameters of both the input sinusoid and
%the filter.
%
%----------------------------------------------------------------------------
%Theory
%----------------------------------------------------------------------------
%The general form for the input sinusoid is:
%
%     Input = A + B*cos(2*pi*f0*n + phi)
%
%where
%
%       A = DC Level
%       B = Sinusoid Amplitude
%      f0 = Sinusoid Frequency
%     phi = Sinsuoid Phase
%
%Because the filter is an LTI filter, the output is
%
%     Output = A*D + B*M*cos(2*pi*f0*n + phi + P)
%
%where
% 
%     D = The filter's DC response, i.e., the frequency response at f=0.
%     M = Magnitude of the filter's frequency response evaluated at f=f0.
%     P = Phase of the filter's frequency response evaluated at f=f0.
%
%Note that the output of the filter is still a sinusoid.  In fact, it is a
%sinusoid with the same frequency as the input sinusoid.  The filter only
%changes the DC level, magnitude, and phase of the input sinusoid.
%
%----------------------------------------------------------------------------
%LTIDemo Controls
%----------------------------------------------------------------------------
%Changing the Input Sinusoid:
%
%  The Amplitude, Frequency, Phase, and DC Level of the input sinusoid can be 
%  changed with the sliders and edit boxes at the bottom left of the screen.
%  As the values are changed the graph of the input signal will change 
%  accordingly.
%
%Changing the Filter:
%
%  Using the drop-down box at the lower right of the screen, the user can 
%  pick from a preset list of filters.  The user can then change the
%  parameters of the filter using the other controls in the "Filter 
%  Specifications" box.  The parameters that the user is allowed to change 
%  will depend on the filter.
%
%  The filter's frequency response is displayed in the two central graphs.
%  The top central graph is the magnitude of the frequency response.  The 
%  bottom central graph is the phase of the frequency response.
%
%  The small round markers in the frequency response graphs indicate the 
%  filter's response to the input sinusoid of frequency f0.  By reading the 
%  value of these markers one obtains M and P, i.e., the magnitude and 
%  phase response of the filter to a sinusoid with frequency f0.  If the
%  DC Level of the input is nonzero, then another marker will appear
%  indicating D, the filter's DC response. 
%  
%Theoretical Answer Button:
%
%   When the Theoretical Answer button is pressed, the formula for the output
%   signal will appear above the output signal graph.  The formula for the 
%   output signal is initially hidden from the user to encourage the user to 
%   work the answer out for himself using the information contained within 
%   the other graphs.
%
%   We believe that when the user can correctly and consistently derive the
%   output formula without the aid of the Theoretical Answer button, then the 
%   user will have a true understanding of the theory this program is trying 
%   to illustrate.
%
%Reading Values from the Graphs (Matlab 5.2 or later):
%
%   By right-clicking on a value in a plot window, a small popup window will 
%   appear at the mouse location giving the exact x-y values of the plot.
%
%   This is especially useful to find the exact values of the filter's 
%   response to the input sinusoid represented by the two small round markers 
%   in the central frequency response plots.
%
%Changing the Line Width:
%
%   By clicking on the Set Line Width menu, the user can change the widths of 
%   all the graph lines.  This can be useful when using this program in a 
%   class lecture to make sure the lines are visible from the back of a 
%   lecture room.
