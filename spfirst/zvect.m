function hv = zvect(zFrom, zTo, arg3, arg4)
%ZVECT   Plot vectors in complex z-plane from zFrom to zTo
%
% common usage:  zvect(Z) 
%     displays each element of Z as an arrow emanating from the origin.
%
% usage:   HV = zvect(zFrom, <zTo>, <LTYPE>, <SCALE>)
%
%    zFrom:  is a vector of complex numbers; each one will be
%              the starting location of an arrow.
%      zTo:  is a vector of complex numbers; each one will be
%              the ending point of an arrow starting at zFrom.
%     LTYPE: string containing any valid line type (see PLOT)            
%     SCALE: controls size of arrowhead (default = 1.0)
%               (order of LTYPE and SCALE args doesn't matter)
%        HV: output handle from graphics of vector plot
%
%    ** If either zFrom or zTo is a scalar all vectors will
%          start or end at that point.
%
%	See also ZCAT, PLOT, COMPASS, ROSE, FEATHER, QUIVER.

% based on the MATLAB toolbox function COMPASS

zFrom = zFrom(:).';
scale = 1.0;
vv = version;
if( vv(1)>='5')
	linetype = 'b-';
else
	linetype = 'w:-'; %<--- WHITE is NOT good in v5 
end
if( nargin==1 )
   zTo = zFrom;  zFrom = 0*zTo;
elseif( nargin == 2 )
   if( isstr(zTo) )
      linetype = zTo;  zTo = zFrom;  zFrom = 0*zTo;
   elseif( isempty(zTo) )
      zTo = zFrom;  zFrom = 0*zTo;
   elseif( length(zTo)==1 )
      zTo = zTo*ones(size(zFrom));
   end
elseif( nargin==3 )
   if( isstr(arg3) ),  linetype = arg3;
   else,               scale = arg3;
   end
elseif( nargin == 4 )
   if( isstr(arg3) ),  linetype = arg3; scale = arg4;
   else,               scale = arg3; linetype = arg4;
   end
end
zTo = zTo(:).';
jkl = find( ~isnan(zTo-zFrom) );
if( length(jkl)==0 ),  error('cannot plot NaNs'),  end
zTo = zTo(jkl);
zFrom = zFrom(jkl);
if( length(zFrom)==1 )
    zFrom = zFrom*ones(size(zTo));
elseif( length(zTo)==1 )
    zTo = zTo*ones(size(zFrom));
end
if length(zFrom) ~= length(zTo)
   error('ZVECT: zFrom and zTo must be same length.');
end

tt = [zFrom,zTo];
[zmx,jkl] = max(abs(tt));
figsize =  max(abs(tt-tt(jkl)));

arrow = scale*([-1; 0; -1] + sqrt(-1)*[1/4; 0; -1/4]);
dz = zTo - zFrom;
dzm = abs(dz);
zmax = max(dzm);
zscale = mean([zmax,figsize]);
scz = 0.11 + 0.77*(dzm/zscale - 1).^6;
tt = [ ones(3,1)*(zTo) + arrow*(scz.*dz) ];

   next = lower(get(gca,'NextPlot'));   %--Ver 4.1
   isholdon = ishold;                   %--Ver 4.1
h = plot(real([zFrom;zTo]), imag([zFrom;zTo]), linetype,...
         real(tt), imag(tt), linetype );
num_zzz = length(zFrom);
for  kk = 1:num_zzz
   kolor = get(h(kk),'color');
   set(h(kk+num_zzz), 'color',kolor);
end
   axis('equal');                       %--Ver 4.1
   if ~isholdon;                        %--Ver 4.1
      set(gca,'NextPlot',next);         %--Ver 4.1
   end;                                 %--Ver 4.1
if nargout > 0
   hv = h;
end
