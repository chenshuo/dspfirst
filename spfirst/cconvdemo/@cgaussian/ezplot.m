function hOut = ezplot(sig,varargin)
%EZPLOT Overloaded EZPLOT command.
%   EZPLOT(sig) plots the expression f = f(x) over the default
%   domain supp(1) - 0.5*diff(supp) <= x <= supp(2) + 0.5*diff(supp)
%   where supp = SUPPORT(sig).
%
%   EZPLOT(sig,[a,b]) plots f = f(x) over a<= x <= b.
%
%   h = EZPLOT(...) returns the handle to the line object.
%
%   The arguments can be followed by parameter/value pairs which
%   get applied to the line object.
%
%   See also SUPPORT

% Jordan Rosenthal, 11/04/99
%             Rev., 26-Oct-2000 : Changed sig(t) to feval(sig,t) to make
%                               : function work inside class directory.
% Rajbabu Velmurugan, 15-Feb-2004: Adapted from 'ezplot' for exponential signal

YES = 1; NO = 0;

supp = support(sig);
   
if nargin == 1
  a = supp(1) - 0.5*diff(supp);
  b = supp(2) + 0.5*diff(supp);
else
  if ~isa(varargin{1},'char')
    a = varargin{1}(1);
    b = varargin{1}(2);
    if length(varargin)>1
      varargin = varargin(2:end);
    else
         varargin = {};
    end
  else
    a = supp(1) - 0.5*diff(supp);
    b = supp(2) + 0.5*diff(supp);
  end
end

fs = suggestrate(sig,[a b]);
if (supp(1)>b) | (supp(2)<a)
  t = [a b];
  y = [0 0];
elseif (supp(1)<a) & (supp(2)>b)
  t = a:1/fs:b;
  y = feval(sig,t);
elseif supp(1)>a & supp(2)<b
  t = supp(1):1/fs:supp(2);
  y = feval(sig,t);
  t = [a t(1) t t(end) b];
  y = [0 0 y 0 0];
elseif supp(1)<a
  t = a:1/fs:supp(2);
  y = feval(sig,t);
  t = [t t(end) b];
  y = [y 0 0];
else
  t = supp(1):1/fs:b;
  y = feval(sig,t);
  t = [a t(1) t];
  y = [0 0 y];
end

h = plot(t,y,varargin{:});

if nargout > 0, hOut = h; end
