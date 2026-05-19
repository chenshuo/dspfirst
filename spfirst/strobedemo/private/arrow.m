function arrow_handles = arrow(theta,type,arrow_length,arrow_span,tail_x,tail_y,fraction,color)
% Construct and draw an arrow object.
%
% ARROW(THETA) displays arrow with angle THETA in radians
%
% ARROW(THETA,TYPE) displays arrow tip either as a 'line' 
%   or as a 'patch'
%
% ARROW(THETA,TYPE,LENGTH,SPAN) displays arrow tip according
%   to specified ARROW_LENGTH and ARROW_SPAN; these are specified 
%   as a ratio of the stem of the arrow.  The arrow is drawn from
%   the orgin to the unit circle by default.
%
% ARROW(THETA,TYPE,LENGTH,SPAN,TAILX,TAILY,FRACTION,COLOR) draws arrow from TAILX and TAILY
% location instead from the orgin (default), FRACTION of the stem is a
% multiple of the length of the stem (default = 1),COLOR specifies line
% color property.
%
% H = ARROW(THETA, ...) returns arrow handles

% Author(s): Greg Krudysz, May 5, 2005

axis([-1 1 -1 1]);
switch nargin
    case 0
        theta = 0;
        type = 'line';
        arrow_length = 0.1; arrow_span = 0.05;
    case 1
        type = 'line';
        arrow_length = 0.1; arrow_span = 0.05;
    case 2
        arrow_length = 0.1; arrow_span = 0.05;
    case 3
        arrow_span = 0.05;
end

if nargin < 5
    tail_x = 0; 
    tail_y = 0;
    fraction = 1;
end
if nargin < 8
    color = 'b';
end

% Construct Stem Line
tipx = fraction*cos(theta) + tail_x;
tipy = fraction*sin(theta) + tail_y;
h.line1 = line([tail_x tipx],[tail_y tipy],'color',color);

% Find arrow points
a = sqrt( (1-arrow_length)^2 + (arrow_span)^2 );
sig = atan(arrow_span/(1-arrow_length));

x1 = fraction*a*cos(theta-sig) + tail_x;
y1 = fraction*a*sin(theta-sig) + tail_y;
x2 = fraction*a*cos(theta+sig) + tail_x;
y2 = fraction*a*sin(theta+sig) + tail_y;

if strcmp(type,'line')
    h.line2 = line([x1 tipx],[y1 tipy],'color',color); 
    h.line3 = line([x2 tipx],[y2 tipy],'color',color); 
    %h.line4 = line([x1 x2],[y1 y2]);
    arrow_handles = [h.line1,h.line2,h.line3];
else
    h.patch = patch([x1 x2 tipx],[y1 y2 tipy],color);
    arrow_handles = [h.line1,h.patch];
end