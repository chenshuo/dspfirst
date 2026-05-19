function cconvdemo_callbacks(action)
%CCONVDEMO_CALLBACKS
%   This file contains the main code and callbacks for the CCONVDEMO
%   program.

% Jordan Rosenthal, 03-Nov-1999 : Adapted from CONVDEMO for discrete signals.
%        Rev. 1.01, 10-Nov-1999 : Fixed a bug in multiplypatch code
%        Rev. 1.02, 26-Mar-2000 : Added a simple installation check
%                               : Added try block to initialization code. 
%                               : Fixed 'Close' case to handle multiple instances
%                                 of GUI correctly.
%        Rev. 2.00, 26-Oct-2000 : Renamed to CCONVDEMO
%                               : Renamed class files to avoid conflicts with 
%                                 discrete convdemo classes.
%        Rev. 2.01  06-Nov-2000 : Fixed for SIGGENDLG to CSIGGENDLG name change.
%                               : Fixed for CCONVDEMO to CCONVDEMO_CALLBACKS name change.
%                               : Modified for better path handling.
%        Rev. 2.02  17-Nov-2000 : Fixed bug when creating delayed signals.
%        Rev. 2.04  01-Feb-2001 : Modified to run in R12
%        Rev. 2.05  12-Mar-2002 : Enabled HTML version of 'Help' 
%        Rev. 2.07  05-Dec-2002 : Release for SP First 
%        Rev. 2.08  08-Apr-2003 : small fixes, mostly for u(t). removed u(0)=1/2.
%        Rev. 2.09  13-Nov-2003 : XP bug; fixed resize in csiggendlg.m
%        Rev. 2.10  15-Feb-2004 : Added Gaussian Signal (@cgaussian)
%
spfirstVer =  'Revision: 2.18 30-Oct-2017';
NO = 0; YES = 1; OFF = 0; ON = 1;

if nargin == 0
   action = 'Initialize';
else
   h = get(gcbf, 'UserData');
end

switch(action)
   %-----------------------------------------------------------
case 'Initialize'
   %-----------------------------------------------------------
   try
      % All error checking moved to the CCONVDEMO function.  Keep this here as
      % well because we need the Matlab version number for some of the bug
      % workarounds.
      h.MATLABVER = versioncheck(5.2);     % Check Matlab Version
      
      %---  Set up GUI  ---%
      convgui;
      set(gcf, 'Name', ['Continuous Convolution Demo v' spfirstVer(10:14)]);
      h.LineWidth = 0.5;
      h.FigPos = get(gcf,'Pos');
      
      SCALE = getfontscale;          % Platform dependent code to determine SCALE parameter
      setfonts(gcf,SCALE);           % Setup fonts: override default fonts used in ltigui
      configresize(gcf);             % Change all 'units'/'font units' to normalized
  
      h = gethandles(h);             % Get GUI graphic handles
      h = defaultplots(h);           % Create default plots
      
      set(gcf,'UserData',h);
      set(gcf, 'WindowButtonMotionFcn', [mfilename ' WindowButtonMotionFcn']);
      
      set(gcf,'HandleVisibility','callback');    % Make figure inaccessible from command line            
   catch
      %---  Delete any GUI figures  --%
      delete(findall(0,'type','figure','tag','cconvdemo'));
      
      %---  Display the error to the user and exit  ---%
      errordlg(lasterr,'Error Initializing Figure');
      return;
   end
   %-----------------------------------------------------------
case 'SetFigureSize'   
   %-----------------------------------------------------------   
   % Center figure on screen
   OldUnits = get([0; gcf], 'units');
   set([0; gcf],'units','pixels');
   ScreenSize = get(0,'ScreenSize');
   FigPos = get(gcf,'Position');
   newFigPos = round([ (ScreenSize(3)-FigPos(3))/2  (ScreenSize(4)-FigPos(4))/2  FigPos(3:4) ]);
   set(gcf,'Pos',newFigPos);
   %   set(gcf,'ResizeFcn',[mfilename ' ResizeFcn']);
   set([0; gcf],{'units'},OldUnits);   
   %-----------------------------------------------------------
