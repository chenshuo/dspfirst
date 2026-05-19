function [x,y,w,ht] = arrowpos(h)
%ARROWPOS Get current position of the n arrows.
%   [x,y,w,ht] = ARROWPOS(h) converts the n arrow positions from axes
%   data units to pixels with respect to the figure.  Each output argument
%   is a vector, one element for each arrow.  h is the GUI state/handle vector.
%
%   x,y,w,ht are all vectors containing the location

% Jordan Rosenthal, 12/14/97
%             Rev., 04/28/98
%             Rev., 11/03/99  Took out references to circular discrete convolution
% Greg Krudysz, 11/25/05 Added curly braces to 'Extent' to fix ResetAxes 
% if ~ishandle(h.Text.Arrows)
% h = get(gcbf,'UserData');
% end

Arrow_Ext = get(h.Text.Arrows, {'Extent'});
hAxes = [ h.Axis.Signal; h.Axis.Output ];
OldUnits = get(hAxes, 'units');
set(hAxes, 'units', 'pixels');
Axes_Pos = get(hAxes, 'Position');
set(hAxes, {'units'}, OldUnits);
XLim = get(hAxes, 'XLim');
YLim = get(hAxes, 'YLim');
for i = 1:length(Arrow_Ext)
   Width_DataUnits = XLim{i}(2) - XLim{i}(1);
   Height_DataUnits = YLim{i}(2) - YLim{i}(1);  
   Arrow_Left = Axes_Pos{i}(3) * ( Arrow_Ext{i}(1)-XLim{i}(1) ) / Width_DataUnits; 
   Arrow_Bottom = Axes_Pos{i}(4) * ( Arrow_Ext{i}(2)-YLim{i}(1) ) / Height_DataUnits;
   x(i) = Arrow_Left + Axes_Pos{i}(1);
   y(i) = Arrow_Bottom + Axes_Pos{i}(2);
   w(i) = Axes_Pos{i}(3) * Arrow_Ext{i}(3) / Width_DataUnits;
   ht(i) = Axes_Pos{i}(4) * Arrow_Ext{i}(4) / Height_DataUnits;
end
