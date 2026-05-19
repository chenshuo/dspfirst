function dconvdemo_callbacks(action)
%DCONVDEMO_CALLBACKS
%   This file contains the main code and callbacks for the DCONVDEMO
%   program.

% Jordan Rosenthal, 12/14/97
%     Rev. 2.00, 08-May-1998
%     Rev. 2.01, 04-Oct-1999 : Made it work in Matlab 5.3.
%     Rev. 2.02, 02-Apr-2000 : Updated intialization case.
%                            : Cleaned up some code and added more comments.
%                            : Added a simple installation check
%                            : Added try block to initialization code.
%                            : Fixed 'Close' case to handle multiple instances
%                              of GUI correctly.
%                            : Fixed a problem occuring when in circular
%                              convolution and tutorial mode at the same time.
%     Rev. 2.03, 15-May-2000 : Improved signal dragging response
%     Rev. 3.00, 06-Nov-2000 : Renamed to DCONVDEMO_CALLBACKS
%                            : Modified for better path handling
%     Rev. 3.01, 01-Feb-2001 : Modified to run in R12
%     Rev. 3.02, 31-Aug-2001 : AXISXLIM acts like a global so define it here (JMc)
%     Rev. 3.05, 13-Nov-2003 : XP bug; fix resize in siggendlg.m (JMc)
%     Rev. 3.06, 17-Feb-2004 : Added 'User Signal' as a new type of signal
%                              (Rajbabu)
%     Rev. 3.08, 06-Mar-2009 : Added stemdata.m to fix stem('v6', ...)
%                               warning (Greg Krudysz)
%     Rev. 3.12, 25-Jan-2015 : R2014b upgrades (Greg Krudysz)
%     Rev. 3.15, 24-Jun-2015 : R2015a upgrades (Greg Krudysz)
%     Rev. 3.16, 30-Mar-2016 : R2016a upgrades (Greg Krudysz)

spfirstVer =  'Revision: 3.18 07-Mar-2017';
NO = 0; YES = 1; OFF = 0; ON = 1;
%--------------------------------------------------------------------------------
% Default Settings
%--------------------------------------------------------------------------------
AXISXLIM       = [-25 25];

if nargin == 0
   action = 'Initialize';
else
   h = get(gcbf, 'UserData');
end

switch(action)
   %---------------------------------------------------------------------------
case 'Initialize'
   %---------------------------------------------------------------------------
   try
      % All error checking moved to the DCONVDEMO function.  Keep this here as
      % well because we need the Matlab version number for some of the bug
      % workarounds.
      h.MATLABVER = versioncheck(5.2);     % Check Matlab Version

      %---  Set up GUI  ---%
      convgui;
      set(gcf, 'Name', ['Discrete Convolution Demo v' spfirstVer(10:14)]);
      h.LineWidth = 0.5;
      h.AxisMargin = 1.1;
      h.FigPos = get(gcf,'Pos');

      SCALE = getfontscale;          % Platform dependent code to determine SCALE parameter
      setfonts(gcf,SCALE);           % Setup fonts: override default fonts used in ltigui
      configresize(gcf);             % Change all 'units'/'font units' to normalized

      h = gethandles(h);             % Get GUI graphic handles
      h = defaultplots(h,AXISXLIM);  % Create default plots

      set(gcf,'UserData',h);
      set(gcf, 'WindowButtonMotionFcn',[mfilename ' WindowButtonMotionFcn']);
      set(gcf,'HandleVisibility','callback');    % Make figure inaccessible from command line

   catch
      %---  Delete any GUI figures and remove from path if necessary  --%
      delete(findall(0,'type','figure','tag','dconvdemo'));

      %---  Display the error to the user and exit  ---%
      errordlg(lasterr,'Error Initializing Figure');
      return;
   end
   %---------------------------------------------------------------------------
