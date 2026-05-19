function  [peaks,pos] = pkinterp( x, locs )
%PKINTERP     interpolate to refine a peak position 
%
%   usage:  [peaks,pos] = pkinterp( x, locs )
%
%         peaks    =  peak values
%         pos      =  location of peaks (between samples)
%         x        =  input data  (if complex, operate on mag)
%         locs     =  location of peaks (from PKPICK)
%                      if this arg not present, call pkpick
%
%   see also PKPICK

if nargin == 1
   [tt, locs] = pkpick( x );
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
  ii = find( locs(:,kk)==1 );
  if ~isempty(ii)
     pos(ii,kk) = 1;  peaks(ii,kk) = x(ii,kk); end
  ii = find( locs(:,kk)==M );
  if ~isempty(ii)
     pos(ii,kk) = M;  peaks(ii,kk) = x(ii,kk); end
  ii = find( locs(:,kk)~=1 & locs(:,kk)~=M );
  jj = locs( ii, kk );
  alfa = -x(jj,kk) + 0.5*x(jj-1,kk) + 0.5*x(jj+1,kk);
  if any(alfa>0)
     error('PKINTERP: trying to fit a valley (alfa>0)' );
  end
  beta = 0.5*(x(jj+1,kk) - x(jj-1,kk));
  pos(ii,kk) = jj - 0.5*beta./(alfa+(alfa==0)).*(alfa<0);
  peaks(ii,kk) = x(jj,kk) - 0.25*beta.*beta./alfa;
end
