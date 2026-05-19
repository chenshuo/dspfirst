function f = cexponential(varargin)
%CEXPONENTIAL Create an CEXPONENTIAL object.
%   f = CEXPONENTIAL('Parameter1','Value1','Parameter2','Value2',...)
%   create an object of class 'cexponential' with the given parameters.
%
%   f = CEXPONENTIAL(Signal,'Parameter1','Value1','Parameter2','Value2',...)
%   uses the CEXPONENTIAL object Signal as a template.
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

% Jordan Rosenthal, 16-Dec-1997
%             Rev., 04-Nov-1997 Adjusted from discrete-time version
%             Rev., 26-Oct-2000 Renamed to CEXPONENTIAL

if (nargin > 0) & isa(varargin{1},'cexponential')
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
      case 'length'                  , f.Length        = Param_Vals{i};
         if f.Length<0, error('Signal length must be greater than or equal to 0.');, end
      case 'delay'                   , f.Delay         = Param_Vals{i};
      case 'causality'               , f.Causality     = Param_Vals{i};
         if ~any( strcmp(lower(f.Causality),{'causal','noncausal'}) )
            error('Causality must be either Causal or Noncausal.');
         end
      end
   end
end
if ~isa(f,'cexponential')
   f = class(f,'cexponential');
end
