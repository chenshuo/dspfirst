function outSignal = csiggendlg(varargin)
%CSIGGENDLG  Signal generator dialog.
%   Signal = CSIGGENDLG() creates a graphical user interface (GUI)
%   that lets the user interactively generate signals.  It returns an object
%   Signal corresponding to the values chosen.
%
%   Signal = CSIGGENDLG(DefSignal) sets the initial signal to the signal object given
%   by DefSignal.
%
%   Signal = CSIGGENDLG(type) set the initial signal to the default of the signal
%   object given by the string type.
%
%   Signal = CSIGGENDLG(...,'Title',s) also changes the dialog's figure title from the
%   default of 'Get Signal' to the given string s.
%
%   Signal = CSIGGENDLG(...,'LineWidth',x) sets the line widths used to x
%
%   A signal object must be created in the same directory as CSIGGENDLG.M.  To create
%   a signal object make a @signal_name directory (lowercase).  Then within that
%   directory the following files are necessary:
%
%      display.m        Text display of the object
%      formulastring.m  Formula string to be displayed above stem plot
%      gui.m            Creates the GUI info necessary for this signal
%      signal_name.m    Object creation m-file
%      plot.m           Plots the signal appropriately
%
%   See any of the examples included for the appropriate nature of the above files.
%
%   For parameter names, see the appropriate Signal object's description.

% Jordan Rosenthal, 11/03/99
%   Based on code for discrete convdemo.m
%             Rev., 26-Oct-2000 Revised default signal since named changed to CPULSE
%             Rev., 05-Nov-2000 Rename to CSIGGENDLG to avoid conflicts with discrete
%                               version.
%             Rev., 01-Oct-2003 Rajbabu, Added 'Resize' 'on' to dialog box for 'Get Signal'
%                               to fix a problem with Win XP.

DEFSIGNAL = 'cpulse';  % The class name of the default signal
DEFPATH = which('csiggendlg.m');
CLASSDIRS = dir([DEFPATH(1:end-12) '@*']);
CLASSFCN = cell(length(CLASSDIRS),1);
SIGNALS = cell(length(CLASSDIRS),1);
for i = 1:length(CLASSDIRS)
   CLASSFCN{i} = CLASSDIRS(i).name(2:end);
   f = eval(CLASSFCN{i});
   SIGNALS{i} = f.Name;
end
DEFSIGNAL = strmatch(DEFSIGNAL,CLASSFCN,'exact');
DEFTITLE = 'Get Signal';
DEFLINEWIDTH = 2;
REMOVE = [];
for i = 1:length(varargin)
   if isstr(varargin{i})
      switch lower(varargin{i})
      case 'title'
         DEFTITLE = varargin{i+1};
         REMOVE = [REMOVE i i+1];
      case 'linewidth'
         DEFLINEWIDTH = varargin{i+1};
         REMOVE = [REMOVE i i+1];
      end
   end
end
varargin(REMOVE) = [];
NArgs = nargin-length(REMOVE);

%%%  Parse input arguments  %%%
switch NArgs
case 0
   Signal = eval( CLASSFCN{DEFSIGNAL} );
   action = 'Initialize';
case 1
   for i = 1:length(SIGNALS), SIGS{i} = lower( SIGNALS{i} );, end
   if any( strcmp(class(varargin{1}), CLASSFCN) )
      DEFSIGNAL = find( strcmp(class(varargin{1}), CLASSFCN) );
      Signal = varargin{1};
      action = 'Initialize';
   else
      switch lower( varargin{1} )
      case SIGS
         DEFSIGNAL = find( strcmp(lower(varargin{1}), SIGS) );
         Signal = eval( CLASSFCN{DEFSIGNAL} );
         action = 'Initialize';
      otherwise
         action = varargin{1};
      end
   end
otherwise
   error('Wrong number of input parameters');
end

