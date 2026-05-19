function huc = ucplot( radius, center, arg3 )
%UCPLOT   Plot a circle with specified center and radius
% usage:
%    huc = ucplot( radius, center, linetype )
%      radius: (default = 1)
%      center: complex number (x+j*y) (default = 0)
%    linetype: any valid MATLAB type (see help plot)
%         huc: handle to plot of the circle
%
%	See also ZVECT
vv = version;
if( vv(1)>='5')
	linetype = 'b:';
else
	linetype = 'w:';
end
rad = 1.0;  cent = 0;
if( nargin == 1 )
   if( isstr(radius) ), linetype = radius;
   else,                rad = radius;
   end
elseif( nargin == 2 )
   rad = radius;
   if( isstr(center) ), linetype = center;
   else,                cent = center;
   end
elseif( nargin == 3 )
   rad = radius;  cent = center;  linetype = arg3;
end

ucircle = rad*exp(sqrt(-1)*linspace(0,2*pi,100)) + cent;

   next = lower(get(gca,'NextPlot'));
   isholdon = ishold;
u = plot(real(ucircle), imag(ucircle), linetype); hold on
axis('equal')
   if ~isholdon
      set(gca,'NextPlot',next);
   end
if nargout > 0
   huc = u;
end
