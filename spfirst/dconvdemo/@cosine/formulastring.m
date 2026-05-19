function s = formulastring(Signal)
%FORMULASTRING Gets the formula string for the COSINE object.
%   s = FORMULASTRING(Signal) returns a formatted string which represents
%   the formula for the COSINE object Signal.
%
%   See also COSINE

% Jordan Rosenthal, 4/6/98

if Signal.Amplitude == 1
   A = '';
elseif Signal.Amplitude == -1
   A = '-';
else
   A = [num2str(Signal.Amplitude) ' '];
end
w0 = 2/Signal.Period;
if w0 == 1
   w0 = '\pi';
elseif w0 == -1
   w0 = '-\pi';
else
   w0 = [num2str(w0) '\pi'];
end
n = '\itn\rm';
if Signal.Delay > 0
   n = [' ( ' n ' - ' num2str(Signal.Delay) ' )'];
elseif Signal.Delay < 0
   n = [' ( ' n ' + ' num2str(-Signal.Delay) ' )'];
end
Phase = Signal.Phase/pi;
if Phase == 0
   Phase = '';
elseif Phase == 1
   Phase = ' + \pi';
elseif Phase == -1
   Phase = ' - \pi';
elseif Phase > 0
   Phase = [' + ' num2str(Phase) '\pi'];
else
   Phase = [' - ' num2str(-Phase) '\pi'];
end
w = pulse('Length',Signal.Length,'Delay',Signal.Delay);
% The following changes the font size of the window function line
% Unfortunately you must do this in points since the TeX interpreter does
% not seem to be able to use the default font units (normalized) as the
% manual implies.
set(get(gca,'title'),'fontunits','points');
FontSize = get(get(gca,'title'),'FontSize')-1;
set(get(gca,'title'),'fontunits','normalized');
s = {[A 'cos ( ' w0 n Phase ' ) w[n]'] , ...
      ['\fontsize{' num2str(FontSize) '}\itw[n] = ' formulastring(w)]};