case 'ResizeFcn'   
   %-----------------------------------------------------------
   % For Matlab 5.1, this will not be called because 'Resize' = 'off'
   % Fix for bugs in normalized fontunits in Matlab 5.2.  
   % Force constant figure aspect ratio if in Matlab 5.3.
   FigPos = resizefcn(h.FigPos,gcbo,h.MATLABVER);  % Version dependent resize code
   switch computer
   case {'MAC2','PCWIN','GLNXA64'}
      % On MAC, baseline of text inside edit boxes remains at same
      % vertical position irregardless of change in font size.
      % To properly align text, here the old edit boxes are deleted
      % and new ones created with the proper size.
      hEd = findall(gcbf,'type','uicontrol','style','edit');
      OldFontUnits = get(hEd,'FontUnits');
      set(hEd,'FontUnits','Pixels');
      hEdNew = gobjects(size(hEd));
      relHeightChange = FigPos(4)/h.FigPos(4);
      for i = 1:length(hEd)
         Props = get(hEd(i));
         FontSize = relHeightChange*Props.FontSize;
         Props = rmfield(Props,{'Extent','Type','FontSize','FontUnits'});
         delete(hEd(i));
         hEdNew(i) = uicontrol('FontUnits','Pixels', ...
            'FontSize',FontSize,Props);
      end
      set(hEdNew,{'FontUnits'},OldFontUnits);
      h = gethandles(h);
      set(gcbf,'UserData',h);
   end
   h.FigPos = FigPos;         % Store old position
   set(gcbf,'UserData',h);   
   %-----------------------------------------------------------
case 'Get x(t)'
   %-----------------------------------------------------------
   getsignal('x(t)',h);   
   %-----------------------------------------------------------
case 'Get h(t)'
   %-----------------------------------------------------------
   getsignal('h(t)',h);  
   %-----------------------------------------------------------   
case 'FlipButton'
   %-----------------------------------------------------------
   set( h.Button.Radio, 'Value', OFF);
   
   if h.MATLABVER < 8.4
       flagUicontrol = strcmp( get(gcbo,'type'),'uicontrol');
   else
       flagUicontrol = isgraphics(gcbo,'uicontrol');
   end

   if flagUicontrol
      set( gcbo, 'Value', ON);
      SignalToFlip = get(gcbo, 'String');
   else
      MenuLabel = get(gcbo,'Label');
      switch MenuLabel
      case '&Flip x(t)'
         SignalToFlip = 'Flip x(t)';
         set(gcbo, 'Label', '&Flip h(t)');
         set( findobj(gcbf,'Style','radiobutton','String','Flip x(t)'), 'Value', ON);
      case '&Flip h(t)'
         SignalToFlip = 'Flip h(t)';
         set(gcbo, 'Label', '&Flip x(t)');
         set( findobj(gcbf,'Style','radiobutton','String','Flip h(t)'), 'Value', ON);
      end
   end
   h = sethandles(h,{'State','SignalToFlip'}, SignalToFlip);
   if h.State.DataInitialized
      initialize(h);
   end  
   %-----------------------------------------------------------
case 'WindowButtonMotionFcn'
   %-----------------------------------------------------------
   if h.State.DataInitialized
      [Mouse_x,Mouse_y] = mousepos;
      [x,y,w,ht] = arrowpos(h);
      if strcmp( lower( get(h.Button.Tutorial, 'Visible')), 'on')
         x = x(1);
         y = y(1);
         w = w(1);
         ht = ht(1);
      end
      if any( (x<Mouse_x) & (Mouse_x<x+w) & (y<Mouse_y) & (Mouse_y<y+ht) )
         setptr(gcbf, 'hand');
      else
         setptr(gcbf, 'arrow');
      end
   end
  %-----------------------------------------------------------
case 'KeyPressFcn'
    %-----------------------------------------------------------
    if h.State.DataInitialized
        CurrentChar = double( get(gcbf,'CurrentCharacter') );
        if ~isempty(CurrentChar) & any( CurrentChar == [52 54 28 29] )
            % 52 = numeric four
            % 54 = numeric six
            % 28 = left arrow
            % 29 = right arrow
          set(gcbf, 'KeyPressFcn', 'figure(gcbf)');
          if any(CurrentChar == [52 28])
              DistanceMoved = -1/2;
          else
              DistanceMoved = 1/2;
          end
          movesignal(DistanceMoved);
          set(gcbf, 'KeyPressFcn', [mfilename ' KeyPressFcn']);
      end
    end  
   %-----------------------------------------------------------
