function [ph] = show_img_v2(img, figno, scaled, map)
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
%
% edited, <msv:gte631d> 02/14/2004
%   Made *minimal* changes to accomodate color images.
%   Calls trusize_v2.m, which was also edited to
%   accomodate color images.
%----

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

% <msv> made minimal changes to allomodate 3D arrays: 
%       cast to uint8, so 0~255 range would be valid 
%       for color image, while gray-scale images are
%       not affected
if (scaled)
   disp('Image being scaled so that min value is 0 and max value is 255')
   mx = max(img(:));
   mn = min(img(:));
   omg = uint8(round(255*(img-mn)/(mx-mn)));
   
elseif (~scaled)
   disp('Values > 255 set to 255 and  negative values set to 0')
   omg = round(img);
   I = find(omg < 0);
   omg(I) = zeros(size(I));
   I = find(omg > 255);
   omg(I) = 255 * ones(size(I));
   omg = uint8(omg);
end;

if (nargin < 4)
  colormap(gray(256))   %--- Linear color map
else 
  omg = img;
  colormap(map);
end;
pim = image(omg);

% Edt. truesize.m <msv>
trusize;   %--- DSP First version of truesize (Edt.)

axis('image')
ph = gca;
