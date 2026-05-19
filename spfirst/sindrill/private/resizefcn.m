function newPos = resizefcn(oldPos,hFig,MATLABVER)
%RESIZEFCN Version dependent resize function.
%   newPos = RESIZEFCN(oldPos,hFig,MATLABVER) provides the appropriate
%   resizefcn callback for different versions of Matlab.  The variable oldPos 
%   refers to the figure position prior to the resize operation.  The output 
%   newPos is the figures position after the resize operation.  The actual code 
%   run depends on MATLABVER which should be 5.2 or higher.
%
%   Matlab 5.2
%   ----------
%      1) newPos = get(hFig,'Pos');  This means the new figure size will equal the 
%         size the user wants.  There is no effective way to keep figure aspect
%         ratio constant so fonts may be too big if figure made too small horizontally.
%
%   Matlab 5.3
%   ----------
%      1) newPos = resizepropfcn(hFig,oldPos);  This keeps the aspect ratio of the
%         resize constant.
%
%   To use this function call it from the 'ResizeFcn' figure callback.
%
%   Example:
%
%      function figresizetest(action)
%      % Run this function without any arguments and then resize the figure.
%      if nargin==0
%         figure('ResizeFcn','figresizetest ResizeFcn');
%         h.MATLABVER = 5.2;
%         h.Pos = get(gcf,'Pos');
%         set(gcf,'UserData',h);
%      else
%         h = get(gcbo,'UserData');
%         h.Pos = resizefcn(h.Pos,gcbo,h.MATLABVER);
%         set(gcbo,'UserData',h);
%      end
%
%   For proper resizing response, this function should be used in conjunction with 
%   the CONFIGRESIZE function.
%
%   See also CONFIGRESIZE, RESIZEPROPFCN

% Jordan Rosenthal, 22-Jun-99

if MATLABVER < 8
    error(nargchk(3,3,nargin)); %-- Error check number of input arguments
else
    narginchk(3,3);
end

if MATLABVER < 5.2, error('CONFIGRESIZE written for Matlab 5.2 or higher.'); end

newPos = get(hFig,'Pos');

if MATLABVER == 5.2                        % Matlab Version 5.2
   newPos = get(hFig,'Pos');               % ResizeFcn should not affect the new position
   resizefcn52fix(hFig,oldPos,newPos);     % Run a fix for uicontrols
elseif MATLABVER >= 5.3 && MATLABVER < 8   % Matlab Version 5.3
   newPos = resizepropfcn(hFig,oldPos);    % Make sure figure stays proportional
end
