%===========================================================================
% Contineous to Discrete Demo  (con2dis.m)
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
%    The GUI is started by running the con2dis.m file.  For further help,
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
%---------------------------------------------------------------------------
% Con2Dis ver 2.27 (30-Mar-2016, Greg Krudysz)
%       : R2016a update
% Con2Dis ver 2.26 (16-Jun-2015, Greg Krudysz)
%       : Screen-shot dialog, LaTex fixes
% Con2Dis ver 2.23 (08-Apr-2015, Greg Krudysz)
%       : R2015a update
% Con2Dis ver 2.22 (12-Feb-2015, Greg Krudysz)
%       : R2014b update
% Con2Dis ver 2.1 (28-May-2009, Greg Krudysz)
%       : Updated for stem('v6' ..) depreciation, modified stemdata.m
%       : Bug fix in con2dis('Unfold') function
% Con2Dis ver 2.0 (17-Dec-2004, Greg Krudysz)
%       : Final Release for Spring 2005 semester
%---------------------------------------------------------------------------
% Con2Dis ver 1.2 (10-Dec-2004, Greg Krudysz)
%       : Adopted for updated class based MovieTool
% Con2Dis ver 1.1 (05-Apr-2004, Greg Krudysz) 
%       : Adopted for MovieTool
% Con2Dis ver 1.04 (27-Sep-2003, Greg Krudysz)
%       : Set marker to 'star' on neg. frequencies
%       : Prevented h.Slider1 from maxing-out
% Con2Dis ver 1.03 (04-Aug-2003, Greg Krudysz)
% 		: Axis4 xlabel fixed when rad/sec button is toggled
%       : Axis3 symbolic fontsize approx = normal fontsize
%---------------------------------------------------------------------------
% Con2Dis ver 0.97 (20-October-2001, Greg Krudysz)
% 		: Code from 'Initialize' was broken up into two new functions 
%            defaultplots.m and defaultplots.m 
%       : Added 'ResizeFigure' within con2dis.m 
%       : Took out '^' from xlabel under h.Axis3, due to figure resize problems 
%---------------------------------------------------------------------------
% Con2Dis ver 0.96 (5-October-2001, Jim McClellan)
%---------------------------------------------------------------------------

%----------------------------------------------------------------------------
% Known Problems:
% Unix: Font xlabel under h.Axis2 differs from other fonts
%       Font size is too small
