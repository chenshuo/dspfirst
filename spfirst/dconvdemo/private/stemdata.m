function [xx,yy] = stemdata(x,y)
%STEMDATA Create stem plot data
%   [xx,yy] = STEMDATA(x,y) returns data such that plot(xx,yy) is
%   a stem plot without the data point markers.  That is, just
%   the lines of a stem plot would be plotted.
%
%   The input x and y should be equal length vectors.

% Jordan Rosenthal, 5/4/98

ISROW = (size(x,1) == 1);

N = length(x);
xx = zeros( 3*N, 1);
yy = zeros( 3*N, 1);
xx(1:3:end) = x;  
xx(2:3:end) = x;   
xx(3:3:end) = nan;
yy(2:3:end) = y;  
yy(3:3:end) = nan;

if ISROW
   xx = xx.';
   yy = yy.';
end