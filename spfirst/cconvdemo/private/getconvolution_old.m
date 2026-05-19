function [y,t] = getconvolution(s,h,tRange)

% Make the signal with the smaller support h
supps = support(s);
supph = support(h);
if diff(supps) < diff(supph)
   temp = s;
   h = s;
   s = temp;
   temp  = supph;
   supph = supps;
   supps = temp;
end

if isa(s,'pulse') & isa(h,'pulse')
   %------------------------------------------------------------------
   % Pulse/Pulse
   %------------------------------------------------------------------
   
   A = s.Amplitude;
   B = h.Amplitude;
   [a,b] = deal(supps(1),supps(2));
   [c,d] = deal(supph(1),supph(2));
   
   supp = supps + supph;
   if (supp(1)>tRange(2)) | (supp(2)<tRange(1))
      t = tRange;
      y = [0 0];
      return;
   elseif (supp(1)<tRange(1)) & (supp(2)>tRange(2))
      t = linspace(tRange(1),tRange(2),100);
   elseif supp(1)>tRange(1) & supp(2)<tRange(2)
      t = linspace(supp(1),supp(2),100);
   elseif supp(1)<tRange(1)
      t = linspace(tRange(1),supp(2),100);
   else
      t = linspace(supp(1),tRange(2),100);
   end
   
   y =    0         .* (t-c<=a) + ...
      A*B*(t-c-a)   .* (t-c>a & t-d<a) + ...
      A*B*(d-c)     .* (t-c<=b & t-d>=a) + ...
      A*B*(b-(t-d)) .* (t-c>b & t-d<b) + ...
      0         .* (t-d>=b);
   
      
elseif isa(s,'exponential') & isa(h,'exponential')
   %------------------------------------------------------------------
   % Exponential/Exponential
   %------------------------------------------------------------------
   
   A = s.ScalingFactor;
   B = h.ScalingFactor;
   aa = s.ExpConstant;
   bb = h.ExpConstant;
   
   [a,b] = deal(supps(1),supps(2));
   [c,d] = deal(supph(1),supph(2));
   
   fs = max(suggestrate(s,tRange),suggestrate(h,tRange));
   
   supp = supps + supph;
   if (supp(1)>tRange(2)) | (supp(2)<tRange(1))
      t = tRange;
      y = [0 0];
      return;
   elseif (supp(1)<tRange(1)) & (supp(2)>tRange(2))
      t = tRange(1):1/fs:tRange(2);
   elseif supp(1)>tRange(1) & supp(2)<tRange(2)
      t = supp(1):1/fs:supp(2);
   elseif supp(1)<tRange(1)
      t = tRange(1):1/fs:supp(2);
   else
      t = supp(1):1/fs:tRange(2);
   end
   
   y = 0 + (t-c<=a)          .* 0;
   y = y + (t-c>a & t-d<a)   .* intExpExp(A,B,aa,bb,a,(t-c),t);
   y = y + (t-c<=b & t-d>=a) .* intExpExp(A,B,aa,bb,(t-d),(t-c),t);
   y = y + (t-c>b & t-d<b)   .* intExpExp(A,B,aa,bb,(t-d),b,t);
   y = y + (t-d>=b)          .* 0;
   
else
   error('Convolution not implemented.');
end

function f = intExpExp(A,B,a,b,x,y,t);
% A = Scaling Factor 1, B = Scaling Factor 2
% a = ExpConstant 1, b = ExpConstant 2
% x = lower integral limit, y = higher integral limit
% t = vector of times
if a==b
   f = A*B*exp(-a.*t).*(y-x);
else
   f = A*B*exp(-b.*t)./(b-a) .* ( exp((b-a).*y) - exp((b-a).*x) );
end

function f = intExpPulse(A,B,b,x,y,t);
% A = Pulse Amplitude
% B = Exponential Scaling Factor, b = Exponential Constant
% x = lower integral limit, y = higher integral limit
% t = vector of times
if a==b
   f = A*B*exp(-a.*t).*(y-x);
else
   f = A*B*exp(-b.*t)./(b-a) .* ( exp((b-a).*y) - exp((b-a).*x) );
end

