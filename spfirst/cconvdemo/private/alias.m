function y = alias(x,L,nStart);
%ALIAS Alias the vector x
%   y = ALIAS(x,L,nStart) aliases the vector x using sections of length L.
%   nStart denotes the index of the first element in the vector x.  If omitted
%   the vector is assumed to start at the origin.
%
%   This function implements:
%
%     y[n] = x[n] + x[n-L] + x[n+L] + x[n-2L] + ...     for n = 0,...,L-1
%          = 0                                          else
%
%   and returns the nonzero portion in the vector y

% Jordan Rosenthal, 5/4/98

if nargin < 2, error('Not enough input arguements.'); end

D = size(x);
if (length(D) ~= 2) | all( D ~= 1)
   error('x must be a a vector.');
elseif fix(L)~=L | L < 1
   error('L must be a positive integer.');
end
if nargin == 2
   nStart = 0;
elseif fix(nStart)~=nStart
   error('nStart must be an integer.');
end

if D(1) == 1
   ISROW = 1;
   x = x(:);
else
   ISROW = 0;
end
nend = nStart + length(x) - 1;

nFillLow = mod(nStart,L);
nFillHigh = L - mod(nend,L) - 1;
y = [zeros(nFillLow,1); x; zeros(nFillHigh,1)];
y = reshape(y,L,length(y)/L);
y = sum(y,2);

if ISROW
   y = y.';
end