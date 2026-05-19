function f = exponential(varargin)
%EXPONENTIAL Create an EXPONENTIAL object.
%   f = EXPONENTIAL('Parameter1','Value1','Parameter2','Value2',...)
%   create an object of class 'exponential' with the given parameters.
%
%   f = EXPONENTIAL(Signal,'Parameter1','Value1','Parameter2','Value2',...)
%   uses the EXPONENTIAL object Signal as a template.
%
%   This function can be called with no arguments, or just a subset of
%   parameter/value pairs as well.  In that case, default values are substituted.
%
%   Parameter Names / Default Values
%   --------------------------------
%   'Name'               'Exponential'
%   'ScalingFactor'           1
%   'ExpConstant'           0.5
%   'Length'                 10
%   'Delay'                   0
%   'Causality'            'Causal'   {'Causal' or 'Noncausal'}

% Jordan Rosenthal, 12/16/97

if (nargin > 0) & isa(varargin{1},'exponential')
   f = varargin{1};
   varargin = varargin(2:end);
   if nargin == 1, return;, end
else
   f.Name = 'Exponential';
   f.ScalingFactor = 1;
   f.ExpConstant = 0.5;
   f.Length = 10;
   f.Delay = 0;
   f.Causality = 'Causal';
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
      case 'name'                    , f.Name          = Param_Vals{i};
      case 'scalingfactor'           , f.ScalingFactor = Param_Vals{i};
      case 'expconstant'             , f.ExpConstant   = Param_Vals{i};
      case 'length'                  , f.Length        = round( Param_Vals{i} );
         if f.Length<1, error('Signal length must be greater than or equal to 1.');, end
      case 'delay'                   , f.Delay         = round( Param_Vals{i} );
      case 'causality'               , f.Causality     = Param_Vals{i};
         if ~any( strcmp(lower(f.Causality),{'causal','noncausal'}) )
            error('Causality must be either Causal or Noncausal.');
         end
      end
   end
end
if strcmp( lower(f.Causality), 'causal' )
   f.XData = f.Delay : (f.Delay + f.Length - 1);
   f.YData = f.ScalingFactor*(f.ExpConstant).^(0:f.Length-1);
else
   f.XData = (f.Delay - f.Length + 1):f.Delay;
   f.YData = f.ScalingFactor*(f.ExpConstant).^(f.Length-1:-1:0);
end
f.XData = f.XData';
f.YData = f.YData';
if ~isa(f,'exponential')
   f = class(f,'exponential');
end
