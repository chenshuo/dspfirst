function hOut = ezplot(sig,varargin)
%EXPONENTIAL/EZPLOT Overloaded EZPLOT command.
%   EZPLOT(sig) plots the expression f = f(x) over the default
%   domain supp - 10 <= x <= supp + 10 where supp = SUPPORT(sig).
%
%   EZPLOT(sig,[a,b]) plots f = f(x) over a<= x <= b.
%
%   h = EZPLOT(...) returns a 2x1 vector with the handle to the 
%   patch and text objects.
%
%   The arguments can be followed by parameter/value pairs which
%   get applied to the patch object.
%
%   Note: The x-axis limits should equal the range that the signal
%   is plotted over for the plot to look correct.  For example,
%
%       ezplot(cimpulse,[-15 20]);
%       set(gca,'XLim',[-15 20]);
%
%   See also SUPPORT

% Jordan Rosenthal, 06-Nov-1999
%             Rev., 26-Oct-2000 Revised comments

YES = 1; NO = 0;

hAxis = newplot;

supp = support(sig);
if nargin == 1
   a = supp - 10;
   b = supp + 10;
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
      a = supp - 10;
      b = supp + 10;
   end
end

r = sig.PlotHeight;
basewidth  = 0.025 * r;
headinset  = 0.075 * r;
headlength = 0.1 * r;
headwidth  = 5 * basewidth;
scale      = 0.75 * sig.PlotScale;

bw = scale*basewidth;
hi = scale*headinset;
hl = scale*headlength;
hw = scale*headwidth;

if r == 0
   XLims = get(gca,'XLim');
   YLims = get(gca,'YLim');
   [Arrow.x,Arrow.y] = pol2cart(linspace(0,2*pi,50),diff(XLims)/100);
   Arrow.x = Arrow.x + sig.Delay;
   Arrow.y = Arrow.y*diff(YLims)/diff(XLims);
   hV = fill(Arrow.x,Arrow.y,'g',varargin{:});
   hText = text(sig.Delay+0.75*hw,0,'');
else
   aspRatio = r/diff([a b]);
   bw = bw/aspRatio;
   hw = hw/aspRatio;
   Arrow.x = [bw bw hw 0 -hw -bw -bw]/2 + sig.Delay;
   Arrow.y = [0 (r-hi) (r-hl) r (r-hl) (r-hi) 0];
   hV = patch(Arrow.x,Arrow.y,'g','edgecolor','k',varargin{:});
   if r > 0
      VertAlign = 'top';
   else
      VertAlign = 'bottom';
   end
   hText = text(sig.Delay+0.75*hw,r,['(' num2str(sig.Area,2) ')'], ...
      'color','r','vert',VertAlign, ...
      'fontname','helvetica','fontunits','normalized','fontsize', 0.05);
end

if nargout > 0, hOut = [hV; hText]; end
