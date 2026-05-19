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
%    The GUI is started by running the cconvdemo.m file.  For further help,
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
% Matlab Convolution GUI version 2.16 (30-Mar-2016) - Krudysz
%---------------------------------------------------------------------------
%   : Matlab R2016a update
%---------------------------------------------------------------------------
% Matlab Convolution GUI version 2.14 (08-Apr-2015) - Krudysz
%---------------------------------------------------------------------------
%   : Matlab R2015a update
%---------------------------------------------------------------------------
% Matlab Convolution GUI version 2.13 (24-Feb-2015) - Krudysz
%---------------------------------------------------------------------------
%   : Matlab R2014b update
%---------------------------------------------------------------------------
% Matlab Convolution GUI version 2.12 (26-Oct-2007) - Krudysz
%---------------------------------------------------------------------------
%   : Matlab R2007a update : fixed umtoggle obsolete function
%---------------------------------------------------------------------------
% Matlab Convolution GUI version 2.11 (27-Nov-2005) - Krudysz
%---------------------------------------------------------------------------
%   : Matlab 7.1 update : fixed axes() bug
%---------------------------------------------------------------------------
% Matlab Convolution GUI version 2.04 (16-Mar-2001)
%---------------------------------------------------------------------------
%   : Fixed a drawing problem.  For example, the convolution of two 
%     exponentials looked a little strange.
%---------------------------------------------------------------------------
% Matlab Convolution GUI version 2.03 (01-Feb-2001)
%---------------------------------------------------------------------------
%   : Modified to run in R12.  This involved changing the way the SETHANDLES
%     function worked and how the help files are displayed.
%   : Added support for arrow keys which work in R12.
%---------------------------------------------------------------------------
% Matlab Convolution GUI version 2.02 (17-Nov-2000)
%---------------------------------------------------------------------------
%   : Fixed bug that occurred when generating delayed exponential, cosine, 
%     and sine signals by correcting the FEVAL functions within the class 
%     definitions.
%---------------------------------------------------------------------------
% Matlab Convolution GUI version 2.01 (06-Nov-2000)
%---------------------------------------------------------------------------
%   : Put callbacks into CCONVDEMO_CALLBACKS and created a startup file
%     called CCONVDEMO containing startup code.  The old version used a
%     TRY/CATCH block which created errors in Matlab 5.2.
%   : Renamed SIGGENDLG to CSIGGENDLG to avoid path conflicts with discrete
%     CONVDEMO version.
%   : Modified for better path handling:  added ADJUSTPATH function and 
%     modified version of Matlab's QUESTDLG function (to fix bug on that
%     occurs in Windows machines).  GUI now will only run if it is on the
%     path in a single location.  If not on the path, it will ask user if 
%     it should be added.
%---------------------------------------------------------------------------
% Matlab Convolution GUI version 2.00 (26-Oct-2000)
%---------------------------------------------------------------------------
%   : Renamed main file to cconvdemo.
%   : Renamed class files to avoid conflicts with discrete convdemo classes.
%   : Moved EZPLOT function into class directories to avoid path conflicts.
%---------------------------------------------------------------------------
% Matlab Convolution GUI version 1.02 (26-Mar-2000)
%---------------------------------------------------------------------------
%   : Added a simple installation check
%   : Added try block to initialization code. 
%   : Fixed 'Close' case to handle multiple instances of GUI correctly.
%---------------------------------------------------------------------------
% Matlab Convolution GUI version 1.01 (10-Nov-1999)
%---------------------------------------------------------------------------
%   : Fixed a bug in multiplypatch code
%---------------------------------------------------------------------------
% Matlab Convolution GUI version 1.00 (03-Nov-1999)
%---------------------------------------------------------------------------
%   : Original code based on the original Convolution GUI for discrete 
%     signals.