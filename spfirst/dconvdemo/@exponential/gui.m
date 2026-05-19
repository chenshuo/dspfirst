function gui(varargin)
%GUI Create and manage the graphic controls for EXPONENTIAL object
%   GUI(Signal, Pos) creates the controls in the rectangle of the current
%   figure described by Pos to let the user interactively change the EXPONENTIAL
%   object's parameters.  Pos is in normalized units.
%
%   GUI(Signal) assumes the position rectangle of [0 0 1 1]
%
%   This function assumes a figure has already been created and that its
%   UserData property holds a EXPONENTIAL object.
%
%   The function was written to be use within the SIGGENDLG function. 
%
%   Callbacks:
%     GUI('Replot') replots the Signal data with the current parameters and
%     stores the EXPONENTIAL data in the UserData property of the plot.
%
%     GUI('Rescale Plot') rescales the x and y axis of the plot to fit the data.
%
%   See also SIGGENDLG, EXPONENTIAL

% Jordan Rosenthal, 12/16/97

% Rev 1 - 11/10/02 - Rajbabu Velmurugan, 
%                   Updated to handle changes to 'stem' in ML6.5
%                   Matlab function, 'stem' returns handles to 3 objects
% Rev 2 - 06/02/09 - Greg Krudysz,
%                   Rewrote redundant code into 'stemdata' method to fix
%                   baseline bug in 'Replot'

MATLABVERSION = version;
MATLABVERSION = str2num(MATLABVERSION(1:3));

switch nargin
case 1
   action = 'Initialize';
   Signal = varargin{1};
   Pos = [0 0 1 1];
case 2
   Signal = varargin{1};
   if ~isstr(varargin{2})
      action = 'Initialize';
      Pos = varargin{2};
   else
      action = varargin{2};
   end
otherwise
   error('Illegal action.');
end

switch action
case 'Causal'
   set(findobj(gcbf,'style','radiobutton'),'Value',0);
   set(findobj(gcbf,'Tag','Causal'),'Value',1);
   Signal = exponential(Signal, 'Causality','Causal');
   set(gcbf,'UserData',Signal);
   gui(Signal,'Replot');
   gui(Signal,'Rescale Plot');
case 'Noncausal'
   set(findobj(gcbf,'style','radiobutton'),'Value',0);
   set(findobj(gcbf,'Tag','Noncausal'),'Value',1);
   Signal = exponential(Signal, 'Causality','Noncausal');
   set(gcbf,'UserData',Signal);
   gui(Signal,'Replot');
   gui(Signal,'Rescale Plot');
case 'Rescale Plot'
   Handles = getappdata(gcbf,'Handles');
   rescaleplot(Signal,Handles.PlotAxis);
case 'Replot'
   Handles = getappdata(gcbf,'Handles');
   Values = get(Handles.Controls,'Value');
   if Values{5}          % The causal button
      Causal = 'Causal';
   else
      Causal = 'Noncausal';
   end
   Signal = exponential( ...
      'Name'          , Signal.Name, ...
      'ScalingFactor' , Values{1}, ...
      'ExpConstant'   , Values{2}, ...
      'Length'        , Values{3}, ...
      'Delay'         , Values{4}, ...
      'Causality'     , Causal );
   set(gcbf,'UserData',Signal);
   %hStemMarkers = findobj(Handles.PlotLines,'Marker','o');
   hStemMarkers = Handles.PlotLines(1);
   %hStemLines = findobj(Handles.PlotLines,'Marker','none');
   hStemLines = Handles.PlotLines(2);
   if size(Handles.PlotLines,1) > 2
       hBaseLine  = Handles.PlotLines(3);
   end
   
   Handles.PlotLines = stemdata(Signal,Handles.PlotLines);
   set( get(Handles.PlotAxis, 'title'), 'String',formulastring(Signal));
