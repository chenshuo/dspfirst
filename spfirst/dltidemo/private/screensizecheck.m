function screensizecheck(SZ)
%SCREENSIZECHECK Check the current screen resolution.
%   SCREENSIZECHECK([width height]) compares the current screen 
%   resolution to the width and height given (in pixels).  If the 
%   current screen size is smaller than either width or height, an
%   appropriate error message is generated.
%
%   Example:
%   -------
%   Generate an error if the screen resolution is smaller than
%   800x600.
%
%       screensizecheck([800 600]);
%
%   See also VERSIONCHECK

% Jordan Rosenthal, 11-Sep-1999

oldUnits = get(0,'units');
set(0,'units','pixels');
ScreenSize = get(0,'ScreenSize');
set(0,'units',oldUnits);
if any( ScreenSize(1:2) ~= [1 1] )
   msg = ['The screen resolution was changed while Matlab was ', ...
         'running.  An accurate measurement of the screen size ', ...
         'is only taken when Matlab starts.  Therefore, please ', ...
         'restart Matlab and run this program again.'];
   error(msg);
end
if ScreenSize(3)<SZ(1) | ScreenSize(4)<SZ(2)
   strSize = [num2str(SZ(1)) 'x' num2str(SZ(2))];
   msg = ['Screen resolution should be ' strSize ' or higher.  '...
         'To use this program you must increase your screen ', ...
         'resolution, RESTART Matlab, and run the program again.'];
   error(msg);
end