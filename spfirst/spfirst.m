function mypath = SPFirst
% Run this to update the MATLAB path to include the MATLAB demos:
%
%   Sinusoid Drill (sindrill)
%   Complex Number Drill (zdrill)
%   Phasor Races (phrace)
%   Fourier Series Demo (fseriesdemo)
%   Continuous to Discrete Sampling Demo (con2dis)
%   Continuous-Time Convolution Demo (cconvdemo)
%   Discrete-Time Convolution Demo (dconvdemo)
%   Continuous LTI Demo (cltidemo)
%   Discrete LTI Demo (dltidemo)
%   PEZ  Pole/Zero Plotter (pezdemo)
%   Music GUI (musicgui)
%   Beat Frequencies
%   Filter Design (filterdesign)
%   Strobe Demo (strobedemo)
%   Complex Spin (cspin)
%
% NOTE: this file must be on the MATLAB path
%===========================================================================
% Revision Summary
%===========================================================================
% Greg Krudysz, 25-May-2021 (spfirst v1.73)
%   : R2021a update3
%                    cspin:        version 1.49
%--------------------------------------------------------------------------
% Greg Krudysz, 06-Nov-2017 (spfirst v1.72)
%   : R2017b update2 con2dis:      version 2.30
%                    sindrill:     version 2.13
%                    cltidemo:     version 2.59
%                    dltidemo:     version 2.76
%---------------------------------------------------------------------------
% Greg Krudysz, 06-Nov-2017 (spfirst v1.71)
%   : R2017b update  con2dis:      version 2.30
%                    cconvdemo:    version 2.18
%                    beacon:       version 2.61
%                    cltidemo:     version 2.58
%                    dltidemo:     version 2.75
%---------------------------------------------------------------------------
% Greg Krudysz, 17-Apr-2017 (spfirst v1.69)
%   : R2017a update  filterdesign: version 2.45
%                    dconvdemo:    version 3.18
%---------------------------------------------------------------------------
% Greg Krudysz, 7-Dec-2016 (spfirst v1.68)
%   : Added cspin: version 1.48
%---------------------------------------------------------------------------
% Greg Krudysz, 10-Oct-2016 (spfirst v1.67)
%   : R2016b update: screenshotdlg.m preserves color/size
%---------------------------------------------------------------------------
% Greg Krudysz, 29-Mar-2016 (spfirst v1.66)
%   : R2016a update: nargchk warning
%                    brought out of private/linewidthdlg.m, screenshotdlg.m
%---------------------------------------------------------------------------
% Greg Krudysz, 24-Jun-2015 (spfirst v1.65)
%   : beaton R2014b graphics update
%---------------------------------------------------------------------------
% Greg Krudysz, 14-May-2015 (spfirst v1.62)
%   : Added screen-shot menu option
%   : R2015a update
%---------------------------------------------------------------------------
% Greg Krudysz, 10-Apr-2015 (spfirst v1.60)
%   : R2014b update: cltidemo (v2.55), con2dis (v2.23), cconvdemo (v.2.14), 
%				     dconvdemo (v3.13), dltidemo (v2.72), filterdesign (v2.81), 
%				     fseriesdemo (v1.43), pezdemo (v2.88), phasorraces (v.1.15), 
%				     sindrill (v2.11), zdrill (v.2.12)
%---------------------------------------------------------------------------
% Jim McClellan, 12-Feb-2010 (spfirst v1.53)
%   : fix computer-dependent file separator in spfirst.m
%---------------------------------------------------------------------------
% Greg Krudysz, 02-June-2009 (spfirst v1.52)
%   : more general fix for stem('v6', ...) deprecation in con2dis,
%                     dconvdemo, dltidemo, fseriesdemo, and strobedemo
%---------------------------------------------------------------------------
% Greg Krudysz, 6-Mar-2009 (spfirst v1.49)
%   : fix stem('v6', ...) deprecation in dconvdemo,dltidemo
%---------------------------------------------------------------------------
% Jim McClellan, Greg Krudysz, 6-Mar-2008 (spfirst v1.48)
%   : Bug fixes in cltidemo, v2.52
%   : Added @spfirst_coord and bug fixes to filterdesign, v2.7
%---------------------------------------------------------------------------
% Jim McClellan, Greg Krudysz, 6-Mar-2008 (spfirst v1.47)
%   : Bug fixes in dltidemo, v2.5
%---------------------------------------------------------------------------
% Greg Krudysz, 4-Mar-2008 (spfirst v1.46)
%   : Removed SSN from nveloper.m, edited for warnings in woodwenv.m
%   : Fixed bug in Filterdesign
%---------------------------------------------------------------------------
% Greg Krudysz, 4-Dec-2007 (spfirst v1.44)
%   : Final release for Spring 2008 semester
%   : Updated Filterdesign & Pezdemo
%---------------------------------------------------------------------------
% Greg Krudysz, 26-Oct-2007 (spfirst v1.41)
%   : MATLAB R2007a update
%   : Updated Pezdemo, C/Dconvdemo
%---------------------------------------------------------------------------
% Greg Krudysz, 18-Jan-2007 (spfirst v1.40)
%   : Final release for Spring 2007 semester
%   : Updated Pezdemo and FilterDesign
%---------------------------------------------------------------------------
% Krudysz, 19-Mar-2006 (spfirst v1.36)
% 	: Updated Pezdemo
%---------------------------------------------------------------------------
% Krudysz, 19-Mar-2006 (spfirst v1.35)
% 	: Filterdesign update version 1.47 (from 1.3) (FIR filters addition)
% 	: Fixed bugs in /updated  cltidemo and pezdemo
%---------------------------------------------------------------------------
% Krudysz, Velmurugan, 30-Dec-2005 (spfirst v1.26)
% 	: Matlab 7.1 Update: 
%   : Addressed problems with axes() function in ML 7.1
%   : Renamed g/setuprop to g/setappdata, datestr, mode fcns
%   : Updated linewidthdlg.m
%---------------------------------------------------------------------------
% Greg Krudysz, 17-Dec-2004 (spfirst v1.25)
%   : Final release for Spring 2005 semester
%   : Added 'movietool' object for GUI recoring and playback
%     for con2dis,cltidemo,dltidemo,fseriesdemo,pezdemo
%---------------------------------------------------------------------------
%
%   fseriesdemo  v1.44
%   cconvdemo    v2.18
%   con2dis      v2.31
%   cltidemo     v2.60
%   dconvdemo    v3.18
%   dltidemo     v2.77
%   pezdemo      v2.90
%   phrace       v1.16
%   filterdesign v2.86
%   sindrill     v2.14
%   specgramdemo v2.82
%   strobedemo   v1.42
%   zdrill       v2.14

% if strcmp(computer,'PCWIN'),   Sep='\';
% elseif strcmp(computer,'MAC2'),  Sep=':';
% else,  Sep='/';
% end;
%----****----Use filesep instead

SP1_path = which('spfirst');
if(strcmp(SP1_path, ''))
    error('>> spfirst.m  must be in a directory already on your MATLAB path');
end

%% xx = findstr(SP1_path, Sep);
%% xx = xx(length(xx));	    % get last element of xx
%% SP1_path = SP1_path(1:xx-1);	% chop off dspfirst.m

SP_path  = fileparts(SP1_path);
ALL_dirs = {'sindrill', 'zdrill', 'fseriesdemo', 'phrace',...
            'cspin','cltidemo', 'dltidemo', 'cconvdemo', 'dconvdemo',...
            'pezdemo', 'con2dis', 'musiclab', 'filterdesign', 'strobedemo', 'specgramdemo'};
for kk = 1:length(ALL_dirs)
    if exist([SP_path, filesep, ALL_dirs{kk}],'dir')
        path(path,[SP_path, filesep, ALL_dirs{kk}]);
    end
end

mypath = path;
