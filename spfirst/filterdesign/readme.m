%---------------------------------------------------------------------------
% Filter Demo version 1.00 (08-Nov-2004)
%---------------------------------------------------------------------------
%  : Created by Milind Borkar 
%       Undergraduate Research Project (Summer 2002 - Fall 2002)
%       Completed under the advisement of Dr. James McClellan
%
%  : FIR filters added by Milan Doshi
%       Graduate Research Project (Summer 2005 - Spring 2006)
%
%---------------------------------------------------------------------------
%
% If there is any other bug that you found while running the program or
% have questions, please let me know by sending email to: 
%
%   Professor James McClellan (james.mcclellan@ece.gatech.edu)

%===========================================================================
% Revision Summary
%===========================================================================
% G Krudysz 16-Apr-2017 (ver. 2.85)
%       R2016b/R2017a updates
%---------------------------------------------------------------------------
% G Krudysz 30-Mar-2016 (ver. 2.83)
%       R2016a updates
%---------------------------------------------------------------------------
% G Krudysz 19-Feb-2015 (ver. 2.8)
%       R2014b updates
%---------------------------------------------------------------------------
% G Krudysz 28-Feb-2009 (ver. 2.71)
%       @spfirst_coord marker bug fix
%---------------------------------------------------------------------------
% G Krudysz 08-Apr-2008 (ver. 2.7)
%       x-limit from fsamp update bug fix  - submitted by Dr. McClellan 3/26/08
%       Added @spfirst module: '_coord' for line coordinate readout
%---------------------------------------------------------------------------
% G Krudysz 24-Mar-2008 (ver. 2.68)
%       LineWidth bug fix - submitted by Dr. McClellan 3/24/08
%---------------------------------------------------------------------------
% G Krudysz 3-Mar-2008 (ver. 2.67)
%       Exit menu bug fix - submitted by Dr. McClellan 3/2/08
%---------------------------------------------------------------------------
% G Krudysz 4-Dec-2007 (ver. 2.66)
%       Spfirst release for Spring 2008
%       Added @spfirst module:'_dialog'
%       fixed error checking
%---------------------------------------------------------------------------
% G Krudysz 18-Jan-2007 (ver. 2.62)
%       Spfirst release for Spring 2007
%       Added "Various Responses" for all filters
%       Rewrote Kaiser under FIR
%       Added @spfirst modules: '_obj' and '_axis' 
%       rewrote/deleted rmvduplicate.m
%---------------------------------------------------------------------------
% Milan Doshi, G Krudysz 8-Mar-2006 (ver. 1.47)
%       Release for Spring 2006
%       Added FIR filters (Milan)
%       Added context menus (Milan)
%       Symbolic phase, code restructuring, HTML mods, rewrote coeff_dlg (Greg)
%---------------------------------------------------------------------------
% G Krudysz 15-Jul-2005 (ver. 1.25)
%       Spfirst release for Fall 2005
%       Added SPTcheck.m
%       Added x-Normalized and y-dB control option, added unit texts
%       Rewrote user.m; re-structured code for readability/efficiency
%---------------------------------------------------------------------------
% G Krudysz 22-Nov-2004 (ver. 1.10)
%       Fixed scaling issues, figure is saved in "pixel" units, then
%       rescaled in "norm" units, see "Re-center and normalalize figure"
%---------------------------------------------------------------------------
% G Krudysz 07-Nov-2004 (ver. 1.00)
%       Replaced installcheck.m for version 7.0
%---------------------------------------------------------------------------
% G Krudysz 20-Apr-2003 (ver. 0.90)
%       Made compatible with Matlab R12 (6.0)
%       Added export to workspace, opens coeff_dlg
%---------------------------------------------------------------------------
% G Krudysz 27-Mar-2003 (ver. 0.89) 
%       Added default plot, deleted "plot" button
%       Rewrote code for line objects/props
%       Reorganized menus
%---------------------------------------------------------------------------
% G Krudysz 07-Mar-2003 (ver. 0.81)
%       Added Version check, pathcheck
%       Added hand over line capability
%       Added 'Set Line Width' menu, checks
%       fixed figure properties, warnings 
%---------------------------------------------------------------------------
%===========================================================================
% Known Issues
%===========================================================================
% Took out "Barcilon-temes" FIR filter - needs additional work (Greg)
% Resize problems in MATLAB 7.0.x - edit-boxes