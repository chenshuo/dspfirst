%===========================================================================
% Discrete Linear Time-Invariant System Demo (DLTIDemo)
%===========================================================================
%
%  The GUI was created to help illustrate the relationship between the input
%  and output of a linear time-invariant (LTI) filter when the input is a 
%  sinusoidal function.  The user is allowed to control the parameters of 
%  both the input sinusoid and the filter.
%
% Installation Instructions:
% --------------------------
%    There are no special installation instructions required.  The archive
%    just needs to be unpacked with the original directory structure 
%    preserved.
%
% To Run:
% -------
%    The GUI is started by running the dltidemo.m file.  For further help,
%    use the help menu.
%
% Contact Information:
% --------------------
% If you find wish to report a bug or have any questions you can contact
%
%    Jordan Rosenthal        or        James H. McClellan
%    jr@ece.gatech.edu                 james.mcclellan@ece.gatech.edu
%
%===========================================================================
% Revision Summary
%===========================================================================
% CLTIDemo version 2.74 (30-Mar-2016, Greg Krudysz ): Matlab 9.0 (R2016a) update
%--------------------------------------------------------------------------
% CLTIDemo version 2.71 (05-Feb-2015, Greg Krudysz ): Matlab 8.4 (R2014b) update + bug fixes
%--------------------------------------------------------------------------
% CLTIDemo version 2.6 (06-Mar-2009, Greg Krudysz )
%--------------------------------------------------------------------------
%  : modified stemdata.m to fix stem('v6',...) depreciation
%--------------------------------------------------------------------------
% CLTIDemo version 2.5 (06-Mar-2008, Jim McClellan )
%--------------------------------------------------------------------------
%  : fixed marker placement due to precision errors
%  : fixed ideal filter phase and phase slope formula
%--------------------------------------------------------------------------
% CLTIDemo version 2.4 (27-Nov-2005, Greg Krudysz )
%--------------------------------------------------------------------------
%  : Matlab 7.1 update: changed axes() due to version bug, updated [g/s]etuprop
%---------------------------------------------------------------------------
% DLTIDemo version 2.3 (28-Feg-2005, Greg Krudysz )
%--------------------------------------------------------------------------
%  : Replaced uicontrol text with axes text for Tex font
%  : Bug fixes associated with red dot and phase
%---------------------------------------------------------------------------
% DLTIDemo version 2.2 (17-Dec-2004, Greg Krudysz )
%---------------------------------------------------------------------------
%  : Final Release for Spring 2005 semester
%  : Added movietool package
%---------------------------------------------------------------------------
% DLTIDemo version 2.11 (26-Oct-2004, Greg Krudysz )
%---------------------------------------------------------------------------
%  : Fixed precision bug; filter markers evaluate to 'true' value, not
%    one of the bin values.  See NOTE in dltidemo.m/changeplots() function
%  : Modified "Frequency = " string for Freq = 0 case
%  : Fixed UIcontrolText to display frequency in radians
%---------------------------------------------------------------------------
% DLTIDemo version 2.05 (06-Apr-2003, Greg Krudysz )
%---------------------------------------------------------------------------
%  : changed x-axis from -pi to pi
%  : added uicontrol texts for symbolic pi in Freq EBox
%---------------------------------------------------------------------------
% DLTIDemo version 2.00 (19-Nov-2000, Jordan Rosenthal)
%---------------------------------------------------------------------------
%  : Changed name from LTIDemo to DLTIDemo
%  : Small modifications to formatting of comments
%  : Miscellaneous modifications
%---------------------------------------------------------------------------
% LTIDemo version 1.15 (05-Nov-2000, Jordan Rosenthal)s
%---------------------------------------------------------------------------
%  : Modified for better path handling
%---------------------------------------------------------------------------
% LTIDemo version 1.14 (26-Mar-2000, Jordan Rosenthal)
%---------------------------------------------------------------------------
%  : Added simple installation check
%  : Corrected 'CloseRequestFcn' code to handle multiple GUI instances. 
%---------------------------------------------------------------------------
% LTIDemo version 1.13 (11-Oct-99, Jordan Rosenthal)
%---------------------------------------------------------------------------
%  : Added freekz.m to the private directory
%---------------------------------------------------------------------------
% LTIDemo version 1.12 (27-Sep-99, Jordan Rosenthal)
%---------------------------------------------------------------------------
%  : Updated to handle Matlab 5.1+
%---------------------------------------------------------------------------
% LTIDemo version 1.11 (30-Jun-99, Jordan Rosenthal)
%---------------------------------------------------------------------------
%  The major purpose of revision 1.11 was to fix font and resize problems.
%  The program should now run well in all screen resolutions and handle
%  resize operations properly.
%
%  : Moved version check initialize case.
%  : Added private directory and moved some function there.
%  : Added addpath to Initialize case and rmpath to CloseRequestFcn so 
%    "Run Script" works from all directories.
%  : Changed all axes' 'NextPlot' values to 'ReplaceChildren', removed
%    now unnecessary xlabel/ylabel commands.
%  : Added DoubleBuffering to figure and removed all 'erasemode' references.
%  : Positioned controls in character units.
%  : Added function to override initial font setup.
%  : Added version dependent resize capability.
%  : Changed HandleVisibility to callback
%  : Added right-click context menu for plot values
%  : Updated Help functionality and text.
%
%  Known Issues:
%     - The Theoretical Answer
%        For non-ideal filters, the sign of phase of the output sometimes
%        does not correspond to the value from the phase plot of the filter
%       (middle-bottom plot). In particular case, the plot shows phase value
%        of -PI, but the answer shows the value of +PI. 
%     Note: Actually, PI is equal to -PI in the Cosine function.
%
%----------------------------------------------------------------------------
% LTIDemo version 1.01-1.10 (08-May-1999 through 18-May-1999, Jim McClellan)
%----------------------------------------------------------------------------
%  1.01 (08-May-1999): Minor modifications to make fonts bold
%  1.02 (09-May-1999): Position edit boxes and text better (sizing optimized
%                      for 768 x 1024 display on Mac)
%  1.03 (09-May-1999): Added DC level capability
%  1.04 (14-May-1999): Commented out line 127 with 'VerticalAlignment' which 
%                      crashed MATLAB 5.3
%  1.05 (15-May-1999): Added user input of h[n], re-order filter choices
%  1.06 (16-May-1999): Bug fixes
%  1.07 (16-May-1999): Bug fixes
%  1.08 (17-May-1999): Change dependence from FREQZ to FREEKZ
%  1.09 (18-May-1999): Find either FREQZ or FREEKZ, depending on the path
%                    : Change FIR1 to MYFIR1
%                    : Change erasemode from 'xor' to 'normal' everywhere
%  1.10 (18-May-1999): Fixed band edges of ideal filters when rounding occurs.
%                    : Changed length of LPF and BPF to L=15
%
%  Known Issues:
%      - The Normalization of the window and fonts.
%        If you resize the window smaller, the fonts will not become smaller.
%        Therefore, the best solution is setting your screen to 1280x1024 
%        pixels.
%   
%      - The Theoretical Answer
%         For non-ideal filters, the sign of phase of the output sometimes
%         does not correspond to the value from the phase plot of the filter
%        (middle-bottom plot). In particular case, the plot shows phase value
%         of -PI, but the answer shows the value of +PI. 
%      Note: Actually, PI is equal to -PI in the Cosine function.
%
%----------------------------------------------------------------------------
% LTIDemo version 1.00 (Winter 1999, Budiyanto Junus)
%----------------------------------------------------------------------------
%  : Original code developed by Budiyanto Junus for special topic course
%    (EE4092) under Professor James McClellan.