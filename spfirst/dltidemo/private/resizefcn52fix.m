function resizefcn52fix(hFig,oldPos,newPos)
%RESIZEFCN52FIX Fixes normalized fontunits bug in Matlab 5.2
%   RESIZEFCN52FIX(hFig,oldPos,newPos) fixes the normalized fontunits bug in Matlab 5.2.
%   In that version of Matlab (and earlier versions) setting the 'fontunits' of UICONTROLS
%   to 'normalized' does not work.  This function, which should be called from the 'ResizeFcn'
%   callback of a figure, correctly changes the font size of UIControls according to the change
%   in the figure size.
%
%   hFig is the handle of the figure being resized.  oldPos and newPos correspond to the position
%   vectors of the figure before and after resizing.
%
%   Example:
%
%      function figresizetest(action)
%      % Run this function without any arguments and then resize the figure.
%      if nargin==0
%         figure('ResizeFcn','figresizetest ResizeFcn');
%         Pos = get(gcf,'Pos');
%         set(gcf,'UserData',Pos);
%      else
%         Pos = get(gcbo,'UserData');
%         Pos = resizefcn52fix(gcbo,Pos,get(gcbo,'Pos'));
%         set(gcbo,'UserData',Pos);
%      end
%
%   As normalized fontunits should work, this function changes the fontsize depending on the height
%   change of the figure.  Width changes do not affect the fontsize.
%
%   See also CONFIGRESIZE, RESIZEFCN

% Jordan Rosenthal, 22-Jun-99

hUIControls = findall(hFig,'type','uicontrol');         % Get handles to all UIControls
OldFontUnits = get(hUIControls,'FontUnits');            % Save the current font units
set(hUIControls,'FontUnits','Pixels');                  % Set all font units to pixels

relHeightChange = newPos(4)/oldPos(4);                  % Calculate relative height change
for i = 1:length(hUIControls)
	set(hUIControls(i),'FontSize',relHeightChange*get(hUIControls(i),'FontSize'));  % Change font size
end

%  Restore previous font units
if iscell(OldFontUnits)
	set(hUIControls,{'FontUnits'},OldFontUnits);
else
	set(hUIControls,'FontUnits',OldFontUnits);
end
