function s = formulastring(Signal,N)
%FORMULASTRING Gets the formula string for the CPULSE object.
%   s = FORMULASTRING(Signal,N) returns a formatted string which represents
%   the formula for the CPULSE object Signal.  N is the number of digits
%   of precision in the NUM2STR call.  It defaults to N = 3.
%
%   See also CPULSE, NUM2STR

% Jordan Rosenthal, 03-Nov-1999
%             Rev., 26-Oct-2000

if nargin == 1, N = 3; end

TOL = 1e-6;
if abs(Signal.Amplitude-1)<TOL
   sA = ' ';
elseif abs(Signal.Amplitude+1)<TOL
   sA = '-';
else
   sA = [num2str(Signal.Amplitude,N) ' *'];
end
   
d = Signal.Delay * (abs(Signal.Delay)>TOL);
w = (Signal.Delay+Signal.Width) * (abs(Signal.Delay+Signal.Width)>TOL);
signd = char( '-' * (d>=0) + '+' * (d<0) );
signw = char( '-' * (w>=0) + '+' * (w<0) );

arg = '(\itt\rm)';
u = ['\itu\rm' arg];

u1 = strrep(u,arg,['(\itt\rm ' signd ' ' num2str(abs(d),N) ')' ]);
u2 = strrep(u,arg,['(\itt\rm ' signw ' ' num2str(abs(w),N) ')' ]);
u1 = strrep(u1,'(\itt\rm - 0)',arg);
u2 = strrep(u2,'(\itt\rm - 0)',arg);

if abs(Signal.Amplitude) < TOL
   s = '0';
else
   s = [ sA ' [ ' u1 ' - ' u2 ' ]' ];
end

