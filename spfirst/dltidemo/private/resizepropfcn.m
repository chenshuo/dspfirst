function newPos = resizepropfcn(hFig,oldPos)
%RESIZEPROPFCN Resize a figure with constant width to height proportion.
%   newPos = RESIZEPROPFCN(hFig,oldPos) is a function designed for use as part
%   of the 'ResizeFcn' callback of a figure.  The function ensures that the 
%   width to height aspect ratio of the figure with handle hFig remains constant
%   after a user resize operation.  The variable oldPos refers to the figure 
%   position prior to the resize operation.  The output newPos is the figures
%   position after the resize operation.
%
%   Example:
%
%      function figresizetest(action)
%      % Run this function without any arguments and then resize the figure.
%      if nargin==0
%         figure('ResizeFcn','figresizetest ResizeFcn');
%         set(gcf,'UserData',get(gcf,'Pos'));
%      else
%         oldPos = get(gcbo,'UserData');
%         newPos = resizepropfcn(gcbo,oldPos);
%         set(gcbo,'UserData',newPos);
%      end
%
%   This function should only be used in Matlab 5.3 or higher.

% Jordan Rosenthal, 17-Jun-1999

aspRatio = oldPos(3)/oldPos(4);                            % Figure aspect ratio
newPos = get(gcf,'Pos');                                   % Get new figure position
sizeChg = abs(newPos(3:4)-oldPos(3:4));                    % Change in figure size: [widthchg heightchg]

if sizeChg(1) >= sizeChg(2)
   % Width change is larger, so change height to keep figure aspect ratio constant
   newPos(3:4) = [newPos(3)  newPos(3)/aspRatio];
else
   % Height change is larger, so change width to keep figure aspect ratio constant
   newPos(3:4) = [newPos(4)*aspRatio  newPos(4)];
end

set(gcbf,'Pos',newPos);                                    % Set new figure size
findfigs;                                                  % Reposition figure if it goes off screen
