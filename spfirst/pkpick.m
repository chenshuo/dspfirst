function  [peaks, locs] = pkpick( x, thresh, number )
%PKPICKER      pick out the peaks in a vector
%   Usage:  [peaks,locs] = pkpick( x, thresh, number )
%         peaks   :  peak values
%         locs    :  location of peaks (index within a column)
%         x       :  input data  (if complex, operate on mag)
%         thresh  :  reject peaks below this level
%         number  :  max number of peaks to return
%
%   see also PKINTERP

if nargin == 1
   thresh = -inf;   number = -1;
elseif nargin == 2
   number = -1;
end

[M,N] = size(x);
if M==1
   x = x(:);     %-- make it a single column
   [M,N] = size(x);
end
if any(imag(x(:))~=0)
   x = abs(x);       %---- complex data, so work with magnitude
end
for kk = 1:N
  mask = diff( sign( diff( [x(1,N)-1;  x(:,N); x(M,N)-1] ) ) );
  jkl = find( mask < 0 & x >= thresh);
  if (number>0 & length(jkl)>number)
     [tt,ii] = sort(-x(jkl));
     jkl = jkl(ii(1:number));
     jkl = sort(jkl);      %-- sort by index
  end
  L = length(jkl);
  peaks(1:L,kk) = x(jkl);
  locs(1:L,kk)  = jkl;
end