case 'SetFigureSize'
   %---------------------------------------------------------------------------
   OldUnits = get(0, 'Units');
   set(0, 'Units','pixels');
   ScreenSize = get(0,'ScreenSize');
   set(0, 'Units', OldUnits);
   FigSize = [0.15*ScreenSize(3), 0.2*ScreenSize(4), 0.7*ScreenSize(3), 0.6*ScreenSize(4)];
   set(gcbf, 'Position', FigSize);
   %---------------------------------------------------------------------------
case 'InitTextBox'
   %---------------------------------------------------------------------------
   Props_Common = {'Tag','InitTextInfo','FontUnits','normalized', ...
         'FontSize',0.1,'FontWeight','bold','HorizontalAlignment','center'};
   PropNames_Unique = {'String','color','Position'};
   PropVals_Unique = {'To Start','b',[0.5,0.1]; ...
         {'Pick both an input signal', ...
            'and an impulse response.', ...
            ' ', ...
            'Then drag pointers or use the', ...
            '4 and 6 keys to slide the', ...
            'flipped signal around.'},'k',[0.5 0.55]};
   hText = text(zeros(2,1),zeros(2,1),'',Props_Common{:});
   set(hText,PropNames_Unique,PropVals_Unique);
   %---------------------------------------------------------------------------
case 'InitAxis'
   %---------------------------------------------------------------------------
   set(gcbo, 'XLim', AXISXLIM);
   %---------------------------------------------------------------------------
case 'Get x[n]'
   %---------------------------------------------------------------------------
   getsignal('x[n]');
   %---------------------------------------------------------------------------
case 'Get h[n]'
   %---------------------------------------------------------------------------
   getsignal('h[n]');
   %---------------------------------------------------------------------------
case 'FlipButton'
   %---------------------------------------------------------------------------
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
      case '&Flip x[n]'
         SignalToFlip = 'Flip x[n]';
         set(gcbo, 'Label', '&Flip h[n]');
         set( findobj(gcbf,'Style','radiobutton','String','Flip x[n]'), 'Value', ON);
      case '&Flip h[n]'
         SignalToFlip = 'Flip h[n]';
         set(gcbo, 'Label', '&Flip x[n]');
         set( findobj(gcbf,'Style','radiobutton','String','Flip h[n]'), 'Value', ON);
      end
   end
   sethandles(h,{'State','SignalToFlip'}, SignalToFlip);
   if h.State.DataInitialized
      initialize;
   end
   %---------------------------------------------------------------------------
case 'WindowButtonMotionFcn'
   %--------------------------------------------------------------------------
   if h.State.DataInitialized

      [Mouse_x,Mouse_y] = mousepos;
      [x,y,w,ht] = arrowpos;
      if ~h.State.CircularMode
         if strcmpi(get(h.Button.Tutorial.Linear,'Visible'), 'on')
            x = x(1);
            y = y(1);
            w = w(1);
            ht = ht(1);
         end
      else
         if strcmpi(get(h.Button.Tutorial.Linear,'Visible'),'on')
            x = x(1,3);
            y = y(1,3);
            w = w(1,3);
            ht = ht(1,3);
         end
         if strcmpi(get(h.Button.Tutorial.Circular,'Visible'),'on')
            x = x(1);
            y = y(1);
            w = w(1);
            ht = ht(1);
         end
      end
      if any( (x<Mouse_x) & (Mouse_x<x+w) & (y<Mouse_y) & (Mouse_y<y+ht) )
         setptr(gcbf, 'hand');
      else
         setptr(gcbf, 'arrow');
      end
   end
   %---------------------------------------------------------------------------
case 'KeyPressFcn'
   %---------------------------------------------------------------------------
   if h.State.DataInitialized
      CurrentChar = double( get(gcbf,'CurrentCharacter') );
      if ~isempty(CurrentChar) & any( CurrentChar == [52 54 28 29] )
            % 52 = numeric four
            % 54 = numeric six
            % 28 = left arrow
            % 29 = right arrow
          set(gcbf, 'KeyPressFcn', 'figure(gcbf)');
         if any(CurrentChar == [52 28])
            DistanceMoved = -1;
         else
            DistanceMoved = 1;
         end
         if h.State.CircularMode
            changeconvlength(DistanceMoved);
            feval(mfilename,'StopChangeCircularLength');
         else
            movesignal(DistanceMoved);
         end
         set(gcbf, 'KeyPressFcn', [mfilename ' KeyPressFcn']);
      end
   end
   %---------------------------------------------------------------------------
