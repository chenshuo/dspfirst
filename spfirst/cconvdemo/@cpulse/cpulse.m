function f = cpulse(varargin)
%CPULSE Create a CPULSE object.
%   f = CPULSE('Parameter1','Value1','Parameter2','Value2',...)
%   create an object of class 'cpulse' with the given parameters.
%
%   f = CPULSE(Signal,'Parameter1','Value1','Parameter2','Value2',...)
%   uses the CPULSE object Signal as a template.
%
%   This function can be called with no arguments, or just a subset of
%   parameter/value pairs as well.  In that case, default values are substituted.
%
%   Parameter Names / Default Values
%   --------------------------------
%   'Name'      'Pulse'
%   'Amplitude'      1
%   'Width'          2
%   'Delay'          0

% Jordan Rosenthal, 16-Dec-1997
%             Rev., 26-Oct-2000 Renamed to CPULSE

if (nargin > 0) & isa(varargin{1},'cpulse')
   f = varargin{1};
   varargin = varargin(2:end);
   if nargin == 1, return;, end
else
   f.Name = 'Pulse';
   f.Amplitude = 1;
   f.Width    = 2;
   f.Delay     = 0;
end

if nargin > 0 
   L = length( varargin );
   if ( rem( L, 2 ) ~= 0 )
      error('Parameter/Values must come in pairs.')
   end
   Param_Names = varargin(1:2:end);
   Param_Vals = varargin(2:2:end);
   for i = 1:length(Param_Names)
      switch lower( Param_Names{i} )
      case 'name'      , f.Name      = Param_Vals{i};
      case 'amplitude' , f.Amplitude = Param_Vals{i};
      case 'width'     , f.Width     = Param_Vals{i};
         if f.Width<=0, error('Signal length must be greater than 0.');, end
      case 'delay'     , f.Delay     = Param_Vals{i};
      end
   end
end
if ~isa(f,'cpulse')
   f = class(f,'cpulse');
end