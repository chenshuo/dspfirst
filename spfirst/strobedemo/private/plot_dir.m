function [h1, h2] = plot_dir (vX, vY)
%function [h1, h2] = plot_dir (vX, vY)
%Plotting x-y variables with direction indicating vector to the next element.
%Example
%   vX = linspace(0,2*pi, 10)';
%   vY = sin (vX);
%   plot_dir(vX, vY);

rMag = 0.5;

lenTime = length(vX);

vSelect0 = 1:(lenTime-1);
vSelect1 = vSelect0 + 1;

vXQ0 = vX(vSelect0, 1);
vYQ0 = vY(vSelect0, 1);

vXQ1 = vX(vSelect1, 1);
vYQ1 = vY(vSelect1, 1);

vPx = (vXQ1 - vXQ0) * rMag;
vPy = (vYQ1 - vYQ0) * rMag;

h1 = plot (vX, vY, '.-'); hold on;
h2 = quiver (vXQ0,vYQ0, vPx, vPy, 0, 'r'); grid on; hold off
axis equal
