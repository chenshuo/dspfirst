function configresize(hFig)
%CONFIGRESIZE Configure GUI to handle resizing operations.
%   CONFIGRESIZE(hFig) changes the units and fontunits of all objects that support these
%   units to 'normalized'.  Then, when a figure is resized all objects are resized
%   accordingly.  
%
%   This function should be used in conjunction with the RESIZEFCN function.
%
%   See also RESIZEFCN

% Jordan Rosenthal, 22-Jun-99

ver = version;
if str2num(ver(1:3)) < 8
  error(nargchk(1,1,nargin)); %-- Error check number of input arguments
else
  narginchk(1,1);
end

%-------------------------------------------------------------------------------
% Get handles
%-------------------------------------------------------------------------------
hAxes       = findall(hFig,'type','axes');
hText       = findall(hAxes,'type','text');%,'interpreter','tex');
hUIControls = findall(gcf,'type','uicontrol');
hUIText     = findall(hUIControls,'style','text');
hUIFrames   = findall(hUIControls,'style','frame');

%-------------------------------------------------------------------------------
% Set objects to normalized units
%-------------------------------------------------------------------------------
set([hAxes; hUIControls],'units','normalized','fontunits','normalized');
set(hText,'units','normalized','HandleVisibility','on','fontunits','normalized');