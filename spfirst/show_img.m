function [ph] = show_img(img, where2plot, scaled, map)
%SHOW_IMG    display an image with possible scaling
% usage:  ph = show_img(img, figno, scaled, map)
%    img = input image
%    where2plot = figure number to use for the plot
%                 if 0, re-use the same figure
%                 if omitted a new figure will be opened
%                  ** OR **
%                 if 3-component vector, the image 
%                 will appear as a subplot in the current
%                 figure, as defined by the vector.
%                 So, for example if you specify 
%                 [2 2 1] for "where2plot", this would
%                 be like using subplot(2,2,1) for
%                 regular plots
%    scaled = 1 (TRUE) to do auto-scale (DEFAULT)
%           not equal to 1 (FALSE) to inhibit scaling
%    map = user-specified color map
%     ph = figure handle

%----

% Jim McClellan, 27-Oct-97   for DSP First and SP First
% 
% edited, <msv:gte631d> 02/14/2004 to provide the following:
%  1. Handle color images
%  2. Provide subplot ability
%  3. Work with uint8 arrays efficiently
%----                   

% initialize FLAGs
subplot_FLAG = 0;
uint8_FLAG = 0;

whos_img = whos('img');

if length(whos_img.class) == 5 & whos_img.class(end) == '8';
    uint8_FLAG =  1;
end
% --- end initializing FLAGs ---    

if( nargin > 1 )
    if  length(where2plot) == 1
        if where2plot > 0
            figure( where2plot );
        else
            %- use same figure
        end
    elseif length(where2plot) == 3
        subplot(where2plot(1), where2plot(2), where2plot(3));
        subplot_FLAG = 1;
    else
        error(sprintf(['"where2plot" must either be a single '...
                'positive integer\n or a length-3 vector of '...
                'positive integers\n']));
    end
else
    figure;
end

if(nargin < 3),
    if uint8_FLAG,
        scaled = 0;
    else, % needs to be double
        scaled = 1;   %--- TRUE
    end
end;


if (scaled)
    if uint8_FLAG,
        img = double(img);
    end
    disp('Image being scaled so that min value is 0 and max value is 255')
    mx = max(img(:));
    mn = min(img(:));
    omg = uint8(round(255*(img-mn)/(mx-mn)));
    
elseif (~scaled),
    if uint8_FLAG,
        % 0 ~ 255 limits are naturally gauranteed
        omg = img;
    else
        disp('Values > 255 set to 255 and  negative values set to 0')
        omg = round(img);
        I = find(omg < 0);
        omg(I) = zeros(size(I));
        I = find(omg > 255);
        omg(I) = 255 * ones(size(I));
        omg = uint8(omg);
    end
end;

if (nargin < 4)
    if length(size(omg)) == 2,
        colormap(gray(256))   %--- Linear color map
    end
else 
    %%%omg = img;
    colormap(map);
end;

pim = image(omg);

if ~subplot_FLAG,
    % Edt. truesize.m <msv>
    trusize;   %--- DSP First version of truesize                 
end

axis('image')
ph = gca;
