%===========================================================================
% Pole/Zero Demo  (PEZdemo.m)
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
%    The GUI is started by running the PEZdemo.m file.  For further help,
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
% 30-Mar-2016 - G.Krudysz (PEZdemo ver 2.9)
%       R2016a update
%---------------------------------------------------------------------------
% 24-Feb-2015 - G.Krudysz (PEZdemo ver 2.87)
%       R2014b update
%---------------------------------------------------------------------------
% 30-Oct-2011 - G.Krudysz (PEZdemo ver 2.86)
%       Added "Move along a Radial Line" option ( menu )
% 17-Oct-2011 - G.Krudysz (PEZdemo ver 2.85)
%       Added "Move along a Circle" option ( menu )
% 08-Nov-2007 - G.Krudysz (PEZdemo ver 2.84)
%       PZ tooltip fix
% 26-Oct-2007 - G.Krudysz (PEZdemo ver 2.83)
%       Ray text fixes
%       fixed umtoggle & 'WindowButtonUpFcn' obsolete warnings
% 18-Jan-2007 - G Krudysz (PEZdemo ver. 2.8)
%       Ray fixes
% 5-Apr-2006 - G Krudysz (PEZdemo ver. 2.7)
%       Added H(z) formula text, see recal.m ("Formula text formatting")
%       Added ray angle text
%       Added ray motion in Mag/Phase plot 
%       Bounded poles/zeros to remain within PEZ axis, cosmetic changes
%       Fixed bug associated with "Import default values" menu operation 
% 19-Mar-2006 - G Krudysz (PEZdemo ver. 2.64)
%       Added 'dat' structure to coeff_dlg and import_dlg
% 15-Mar-2006 - G Krudysz (PEZdemo ver. 2.63) 
%       Fixed file extension bug in coeff_dlg.m
%       Fixed file existence bug, color scheme in import_dlg.m
%       Fixed color scheme in showgph.m, some changes in pezdemo.m
% 07-Mar-2006 - G Krudysz (PEZdemo ver. 2.62) 
%       Updated coeff_dlg, changed WARNDLG to lower-case, updated help files
%---------------------------------------------------------------------------
% 15-Jul-2005 - G.Krudysz (PEZdemo ver 2.61)
%---------------------------------------------------------------------------
% 17-Dec-2004 - G Krudysz (PEZdemo ver. 2.60) 
%       Final Release for Spring 2005 semester
% 12-Dec-2004 - G Krudysz (PEZdemo ver. 2.53)
%       Fixed version 6.1, browswer, load file, demo bugs
% 08-Dec-2004 - G Krudysz (PEZdemo ver. 2.51)
%       Added final realease of "movietool" version 3.6
%       Fixed 'axis_limit_check' function to run with movietool
%       Renamed to PEZdemo
%---------------------------------------------------------------------------
% 29-Nov-2003 - G Krudysz   (pezmovie ver. 1.71)
%       Added menu "Movie on Real Line" under Options
%       Renamed it from pezdemoR to pezmovie
%       Created movies under "Movie Demos" menu
% 07-Sep-2003 - G Krudysz
%       Fixed slider position
%       Recentered all figures
%       Fixed closed request function
% 14-May-2003 - G Krudysz
%       Added slider for zooming
%       Added Import and Export capabilities
%       Chnaged x-label in Mag and Phase Response Plot to symbolic
%---------------------------------------------------------------------------
% 14-May-2002 - Rajbabu
%       Added version check, screen size check and fixed minor bug/typo.
%       Added callback for online 'Help', along with required update in 
%       pezmovie.fig using GUIDE
% 05-Dec-2002 - J McClellan
%       Final release for DSP First
%       Fixed warning when deleting poles/zeros when none are present
%===========================================================================
% Known Problems
%===========================================================================
% * In 6.1/6.0 'Help' opens Mozilla with '%1' in location window, does not 
%   launch Netscape (7.0); works fine for >= 6.5 
