function hout = mystem(x,y,parent,color)
%MYSTEM Custom stem plot
%   h = MYSTEM(x,y,parent,color) makes a stem plot of the x and y
%   data in the axes given by parent and in the given color.
%
%   See also STEM

% Jordan Rosenthal, 03/26/2000

ver = version;
if str2num(ver(1:3)) < 8
  error(nargchk(3,4,nargin)); %-- Error check number of input arguments
else
  narginchk(3,4);
end

h = get(gcbf, 'UserData');
DEFAULTCOLOR = 'b';
x = x(:);
y = y(:);
Nx = length(x);
Ny = length(y);
if Nx ~= Ny, error('x and y must be the same length'), end
if nargin == 3, color = DEFAULTCOLOR;, end
xx = zeros( 3*Nx, 1);
yy = zeros( 3*Ny, 1);
xx(1:3:end) = x;
xx(2:3:end) = x;
xx(3:3:end) = nan;
yy(2:3:end) = y;
yy(3:3:end) = nan;
nextpl = lower( get(parent,'NextPlot') );
hold_state = ishold;
h1 = plot(x,y,'o','parent',parent,'color',color,'MarkerFaceColor',color);
set(parent, 'NextPlot', 'add');
h2 = plot(xx,yy,'-','parent',parent,'color',color);
hout = [h1;h2];
set(hout, 'LineWidth', h.State.LineWidth);
if ~hold_state, set(parent, 'NextPlot', nextpl);, end

