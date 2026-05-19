function setaxislimits(h)
%SETAXISLIMITS Change the axis limits of the plots.
%   This should be called after any change to a plot.

% Jordan Rosenthal, 02/02/2000
% jr@ece.gatech.edu
%  Rev. Krudysz 11/25/2005 : problems with axes() in 7.1 (?)

set(gcbf,'currentAxes',h.Axis); %axes(h.Axis);
%---  Retrieve Guesses  ---%
A = str2num(get(h.Edit.Amplitude,'String'));
f0 = str2num(get(h.Edit.Frequency,'String'));

if get(h.Checkbox.ShowGuess,'Value') == 0
   axis([ h.t([1 end]) h.Amplitude*[-1 1] ] );
else
   % Old method:  YLimit = max( min(5*h.Amplitude,abs(A)), h.Amplitude );
   if abs(A) > h.Amplitude
      YLimit = 1.1*abs(A);
   elseif abs(A) == h.Amplitude & f0<h.Frequency/10
      YLimit = 1.1*h.Amplitude;
   else
      YLimit = h.Amplitude;
   end
   axis([ h.t([1 end]) YLimit*[-1 1] ] );
end
