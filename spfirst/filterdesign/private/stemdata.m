function [L1,L2] = stemdata(x,y,hAxes,handL1,handL2)
%STEMDATA Create stem plot data
%   STEMDATA(x,y,hAxes) changes the stem plot given by the handles
%   in hLines to the new data x and y.
%
%   The input x and y should be equal length vectors.

% Jordan Rosenthal, 5/4/98
%          Revised, 1/20/99
% Rajbabu, Revised, 11/19/2002
% G Krudysz 10/13/05 - added handles
 
N = length(x);
xx = zeros(3*N,1);
yy = zeros(3*N,1);
xx(1:3:end) = x;
xx(2:3:end) = x;
xx(3:3:end) = nan;
yy(2:3:end) = y;
yy(3:3:end) = nan;

switch nargin
    case 3
        L1 = line(xx,yy,'parent',hAxes);
        L2 = line(x,y,'marker','o','linestyle','none','parent',hAxes);
    case 5
        set(handL1,'xdata',xx,'ydata',yy);
        set(handL2,'xdata',x,'ydata',y);
        L1 = [];
        L2 = [];
    otherwise
        error('Error in stemdata, check no. of arguments');
end