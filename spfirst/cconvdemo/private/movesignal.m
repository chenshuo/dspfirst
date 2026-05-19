function movesignal(DistanceMoved)
%MOVESIGNAL(Distance)
%   MOVESIGNAL(Distance) handle all changes necessary when the signal
%   is moved a certain distance.

% Jordan Rosenthal, 11/06/99

h = get(gcbf,'UserData');

% Signal Axis
switch h.State.SignalToFlip
case 'Flip x(t)'
   Signal     = h.Data.Input.h;
   FlippedSig = h.Data.Input.x;
case 'Flip h(t)'
   Signal     = h.Data.Input.x;
   FlippedSig = h.Data.Input.h;
end
if isa(FlippedSig.Object,'cimpulse')
   FlippedXData = get(h.Graphics.FlippedSig(1),'XData') + DistanceMoved;
   FlippedTextPos = get(h.Graphics.FlippedSig(2),'Pos') + [DistanceMoved 0 0];
   set(h.Graphics.FlippedSig(1),'XData',FlippedXData);
   set(h.Graphics.FlippedSig(2),'Pos',FlippedTextPos);
else
   FlippedXData = get(h.Graphics.FlippedSig, 'XData') + DistanceMoved;
   set(h.Graphics.FlippedSig, 'xdata', FlippedXData);
end
% Pan Axis if necessary
XLim = get(h.Axis.Signal, 'XLim');
t = h.State.t + DistanceMoved;
h = sethandles(h, {'State','t'}, t);
if t < XLim(1)
   set(h.Axis.Big, 'XLim', [t, XLim(2)-(XLim(1)-t)]);
elseif t > XLim(2)
   set(h.Axis.Big, 'XLim', [XLim(1)+(t-XLim(2)), t]);
end

% t Arrows
Pos = get(h.Text.Arrows, 'Position');
Pos{1}(1) = t - h.State.tArrowOffset;
Pos{2}(1) = t - h.State.tArrowOffset;
String = { ['\uparrow t = ' num2str(t,'%3.2f')]; ['\downarrow t = ' num2str(t,'%3.2f')] };
set(h.Text.Arrows, {'Position'}, Pos, {'String'}, String);

% CurrentOutput
tStart = h.Data.Output.XData(1);
tEnd   = h.Data.Output.XData(end);
if (t < tStart) | (t > tEnd)
   set(h.Lines.CurrentOutput, {'XData', 'YData'} , {t 0; t 0});
else
   [m,kMin] = min(abs(h.Data.Output.XData-t));
   height = h.Data.Output.YData(kMin);
   set(h.Lines.CurrentOutput, {'XData', 'YData'}, {t height; [t t] [0 height]});
end

% Multiply Axis
switch h.State.SignalToFlip
case 'Flip x(t)'
   Signal     = h.Data.Input.h;
   FlippedSig = h.Data.Input.x;
case 'Flip h(t)'
   Signal     = h.Data.Input.x;
   FlippedSig = h.Data.Input.h;
end
h = multiplypatch(h,Signal,FlippedSig);
set(h.Lines.MultiplyZeroLine,'XData',get(h.Axis.Multiply,'XLim'));