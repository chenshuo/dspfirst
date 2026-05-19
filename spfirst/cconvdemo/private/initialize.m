function initialize(h)
% Jordan Rosenthal, 11/06/99
%             Rev., 26-Oct-2000
%             Rev., 06-Nov-2000 Revised for name change to CCONVDEMO_CALLBACKS
%             Rev., 08-Apr-2003 Made \tau bigger and bold.

NO = 0; YES = 1;
t  = h.State.t;

%------------------------------------------------------------------------
% Delete Lines and Arrows
%------------------------------------------------------------------------
delete( [h.Graphics.Signal; h.Graphics.FlippedSig; h.Patch.MultipliedSig; ...
    h.Lines.MultiplyZeroLine; h.Lines.TotalOutput; h.Lines.CurrentOutput; ...
    h.Text.ImpulseText.Multiply; h.Text.Arrows] );

%------------------------------------------------------------------------
% Signal Axis
%------------------------------------------------------------------------
set(gcbf,'currentAxes',h.Axis.Signal);
switch h.State.SignalToFlip
    case 'Flip x(t)'
        Signal     = h.Data.Input.h;
        FlippedSig = h.Data.Input.x;
    case 'Flip h(t)'
        Signal     = h.Data.Input.x;
        FlippedSig = h.Data.Input.h;
end
FlippedSig.XData = -FlippedSig.XData + t;

if Signal.IsImpulse & ~FlippedSig.IsImpulse
    Signal.Object.PlotHeight = max(FlippedSig.YData);
elseif ~Signal.IsImpulse & FlippedSig.IsImpulse
    FlippedSig.Object.PlotHeight = max(Signal.YData);
end

% Draw the signals
set(h.Axis.Signal,'nextplot','add');
if Signal.IsImpulse
    hSignalGraphics = ezplot(Signal.Object,get(h.Axis.Signal,'XLim'),'facecolor','b');
    set(hSignalGraphics(2),'FontSize',2*get(hSignalGraphics(2),'FontSize'));
else
    hSignalGraphics = plot(Signal.XData, Signal.YData, ...
        'parent', h.Axis.Signal,'LineWidth',h.State.LineWidth,'color','b');
end
if FlippedSig.IsImpulse
    hFlippedSigGraphics = ezplot(FlippedSig.Object,get(h.Axis.Signal,'XLim'),'facecolor','r');
    set(hFlippedSigGraphics(1),'XData',-get(hFlippedSigGraphics(1),'XData') + t);
    txtPos = get(hFlippedSigGraphics(2),'pos');
    txtPos(1) = -txtPos(1) + t;
    set(hFlippedSigGraphics(2),'Pos',txtPos,...
        'Horiz','right','FontSize',2*get(hFlippedSigGraphics(2),'FontSize'));
else
    hFlippedSigGraphics = plot(FlippedSig.XData, FlippedSig.YData, 'r', ...
        'parent', h.Axis.Signal,'LineWidth',h.State.LineWidth);
end
set(h.Axis.Signal,'NextPlot','ReplaceChildren');

% Save the handles
h = sethandles(h,{'Graphics','Signal'},hSignalGraphics);
h = sethandles(h,{'Graphics','FlippedSig'},hFlippedSigGraphics);


%------------------------------------------------------------------------
% Multiply Axis
%------------------------------------------------------------------------
% Create dummy patch and impulse text object and then call routine to adjust it
set(gcbf,'currentAxes',h.Axis.Multiply);
h.Patch.MultipliedSig = patch([0 0 1 1],[0 1 1 0],'g','edgecolor','b','visible','off');
h.Text.ImpulseText.Multiply = text(0,0,'dummytext','color','r','visible','off');
h = sethandles(h,{'Patch','MultipliedSig'},h.Patch.MultipliedSig);
h = sethandles(h,{'Text','ImpulseText','Multiply'},h.Text.ImpulseText.Multiply);
h = multiplypatch(h,Signal,FlippedSig);
%------------------------------------------------------------------------
% Create The line that runs through y = 0
%------------------------------------------------------------------------
hLine = line('XData',get(h.Axis.Multiply,'XLim'),'YData',[0 0],'Color','b');
set( hLine, 'Tag', 'MultiplyZeroLine');
h = sethandles(h,{'Lines','MultiplyZeroLine'}, hLine);

%------------------------------------------------------------------------
% Output Axis
%------------------------------------------------------------------------
set(gcbf,'currentAxes',h.Axis.Output);
if isa(Signal.Object,'cimpulse') & isa(FlippedSig.Object,'cimpulse')
    area = Signal.Object.Area * FlippedSig.Object.Area;
    delay = Signal.Object.Delay+FlippedSig.Object.Delay;
    Output.XData = delay;
    Output.YData = 1;
    set(h.Axis.Output,'YLim',[0 1],'NextPlot','Add');
    XLim = get(h.Axis.Output,'XLim');
    hTotalOutputLines = ezplot(cimpulse('Delay',delay,'Area',area,'PlotScale',0.5),XLim);
    set(hTotalOutputLines(2),'FontSize',2*get(hTotalOutputLines(2),'FontSize'));
    set(h.Axis.Output,'NextPlot','ReplaceChildren');
