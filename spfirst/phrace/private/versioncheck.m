function MATLABVERSION = versioncheck(x)
%VERSIONCHECK Check the Matlab Version
%   MATLABVERSION = VERSIONCHECK(x) compares the number x to the 
%   version of Matlab on which the function is running.  If x is 
%   less than the current Matlab version the function generates 
%   the error "This program requires Matlab version # or later" 
%   where # is replaced by x.  MATLABVERSION is a variable 
%   containing the current version.
%
%   See also SCREENSIZECHECK

% Jordan Rosenthal, 11-Sep-1999

MATLABVERSION = version;
MATLABVERSION = str2num(MATLABVERSION(1:3));
if MATLABVERSION < x
   error(['This program requires Matlab version ' num2str(x) ' or later']);
end
