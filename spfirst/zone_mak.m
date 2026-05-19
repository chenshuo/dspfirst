function img = zone_make(N, shift)
%ZONE_MAK      Creates an N by N zone-plate image
% usage:
%           y = create_zone(N, <shift>)
%      y = output image
%      N = size of image (N by N)
%  shift =  shift of the center of the image
%           (DEFAULT = N/2 puts center in center)
% NOTE:
% To display the image "img":
% 1. Load the colormap with a linear grayscale (only needs to 
%    be done once) using the  command "colormap(gray(256))".
% 2. Display the image y using the MATLAB command
%    "image(y)" or "imagesc(y)".
%
 
if( nargin < 2 )
   shift = N/2;
end
imax = 256*(1-10*eps);
x = ones(N,1) * [0:(N-1)];
x = (x - shift).^2;
kx = pi/N;
img = floor( imax*(cos(kx*(x + x')) + 1) );
%%
%% we are actually implementing the following 
%% linear-FM equation:
%%      img = A*cos(k*(r^2 + c^2));
%%  where:
%%    r = row in image
%%    c = column in image
