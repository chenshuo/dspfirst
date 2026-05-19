function [ph] = show_img(img, figno, scaled, map)
%SHOW_IMG    display an image with possible scaling
% usage:  ph = show_img(img, figno, scaled, map)
%    img = input image
%    figno = figure number to use for the plot
%             if 0, re-use the same figure
%             if omitted a new figure will be opened
% optional args:
%    scaled = 1 (TRUE) to do auto-scale (DEFAULT)
%           not equal to 1 (FALSE) to inhibit scaling
%    map = user-specified color map
%     ph = figure handle
%----

% Jim McClellan, 27-Oct-97   for DSP First and SP First

if( nargin > 1 )
   if( figno > 0 )
      figure( figno );
   end
else
   figure;
end
if(nargin < 3) 
   scaled = 1;   %--- TRUE
end;
if (scaled)
   disp('Image being scaled so that min value is 0 and max value is 255')
   mx = max(max(img));
   mn = min(min(img));
   omg = round(255*(img-mn)/(mx-mn));
elseif (~scaled)
   disp('Values > 255 set to 255 and  negative values set to 0')
   omg = round(img);
   I = find(omg < 0);
   omg(I) = zeros(size(I));
   I = find(omg > 255);
   omg(I) = 255 * ones(size(I));
end;
if (nargin < 4)
  colormap(gray(256))   %--- Linear color map
else 
  omg = img;
  colormap(map);
end;
pim = image(omg);
trusize;   %--- DSP First version of truesize
axis('image')
ph = gca;
