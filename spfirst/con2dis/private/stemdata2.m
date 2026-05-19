function stemdata2(x,hLines)
%STEMDATA2 Create stem plot data
%   STEMDATA2(x,hLines) changes the stem plot given by the handles
%   in hLines to the new data x.

% Jordan Rosenthal, 5/4/98
%          Revised, 1/20/99
%          Revised, 7/06/01

N = length(x);
xx = zeros( 3*N, 1);
xx(1:3:end) = x;
xx(2:3:end) = x;
xx(3:3:end) = nan;
set(hLines,{'XData'},{x;xx});