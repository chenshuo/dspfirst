function s = zpolystr(x,p,sFORMAT)
%POLYSTR Create a string representation of a polynomial.
%   s = POLYSTR(x,p) takes the vector of coefficients x and the
%   power p of its first element and returns the string
%   representation of the associated polynomial.  The string
%   is formatted so it will display well with Matlab's TeX
%   interpreter.
%
%   It is assumed that the coefficients are listed in
%   descending powers as is customary in the signal processing
%   community.
%
%   s = POLYSTR(x) uses p = 0.
%   s = POLYSTR(x,p,FORMAT) uses the format string FORMAT for the
%   coefficients (see SPRINTF for details).  The default is to
%   use FORMAT = '%0.3g'
%
%
%   See also SPRINTF

% Jordan Rosenthal, 10/27/99

ver = version;
if str2num(ver(1:3)) < 8
    error(nargchk(1,3,nargin));  %-- Error check number of input arguments
else
    narginchk(1,3);
end

if nargin < 3, sFORMAT = '%0.3g'; end
if nargin < 2, p = 0; end

L = length(x);

TOL = 1e-6;
x(abs(x)<TOL) = 0;               % Set all really small elements to zero

signx = repmat('+',1,L);         % Create a vector holding the string
signx(x<0) = '-';                % representation of the sign of x

nz = find(x);                    % Indices of the nonzero elements
c = cell(3,length(nz));
c(1,:) = num2cell(signx(nz));
c(2,:) = num2cell(abs(x(nz)));
c(3,:) = num2cell(-nz+1+p);
s = sprintf([' %c ' sFORMAT 'z^{%d}'],c{:});

s = s(4:end);                    % Remove the first sign operator
s = strrep(s,'z^{0}','');        % Remove the z^{0} term
s = strrep(s,'z^{1}','z');       % Replace z^1 with z
s = strrep(s,'1z','z');          % Replace 1z with z