case 'SignalStartMove'
   %---------------------------------------------------------------------------
   setptr(gcbf, 'closedhand');
   currentPoint = get(gca, 'CurrentPoint');
   setappdata(gcbf, 'StartPos', currentPoint(1,1) );
   set(gcbf, 'WindowButtonMotionFcn', [mfilename ' SignalMove']);
   set(gcbf, 'WindowButtonUpFcn', [mfilename ' SignalStopMove']);
   %---------------------------------------------------------------------------
case 'SignalMove'
   %---------------------------------------------------------------------------
   currentPoint = get(gca, 'CurrentPoint');
   DistanceMoved = fix( currentPoint(1,1) - getappdata(gcbf, 'StartPos') );
   if DistanceMoved ~= 0
      movesignal(DistanceMoved);
      setappdata(gcbf, 'StartPos', currentPoint(1,1));
   end
   %---------------------------------------------------------------------------
case 'SignalStopMove'
   %---------------------------------------------------------------------------
   set(gcbf, 'WindowButtonMotionFcn', [mfilename ' WindowButtonMotionFcn']);
   set(gcbf, 'WindowButtonUpFcn', '');
   setptr(gcbf,'hand');
   %---------------------------------------------------------------------------
case 'StartChangeCircularLength'
   %---------------------------------------------------------------------------
   setptr(gcbf, 'closedhand');
   currentPoint = get(gca, 'CurrentPoint');
   setappdata(gcbf, 'StartPos', currentPoint(1,1) );
   set(gcbf, 'WindowButtonMotionFcn', [ mfilename ' ChangeCircularLength']);
   set(gcbf, 'WindowButtonUpFcn', [ mfilename ' StopChangeCircularLength']);
   %---------------------------------------------------------------------------
case 'ChangeCircularLength'
   %---------------------------------------------------------------------------
   currentPoint = get(gca, 'CurrentPoint');
   DistanceMoved = fix( currentPoint(1,1) - getappdata(gcbf, 'StartPos') );
   if DistanceMoved ~= 0
      changeconvlength(DistanceMoved);
      setappdata(gcbf, 'StartPos', currentPoint(1,1));
   end
   %---------------------------------------------------------------------------
case 'StopChangeCircularLength'
   %---------------------------------------------------------------------------
   set(gcbf, 'WindowButtonMotionFcn', [ mfilename ' WindowButtonMotionFcn']);
   set(gcbf, 'WindowButtonUpFcn', '');
   rescalecircplots;
   setptr(gcbf,'hand');
   %---------------------------------------------------------------------------