case 'SignalStartMove'
   %-----------------------------------------------------------
   setptr(gcbf, 'closedhand');
   currentPoint = get(gca, 'CurrentPoint');
   setappdata(gcbf, 'StartPos', currentPoint(1,1) );
   set(gcbf, 'WindowButtonMotionFcn', [mfilename ' SignalMove']);
   set(gcbf, 'WindowButtonUpFcn', [mfilename ' SignalStopMove']);
   %-----------------------------------------------------------
case 'SignalMove'
   %-----------------------------------------------------------
   currentPoint = get(gca, 'CurrentPoint');
   DistanceMoved = currentPoint(1,1) - getappdata(gcbf, 'StartPos');
   DistanceMoved = round(DistanceMoved*100)/100;
   movesignal(DistanceMoved);
   setappdata(gcbf, 'StartPos', currentPoint(1,1));   
   %-----------------------------------------------------------
case 'SignalStopMove'
   %-----------------------------------------------------------
   set(gcbf,'WindowButtonMotionFcn', [mfilename ' WindowButtonMotionFcn']);
   set(gcbf,'WindowButtonUpFcn','');
   setptr(gcbf,'hand'); 
   %-----------------------------------------------------------
case 'Tutorial Mode'
   %-----------------------------------------------------------
   hOutputPlots = findobj(h.Axis.Output);
   hText = h.Text.OutputLabel;
   OnText = {'Convolution','Click to hide plot'};
   OffText = 'Convolution';
   if strcmp(get(gcbo,'checked'),'off')
      set(gcbo,'checked','on');
      h = sethandles(h,{'State','TutorialMode'},ON);
      set(hOutputPlots, 'Visible', 'off', ...
         'ButtonDownFcn', [mfilename ' TutorialPlotClick']);
      set(h.Text.Arrows,'ButtonDownFcn',[mfilename ' SignalStartMove']);
      set(hText,'String',OnText);
      set(h.Button.Tutorial,'Visible','on');
   else
      set(gcbo,'checked','off');
      h = sethandles(h,{'State','TutorialMode'},OFF);
      set(h.Button.Tutorial,'Visible','off');
      set(hText,'String',OffText);
      set(hOutputPlots,'ButtonDownFcn','');
      set(h.Text.Arrows, 'ButtonDownFcn', [mfilename ' SignalStartMove']);
      set(findobj(h.Axis.Output),'visible','on');
   end   
   %-----------------------------------------------------------
case 'TutorialPlotClick'
   %-----------------------------------------------------------
   set(h.Button.Tutorial,'Visible','on');
   set(findobj(h.Axis.Output),'Visible','off');  
   %-----------------------------------------------------------
case 'TutorialButtonPush'
   %-----------------------------------------------------------
   set(h.Button.Tutorial, 'Visible', 'off');
   set(findobj(h.Axis.Output), 'Visible', 'on');   
   %-----------------------------------------------------------
case 'Conserve Space'
   %-----------------------------------------------------------
   hHideable = [ findobj(h.Axis.Hideable); h.Button.Hideable ];
   Axes_Pos = get(h.Axis.Big,'Position');
   TutorialButton_Pos = get(h.Button.Tutorial,'Position');
   if strcmp(get(gcbo,'checked'),'off')
      set(gcbo,'checked','on');
      set(hHideable,'visible','off');
      for i = 1:length(h.Axis.Big), Axes_Pos{i}(3) = 0.9; end
      TutorialButton_Pos(1) = 0.4;
      set(h.Axis.Big,{'Position'},Axes_Pos);
      set(h.Button.Tutorial,'Position', TutorialButton_Pos);
      changemenu('ConservedSpaceMenu');
   else
      set(gcbo,'checked','off');
      for i = 1:length(h.Axis.Big), Axes_Pos{i}(3) = 0.53; end
      TutorialButton_Pos(1) = 0.2150;
      set(h.Axis.Big,{'Position'},Axes_Pos);
      set(h.Button.Tutorial, 'Position', TutorialButton_Pos);
      set(hHideable,'visible','on');
      changemenu('NormalMenu');
   end 
   %-----------------------------------------------------------
case 'Grid On'
   %-----------------------------------------------------------
   hAxes = findobj(gcbf, 'Type', 'axes');
   if strcmp(get(gcbo,'checked'),'off')
      set(gcbo,'checked','on');
      set(hAxes, 'XGrid', 'on', 'YGrid', 'on');
   else
      set(gcbo,'checked','off'); 
      set(hAxes, 'XGrid', 'off', 'YGrid', 'off');
   end   
   %-----------------------------------------------------------
