function h = multiplypatch(h,Signal,FlippedSig)

set(gcbf,'currentAxes',h.Axis.Multiply);
t = h.State.t;
YLim_SigAxis = get(h.Axis.Signal,'YLim');

suppSig = support(Signal.Object);
suppFlippedSig = -fliplr(flipud(support(FlippedSig.Object))) + t;
supp = suppoverlap(suppSig,suppFlippedSig);
if isempty(supp)
   %-----------------------------------------------------------------------
   % No overlap
   %-----------------------------------------------------------------------
   set([h.Patch.MultipliedSig; h.Text.ImpulseText.Multiply],'Visible','off');
   mY = -1;
   MY = 1;
elseif length(supp)==1
   if length(suppSig)==1 & length(suppFlippedSig)==1
      %-----------------------------------------------------------------------
      % Both signals are impulses      
      %-----------------------------------------------------------------------
      Area = Signal.Object.Area * FlippedSig.Object.Area;
   elseif length(suppSig)==1
      %-----------------------------------------------------------------------
      % Signal object is an impulse, but FlippedSig is not
      %-----------------------------------------------------------------------
      Area = Signal.Object.Area * FlippedSig.Object(t-Signal.Object.Delay);
   else
      %-----------------------------------------------------------------------
      % FlippedSig is an impulse, but Signal is not
      %-----------------------------------------------------------------------
      Area = FlippedSig.Object.Area * Signal.Object(t-FlippedSig.Object.Delay);
   end
   % Create a dummy impulse to get its xdata/ydata, then delete it
   imp = cimpulse('PlotHeight',Area,'PlotScale',0.5,'Delay',t,'Area',Area);
   hold on;
   hP = ezplot(imp,'visible','off');
   hold off;
   PatchData = get(hP(1),{'XData','YData'});
   TextData  = get(hP(2),{'Pos','String','Vert'});
   delete(hP);
   set(h.Patch.MultipliedSig,{'XData','YData'},PatchData,'visible','on');
   set(h.Text.ImpulseText.Multiply,{'Pos','String','Vert'},TextData,'visible','on');
   mY = min([0; min(PatchData{2}); YLim_SigAxis(1)]);
   MY = max([0; max(PatchData{2}); YLim_SigAxis(2)]);
else
   fs = max(suggestrate(Signal.Object,supp),suggestrate(FlippedSig.Object,supp));
   tau = [supp(1):1/fs:supp(2)];
   y  = [0 Signal.Object(tau) .* FlippedSig.Object(t-tau) 0];
   tau = [tau(1) tau tau(end)];
   set(h.Patch.MultipliedSig,'XData',tau,'YData',y,'Visible','on');
   mY = min([0 min(y) YLim_SigAxis(1)]);
   MY = max([0 y YLim_SigAxis(2)]);
end
if mY == MY;
   mY = MY - 1;
   MY = mY + 1;
end
set(h.Axis.Multiply, 'YLim', [mY MY]);