case 'Tutorial Mode'
   %---------------------------------------------------------------------------
   hOutputPlots = findobj([h.Axis.Output; h.Axis.CircularOutput]);
   hText = [h.Text.OutputLabel; h.Text.CircularOutputLabel];
   OnText = {{'Linear Convolution','Click to hide plot'}; ...
         {'Circular Convolution','Click to hide plot'}};
   OffText = {'Linear Convolution';'Circular Convolution'};
   if strcmp(get(gcbo,'checked'),'off')
       set(gcbo,'checked','on');
      h = sethandles(h,{'State','TutorialMode'},ON);
      set(hOutputPlots, 'Visible', 'off', ...
         'ButtonDownFcn', [ mfilename ' TutorialPlotClick']);
      set(h.Text.Arrows,'ButtonDownFcn',[ mfilename ' SignalStartMove']);
      set(h.Text.CircularConvLength, ...
         'ButtonDownFcn', [ mfilename ' StartChangeCircularLength']);
      set(hText,{'String'},OnText);
      if h.State.CircularMode
         set(h.Button.Tutorial.Both,'Visible','on');
      else
         set(h.Button.Tutorial.Linear,'Visible','on');
      end
   else
       set(gcbo,'checked','off');
      h = sethandles(h,{'State','TutorialMode'},OFF);
      set(h.Button.Tutorial.Both,'Visible','off');
      set(hText,{'String'},OffText);
      set(hOutputPlots,'ButtonDownFcn','');
      set(h.Text.Arrows, 'ButtonDownFcn', [ mfilename ' SignalStartMove']);
      set(h.Text.CircularConvLength, ...
         'ButtonDownFcn', [ mfilename ' StartChangeCircularLength']);
      if h.State.CircularMode
         set(hOutputPlots,'Visible','on');
      else
         set(findobj(h.Axis.Output),'visible','on');
         if h.State.DataInitialized
            set(h.Lines.AliasSections(1),'visible','off');
         end
      end
   end
   %---------------------------------------------------------------------------
case 'TutorialPlotClick'
   %---------------------------------------------------------------------------
   if any( gcbo==findobj(h.Axis.Output) )
      set(h.Button.Tutorial.Linear,'Visible','on');
      set(findobj(h.Axis.Output),'Visible','off');
   else
      set(h.Button.Tutorial.Circular,'Visible','on');
      set(findobj(h.Axis.CircularOutput),'Visible','off');
   end
   %---------------------------------------------------------------------------
case 'TutorialButtonPush'
   %---------------------------------------------------------------------------
   if gcbo == h.Button.Tutorial.Linear
      set(h.Button.Tutorial.Linear, 'Visible', 'off');
      set(findobj(h.Axis.Output), 'Visible', 'on');
      if ~h.State.CircularMode & h.State.DataInitialized
         set(h.Lines.AliasSections,'visible','off');
      end
   else
      set(h.Button.Tutorial.Circular, 'Visible', 'off');
      set(findobj(h.Axis.CircularOutput), 'Visible', 'on');
   end
   %---------------------------------------------------------------------------
case 'Circular Mode'
   %---------------------------------------------------------------------------
   if strcmp(get(gcbo,'checked'),'off')
       set(gcbo,'checked','on')
      h = sethandles(h,{'State','CircularMode'},ON);
      if h.State.TutorialMode
         set(h.Button.Tutorial.Circular,'Visible','on');
         if ~isempty(h.Lines.AliasSections)
            if strcmpi(get(h.Button.Tutorial.Linear,'visible'),'on')
               set(h.Lines.AliasSections(1),'visible','off');
            else
               set(h.Lines.AliasSections(1),'visible','on');
            end
         end
      else
         set(findobj(h.Axis.CircularOutput),'Visible','on');
         set(h.Lines.AliasSections,'visible','on');
      end
      if h.State.DataInitialized
         hFormulasText = textbox(h);
         highlightaliaseddata(ON);
      end
      positionplots;
   else
      set(gcbo,'checked','off')
      h = sethandles(h,{'State','CircularMode'},OFF);
      highlightaliaseddata(OFF);
      set([h.Button.Tutorial.Circular; findobj(h.Axis.CircularOutput)], ...
         'Visible','off');
      if h.State.DataInitialized
         hFormulasText = textbox(h);
         set(h.Lines.AliasSections(1),'Visible','off');
      end
      positionplots;
   end
   if h.State.DataInitialized & strcmpi(get(h.Menu.ConserveSpace,'Checked'),'on')
      set(hFormulasText,'Visible','off');
   end
   %---------------------------------------------------------------------------
