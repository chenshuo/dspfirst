function f = pulse(varargin)
%PULSE Create a PULSE object.
%   f = PULSE('Parameter1','Value1','Parameter2','Value2',...)
%   create an object of class 'pulse' with the given parameters.
%
%   f = PULSE(Signal,'Parameter1','Value1','Parameter2','Value2',...)
%   uses the PULSE object Signal as a template.
%
%   This function can be called with no arguments, or just a subset of
%   parameter/value pairs as well.  In that case, default values are substituted.
%
%   Parameter Names / Default Values
%   --------------------------------
%   'Name'      'Pulse'
%   'Amplitude'      1
%   'Length'        10
%   'Delay'          0

% Jordan Rosenthal, 12/16/97

if (nargin > 0) & isa(varargin{1},'pulse')
   f = varargin{1};
   varargin = varargin(2:end);
   if nargin == 1, return;, end
else
   f.Name = 'Pulse';
   f.Amplitude = 1;
   f.Length = 10;
   f.Delay = 0;
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
      case 'length'    , f.Length    = round( Param_Vals{i} );
         if f.Length<1, error('Signal length must be greater than or equal to 1.');, end
      case 'delay'     , f.Delay     = round( Param_Vals{i} );
      end
   end
end
f.XData = f.Delay:f.Delay + f.Length - 1;
f.YData = f.Amplitude*ones(f.Length,1);
f.XData = f.XData';
if ~isa(f,'pulse')
   f = class(f,'pulse');
end