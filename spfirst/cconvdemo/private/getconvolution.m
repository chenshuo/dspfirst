function [y,t] = getconvolution(sig1,sig2);
% [y,t] = GETCONVOLUTION(sig1,sig2)
% Numerical Convolution of two signal objects.  It returns data
% appropriate to create a line plot.  The convolution is actually only
% calculated over the range in tRange or the support of the signals
% whichever is smaller.

% Rev., 16-Mar-2001
% Rev., 8-Apr-03   JMc, increase rate during convolution only.

supp1 = support(sig1);
supp2 = support(sig2);
supp = supp1 + supp2;
fs = max(suggestrate(sig1,supp1),suggestrate(sig2,supp2));
rate_change = 2;        %-- JMc [8-Apr-03]
fs = rate_change*fs;    %-- JMc [8-Apr-03]
T = 1/fs;

if 1
   s1 = sig1(supp1(1):T:supp1(2));
   s2 = sig2(supp2(1):T:supp2(2));
   NConv = length(s1)+length(s2)-1;
   NFFT = 2^nextpow2(NConv);
   s1 = fft(s1,NFFT);
   s2 = fft(s2,NFFT);
   y = real(ifft(s1.*s2));
   y = T*y(1:NConv);
   t = supp(1):1/fs:supp(2);
   y = y(1:rate_change:end);    %-- JMc [8-Apr-03]
   t = t(1:rate_change:end);    %-- JMc [8-Apr-03]
 
   % Modified 16-Mar-2001
   %---------------------
   % This code has drawing problems:
   %
   %   t = [ t(1)-diff(supp)/2  t  t(end)+diff(supp)/2 ];
   %   y = [0 y 0];
   % 
   % For example, try the convolution of two exponentials
   % The replacement code below fixes it.
   tstart = t(1)   - diff(supp)/2;
   tend   = t(end) + diff(supp)/2;
   t = [ tstart t(1) t t(end) tend ];
   y = [0 0 y 0 0];

end

% Integration Method
if 0
   supp = support(sig1) + support(sig2);
   if (supp(1)>tRange(2)) | (supp(2)<tRange(1))
      t = tRange;
      y = [0 0];
      return;
   elseif (supp(1)<tRange(1)) & (supp(2)>tRange(2))
      t = tRange(1):1/fs:tRange(2)-1/fs;
      [tt,tau] = meshgrid(t);
      y = trapz(sig1(tau).*sig2(tt-tau)) * T;
   elseif supp(1)>tRange(1) & supp(2)<tRange(2)
      t = supp(1):1/fs:supp(2)-1/fs;
      [tt,tau] = meshgrid(t);
      y = trapz(sig1(tau).*sig2(tt-tau)) * T;
      t = [tRange(1) t(1) t t(end) tRange(2)];
      y = [0 0 y 0 0];
   elseif supp(1)<tRange(1)
      t = tRange(1):1/fs:supp(2)-1/fs;
      [tt,tau] = meshgrid(t);
      y = trapz(sig1(tau).*sig2(tt-tau)) * T;
      t = [t t(end) tRange(2)];
      y = [y 0 0];
   else
      t = supp(1):1/fs:tRange(2)-1/fs;
      [tt,tau] = meshgrid(t);
      y = trapz(sig1(tau).*sig2(tt-tau)) * T;
      t = [tRange(1) t(1) t];
      y = [0 0 y];
   end
end