case 'Conserve Space'
   %---------------------------------------------------------------------------
   hHideable = [ findobj(h.Axis.Hideable); h.Button.Hideable ];
   Axes_Pos = get(h.Axis.Big,'Position');
   TutorialButton_Pos = get(h.Button.Tutorial.Both,'Position');
   if strcmp(get(gcbo,'checked'),'off')
      set(gcbo,'checked','on');
      set(hHideable,'visible','off');
      for i = 1:length(h.Axis.Big), Axes_Pos{i}(3) = 0.9; end
      for i = 1:2, TutorialButton_Pos{i}(1) = 0.4; end
      set(h.Axis.Big,{'Position'},Axes_Pos);
      set(h.Button.Tutorial.Both,{'Position'}, TutorialButton_Pos);
      changemenu('ConservedSpaceMenu');
   else
      set(gcbo,'checked','off');
      for i = 1:length(h.Axis.Big), Axes_Pos{i}(3) = 0.53; end
      for i = 1:2, TutorialButton_Pos{i}(1) = 0.2150; end
      set(h.Axis.Big,{'Position'},Axes_Pos);
      set(h.Button.Tutorial.Both, {'Position'}, TutorialButton_Pos);
      set(hHideable,'visible','on');
      changemenu('NormalMenu');
   end
   %---------------------------------------------------------------------------
case 'Grid On'
   %---------------------------------------------------------------------------
   hAxes = findobj(gcbf, 'Type', 'axes');
   if strcmp(get(gcbo,'checked'),'off')
      set(gcbo,'checked','on');
      set(hAxes, 'XGrid', 'on', 'YGrid', 'on');
   else
      set(gcbo,'checked','off');
      set(hAxes, 'XGrid', 'off', 'YGrid', 'off');
   end
   %---------------------------------------------------------------------------
case 'Reset Axes'
   %---------------------------------------------------------------------------
   if h.State.DataInitialized
      set(h.Axis.Big, 'XLim', h.State.AxisXLim);
      initialize;
   end
   %---------------------------------------------------------------------------
case 'Set Line Width'
   %---------------------------------------------------------------------------
   LineWidth = linewidthdlg(h.State.LineWidth);
   set(findobj(gcbf,'Type','line'), 'LineWidth', LineWidth);
   set(h.Lines.AliasSections,'LineWidth',LineWidth+1);
   sethandles(h, {'State','LineWidth'}, LineWidth); 
   %---------------------------------------------------------------------------
case 'Set Font Size'
   %---------------------------------------------------------------------------
   oldFontUnits = get(h.Axis.Signal,'fontunits');
   set(h.Axis.Signal,'fontunits','points');
   currentFS = get(h.Axis.Signal,'fontsize');
   
   FontSize = fontsizedlg(currentFS);
   hTx = findobj(gcbf,'Type','text');
   hAx = findobj(gcbf,'Type','axes');
   set([hTx;hAx],'FontUnits','points','FontSize',FontSize);
   titles = get(hAx,'Title');
   for t=1:length(titles)
       set(titles{t},'FontUnits','points','FontSize',FontSize);
       set(titles{t},'FontUnits','normalized');
   end
   set([hTx;hAx], 'FontUnits', 'normalized'); 
   sethandles(h, {'State','FontSize'}, FontSize);
   %---------------------------------------------------------------------------
case 'Screenshot'
   %---------------------------------------------------------------------------
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
   %---------------------------------------------------------------------------
case 'Help'
   %---------------------------------------------------------------------------
   hBar = waitbar(0.25,'Opening internet browser...');
   DefPath = which(mfilename);
   DefPath = ['file:///' strrep(DefPath,filesep,'/') ];
   URL = [ DefPath(1:end-21) , 'help/','index.html'];
   if h.MATLABVER >= 6
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
            'which is located in the DConvDemo help directory.'};
      errordlg(s,'Error launching browser.');
   end

   %---------------------------------------------------------------------------
case 'Close'
   %---------------------------------------------------------------------------
   delete(gcbf);
otherwise
   error('Illegal Action');
end

%---------------------------------------------------------------------------
%---------------------------------------------------------------------------

