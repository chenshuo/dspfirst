function s = formulastring(Signal)
%FORMULASTRING Gets the formula string for the CCOSINE object.
%   s = FORMULASTRING(Signal) returns a formatted string which represents
%   the formula for the CCOSINE object Signal.
%
%   See also CCOSINE

% Jordan Rosenthal, 4/6/98
%             Rev., 26-Oct-2000 : Revised comments

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
t = '\itt\rm';
if Signal.Delay > 0
   t = [' ( ' t ' - ' num2str(Signal.Delay) ' )'];
elseif Signal.Delay < 0
   t = [' ( ' t ' + ' num2str(-Signal.Delay) ' )'];
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
w = cpulse('Width',Signal.Length,'Delay',Signal.Delay);
s = {[A 'cos ( ' w0 t Phase ' ) \itw\rm(' t ')'] , ...
      ['\itw\rm(' t ') = ' formulastring(w)]};
