function [x,y] = linedata(sig,tRange)
%  [XData,YData] = LINEDATA(sig,[a b]) 

a = tRange(1);
b = tRange(2);
A  = sig.ScalingFactor;
aa = sig.ExpConstant;
supp = support(sig);
[t1,t2] = deal(supp(1),supp(2));
fs = suggestrate(sig,supp);
t = t1:1/fs:t2;

switch lower(sig.Causality)
case 'causal'
   f = inline('A*exp(-aa*t)','A','aa','t');
otherwise
   f = inline('A*exp(aa*t)','A','aa','t');
end

if all([t1 t2] < a) | all([t1 t2] > b)
   x = [a b];
   y = [0 0];
elseif all(a < [t1 t2]) & all([t1 t2] < b)
   x = [a t1 t t2 b];
   y = [0  0  feval(f,A,aa,t)  0 0];
elseif (t1 < a) & (t2 > b)
   x = t;
   y = feval(f,A,aa,t);
elseif (t1 < a)
   % t2 < b
   [m,ka]  = min(abs(t-a));
   [m,kt2] = min(abs(t-t2));
   x = [t(ka:kt2)         t2 b];
   y = [feval(f,A,aa,t(ka:kt2)) 0 0];
else
   % t1 > a  &  t2 > b
   [m,kt1] = min(abs(t-t1));
   [m,kb]  = min(abs(t-b));
   x = [a t1 t(kt1:kb)];
   y = [ 0 0  feval(f,A,aa,t(kt1:kb))];
end

