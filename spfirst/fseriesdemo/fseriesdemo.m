function fseriesdemo()
% FSERIESDEMO  MATLAB Convolution GUI
%   FSERIESDEMO is a Graphical User Interface which illustrates 
%   fourier series.

% This GUI is written by Mustayeen Nayeem for ECE 4901 (special topic course)
% under Professor James McClellan. 
%
% "I used and modified some of the functions Jordan Rosenthal wrote. His
% examples were a good model to get a hand on MATLAB GUI. I would like
% to thank Rajbabu Velemurugan specially for all his guidance and help 
% to write this GUI. Also thanks to Greg Slabaugh for his similar
% implementation in Java which helped me a lot in designing its MATLAB 
% version."
%
% Mustayeen Nayeem, Summer ,02

% Please see readme.m for revision history.

%--------------------------------------------------------------------
% Startup error checks
%--------------------------------------------------------------------
%  : Check to make sure zip archive extracted with subfolders
%  : Check the Matlab version
%  : Check the screen size
%  : Check the path
%--------------------------------------------------------------------
errCmd = 'errordlg(lasterr,''Error Initializing Figure''); error(lasterr);';
cmdCheck1 = 'installcheck;';
cmdCheck2 = 'h.MATLABVER = versioncheck(5.2);';
cmdCheck3 = 'screensizecheck([800 600]);';
cmdCheck4 = ['adjustpath(''' mfilename ''');'];
eval(cmdCheck1,errCmd);       % Simple installation check
eval(cmdCheck2,errCmd);       % Check Matlab Version
eval(cmdCheck3,errCmd);       % Check Screen Size
eval(cmdCheck4,errCmd);       % Adjust path if necessary

%--------------------------------------------------------------------
% Run the GUI
%--------------------------------------------------------------------
fouriergui_callbacks;
