% Beat Contol Panel v2.4y  / EE2200 / April 23 , 1995    
% Craig Ulmer /  No modifications or sales without author's approval 
%
%   grimace@ee.gatech.edu / ulmer@eedsp.gatech.edu / gt7667a@prism.gatech.edu
%
% 
% Purpose : beatcon.m is a scipt that creates a GUI that manipulates
%           values plugged into the user defined "beat.m" function. It allows
%           output to be plotted or played through the audio speaker, as well
%           as give an example for what beat notes sound like. Plots can be
%           saved to postscript files.
%
% beat.m file: Looks like
%               function x=beat(a_amp,b_amp,freq_center,freq_dis,fs,time)

% Required Files:      beatcon.m     -- Bootstrap 
%                      beatconbin.m  -- Actual Source
%
% Changes since v2.3 : New interface(Again!) Program rewritten as a function
%                      rather than as script. This causes problems with
%                      some compilation, which is why this bootstrap program
%                      is necessary. Lot more solid menu options - such
%                      as save/load, and multiple print options.
%
% Possible problems:   The uimenu options gave a lot of errors as I built them.
%                      In particular, a system hang/segmentation error when
%                      selecting one of the menus. Can't isolate the problem 
%                      due to low frequency, and Mathworks offers no help.
%
% As usual, Send the complaints to grimace@ee.gatech.edu
%
%
%if (exist('beat.m') ~= 2)
%  unix('echo ''function y=beat(a,b,c,d,e,f,g);'' >beat.m');
%end; 
eval('beatconb')