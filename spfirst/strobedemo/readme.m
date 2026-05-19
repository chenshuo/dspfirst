%===========================================================================
% Strobe Demo  (strobedemo.m)
%===========================================================================
%
% Installation Instructions:
% --------------------------
%    There are no special installation instructions required.  The archive
%    just needs to be unpacked with the original directory structure 
%    preserved.
%
% To Run:
% -------
%    The GUI is started by running the strobedemo.m file.  For further help,
%    use the help menu.
%
% Contact Information:
% --------------------
% If you find and wish to report a bug or have any questions you can contact
%
%   James H. McClellan
%   james.mcclellan@ece.gatech.edu
%
%===========================================================================
% Revision Summary
%===========================================================================
%--------------------------------------------------------------------------
% StrobeDemo ver 1.43 (28-May-2009, Greg Krudysz)
%--------------------------------------------------------------------------
%  : Updated for stem('v6' ..) depreciation, modified stemdata.m
%--------------------------------------------------------------------------
% StrobeDemo ver 1.42 (11-Jul-2005, Greg Krudysz)
%--------------------------------------------------------------------------
%  : Matlab 7.1 update : fixed case sensitive calls to s1e1_Callback.m
%--------------------------------------------------------------------------
% StrobeDemo ver 1.4 (11-Jul-2005, Greg Krudysz)
%--------------------------------------------------------------------------
%  : Spfirst release (without hardware support)
%  : Help documentation update
%--------------------------------------------------------------------------
% StrobeDemo ver 1.2 (11-May-2005, Greg Krudysz)
%--------------------------------------------------------------------------
%  : Added help function
%  : Edited for Matlab version 7.0
%  : Fixed cosmetic issues, adopted arrow.m to replace quiver function
%--------------------------------------------------------------------------
%====================================================================
% PROBLEMS
%====================================================================

% 1. Resize problems: does not resize proportionally on Win2000 ML7.0
