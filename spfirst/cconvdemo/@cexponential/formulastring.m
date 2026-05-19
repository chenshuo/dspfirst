function s = formulastring(Signal,N)
%FORMULASTRING Gets the formula string for the CEXPONENTIAL object.
%   s = FORMULASTRING(Signal) returns a formatted string which represents
%   the formula for the CEXPONENTIAL object Signal.  N is the number of digits
%   of precision in the NUM2STR call.  It defaults to N = 3.

%   See also CEXPONENTIAL, NUM2STR

% Jordan Rosenthal,  04-Nov-1999
%              Rev., 26-Oct-2000 Revised comments

if nargin == 1, N = 3; end

TOL = 1e-6;
if abs(Signal.ScalingFactor-1)<TOL
   sA = ' ';
elseif abs(Signal.ScalingFactor+1)<TOL
   sA = '-';
else
   sA = num2str(Signal.ScalingFactor,N);
end

if strcmp(lower(Signal.Causality), 'causal')
   
   d  = Signal.Delay * (abs(Signal.Delay)>TOL);
   l = (Signal.Delay+Signal.Length) * (abs(Signal.Delay+Signal.Length)>TOL);
   a = Signal.ExpConstant;
   signd = char( '-' * (d>=0) + '+' * (d<0) );
   signl = char( '-' * (l>=0) + '+' * (l<0) );
   signa = char( '-' * (a>=0) + '+' * (a<0) );
   signa = strrep(signa,'+','');
   
   t = '\itt\rm';
   arg = ['(' t ')'];
   u = ['\itu\rm' arg];
   e = [ 'e^{' signa num2str(abs(a),N) t '}'];
   
   e  = strrep(e,t,  ['(\itt\rm ' signd ' ' num2str(abs(d),N) ')' ]);
   u1 = strrep(u,arg,['(\itt\rm ' signd ' ' num2str(abs(d),N) ')' ]);
   u2 = strrep(u,arg,['(\itt\rm ' signl ' ' num2str(abs(l),N) ')' ]);
   e = strrep(e,'(\itt\rm - 0)',t);
   u1 = strrep(u1,'(\itt\rm - 0)',arg);
   u2 = strrep(u2,'(\itt\rm - 0)',arg);
   
else
   
   d  = -Signal.Delay * (abs(Signal.Delay)>TOL);
   l = (Signal.Delay-Signal.Length) * (abs(Signal.Delay-Signal.Length)>TOL);
      signd = char( '-' * (d>=0) + '+' * (d<0) );
   a = -Signal.ExpConstant;
   signl = char( '-' * (l>=0) + '+' * (l<0) );
   signa = char( '-' * (a>=0) + '+' * (a<0) );
   signa = strrep(signa,'+','');
   
   t = '\itt\rm';
   arg = ['(-' t ')'];
   u = ['\itu\rm' arg];
   e = [ 'e^{' signa num2str(abs(a),N) t '}'];
   
   e  = strrep(e,t,  ['(-\itt\rm ' signd ' ' num2str(abs(d),N) ')' ]);
   u1 = strrep(u,arg,['(-\itt\rm ' signd ' ' num2str(abs(d),N) ')' ]);
   u2 = strrep(u,arg,['(-\itt\rm ' signl ' ' num2str(abs(l),N) ')' ]);
   e = strrep(e,'(-\itt\rm - 0)',t);
   u1 = strrep(u1,'(-\itt\rm - 0)',arg);
   u2 = strrep(u2,'(-\itt\rm - 0)',arg);

end

if abs(Signal.ScalingFactor) < TOL
   s = '0';
else
   s = [ sA e ' [ ' u1 ' - ' u2 ' ]' ];
end