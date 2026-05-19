function [x,y,fig_size] = mousepos();
%MOUSEPOS Get the current mouse position.
%   [x,y] = MOUSEPOS() converts the mouse location in root object units to 
%   pixel location with respect to the figure.

% Jordan Rosenthal, 12/14/97
% Gregory Krudysz,  11/03/02, added fig_size

Root_Units = get(0, 'units');
Fig_Units = get(gcbf, 'units');
set(0, 'units','pixels');
set(gcbf, 'units', 'pixels');
Mouse_Pos = get(0, 'PointerLocation');
Fig_Pos = get(gcbf, 'Position');
set(gcbf, 'units', Fig_Units);
set(0, 'units', Root_Units);
x = (Mouse_Pos(1) - Fig_Pos(1));
y = (Mouse_Pos(2) - Fig_Pos(2));

fig_size = [Fig_Pos(3) Fig_Pos(4)];


