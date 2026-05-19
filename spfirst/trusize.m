function trusize(fignum)
%TRUSIZE   Display image pixel-for-pixel on the screen
%  usage   trusize(fignum)
%     operates on figure number fignum.  If fignum is
%     missing or is equal to zero, then use current figure.
%   Works by re-sizing the figure window based on the currently
%   active sub-plot that is assumed to contain an image.
%   Maps each image pixel to one true screen pixel.
%   Assumes that all images in the figure window are the same size.
%
%   Based on image processing toolbox function called TRUESIZE
%   See also AXIS IMAGE.

% Jim McClellan, 27-Oct-97   for DSP First and SP First
%
% edited, <msv:gte631d> 02/14/2004
%   Accomodates color images now (Ref: Line 35)
%----

if  nargin<1, fignum = gcf;  end
if fignum==0, fignum = gcf;  end

ch = get(gca,'children');
found_image = 0;
for ii=1:length(ch),
  if strcmp(get(ch(ii),'type'),'image'),
     found_image = 1;
     ima = ch(ii);
  end
end
if ~found_image
  error('TRUSIZE: found no image in current figure or subplot');
end

% <msv> in the original assignment [Nx,Mx], if Cdata refers
% to a color image, then Mx = 3 * number_of_horiz_pixels.
% [Ny,Mx] = size(get(ima,'Cdata'));
Ny = size(get(ima,'Cdata'),1);
Mx = size(get(ima,'Cdata'),2);

%-- Save the units for later
axunits = get(gca,'units');    funits = get(fignum,'units');  runits = get(0,'units');
%
set(gca,'units','normalized'); set(fignum,'units','pixels');  set(0,'units','pixels')
apos = get(gca,'position');    fpos = get(fignum,'position'); rpos = get(0,'screensize');

% Change figure position, but keep the center fixed
dx = ceil(Mx/apos(3) - fpos(3));
dy = ceil(Ny/apos(4) - fpos(4));
fpos = [fpos(1)-round(dx/2) fpos(2)-round(dy/2) fpos(3)+dx fpos(4)+dy];


if fpos(3)>rpos(3) | fpos(4)>rpos(4),
  disp('TRUSIZE: new figure would be too big to fit on the screen. NO CHANGE.');
  return
end

if( (fpos(1)+fpos(3))>ceil(0.8*rpos(3)) )
    fpos(1) = max(rpos(3)-fpos(3),ceil(fpos(1)/2))-ceil(fpos(1)/4);
    fpos(1) = max(fpos(1),1);
end
if( (fpos(2)+fpos(4))>ceil(0.8*rpos(4)) )
    fpos(2) = max(rpos(4)-fpos(4),ceil(fpos(2)/2))-ceil(fpos(1)/4);
    fpos(2) = max(fpos(2),1);
end

set(fignum,'Position',fpos);

% Change axis position to get exactly one pixel per image pixel.
dx = Mx/fpos(3) - apos(3);
dy = Ny/fpos(4) - apos(4);
set(gca,'Position',[apos(1)-dx/2 apos(2)-dy/2 apos(3)+dx apos(4)+dy])

set(0,'units',runits), set(gca,'units',axunits), set(fignum,'units',funits) %-- Restore units
