function varargout = getparams(Signal, varargin)
%GETPARAMS Gets the parameters for the USERSIGNAL object
%   [p1,p2,...] = GETPARAMS(Signal,'Parameter1','Parameter2,...)
%   returns the values of the parameters requested for the USERSIGNAL
%   object Signal.
%
%   Valid parameters are:
%     'Name'
%     'Amplitude'
%     'Delay'
%     'XData'
%     'YData'
%
%   See also USERSIGNAL

% Jordan Rosenthal, 12/16/97

  for i = 1:length(varargin)
    switch lower( varargin{i} )
     case 'name'      , varargout{i} = Signal.Name;
     case 'amplitude' , varargout{i} = Signal.Amplitude;
     case 'xdata'     , varargout{i} = Signal.XData;
     case 'ydata'     , varargout{i} = Signal.YData;
     otherwise
      error('Illegal parameter.');
    end
  end

  


