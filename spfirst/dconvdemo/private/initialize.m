function initialize()
% Jordan Rosenthal, 26-Mar-2000
%             Rev., 06-Nov-2000, Modified for CONVDEMO to DCONVDEMO_CALLBACKS name change.

NO = 0; YES = 1;
h = get(gcbf, 'UserData');
h = sethandles(h,{'State','n'},h.State.nResetValue);
h = sethandles(h,{'State','CircularConvLength'}, ...
    min(length(h.Data.Input.x.XData), length(h.Data.Input.h.XData)));
n = h.State.n;

colorM  = [0.1 0.6 0.2];
yMargin = 1.1; % 10% of YLim
%------------------------------------------------------------------------
% Delete Lines and Arrows
%------------------------------------------------------------------------
delete( [h.Lines.Signal; h.Lines.FlippedSig; h.Lines.MultipliedSig; ...
      h.Lines.TotalOutput; h.Lines.CurrentOutput; ...
      h.Lines.CircularOutput; h.Lines.AliasSections; h.Text.Arrows; ...
      h.Text.CircularConvLength] );

%------------------------------------------------------------------------
% Signal Axis
%------------------------------------------------------------------------
switch h.State.SignalToFlip
case 'Flip x[n]'
   Signal     = h.Data.Input.h;
   FlippedSig = h.Data.Input.x;
case 'Flip h[n]'
   Signal     = h.Data.Input.x;
   FlippedSig = h.Data.Input.h;
end
FlippedSig.XData = -fliplr(flipud(FlippedSig.XData)) + n;
FlippedSig.YData = fliplr(flipud(FlippedSig.YData));
   
hSignalLines = mystem( Signal.XData, Signal.YData, h.Axis.Signal );
set(h.Axis.Signal, 'NextPlot', 'add');
hFlippedSigLines = mystem( FlippedSig.XData, FlippedSig.YData, h.Axis.Signal, 'r' );
set(h.Axis.Signal, 'NextPlot', 'replacechildren');

ylim = [min([min(Signal.YData) min(FlippedSig.YData) 0]) max([0 max(Signal.YData) max(FlippedSig.YData)])];

% yMargin = 0.1*abs(diff(ylim));
% set(h.Axis.Signal,'YLim',[-yMargin yMargin]+ylim);

set(h.Axis.Signal,'YLim',yMargin*ylim);

% Add baseline: iff YLim < 0
if (min(ylim)<0)
    h.Axis.Baseline = line([-1000 1000],[0 0],'parent',h.Axis.Signal,'color','k','LineStyle',':');
end

set(hSignalLines, 'Tag', 'Sig');

set(hFlippedSigLines, 'Tag', 'FlippedSig');

h = sethandles(h, {'Lines','Signal'}, hSignalLines);
h = sethandles(h, {'Lines','FlippedSig'}, hFlippedSigLines);

%------------------------------------------------------------------------
% Multiply Axis
%------------------------------------------------------------------------
M = Signal.YData(:)*FlippedSig.YData(:)';
min_M = min(0, min(min(M)));
max_M = max(max(M));
if min_M == max_M;
    min_M = min_M - 1;
    max_M = max_M + 1;
end

set(h.Axis.Multiply, 'YLim', yMargin*[ min_M, max_M]);

[x,iSig,iFlippedSig] = intersect( Signal.XData, FlippedSig.XData );
if isempty(x)
    hMultipliedSigLines = mystem(nan, nan, h.Axis.Multiply, colorM );
else
    hMultipliedSigLines = mystem(x, ...
        Signal.YData(iSig).*FlippedSig.YData(iFlippedSig), h.Axis.Multiply);
end

% Add baseline: iff YLim < 0
if (min_M<0)
    h.Axis.BaselineM = line([-1000 1000],[0 0],'parent',h.Axis.Multiply,'color','k','LineStyle',':');
end

set( hMultipliedSigLines, 'Tag', 'MultipliedSig');

h = sethandles(h,{'Lines','MultipliedSig'}, hMultipliedSigLines);

%------------------------------------------------------------------------
% Output Axis
%------------------------------------------------------------------------
x_low = Signal.XData(1) - (FlippedSig.XData(end) - n);
x_high = Signal.XData(end) - (FlippedSig.XData(1) - n);
Output.XData = [x_low:x_high];
Output.YData = conv( Signal.YData, fliplr(flipud(FlippedSig.YData)));
min_Y = min(0,min(Output.YData));
max_Y = max(Output.YData);
if min_Y == max_Y
   min_Y = min_Y - 1;
   max_Y = max_Y + 1;
