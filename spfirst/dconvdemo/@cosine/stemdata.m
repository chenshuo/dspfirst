function hLines = stemdata(Signal,varargin)
%STEMDATA Create stem plot data
%   STEMDATA(x,y,lineColor,hLines) changes the stem plot given by the handles
%   in hLines to the new data x and y.
%
%   The input x and y should be equal length vectors.

% Jordan Rosenthal, 5/4/98
%          Revised, 1/20/99
% Rajbabu, Revised, 11/19/2002
% Krudysz, Revised, 06/2/2009

N = length(Signal.XData);
xx = zeros( 3*N, 1);
yy = zeros( 3*N, 1);
xx(1:3:end) = Signal.XData;
xx(2:3:end) = Signal.XData;
xx(3:3:end) = nan;
yy(2:3:end) = Signal.YData;
yy(3:3:end) = nan;

lineColor = 'b';

if nargin == 1
    hax = gca;
    cla(hax);
    hLines(2) = line(xx,yy,'parent',hax,'color',lineColor);
    hLines(3) = line([min(Signal.XData) max(Signal.XData)],[0 0],'parent',hax,'color','k');
    hLines(1) = line(Signal.XData,Signal.YData,'parent',hax,'linestyle','none','marker','o','color',lineColor,'markerfacecolor',lineColor);
else
    hLines = varargin{1};
    set(hLines(1:2),{'XData','YData'},{Signal.XData Signal.YData; xx yy});
    set(hLines(3),'XData',[min(Signal.XData) max(Signal.XData)],'YData',[0 0]);
end