case 'Initialize'   
   %%%  Create Plot  %%%
   Plot_Pos  = [0.06*Pos(3)+Pos(1) 0.2*Pos(4)+Pos(2) 0.5*Pos(3) 0.7*Pos(4)];
   hLines = stemdata(Signal);
   hAxes = gca;
   set(gca, 'Position', Plot_Pos, 'Box', 'on', ...
      'ButtonDownFcn','gui(get(gcbf,''UserData''),''Rescale Plot'')');
   
   %%% Create rescale text message  %%%
   Text_Pos = [0.06*Pos(3)+Pos(1) 0.05*Pos(4)+Pos(2) 0.5*Pos(3) 0.05*Pos(4)];
   uicontrol('Units','normalized', ...
      'BackgroundColor',get(0,'DefaultFigureColor'), ...
      'ForegroundColor','r', ...
      'FontUnits','normalized', ...
      'Position',Text_Pos, ...
      'String','Click inside plot area to rescale axis', ...
      'Style','text');
   
   %%%  Create Controls  %%%
   Controls_Pos = [0.6*Pos(3)+Pos(1) 0.2*Pos(4)+Pos(2) 0.38*Pos(3) 0.7*Pos(4)];
   
   nParams = 5;
   Parameters = {'ScalingFactor','ExpConstant','Length','Delay'};
   Labels = {'Scaling Factor:','Exponential Constant:','Length:','Delay:'};
   Values = num2str( ...
      [Signal.ScalingFactor; ...
         Signal.ExpConstant; ...
         Signal.Length; ...
         Signal.Delay] );
   Min = [-Inf; -Inf; 1; -Inf];
   Max = [Inf; Inf; Inf; Inf];
   StepSize = [1; 0.05; 1; 1];
   
   Width = 0.1*ones(1,nParams);
   Height = 0.05*ones(1,nParams);
   Left = ( Controls_Pos(1) + Controls_Pos(3) - Width ) - 0.04;
   Bottom = Controls_Pos(2) + Controls_Pos(4)-Controls_Pos(4)/nParams*[0:nParams-1] - Height;
   NumEditPos = [Left; Bottom; Width; Height];
   LabelWidth = 0.25*ones(1,nParams);
   LabelHeight = Height;
   LabelLeft = Left - 0.26;
   LabelBottom = Bottom - 0.005;
   LabelPos = [LabelLeft; LabelBottom; LabelWidth; LabelHeight];
   DefFigColor = get(0,'DefaultFigureColor');
   h = zeros(6,1);
   for i = 1:4
       uicontrol('Units','Normalized', ...
           'Position',LabelPos(:,i), ...
           'BackgroundColor',DefFigColor, ...
           'FontUnits','normalized', ...
           'FontWeight','Bold', ...
           'HorizontalAlignment','right', ...
           'String',Labels{i}, ...
           'style','text');
       h(i) = uinumedit('Units','normalized', ...
           'BackgroundColor','w', ...
           'CallBack','gui(get(gcbf,''UserData''),''Replot'')', ...
           'Min', Min(i), ...
           'Max', Max(i), ...
           'Position',NumEditPos(:,i), ...
           'StepSize',StepSize(i), ...
           'String',Values(i,:), ...
           'Tag',Labels{i});
   end
   CausalPos = NumEditPos(:,5) + [-0.16; -0.03; 0.01; 0];
   NonCausalPos = NumEditPos(:,5) + [-0.05; -0.03; 0.04; 0];
   FramePos = NumEditPos(:,5) + [-0.2; -0.07; 0.2; 0.08];
   FrameLabelPos = [FramePos(1); FramePos(2)+FramePos(4); 0.1; 0.04;];
   FrameColor = [0.7 0.7 0.7];
   uicontrol('Units','normalized', ...
      'BackgroundColor',FrameColor, ...
      'Position',FramePos, ...
      'Style','frame');
   uicontrol('Units','normalized', ...
      'BackgroundColor',DefFigColor, ...
      'Position',FrameLabelPos, ...
      'FontWeight','bold', ...
      'String','Causality:', ...   
      'Style','text');
   if strcmp(lower(Signal.Causality),'causal')
      Causal    = 1;
   else
      Causal    = 0;
   end
   h(5) = uicontrol('Units','normalized', ...
      'BackgroundColor',FrameColor, ...
      'ForegroundColor','b', ...
      'CallBack','gui(get(gcbf,''UserData''),''Causal'')', ...
      'Position',CausalPos, ...
      'String','Causal', ...
      'Style','radiobutton', ...
      'Tag','Causal', ...
      'Value', Causal);
   h(6) = uicontrol('Units','normalized', ...
      'BackgroundColor',FrameColor, ...
      'ForegroundColor','b', ...
      'CallBack','gui(get(gcbf,''UserData''),''Noncausal'')', ...
      'Position',NonCausalPos, ...
      'String','Noncausal', ...
      'Style','radiobutton', ...
      'Tag','Noncausal', ...
      'Value', ~Causal);
   
   % Store handles for use in callbacks
   Handles.Controls = h;
   Handles.PlotAxis = hAxes;
   Handles.PlotLines = hLines;
   setappdata(gcf, 'Handles', Handles);
   rescaleplot(Signal,Handles.PlotAxis);
otherwise
   error('Illegal action.');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  rescaleplot(Signal,hPlotAxis)  %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rescaleplot(Signal,hPlotAxis)
XLim = [min(Signal.XData)-2, max(Signal.XData)+2];
YLim = [1.5*min(Signal.YData) 1.5*max(Signal.YData)];
if XLim(1) == XLim(2)
   XLim(1) = XLim(1) - 1;
   XLim(2) = XLim(2) + 1;
end
if YLim(1) == YLim(2)
   YLim(1) = YLim(1) - 1;
   YLim(2) = YLim(2) + 1;
end
set(hPlotAxis,'XLim',XLim,'YLim',YLim);