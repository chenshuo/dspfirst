function   inout(x, y, nstart, npts, nsect)
%INOUT    plot LONG input & output signals together
%-----      put them on alternate lines in a strip plot
%usage:
%   inout(xin, yout, nstart, npts, nsect)
%
%       xin = INPUT signal vector
%      yout = OUTPUT signal vector
%    nstart = STARTING sample number in both sigs
%      npts = number of points to plot PER LINE
%     nsect = number of in/out PAIRS of LINES
%                (for best results use nsect = 4) <====
%
% NOTE: the signals x[n] & y[n] are plotted over the index
%       range:  n = nstart -->  n = nstart + npts*nsect - 1
%
% see also STRIPLOT

if( nsect>8 )
   disp('>>WARNING(INOUT): are you sure you want NSECT this large?')
end
p = [ ];
x = x(:);   y = y(:);
L = max( length(x), length(y) );
for k=1:nsect
   n1 = nstart+(k-1)*npts;
   n2 = n1+npts-1;
   if( L<n2 )
     disp('>>WARNING(INOUT): trying to go past end of signal(s)')
     break
   end
   p = [p; x(n1:n2); y(n1:n2)];
end
striplot(p, 1, npts);
xlabel('SAMPLE INDEX  (n)')
