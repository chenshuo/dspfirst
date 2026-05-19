function hv = zcat(z, arg2, arg3)
%ZCAT   Plot vectors in z-plane end-to-end
%
% usage:    hv = zcat(Z, <LTYPE>, <SCALE>)
%
%     Z = vector of complex numbers; each complex # is displayed
%           as a vector, with the arrows placed end-to-end
%    LTYPE: string containing any valid line type (see PLOT)            
%    SCALE: varies size of arrowhead (default = 1.0)
%           (order of LTYPE and SCALE args doesn't matter)
%       hv: output handle from graphics of vector plot
%
%	See also ZVECT, COMPASS, ROSE, FEATHER, QUIVER.

% based on the MATLAB toolbox function COMPASS

vv = version;
if( vv(1)>='5')
	linetype = 'b-';
else
	linetype = 'w-';  %<-- WHITE is NOT a good default in v5
end
z = z(:).';
scale = 1.0;
if( nargin==2 )
   if( isstr(arg2) ),  linetype = arg2;
   else,               scale = arg2;
   end
elseif( nargin == 3 )
   if( isstr(arg3) ),  linetype = arg2; scale = arg3;
   else,               scale = arg2; linetype = arg3;
   end
end

z2 = cumsum(z);
L = length(z2);
z1 = [0, z2(1:L-1)];

  next = lower(get(gca,'NextPlot'));
  isholdon = ishold;
h = zvect( z1, z2, linetype, scale );
  axis('equal')
  if ~isholdon
     set(gca,'NextPlot',next);
  end
if nargout > 0
   hv = h;
end
