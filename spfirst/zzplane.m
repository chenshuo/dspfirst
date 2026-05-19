function  [hzero,hpole] = zplane(z, p, zmax)
%ZPLANE      plot zeros (o) and poles (x) in the z-plane
%
% Usage:   [hzero,hpole] = zplane( Zeros, Poles, RadiusMax )
%        Zeros : vector of zeros
%        Poles : vector of poles  (OPTIONAL)
%                 (can be [], if 3rd arg is needed)
%    RadiusMax : size of plot for scaling  (OPTIONAL)
%                 (disables auto scaling calculations)
%     hzero = handle to the zeros
%     hpole = handle to the poles
%

%  27-Oct-98 Jim McClellan

if( nargin == 1 )
   p = [];
end
rmax = max( [ abs(z(:)); abs(p(:)) ] );
rmin = min( [ abs(z(:)); abs(p(:))] );
if( rmax/rmin > 100 )
   disp('***** WARNING: DYNAMIC RANGE of ROOTS is > 100 *****' )
   disp('     ===> may need to replot to see them all <===' )
end
if( nargin < 3 )   %--- need to figure out the scaling
   zmax = 1.333;
   if( rmax > 50 )
      zmax = 10*ceil( ceil( rmax )/10 );
   elseif( rmax > 10 )
      zmax = 5*ceil( ceil( rmax )/5 );
   elseif( rmax > 1.333 )
      zmax = ceil( rmax );
   elseif( rmax < 0.09 )
      zmax = 10 .^ fix( log10(rmax) );
   end
elseif( rmax > zmax )
   disp('*** WARNING: some roots are too big to fit on plot ***')
end
plot( [-zmax;zmax],[0;0],':');
hold on
plot([0;0],[-zmax;zmax],':')
axis( zmax*[-1 1 -1 1])
axis('square')
%axis('equal')
if( zmax <= 20 )        %--- then put a UNIT CIRCLE on the plot
   plot( sin(0:.01:2*pi),cos(0:.01:2*pi),':' )
end
posx = get(gca,'position');
marksize = sqrt(posx(3))*13;
if ~isempty(z)
   hzero = plot(real(z),imag(z),'o');
   set(hzero,'MarkerSize',marksize)
   set(hzero,'linewidth',2)
end
if ~isempty(p)
   hpole = plot(real(p),imag(p),'x');
   set(hpole,'MarkerSize',marksize*1.2)
   set(hpole,'linewidth',2)
end
xlabel('REAL PART');ylabel('IMAGINARY PART')
hold off


