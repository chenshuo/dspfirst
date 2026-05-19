function cconvdemo
%CCONVDEMO  MATLAB Convolution GUI
%   CCONVDEMO is a Graphical User Interface which illustrates the 
%   calculation of discrete convolution.

% Jordan Rosenthal, 06-Nov-2000

%--------------------------------------------------------------------
% Startup error checks
%--------------------------------------------------------------------
%  : Check to make sure zip archive extracted with subfolders
%  : Check the Matlab version
%  : Check the screen size
%  : Check the path
%--------------------------------------------------------------------
errCmd    = 'errordlg(lasterr,''Error Initializing Figure''); error(lasterr);';
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
cconvdemo_callbacks;