end
set(h.Axis.Output, 'YLim', yMargin*[min_Y, max_Y],'NextPlot','Add');
hTotalOutputLines = zeros(2*length(Output.XData),1);
for i = 1:length(Output.XData)
  hTotalOutputLines(2*i-1:2*i) = mystem( Output.XData(i), ...
      Output.YData(i), h.Axis.Output);
end

set(h.Axis.Output, 'NextPlot', 'ReplaceChildren');
h = sethandles(h,{'Lines','TotalOutput'},hTotalOutputLines);
h = sethandles(h,{'Data','Output'},Output);
% CurrentOutput
set(h.Axis.Output, 'NextPlot', 'add');
hCurrentOutputLines = mystem(n, 0, h.Axis.Output);
set(h.Axis.Output, 'NextPlot', 'replacechildren');
set(hCurrentOutputLines, 'Tag', 'CurrentOutput', 'color',colorM);

% Add baseline: iff YLim < 0
if (min_Y<0)
    h.Axis.BaselineO = line([-1000 1000],[0 0],'parent',h.Axis.Output,'color','k','LineStyle',':');
end

h = sethandles(h,{'Lines','CurrentOutput'},hCurrentOutputLines);

%------------------------------------------------------------------------
% Circular Output Axis
%------------------------------------------------------------------------
CircularOutput.XData = [0:h.State.CircularConvLength-1];
CircularOutput.YData = alias(h.Data.Output.YData,h.State.CircularConvLength,x_low);
min_Y = min(0,min(CircularOutput.YData));
max_Y = max(CircularOutput.YData);
if min_Y == max_Y
   min_Y = min_Y - 1;
   max_Y = max_Y + 1;
end
set(h.Axis.CircularOutput,'YLim',[min_Y, max_Y]);
hCircularOutputLines = mystem(CircularOutput.XData,CircularOutput.YData,h.Axis.CircularOutput);

set(hCircularOutputLines,'Tag','CircularOutput');

h = sethandles(h,{'Lines','CircularOutput'},hCircularOutputLines);
h = sethandles(h,{'Data','CircularOutput'},CircularOutput);

%------------------------------------------------------------------------
% Axis Labels
%------------------------------------------------------------------------
Props_Common = {'color','k','HorizontalAlignment','right', ...
      'VerticalAlignment','bottom','FontUnits','normalized', ...
      'FontSize',0.1};  
PropNames_Unique = {'String','Parent'};
PropVals_Unique = { ...
      'k',h.Axis.Signal; ...
      'k',h.Axis.Multiply; ...
      'n',h.Axis.Output; ...
      'n',h.Axis.CircularOutput; ...
      'n',h.Axis.x; ...
      'n',h.Axis.h };
hAxisLabels = text(zeros(6,1),zeros(6,1),'',Props_Common{:});
set(hAxisLabels,PropNames_Unique,PropVals_Unique);
set(hAxisLabels,'units','normalized','Position',[0.99 0]);
%------------------------------------------------------------------------
% Axis Legends
%------------------------------------------------------------------------
Props_Common = {'VerticalAlignment','Top','FontAngle','Italic', ...
      'FontUnits','Normalized','FontSize',0.1,'Units','Normalized'};
PropNames_Unique = {'String','Color','Parent','Position'};
PropVals_Unique = { ...
      'Signal','b',h.Axis.Signal,[0.01 0.99]; ...
      'Flipped Signal','r',h.Axis.Signal,[0.01 0.88]; ...
      'Multiplication','b',h.Axis.Multiply,[0.01 0.99]; ...
      'Linear Convolution','b',h.Axis.Output,[0.01 0.99]; ...
      'Circular Convolution','b',h.Axis.CircularOutput,[0.01 0.99]};
hAxisLegendsText = text(0.01*ones(5,1), 0.99*ones(5,1),'', Props_Common{:});
set(hAxisLegendsText,PropNames_Unique,PropVals_Unique);
h = sethandles(h,{'Text','OutputLabel'}, ...
    findobj(hAxisLegendsText,'String','Linear Convolution'));
h = sethandles(h,{'Text','CircularOutputLabel'}, ...
    findobj(hAxisLegendsText,'String','Circular Convolution'));

%------------------------------------------------------------------------
% n Arrows
%------------------------------------------------------------------------
YLim_SignalAxis = get(h.Axis.Signal, 'YLim');
YLim_OutputAxis = get(h.Axis.Output, 'YLim');
Pos_x = [n; n]-h.State.nArrowOffset;
Pos_y = [YLim_SignalAxis(1); YLim_OutputAxis(2)];

