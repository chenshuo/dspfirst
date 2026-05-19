function hOut = plotvect(x,varargin);
% hV = PLOTVECT(x,C,origin);
% hV = PLOTVECT(x,C) uses origin = [0 0];
% hV = PLOTVECT(x) uses origin = [0 0], C = 'k'
% hV = PLOTVECT(x,...,'param','value')
% hV = PLOTVECT(h) with no arguments adjusts all vectors in the list h
% for the current axis limits (each patch object holds information
% in it's userdata property so it can do this.).  The patch 'tag' property
% is set to 'arrow' and must remain so for this to work.
%
% 'param' = {'basewidth','headlength','headwidth','headinset','scale'};
%          
% Should set the axis limits BEFORE drawing the vector
%
% If r = 0 and 'basewidth' is given, it plots a circular patch of diameter 
% 'basewidth'. If r = 0 and 'basewidth' is not given, the patch is not
% drawn, and hV is the empty matrix.
%
% Should use axis equal or else doesn't look right.
%
% One arrow at a time for now.
%
% NOTE: THIS FUNCTION IS NOT CONSIDERED A FINAL VERSION.  THE CURRENT 
% VERSION WORKS FOR ZDRILL-V2, BUT HAS NOT BEEN TESTED FOR OTHER PURPOSES.
%
% Jordan Rosenthal, 9-Sep-1999

%------------------------------------------------------------------------
% Parse Inputs
%------------------------------------------------------------------------
Params = [];
if isempty(varargin)
   if (length(x)~=2) | (length(x)==2 & all(ishandle(x)))
      adjustarrow(x);
      return;
   else
      C = 'k';
      origin = [0 0];
   end
else
   kParamStart = [];
   for i = 1:length(varargin)
      if isa(varargin{i},'char')
         switch lower(varargin{i})
         case {'basewidth','headlength','headwidth','headinset','scale'}
            kParamStart = i;
            break;
         end
      end
   end
   if ~isempty(kParamStart)
      Params = varargin(kParamStart:end);
      varargin = varargin(1:kParamStart-1);
   end
   switch length(varargin)
   case 0
      C      = 'k';
      origin = [0 0];
   case 1
      C      = varargin{1};
      origin = [0 0];
   otherwise
      C      = varargin{1};
      origin = varargin{2};
   end
end

if any(size(origin)~=size(x))
   error('Origin must be the same size as x.');
end

if ~isempty(Params)
   nArgs = length(Params);
   if rem(nArgs,2)==1, error('Parameters and values must come in pairs.'); end
   for i = 1:2:nArgs
      switch lower(Params{i})
      case 'basewidth',   basewidth  = Params{i+1};
      case 'headlength',  headlength = Params{i+1};
      case 'headwidth',   headwidth  = Params{i+1};
      case 'headinset',   headinset  = Params{i+1};
      case 'scale',       scale      = Params{i+1};
      otherwise
         error('Illegal parameter.');
      end
   end
end

r = norm(x);
if ~exist('basewidth','var')
   if r == 0
      if nargout > 0, hOut = []; end
      return;
   else
      basewidth  = 0.025*r;
   end
end
if ~exist('headlength','var')
   headlength = 0.1*r;
end
if ~exist('headwidth','var')
   headwidth  = 5*basewidth;
end
if ~exist('headinset','var')
   headinset  = 0.075*r;
end
if exist('scale','var')
   basewidth  = scale*basewidth;
   headwidth  = scale*headwidth;
   headlength = scale*headlength;
   headinset  = scale*headinset;
end

%------------------------------------------------------------------------
% Plot Vector
%------------------------------------------------------------------------
hAxis = newplot;
hV = plotarrow(x,C,origin,basewidth,headlength,headwidth,headinset);

if nargout > 0
   hOut = hV;
end


%------------------------------------------------------------------------
%------------------------------------------------------------------------
function hV = plotarrow(x,C,origin,basewidth,headlength,headwidth,headinset)
r = norm(x);
if r == 0
   [Arrow.x,Arrow.y] = pol2cart(linspace(0,2*pi,50),basewidth);
   hV = patch(Arrow.x,Arrow.y,C);
else
   theta = atan2(x(2),x(1))/pi*180;
   Arrow.x = [0 (r-headinset) (r-headlength) r (r-headlength) (r-headinset) 0] + origin(1);
   Arrow.y = [basewidth basewidth headwidth 0 -headwidth -basewidth -basewidth]/2 + origin(2);
   hV = patch(Arrow.x,Arrow.y,C,'edgecolor',C);
   rotate(hV,[0 0 1],theta,[origin(1) origin(2) 0]);
end
axLims = axis;
dataAspectRatio  = get(gca,'DataAspectRatio');
aspectRatio  = dataAspectRatio(2)/dataAspectRatio(1);
if aspectRatio < 1
   set(hV,'YData',(get(hV,'YData')-origin(2))*aspectRatio+origin(2));
else
   set(hV,'XData',(get(hV,'XData')-origin(1))/aspectRatio+origin(1));
end
axis(axLims);
set(hV,'UserData',{x,C,origin,basewidth,headlength,headwidth,headinset});

%------------------------------------------------------------------------
%------------------------------------------------------------------------
function hV = adjustarrow(h)
for i = 1:length(h)
   UserData = get(h(i),'UserData');
   plotarrow(UserData{:});
end
