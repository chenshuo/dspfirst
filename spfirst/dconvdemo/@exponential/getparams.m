function varargout = getparams(Signal, varargin)
%GETPARAMS Gets the parameters for the EXPONENTIAL object
%   [p1,p2,...] = GETPARAMS(Signal,'Parameter1','Parameter2,...)
%   returns the values of the parameters requested for the EXPONENTIAL
%   object Signal.
%
%   Valid parameters are:
%     'Name'
%     'ScalingFactor'
%     'ExpConstant'
%     'Length'
%     'Delay'
%     'Causality'
%     'XData'
%     'YData'
%
%   See also EXPONENTIAL

% Jordan Rosenthal, 12/16/97

for i = 1:length(varargin)
   switch lower( varargin{i} )
   case 'name'                 , varargout{i} = Signal.Name;
   case 'scalingfactor'        , varargout{i} = Signal.ScalingFactor;
   case 'expconstant'          , varargout{i} = Signal.ExpConstant;
   case 'length'               , varargout{i} = Signal.Length;
   case 'delay'                , varargout{i} = Signal.Delay;
   case 'causality'            , varargout{i} = Signal.Causality;
   case 'xdata'                , varargout{i} = Signal.XData;
   case 'ydata'                , varargout{i} = Signal.YData;
   otherwise
      error('Illegal parameter.');
   end
end