Props_Common = {'FontWeight','Bold','FontUnits','Normalized','FontSize',0.125, ...
    'Color','b','units','data', ...
    'ButtonDownFcn','dconvdemo_callbacks SignalStartMove'};

PropNames_Unique = {'Tag','String','Parent','VerticalAlignment'};
PropVals_Unique = { ...
      'Arrow1',['\uparrow n = ' num2str(n)],h.Axis.Signal,'Top'; ...
      'Arrow2',['\downarrow n = ' num2str(n)],h.Axis.Output,'Bottom'};
hArrowsText = text(Pos_x,Pos_y,'',Props_Common{:});
set(hArrowsText,PropNames_Unique,PropVals_Unique);
h = sethandles(h,{'Text','Arrows'}, hArrowsText);

%------------------------------------------------------------------------
% N Arrow and Section lines
%------------------------------------------------------------------------
N = h.State.CircularConvLength;
YLim_OutputAxis = get(h.Axis.Output,'YLim');
YLim_CircularOutputAxis = get(h.Axis.CircularOutput,'Ylim');

hCircularConvLength = text('FontWeight','Bold','FontUnits','Normalized','FontSize',0.125, ...
   'Color','b','units','data', ...
   'ButtonDownFcn','dconvdemo_callbacks StartChangeCircularLength', ...
   'Tag','CircularConvLength','String',['\downarrow N = ' num2str(N)], ...
   'Parent',h.Axis.CircularOutput,'VerticalAlignment','Bottom', ...
   'Position',[N YLim_CircularOutputAxis(2)]);

x = N*[fix(h.State.AxisXLim(1)/N):fix(h.State.AxisXLim(2)/N)];
y_linear = YLim_OutputAxis(2)*ones(1,length(x));
y_circular = YLim_CircularOutputAxis(2)*ones(1,length(x));
[xx,yy_linear] = stemdata(x,y_linear);
yy_linear(1:3:end) = YLim_OutputAxis(1);
[xx,yy_circular] = stemdata(x,y_circular);
yy_circular(1:3:end) = YLim_CircularOutputAxis(1);
hLines = line('parent', h.Axis.Output, ...
    'XData', xx, 'YData', yy_linear, 'color', [0.7 0.7 0.7], ...
    'linewidth', h.State.LineWidth);
hLines2 = line('parent',h.Axis.CircularOutput, ...
   'XData', xx, 'YData', yy_circular, 'color', [0.7 0.7 0.7], ...
   'linewidth', h.State.LineWidth);
h = sethandles(h,{'Text','CircularConvLength'},hCircularConvLength);
h = sethandles(h,{'Lines','AliasSections'},[hLines;hLines2]);

%------------------------------------------------------------------------
% Convolution Mode
%------------------------------------------------------------------------
hFormulasText = textbox(h);
if h.State.CircularMode
  nVisiblePlots = 4;
  set(allchild(h.Axis.CircularOutput),'visible','on');
  set(h.Lines.AliasSections(1),'visible','on');
  highlightaliaseddata(YES);
else
  nVisiblePlots = 3;
  set(allchild(h.Axis.CircularOutput),'visible','off');
  set(h.Lines.AliasSections(1),'visible','off');
end

%------------------------------------------------------------------------
% Tutorial mode
%------------------------------------------------------------------------
if h.State.TutorialMode
  set(findobj([h.Axis.Output; h.Axis.CircularOutput]), 'Visible', 'off');
  set(h.Text.OutputLabel,'String',{'Linear Convolution', ...
	'Click to hide plot'});
  set(h.Text.CircularOutputLabel,'String',{'Circular Convolution', ...
	'Click to hide plot'});
  if h.State.CircularMode
     set(h.Button.Tutorial.Both, 'Visible', 'on');
  else
    set(h.Button.Tutorial.Both, 'Visible', 'off');
    set(findobj(h.Axis.Output), 'Visible', 'on');
  end
end

%------------------------------------------------------------------------
% Conserve Space mode
%------------------------------------------------------------------------
if strcmp( lower( get(h.Menu.ConserveSpace, 'Checked') ), 'on')
   set([hFormulasText; hAxisLabels(5:6)],'Visible','off');
end

%------------------------------------------------------------------------
% Enable Reset Axes Menus
%------------------------------------------------------------------------
set(findobj(gcbf,'Tag','Reset Axes'), 'Enable', 'on');

%------------------------------------------------------------------------
% Done
%------------------------------------------------------------------------
sethandles(h,{'State','DataInitialized'}, YES);
