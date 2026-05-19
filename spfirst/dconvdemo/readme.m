%===========================================================================
% Matlab Convolution GUI (by Jordan Rosenthal)
%===========================================================================
%
% This GUI was created to help illustrate the concept of convolution.
%
% Installation Instructions:
% --------------------------
%    There are no special installation instructions required.  The archive
%    just needs to be unpacked with the original directory structure 
%    preserved.
%
% To Run:
% -------
%    The GUI is started by running the convdemo.m file.  For further help,
%    use the help menu.
%
% Contact Information:
% --------------------
% If you find wish to report a bug or have any questions you can contact me
% at
%
%    Jordan Rosenthal
%    jr@ece.gatech.edu
%
%
%===========================================================================
% Revision Summary
%===========================================================================
%---------------------------------------------------------------------------
% Ver 3.18 (07-Mar-2017): ylim bug fix (G Krudysz)
% Ver 3.17 (03-Oct-2016): dconvdemo/fontsizedlg moved from /private (G Krudysz)
% Ver 3.16 (30-Mar-2016): MATLAB R2016a update (G Krudysz)
% Ver 3.15 (24-Jun-2015): MATLAB R2015a update (G Krudysz)
% Ver 3.12 (25-Jan-2015): MATLAB R2014b update: mods to account for new graphics arch (G Krudysz)
% Ver 3.11 (21-Dec-2014): MATLAB R2014a update: unit sample 'onmove' error, added fontsizedlg()
%                          cosmetic updates: stem fills, spacing, 0-line (G Krudysz)
% Ver 3.10 (28-May-2009): MATLAB R2009b update: stem('v6' ..) depreciation, modified stemdata.m (G Krudysz)
% Ver 3.07 (26-Oct-2007): MATLAB R2007a update (G Krudysz)
%---------------------------------------------------------------------------
% Matlab Convolution GUI version 3.02 (31-Aug-2001)
%---------------------------------------------------------------------------
%   : Moved AXISXLIM to dconvdemo_callbacks.m (J McClellan)
%---------------------------------------------------------------------------
% Matlab Convolution GUI version 3.01 (01-Feb-2001)
%---------------------------------------------------------------------------
%   : Modified to run in R12.  This involved changing the way the SETHANDLES
%     function worked and how the help files are displayed.
%   : Added support for arrow keys which work in R12.
%---------------------------------------------------------------------------
% Matlab Convolution GUI version 3.00 (06-Nov-2000)
%---------------------------------------------------------------------------
%   : Put callbacks into DCONVDEMO_CALLBACKS and created a startup file
%     called DCONVDEMO containing startup code.  The old version used a
%     TRY/CATCH block which created errors in Matlab 5.2.
%   : Modified for better path handling.
%---------------------------------------------------------------------------
% Matlab Convolution GUI version 2.03 (15-May-2000)
%---------------------------------------------------------------------------
%   : Improved signal dragging response.
%---------------------------------------------------------------------------
% Matlab Convolution GUI version 2.02 (02-Apr-2000)
%---------------------------------------------------------------------------
%   : Updated intialization case.
%   : Cleaned up some code and added more comments.
%   : Added a simple installation check
%   : Added try block to initialization code. 
%   : Fixed 'Close' case to handle multiple instances of GUI correctly.
%   : Fixed a problem occuring when in circular convolution and tutorial 
%     mode at the same time.
%---------------------------------------------------------------------------
% Matlab Convolution GUI version 2.01 (04-Oct-2000)
%---------------------------------------------------------------------------
%   : Updated to work in Matlab 5.3
%---------------------------------------------------------------------------
% Matlab Convolution GUI version 2.00 (08-May-1999)
%---------------------------------------------------------------------------
%   : Added circular convolution features and cleaned up some code.
%---------------------------------------------------------------------------
% Matlab Convolution GUI version 1.00 (14-Dec-1997)
%---------------------------------------------------------------------------