%%%  Perform actions  %%%
switch action
case 'ChooseSignal'
   hSignalMenu = findobj(gcbf,'Tag','SignalMenu');
   hShouldDelete = setdiff( get(gcbf,'Children'), ...
      [hSignalMenu; ...
         findobj(gcbf,'Tag','MenuFrame'); ...
         findobj(gcbf,'Tag','MenuLabel'); ...
         findobj(gcbf,'Tag','OK'); ...
         findobj(gcbf,'Tag','Cancel')] );
   delete(hShouldDelete);
   Signal = eval( CLASSFCN{ get(hSignalMenu,'Value') } );
   set(gcbf,'UserData',Signal);
   gui(Signal, [0 0 1 0.9]);
case 'OK'
   uiresume(gcbf);
case 'Cancel'
   set(gcbf,'UserData',[]);
   uiresume(gcbf);
case 'Initialize'
   %%%  Create GUI.  %%%
   OldUnits = get(0, 'Units');
   set(0, 'Units','pixels');
   ScreenSize = get(0,'ScreenSize');
   set(0, 'Units', OldUnits);
   FigPos = [0.15*ScreenSize(3), 0.15*ScreenSize(4), 0.7*ScreenSize(3), 0.7*ScreenSize(4)];
   hDlg = dialog('Name',DEFTITLE, ...
       'Units','pixels', ...
       'CloseRequestFcn',[mfilename ' Cancel'], ...
       'Color',get(0,'DefaultFigureColor'), ...
       'DefaultLineLineWidth',DEFLINEWIDTH, ...
       'Position', FigPos, ...
       'Tag','Get Signal', ...
       'HandleVisibility','on', ...
       'UserData',Signal, ...
       'WindowStyle','modal');
   
   MATLABVERSION = version;
   MATLABVERSION = str2num(MATLABVERSION(1:3));
   
   if MATLABVERSION < 8.4
       set(hDlg,'Resize', 'on','DoubleBuffer','on');
   end
   
   %%%  Create Popup Signal Menu, frame, and label %%%
   uicontrol('Parent',hDlg, ...
       'BackgroundColor',[0.65 0.65 0.65], ...
       'ForegroundColor',[0.65 0.65 0.65], ...
       'Units','normalized', ...
       'pos',[0 0.9 1 0.15], ...
       'style','frame', ...
       'Tag','MenuFrame');
   hSigMenu = uicontrol('Parent',hDlg, ...
      'Units','normalized', ...
      'Position',[0.4 0.925 0.2 0.05], ...
      'BackgroundColor','w', ...
      'CallBack',[mfilename ' ChooseSignal'], ...
      'FontWeight','bold', ...
      'FontUnits','normalized', ...
      'String', SIGNALS, ...
      'Style','popupmenu', ...
      'Tag','SignalMenu', ...
      'Value',DEFSIGNAL);
   uicontrol('Parent',hDlg, ...
      'BackgroundColor',[0.65 0.65 0.65], ...
      'Units','normalized', ...
      'Position',[0.3 0.92 0.1 0.05], ...
      'FontWeight','bold', ...
      'FontUnits','normalized', ...
      'String','Signal:', ...
      'style','text', ...
      'Tag','MenuLabel');

   %%%  Create OK and Cancel buttons  %%%
   uicontrol('Parent',hDlg, ...
      'Units','normalized', ...
      'CallBack',[mfilename ' OK'], ...
      'FontUnits','normalized', ...
      'FontWeight','bold', ...
      'Position',[0.63 0.05 0.15 0.07], ...
      'String','OK', ...
      'Style','pushbutton', ...
      'Tag','OK');
   uicontrol('Parent',hDlg, ...
      'Units','normalized', ...
      'CallBack',[ mfilename ' Cancel'], ...
      'FontUnits','normalized', ...    
      'FontWeight','bold', ...
      'Position',[0.8 0.05 0.15 0.07], ...
      'String','Cancel', ...
      'Style','pushbutton', ...
      'Tag','Cancel');
  
   %%%  Create controls  %%%
   gui(Signal, [0 0 1 0.9]);

   uiwait(hDlg);
   Signal = get(hDlg, 'UserData');
   if isempty(Signal)
      outSignal = [];
   else
      outSignal = Signal;
   end
   delete(hDlg);
otherwise
   error('Illegal action.');
end