case 'Reset Axes'
   %-----------------------------------------------------------
   if h.State.DataInitialized
      set(h.Axis.Big, 'XLim', h.State.AxisXLim);
      h = sethandles(h,{'State','t'},h.State.tResetValue);
      initialize(h);
   end   
   %-----------------------------------------------------------
case 'Set t Value'
   %-----------------------------------------------------------
   if h.State.DataInitialized
      ans = inputdlg('New value for t?','Get t Value');
      if ~isempty(ans)
         t = str2num(ans{:});
         if ~isempty(t)
            h = sethandles(h,{'State','t'},t);
            initialize(h);
         end
      end
   end   
   %-----------------------------------------------------------
case 'Set Line Width'
   %-----------------------------------------------------------
   LineWidth = linewidthdlg(h.State.LineWidth);
   set(findobj(gcbf,'Type','line'), 'LineWidth', LineWidth);
   sethandles(h, {'State','LineWidth'}, LineWidth);    
   %-----------------------------------------------------------
case 'Screenshot'
   %-----------------------------------------------------------     
   screenshotdlg(gcbf);
   %---------------------------------------------------------------------------
case 'ShowMenu'
   %---------------------------------------------------------------------------
        check = get(findobj(gcbf, 'tag', 'ShowMenu'),'Checked');
        if strcmp(check,'off')
            set(gcbf,'MenuBar','figure');
            set(gcbo,'Checked','On');
        else
            set(gcbf,'MenuBar','none');
            set(gcbo,'Checked','Off');
        end      
   %-----------------------------------------------------------
case 'Help'
   %-----------------------------------------------------------
   hBar = waitbar(0.25,'Opening internet browser...');
   DefPath = which(mfilename);
   DefPath = ['file:///' strrep(DefPath,filesep,'/') ];
   URL = [ DefPath(1:end-21) , 'help/','index.html'];
   if h.MATLABVER >= 9
     STAT = web(URL,'-new');      
   elseif h.MATLABVER >= 6
     STAT = web(URL,'-browser');
   else
     STAT = web(URL);
   end
   waitbar(1);
   close(hBar);
   switch STAT
    case {1,2}
     s = {'Either your internet browser could not be launched or' , ...
      'it was unable to load the help page.  Please use your' , ...
      'browser to read the file:' , ...
      ' ', '     index.html', ' ', ...
      'which is located in the CConvDemo help directory.'};
     errordlg(s,'Error launching browser.');
   end   
   %-----------------------------------------------------------
case 'Close'
   %-----------------------------------------------------------
   delete(gcbf);  
   %-----------------------------------------------------------
otherwise
   %-----------------------------------------------------------
   error('Illegal Action');
end
%---------------------------------------------------------------------------
% changemenu(NewMenu)
%---------------------------------------------------------------------------
% This function is called to change the menus of the figure when going from
% Conserve Space mode and back.
function changemenu(NewMenu)
h = get(gcbf, 'UserData');
switch NewMenu
case 'ConservedSpaceMenu'
   delete(h.Menu.Help);
   uimenu('Parent',h.Menu.PlotOptions,'Label','C&lose','Tag','ConservedModeMenu', ...
      'Separator','on','CallBack',[mfilename ' Close']);
   a = uimenu('Parent',gcbf,'Label','&Signal','Tag','ConservedModeMenu');
   b = uimenu('Parent',a,'Label','Get &x(t)','Tag','ConservedModeMenu',...
      'CallBack',[mfilename '(''Get x(t)'');']);
   b = uimenu('Parent',a,'Label','Get &h(t)','Tag','ConservedModeMenu',...
      'CallBack',[mfilename '(''Get h(t)'');']);
   if strcmp(h.State.SignalToFlip, 'Flip x(t)')
      Label = '&Flip h(t)';
   else
      Label = '&Flip x(t)';
   end
   b = uimenu('Parent',a,'Label',Label,'Tag','TempMenu',...
      'CallBack',[mfilename '(''FlipButton'');'], 'Separator','on');
   a = uimenu('Parent',gcbf,'Label','&Help','Tag','ConservedModeMenu');
   b = uimenu('Parent',a,'Label','&Navigate to help files with default browser', ...
      'Tag','ConservedModeMenu','CallBack',[mfilename ' Help;']);
