function s = formulastring(Signal)
%FORMULASTRING Gets the formula string for the SINUSOID object.
%   s = FORMULASTRING(Signal) returns a formatted string which represents
%   the formula for the SINUSOID object Signal.
%
%   See also SINUSOID

% Jordan Rosenthal, 12/16/97

if Signal.Amplitude == 1
   A = '';
elseif Signal.Amplitude == -1
   A = '-';
else
   A = [num2str(Signal.Amplitude) ' '];
end   
n = '\itn\rm';
if Signal.Delay > 0
   n = [n ' - ' num2str(Signal.Delay)];
elseif Signal.Delay < 0
   n = [n ' + ' num2str(-Signal.Delay)];
end
s = [A '\delta [ ' n ' ]'];