else
    if isa(Signal.Object,'cimpulse')
        Output.XData = -FlippedSig.XData + t + Signal.Object.Delay;
        Output.YData = Signal.Object.Area * FlippedSig.YData;
    elseif isa(FlippedSig.Object,'cimpulse')
        Output.XData = Signal.XData + FlippedSig.Object.Delay;
        Output.YData = FlippedSig.Object.Area * Signal.YData;
    else
        [Output.YData,Output.XData] = getconvolution(Signal.Object,FlippedSig.Object);
    end
    min_Y = min(0,min(Output.YData));
    max_Y = max(Output.YData);
    if min_Y == max_Y
        min_Y = min_Y - 1;
        max_Y = max_Y + 1;
    end
    set(h.Axis.Output, 'YLim', [min_Y, max_Y],'NextPlot','Add');
    hTotalOutputLines = plot(Output.XData,Output.YData,'b','LineWidth',h.State.LineWidth);
    set(h.Axis.Output, 'NextPlot', 'ReplaceChildren');
end
h = sethandles(h,{'Lines','TotalOutput'},hTotalOutputLines);
h = sethandles(h,{'Data','Output'},Output);

% CurrentOutput
[m,kmin] = min(abs(Output.XData-t));
set(h.Axis.Output, 'NextPlot', 'add');
hCurrentOutputLines = mystem(Output.XData(kmin), Output.YData(kmin), h.Axis.Output);
set(h.Axis.Output, 'NextPlot', 'replacechildren');
set(hCurrentOutputLines, 'Tag', 'CurrentOutput', ...
    'LineWidth',h.State.LineWidth, 'color', 'g');
h = sethandles(h,{'Lines','CurrentOutput'},hCurrentOutputLines);

% Axis Labels
Props_Common = {'color','k','HorizontalAlignment','right', ...
    'VerticalAlignment','bottom','FontUnits','normalized', ...
    'FontSize',0.1,'FontWeight','bold','units','normalized','Position',[0.99 0]};
PropNames_Unique = {'String','Parent','FontSize'};
PropVals_Unique = { ...
    '\tau',h.Axis.Signal,  0.16; ...
    '\tau',h.Axis.Multiply,0.16; ...
    '\it{t}',h.Axis.Output,0.12; ...
    't',h.Axis.x,     0.12; ...
    't',h.Axis.h,     0.12 };
hAxisLabels = text(zeros(5,1),zeros(5,1),'',Props_Common{:});
set(hAxisLabels,PropNames_Unique,PropVals_Unique);

% Axis Legends
Props_Common = {'VerticalAlignment','Top','FontAngle','Italic', ...
    'FontUnits','Normalized','FontSize',0.1,'Units','Normalized'};
PropNames_Unique = {'String','Color','Parent','Position'};
PropVals_Unique = { ...
    'Signal','b',h.Axis.Signal,[0.01 0.99]; ...
    'Flipped Signal','r',h.Axis.Signal,[0.01 0.88]; ...
    'Multiplication','b',h.Axis.Multiply,[0.01 0.99]; ...
    'Convolution','b',h.Axis.Output,[0.01 0.99]};
hAxisLegendsText = text(0.01*ones(4,1), 0.99*ones(4,1),'', Props_Common{:});
set(hAxisLegendsText,PropNames_Unique,PropVals_Unique);
h = sethandles(h,{'Text','OutputLabel'}, ...
    findobj(hAxisLegendsText,'String','Convolution'));

% t Arrows
YLim_SignalAxis = get(h.Axis.Signal, 'YLim');
YLim_OutputAxis = get(h.Axis.Output, 'YLim');
Pos_x = [t; t]-h.State.tArrowOffset;
Pos_y = [YLim_SignalAxis(1); YLim_OutputAxis(2)];
Props_Common = {'FontWeight','Bold','FontUnits','Normalized','FontSize',0.125, ...
    'Color','b','units','data', ...
    'ButtonDownFcn','cconvdemo_callbacks SignalStartMove'};

PropNames_Unique = {'Tag','String','Parent','VerticalAlignment'};
PropVals_Unique = { ...
    'Arrow1',['\uparrow t = ' num2str(t)],h.Axis.Signal,'Top'; ...
    'Arrow2',['\downarrow t = ' num2str(t)],h.Axis.Output,'Bottom'};
hArrowsText = text(Pos_x,Pos_y,'',Props_Common{:});

if h.MATLABVER < 8.4
    set(hArrowsText,'erasemode','xor');
end

set(hArrowsText,PropNames_Unique,PropVals_Unique);
h = sethandles(h,{'Text','Arrows'}, hArrowsText);

% Convolution string
hFormulasText = textbox(h);

% Tutorial mode
if h.State.TutorialMode
    set(findobj(h.Axis.Output), 'Visible', 'off');
    set(h.Text.OutputLabel,'String',{'Linear Convolution', ...
        'Click to hide plot'});
    set(h.Button.Tutorial, 'Visible', 'off');
    set(findobj(h.Axis.Output), 'Visible', 'on');
end

% Conserve Space mode
if strcmp( lower( get(h.Menu.ConserveSpace, 'Checked') ), 'on')
    set([hFormulasText; hAxisLabels(end-1:end)],'Visible','off');
end

% Enable Reset Axes and Set T Value Menus
hObj = [findobj(gcbf,'Tag','Reset Axes') findobj(gcbf,'Tag','Set t Value')];
set(hObj, 'Enable', 'on');

% Done
sethandles(h,{'State','DataInitialized'}, YES);
