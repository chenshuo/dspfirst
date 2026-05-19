function image2bmp(filename)
%IMAGE2BMP Write image to bitmap file.
%   IMAGE2BMP(filename) will write the image within the current figure
%   to a bitmap file with the name filename.
%
%   Ex.  load barbara;
%        show_img(barb);
%        image2bmp('barbara.bmp');

% Jordan Rosenthal, 02/17/2000

hFig = get(0,'CurrentFigure');
if isempty(hFig)
    error('There are no open figures.');
end
hImage = findobj(gcf,'type','image');
if isempty(hImage)
    error('There are no images in the current figure.');
elseif length(hImage)>1
    error('There is more than one image in the current figure.');
end
if ~exist('imwrite')
    error('Your version of Matlab must be upgraded to use this function.');
end

X = get(hImage,'CData');
map = colormap;
imwrite(X,map,filename,'bmp');

