function highlightaliaseddata(whatMode)
%HIGHLIGHTALIASEDDATA Highlight the sections of the data that are aliased.
%   HIGHLIGHTALIASEDDATA(config) will highlight the aliased parts of the
%   linear convolution when in circular convolution configuration.

% Jordan Rosenthal, 04-Apr-2000 Converted to separate function.
% jr@ece.gatech.edu

OFF = 0; ON = 1;
h = get(gcbf,'UserData');
if whatMode == ON
   N = h.State.CircularConvLength;
   XData = h.Data.Output.XData;
   nXData = length(XData);
   [V,I] = intersect(XData,0:N-1);
   ExtraPeriods = setdiff(1:nXData,I);
   if ~isempty(ExtraPeriods)
      [V,Overlapped] = intersect(XData, mod(XData(ExtraPeriods), N));
   else
      Overlapped = [];
   end
   Unaliased = setdiff(I,Overlapped);
   set(h.Lines.TotalOutput(2*Overlapped-1),'color','r','marker','s') 
   set(h.Lines.TotalOutput(2*Overlapped),'color','r');
   set(h.Lines.TotalOutput(2*Unaliased-1),'color','b','marker','o');
   set(h.Lines.TotalOutput(2*Unaliased),'color','b');
   set(h.Lines.TotalOutput(2*ExtraPeriods-1),'color','r','marker','o');
   set(h.Lines.TotalOutput(2*ExtraPeriods),'color','r');
else
   set(h.Lines.TotalOutput,'Color','b');
   set(h.Lines.TotalOutput(1:2:end),'marker','o');
end
