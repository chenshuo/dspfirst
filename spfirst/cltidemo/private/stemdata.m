function stemdata(x,y,hLines)
%STEMDATA Create stem plot data
%   STEMDATA(x,y,hLines) changes the stem plot given by the handles
%   in hLines to the new data x and y.
%
%   The input x and y should be equal length vectors.

% Jordan Rosenthal, 5/4/98
%          Revised, 1/20/99
% Rajbabu, Revised, 11/19/2002
  
N = length(x);
xx = zeros( 3*N, 1);
yy = zeros( 3*N, 1);
xx(1:3:end) = x;
xx(2:3:end) = x;
xx(3:3:end) = nan;
yy(2:3:end) = y;
yy(3:3:end) = nan;
set(hLines(1:2),{'XData','YData'},{x y; xx yy});