%---------------------------------------------------------------------------
% positionplots()
%---------------------------------------------------------------------------
% This function is called when going to or from circular convolution
% mode and is used to position all appropriate objects.
function positionplots()
h = get(gcbf,'UserData');
SPACING = 0.05;
LEFT = 0.05;
if strcmpi(get(h.Menu.ConserveSpace,'Checked'),'on')
   WIDTH = 0.9;
else
   WIDTH = 0.53;
end
if h.State.CircularMode
   nVisiblePlots = 4;
   set(h.Axis.Output,'XTickLabel','');
   hPlots = [h.Axis.CircularOutput , h.Axis.Output, ...
         h.Axis.Multiply , h.Axis.Signal];
else
   nVisiblePlots = 3;
   set(h.Axis.Output,'XTickLabelMode','auto');
   hPlots = [h.Axis.Output, h.Axis.Multiply h.Axis.Signal];
end
HEIGHT = (1-(2+nVisiblePlots-1)*SPACING)/nVisiblePlots;
Bottom = (HEIGHT+SPACING)*[0:nVisiblePlots-1] + SPACING;
for i = 1:nVisiblePlots
   set(hPlots(i),'Position',[LEFT Bottom(i) WIDTH HEIGHT]);
end
Pos = get(h.Button.Tutorial.Both,'Position');
if h.State.CircularMode
   Pos{1}(2) = Bottom(2)+(HEIGHT-0.05)/2; % Linear Button
   Pos{2}(2) = Bottom(1)+(HEIGHT-0.05)/2; % Circular Button
else
   Pos{1}(2) = Bottom(1)+(HEIGHT-0.05)/2; % Linear Button
end
set(h.Button.Tutorial.Both, {'Position'}, Pos);

%---------------------------------------------------------------------------
% rescalecircplots()
%---------------------------------------------------------------------------
% This function is called after the circular convolution length is finished
% changing (when the user has let up the mouse) and rescales the y axis
% of the circular convolution plot.  If this was not done, some data could
% be outside the plot axis.
function rescalecircplots()
h = get(gcbf,'UserData');
min_Y = min(0,min(h.Data.CircularOutput.YData));
max_Y = max(h.Data.CircularOutput.YData);
if min_Y == max_Y
   min_Y = min_Y - 1;
   max_Y = max_Y + 1;
end
set(h.Axis.CircularOutput,'YLim',[min_Y, max_Y]);
NTextPos = get(h.Text.CircularConvLength,'Position');
set(h.Text.CircularConvLength,'Position',[NTextPos(1) max_Y]);
NLineYData = get(h.Lines.AliasSections(1),'YData');
NLineYData(1:3:end) = min_Y;
NLineYData(2:3:end) = max_Y;
set(h.Lines.AliasSections(2),'YData',NLineYData);


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
   b = uimenu('Parent',a,'Label','Get &x[n]','Tag','ConservedModeMenu',...
      'CallBack',[ mfilename '(''Get x[n]'');']);
   b = uimenu('Parent',a,'Label','Get &h[n]','Tag','ConservedModeMenu',...
      'CallBack',[ mfilename '(''Get h[n]'');']);
   if strcmp(h.State.SignalToFlip, 'Flip x[n]')
      Label = '&Flip h[n]';
   else
      Label = '&Flip x[n]';
   end
   b = uimenu('Parent',a,'Label',Label,'Tag','TempMenu',...
      'CallBack',[ mfilename '(''FlipButton'');'], 'Separator','on');
   a = uimenu('Parent',gcbf,'Label','&Help','Tag','ConservedModeMenu');
   b = uimenu('Parent',a,'Label','&Navigate to help files with default browser', ...
      'Tag','ConservedModeMenu','CallBack',[ mfilename ' Help;']);
case 'NormalMenu'
   delete(findobj(gcbf,'Tag','ConservedModeMenu'));
   a = uimenu('Parent',gcbf,'Label','&Help','Tag','Help');
   b = uimenu('Parent',a,'Label','&Navigate to help files with default browser', ...
      'Tag','ConservedModeMenu','CallBack',[ mfilename ' Help;']);
   sethandles(h,{'Menu','Help'},a);
