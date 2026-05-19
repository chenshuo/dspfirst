function s = formulastring(Signal)
%FORMULASTRING Gets the formula string for the EXPONENTIAL object.
%   s = FORMULASTRING(Signal) returns a formatted string which represents
%   the formula for the EXPONENTIAL object Signal.
%
%   See also EXPONENTIAL

% Jordan Rosenthal, 12/16/97

if Signal.ScalingFactor == 1
   A = '';
elseif Signal.ScalingFactor == -1
   A = '-';
else
   A = num2str(Signal.ScalingFactor);
end

if strcmp(lower(Signal.Causality), 'causal')
   CAUSAL = 1;
else
   CAUSAL = 0;
end
n = '\itn\rm';
u = '\itu\rm';
a = ['( ' num2str(Signal.ExpConstant) ' )'];
if Signal.Delay == 0
   if CAUSAL
      a = [ a '^{' n '}' ];
      FirstEdge = [ u '[' n ']' ];
      SecondEdge = [ u '[' n ' - ' num2str(Signal.Delay+Signal.Length) ']' ];
   else
      a = [ a '^{-' n '}' ];
      FirstEdge = [ u '[-' n ']' ];
      SecondEdge = [ u '[-' n ' - ' num2str(Signal.Length) ']' ];
   end
elseif Signal.Delay > 0
   if CAUSAL   
      a = [ a '^{( ' n ' - ' num2str(Signal.Delay) ' )}' ]; 
      FirstEdge = [ u '[' n ' - ' num2str(Signal.Delay) ']' ];
      SecondEdge = [ u '[' n ' - ' num2str(Signal.Delay+Signal.Length) ']' ];
   else
      a = [ a '^{( -' n ' + ' num2str(Signal.Delay) ' )}' ];
      FirstEdge = [ u '[-' n ' + ' num2str(Signal.Delay) ']' ];
      EndPoint = Signal.Delay - Signal.Length;
      if EndPoint == 0
         SecondEdge = [ u '[-' n ']' ];
      elseif EndPoint > 0
         SecondEdge = [ u '[-' n ' + ' num2str(EndPoint) ']' ];
      else 
         SecondEdge = [ u '[-' n ' - ' num2str(-EndPoint) ']' ];
      end
   end
elseif Signal.Delay < 0
   if CAUSAL
      a = [ a '^{( ' n ' + ' num2str(-Signal.Delay) ' )}' ]; 
      FirstEdge = [ u '[' n ' + ' num2str(-Signal.Delay)  ']' ];
      EndPoint = Signal.Delay + Signal.Length;
      if EndPoint == 0
         SecondEdge = [ u '[' n ']' ];
      elseif EndPoint > 0
         SecondEdge = [ u '[' n ' - ' num2str(EndPoint) ']' ];
      else
         SecondEdge = [u '[' n ' + ' num2str(-EndPoint) ']' ];
      end
   else
      a = [ a '^{( -' n ' - ' num2str(-Signal.Delay) ' )}' ]; 
      FirstEdge = [ u '[-' n ' - ' num2str(-Signal.Delay) ']' ];
      SecondEdge = [ u '[-' n ' - ' num2str(-Signal.Delay+Signal.Length) ']' ];
   end
end
u = [ '( ' FirstEdge ' - ' SecondEdge ' )' ];
s = [ A ' ' a ' ' u ];
