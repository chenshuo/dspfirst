function s = formulastring(Signal)
%FORMULASTRING Gets the formula string for the PULSE object.
%   s = FORMULASTRING(Signal) returns a formatted string which represents
%   the formula for the PULSE object Signal.
%
%   See also PULSE

% Jordan Rosenthal, 12/16/97

n = '\itn\rm';
u = '\itu\rm';
if Signal.Delay == 0
   FirstEdge = [ u '[' n ']' ];
   SecondEdge = [ u '[' n ' - ' num2str(Signal.Delay+Signal.Length) ']' ];
elseif Signal.Delay > 0
   FirstEdge = [ u '[' n ' - ' num2str(Signal.Delay) ']'];
   SecondEdge = [ u '[' n ' - ' num2str(Signal.Delay+Signal.Length) ']' ];
elseif Signal.Delay < 0
   FirstEdge = [ u '[' n ' + ' num2str(-Signal.Delay) ']' ];
   EndPoint = Signal.Delay + Signal.Length;
   if EndPoint == 0
      SecondEdge = [ u '[' n ']' ];
   elseif EndPoint > 0
      SecondEdge = [ u '[' n ' - ' num2str(EndPoint) ']'];
   elseif EndPoint < 0
      SecondEdge = [ u '[' n ' + ' num2str(-EndPoint) ']'];
   end
end

if Signal.Amplitude == 1
   s = [ FirstEdge ' - ' SecondEdge ];
elseif Signal.Amplitude == -1
   s = [ '-( ' FirstEdge ' - ' SecondEdge ' )' ];
else
   A = num2str(Signal.Amplitude);
   s = [ A ' ( ' FirstEdge ' - ' SecondEdge ' )' ];
end