case 'NormalMenu'
   delete(findobj(gcbf,'Tag','ConservedModeMenu'));
   a = uimenu('Parent',gcbf,'Label','&Help','Tag','Help');
   b = uimenu('Parent',a,'Label','&Navigate to help files with default browser', ...
      'Tag','ConservedModeMenu','CallBack',[mfilename ' Help;']);
   sethandles(h,{'Menu','Help'},a);
end
%-----------------------------------------------------------
%  getsignal(Sig,h)
%-----------------------------------------------------------
% This function is called when the "Get x(t)" / "Get h(t)" buttons are 
% pushed.
function getsignal(Sig,h)
YES = 1; NO = 0;
switch Sig
case 'x(t)'
   CurrentSignal = h.Data.Input.x;
   hSigAxis = h.Axis.x;
   AxisTitle = 'Input';
   SigName = {'Data','Input','x'};
   OtherSigName = {'Data','Input','h'};
case 'h(t)'
   CurrentSignal = h.Data.Input.h;
   hSigAxis = h.Axis.h;
   AxisTitle = 'Impulse Response';
   SigName = {'Data','Input','h'};
   OtherSigName = {'Data','Input','x'};
end
if ~isempty(CurrentSignal)
   if CurrentSignal.IsImpulse
      CurrentSignal.Object.PlotScale = 1;
   end
   eval(['SigTemplate=' class(CurrentSignal.Object) '(CurrentSignal.Object);']);
   NewSignal.Object = csiggendlg( SigTemplate, ...
      'Title',['Get ' Sig], 'LineWidth', h.State.LineWidth );
else
   NewSignal.Object = csiggendlg('Title',['Get ' Sig],'LineWidth',h.State.LineWidth);
end
if ~isempty( NewSignal.Object )
   supp = support(NewSignal.Object);
   if isa(NewSignal.Object,'cimpulse')
      NewSignal.IsImpulse = YES;
      a = supp - 10;
      b = supp + 10;
      NSamples = -inf;
   else
      NewSignal.IsImpulse = NO;
      a = supp(1) - 0.5*diff(supp);
      b = supp(2) + 0.5*diff(supp);
      fs = suggestrate(NewSignal.Object,[a b]);
      NSamples = diff([a b])*fs + 1;
   end
   if NSamples > h.State.MaxPlotPoints
      msg = {'This signal you chose requires too much memory to', ...
            ' accurately model.  Please choose a different signal.'};
      errordlg(msg,'Error','modal');
   else
      axes(hSigAxis);
      hObj = ezplot(NewSignal.Object,'LineWidth',h.State.LineWidth);
      title(AxisTitle,'FontWeight','bold','FontUnits','normalized','FontSize',0.13);
      if strcmp( lower( get(h.Menu.ConserveSpace, 'Checked') ), 'on')
         set(findobj(hSigAxis),'Visible','off');
      end
      if NewSignal.IsImpulse
         % : Set the axis x limits, y-limits, and turn off the YTicks.
         % : Change the color of the arrow
         % : Make the text fit better in the axis
         % : Adjust the arrow data so it fits better later in the signal axis
         % : Save the text object for later use
         set(hSigAxis,'XLim',10/1.2*[-1 1] + NewSignal.Object.Delay, ...
            'YLim',[0 1.1],'YTick',[]);
         set(hObj(1),'facecolor','b','edgecolor','b');
         NewSignal.Object.PlotScale = 0.5;
         txtData = get(hObj(2),{'FontSize','Pos'});
         OFFSET = [0.75 0 0];
         FONTSCALING = 3;
         set(hObj(2),'fontsize',FONTSCALING*txtData{1},'pos',txtData{2} + OFFSET);
         NewSignal.XData = get(hObj(1),'XData');
         NewSignal.YData = get(hObj(1),'YData');
         NewSignal.ImpulseTextPos = get(hObj(2),'Pos');
      else
         % : Set the axis x limits, y-limits, and turn on the YTicks
         % : Save the object plot data for later
         % : Set the text object data to null since that only applies to impulses
         NewSignal.XData = get(hObj,'XData');
         NewSignal.YData = get(hObj,'YData');
         NewSignal.ImpulseTextPos = [];
         YLims = [min(NewSignal.YData) max(NewSignal.YData)];
         YLims = YLims + diff(YLims)/10*[-1 1];
         set(hSigAxis,'XLim',[a b],'YLim',YLims,'YTickMode','auto');
      end
      h = sethandles(h, SigName, NewSignal);  
      if ~isempty( getfield(h, OtherSigName{:}) )
         initialize(h);
      end
   end
end