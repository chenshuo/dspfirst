function s = formulastring(Signal,N)
%FORMULASTRING Gets the formula string for the PULSE object.
%   s = FORMULASTRING(Signal,N) returns a formatted string which represents
%   the formula for the CIMPULSE object Signal.  N is the number of digits
%   of precision in the NUM2STR call.  It defaults to N = 3.
%
%   See also CIMPULSE, NUM2STR

% Jordan Rosenthal, 05-Nov-1999
%             Rev., 26-Oct-2000

if nargin == 1, N = 3; end

TOL = 1e-6;
if abs(Signal.Area-1)<TOL
   sA = ' ';
elseif abs(Signal.Area+1)<TOL
   sA = '-';
else
   sA = [num2str(Signal.Area,N) ' '];
end
   
d = Signal.Delay * (abs(Signal.Delay)>TOL);
signd = char( '-' * (d>=0) + '+' * (d<0) );

arg = '(\itt\rm)';
dd = ['\delta' arg];

dd = strrep(dd,arg,['(\itt\rm ' signd ' ' num2str(abs(d),N) ')' ]);
dd = strrep(dd,'(\itt\rm - 0)',arg);

if abs(Signal.Area) < TOL
   s = '0';
else
   s = [ sA dd ];
end

