function varargout = getparams(Signal, varargin)
%GETPARAMS Gets the parameters for the COSINE object
%   [p1,p2,...] = GETPARAMS(Signal,'Parameter1','Parameter2,...)
%   returns the values of the parameters requested for the COSINE
%   object Signal.
%
%   Valid parameters are:
%     'Name'
%     'Amplitude'
%     'Period'
%     'Phase'
%     'Length'
%     'Delay'
%     'XData'
%     'YData'
%
%   See also COSINE

% Jordan Rosenthal, 4/6/98

for i = 1:length(varargin)
   switch lower( varargin{i} )
   case 'name'      , varargout{i} = Signal.Name;
   case 'amplitude' , varargout{i} = Signal.Amplitude;
   case 'period'    , varargout{i} = Signal.Period;
   case 'phase'     , varargout{i} = Signal.Phase;
   case 'length'    , varargout{i} = Signal.Length;
   case 'delay'     , varargout{i} = Signal.Delay;
   case 'xdata'     , varargout{i} = Signal.XData;
   case 'ydata'     , varargout{i} = Signal.YData;
   otherwise
      error('Illegal parameter.');
   end
end



