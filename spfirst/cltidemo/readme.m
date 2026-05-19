%---------------------------------------------------------------------------
% Linear Time Invariant System Demo version 1.00 (29-May-2001)
%---------------------------------------------------------------------------
%  : Created CLTIDEMO by modifying LTIDEMO (changed to DLTIDEMO) by
%  Mustayeen Nayeem
%
%----------------------------------------------------------------------------
%----------------------------------------------------------------------------
%
% If there is any other bug that you found while running the program or 
% questions, please let me know by sending email to 
%
%   Jordan Rosenthal	(jr@ece.gatech.edu)
%
%        or
%
%   Professor James McClellan (james.mcclellan@ece.gatech.edu)
%===========================================================================
% Revision Summary
%===========================================================================
%--------------------------------------------------------------------------
% CLTIDemo version 2.57 (30-Mar-2016, Greg Krudysz ): R2016a update
%--------------------------------------------------------------------------
% CLTIDemo version 2.55 (10-Apr-2015, Greg Krudysz ): R2014b update + bug fixes
%--------------------------------------------------------------------------
% CLTIDemo version 2.52 (8-Apr-2008, Greg Krudysz )
%--------------------------------------------------------------------------
%  : fixed ideal filter phase slope bug
%--------------------------------------------------------------------------
% CLTIDemo version 2.51 (7-Mar-2006, Greg Krudysz )
%--------------------------------------------------------------------------
%  : modified ctfirstorderfilter.m
%--------------------------------------------------------------------------
% CLTIDemo version 2.5 (27-Nov-2005, Greg Krudysz )
%--------------------------------------------------------------------------
%  : Matlab 7.1 update: changed axes() due to version bug, updated g/setuprop 
%--------------------------------------------------------------------------
% CLTIDemo version 2.4 (27-Apr-2005, Rajbabu )
%--------------------------------------------------------------------------
%  : fixed bug for BPF, BRF (in ctfirstorderfilter.m)
%  : vectorized equations (in ctfirstorderfilter.m)
%  : changed context menu label 'Norm Freq' to 'Freq' (in defaultplots.m)
%--------------------------------------------------------------------------
% CLTIDemo version 2.3 (28-Feg-2005, Greg Krudysz )
%--------------------------------------------------------------------------
%  : Replaced uicontrol text with axes text for Tex font
%  : Bug fixes associated with red dot and phase
%---------------------------------------------------------------------------
% CLTIDemo version 2.2 (17-Dec-2004, Greg Krudysz )
%---------------------------------------------------------------------------
%  : Final Release for Spring 2005 semester
%  : Added movietool package
%---------------------------------------------------------------------------
% CLTIDemo version 2.05 (26-Oct-2004, Greg Krudysz )
%---------------------------------------------------------------------------
%  : Fixed precision bug; filter markers evaluate to 'true' value, not
%    one of the bin values.  See NOTE in cltidemo.m/changeplots() function
%---------------------------------------------------------------------------