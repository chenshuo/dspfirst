function f = unitsample(varargin)
%UNITSAMPLE Create a UNITSAMPLE object.
%   f = UNITSAMPLE('Parameter1','Value1','Parameter2','Value2',...)
%   create an object of class 'unitsample' with the given parameters.
%
%   This function can be called with no arguments, or just a subset of
%   parameter/value pairs as well.  In that case, default values are substituted.
%
%   Parameter Names / Default Values
%   --------------------------------
%   'Name'      'Unit Sample'
%   'Amplitude'      1
%   'Delay'          0

% Jordan Rosenthal, 12/16/97

if (nargin > 0) & isa(varargin{1},'unitsample')
   f = varargin{1};
   varargin = varargin(2:end);
   if nargin == 1, return;, end
else
   f.Name = 'Unit Sample';
   f.Amplitude = 1;
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
      case 'delay'     , f.Delay     = round( Param_Vals{i} );
      end
   end
end
f.XData = f.Delay;
f.YData = f.Amplitude;
if ~isa(f,'unitsample');
   f = class(f,'unitsample');
end