end

%---------------------------------------------------------------------------
% movesignal(Distance)
%---------------------------------------------------------------------------
% This function is called to move the signals the distance required.  It is
% called in response to keyboard or mouse events.
function movesignal(DistanceMoved)
h = get(gcbf, 'UserData');
% Signal Axis
FlippedXData = get(h.Lines.FlippedSig, 'XData');
for i = 1:length(FlippedXData)
   FlippedXData{i} = FlippedXData{i} + DistanceMoved;
end
set(h.Lines.FlippedSig, {'xdata'}, FlippedXData);
% Pan Axis if necessary
XLim = get(h.Axis.Signal, 'XLim');
n = h.State.n + DistanceMoved;
h = sethandles(h,{'State','n'}, n);
if n < XLim(1)
   set(h.Axis.Big, 'XLim', [n, XLim(2)-(XLim(1)-n)]);
elseif n > XLim(2)
   set(h.Axis.Big, 'XLim', [XLim(1)+(n-XLim(2)), n]);
end

% n Arrows
Pos = get(h.Text.Arrows, 'Position');
Pos{1}(1) = n - h.State.nArrowOffset;
Pos{2}(1) = n - h.State.nArrowOffset;
String = { ['\uparrow n = ' num2str(n)]; ['\downarrow n = ' num2str(n)] };
set(h.Text.Arrows, {'Position'}, Pos, {'String'}, String);

% CurrentOutput
height = h.Data.Output.YData( find(h.Data.Output.XData == n) );
if isempty( height )
   set(h.Lines.CurrentOutput, {'XData', 'YData'} , {n 0; n 0});
else
   set(h.Lines.CurrentOutput, {'XData', 'YData'}, {n height; [n n] [0 height]});
end

% Multiply Axis
XData = get(h.Lines.Signal, 'XData');
YData = get(h.Lines.Signal, 'YData');
FlippedYData = get(h.Lines.FlippedSig, 'YData');
[x,iSig,iFlippedSig] = intersect( XData{1}, FlippedXData{1});

if(~isempty(YData{1}(iSig)) || ~isempty(FlippedYData{1}(iFlippedSig)))
    y = YData{1}(iSig).*FlippedYData{1}(iFlippedSig);
else
    y = zeros(1,length(x));
end
[xx,yy] = stemdata(x,y);
set(h.Lines.MultipliedSig,{'XData','YData'},{x y; xx yy});
%---------------------------------------------------------------------------
% changeconvlength(Distance)
%---------------------------------------------------------------------------
% This function is called when the circular convolution length is changed
% by the user.
function changeconvlength(DistanceMoved)
OFF = 0; ON = 1;
h = get(gcbf, 'UserData');
% Pan Axis if necessary
XLim = get(h.Axis.CircularOutput, 'XLim');
N = h.State.CircularConvLength + DistanceMoved;
nMin = min(length(h.Data.Input.x.XData),length(h.Data.Input.h.XData));
if N < nMin
   return;
elseif N < XLim(1)
   set(h.Axis.Big, 'XLim', [N, XLim(2)-(XLim(1)-N)]);
elseif N > XLim(2)
   set(h.Axis.Big, 'XLim', [XLim(1)+(N-XLim(2)), N]);
end
h = sethandles(h,{'State','CircularConvLength'}, N);

