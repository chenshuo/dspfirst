function [xy,fig_size] = mousepos();
%MOUSEPOS Get the current mouse position.
%   [x,y] = MOUSEPOS() converts the mouse location in root object units to 
%   pixel location with respect to the figure.

% Jordan Rosenthal, 12/14/97
% Gregory Krudysz,  11/03/02, added fig_size

old_Units = get([0,gcbf],'units');
set([0,gcbf],'units','pixels');
Mouse_Pos = get(0,'PointerLocation');
Fig_Pos = get(gcbf, 'Position');
set([0,gcbf],{'units'},old_Units);
xy = (Mouse_Pos(1:2) - Fig_Pos(1:2));
fig_size = [Fig_Pos(3) Fig_Pos(4)];

