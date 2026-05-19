function h = stem(Signal)
%STEM Overloaded STEM command for a COSINE object
%   h = STEM(Signal) creates a STEM plot for the COSINE object Signal.
%   The XLABEL of the plot is set to the Signal's Name property and the
%   plots TITLE is set to the output of FORMULASTRING(Signal).
%
%   See also COSINE, FORMULASTRING

% Jordan Rosenthal, 12/16/97
  
  matlabVersion = version ;
  if str2num(matlabVersion(1:3)) >= 7
    h = stemdata(Signal); %h = stemdata(Signal);
  else
    h = stem(Signal.XData,Signal.YData);
  end
  title(formulastring(Signal), 'Color', 'b', 'FontUnits', 'normalized', ...
	'FontSize',0.07);
  xlabel(Signal.Name, 'FontWeight', 'bold', 'FontUnits', 'normalized');
  