% N Arrow and Line
Pos = get(h.Text.CircularConvLength, 'Position');
Pos(1) = N - h.State.nArrowOffset;
String = ['\downarrow N = ' num2str(N)];
set(h.Text.CircularConvLength, 'Position', Pos, 'String', String);
YLim_OutputAxis = get(h.Axis.Output,'YLim');
YLim_CircularOutputAxis = get(h.Axis.CircularOutput,'Ylim');
x = N*[fix(h.State.AxisXLim(1)/N):fix(h.State.AxisXLim(2)/N)];
y_linear = YLim_OutputAxis(2)*ones(1,length(x));
y_circular = YLim_CircularOutputAxis(2)*ones(1,length(x));
[xx,yy_linear] = stemdata(x,y_linear);
[xx,yy_circular] = stemdata(x,y_circular);
yy_linear(1:3:end) = YLim_OutputAxis(1);
yy_circular(1:3:end) = YLim_CircularOutputAxis(1);
set(h.Lines.AliasSections(1), 'XData', xx, 'YData', yy_linear);
set(h.Lines.AliasSections(2), 'XData', xx, 'YData', yy_circular);

% Alias Data Overlap Lines
highlightaliaseddata(ON);

% Circular Output
nStart = h.Data.Output.XData(1);
x = [0:N-1];
y = alias(h.Data.Output.YData, N, nStart);
[xx,yy] = stemdata(x,y);
set(h.Lines.CircularOutput,{'XData','YData'},{x y; xx yy});
h = sethandles(h,{'Data','CircularOutput','XData'},x);
h = sethandles(h,{'Data','CircularOutput','YData'},y);

%---------------------------------------------------------------------------
% getsignal(Sig)
%---------------------------------------------------------------------------
% This function is called when the "Get x(t)" / "Get h(t)" buttons are
% pushed.
function getsignal(Sig)
h = get(gcbf,'UserData');
switch Sig
case 'x[n]'
   CurrentSignal = h.Data.Input.x;
   hSigAxis = h.Axis.x;
   AxisTitle = 'Input';
   SigName = {'Data','Input','x'};
   OtherSigName = {'Data','Input','h'};    
case 'h[n]'
   CurrentSignal = h.Data.Input.h;
   hSigAxis = h.Axis.h;
   AxisTitle = 'Impulse Response';
   SigName = {'Data','Input','h'};
   OtherSigName = {'Data','Input','x'};    
end
if ~isempty(CurrentSignal)
   SigClass = CurrentSignal.Class;
   CurrentSignal = rmfield(CurrentSignal,'Class');
   ParameterNames = fieldnames(CurrentSignal);
   SignalTemplate = cell( 2*length(ParameterNames), 1 );
   SignalTemplate(1:2:end) = ParameterNames;
   for i = 1:length(ParameterNames)
      SignalTemplate{2*i} = getfield(CurrentSignal,ParameterNames{i});
   end
   NewSignal = siggendlg( feval(SigClass,SignalTemplate{:}), ...
      'Title',['Get ' Sig], 'LineWidth', h.State.LineWidth );
else
   NewSignal = siggendlg('Title',['Get ' Sig],'LineWidth',h.State.LineWidth);
end
if ~isempty( NewSignal )
   SigClass = class(NewSignal);
   NewSignal = struct( NewSignal );
   NewSignal.Class = SigClass;
   sethandles(h, SigName, NewSignal);

   hLines = mystem(NewSignal.XData, NewSignal.YData, hSigAxis);
   
   axes(hSigAxis);
   xlim = get(hSigAxis,'XLim');
   ylim = [min([min(NewSignal.YData) min(NewSignal.YData) 0]) max([max(NewSignal.YData) max(NewSignal.YData) 0])];
   set(hSigAxis,'XLim',[xlim(1)-1 xlim(2)+1],'YLim',h.AxisMargin*ylim);
   
   % Add baseline: iff YLim < 0
   if (min(ylim)<0 && (max(ylim)~=0) )
       h.Axis.BaselineX = line([-1000 1000],[0 0],'parent',hSigAxis,'color','k','LineStyle',':');
   end
   
   title(AxisTitle,'FontWeight','bold','FontUnits','normalized','FontSize',0.13);
   
   if strcmpi( get(h.Menu.ConserveSpace,'Checked'),'on')
      set(findobj(hSigAxis),'Visible','off');
   end
   if ~isempty( getfield(h, OtherSigName{:}) )
      initialize;
   end
end
