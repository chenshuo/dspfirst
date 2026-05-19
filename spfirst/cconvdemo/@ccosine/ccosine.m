function f = sinusoid(varargin)
%CCOSINE Create a CCOSINE object.
%   f = CCOSINE('Parameter1','Value1','Parameter2','Value2',...)
%   create an object of class 'sinusoid' with the given parameters.
%
%   f = CCOSINE(Signal,'Parameter1','Value1','Parameter2','Value2',...)
%   uses the CCOSINE object Signal as a template.
%
%   This function can be called with no arguments, or just a subset of
%   parameter/value pairs as well.  In that case, default values are substituted.
%
%   Parameter Names / Default Values
%   --------------------------------
%   'Name'      'Cosine'
%   'Amplitude'      1
%   'Period'        10
%   'Phase'          0
%   'Length'        10
%   'Delay'          0

% Jordan Rosenthal, 05-Nov-1999
%             Rev., 26-Oct-2000 : Renamed to CCOSINE

if (nargin > 0) & isa(varargin{1},'ccosine')
   f = varargin{1};
   varargin = varargin(2:end);
   if nargin == 1, return;, end
else
   f.Name = 'Cosine';
   f.Amplitude = 1;
   f.Period = 10;
   f.Phase = 0;
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
      case 'period'    , f.Period    = Param_Vals{i};
         if f.Period <= 0, error('Period must be greater than 0.');, end
      case 'phase'     , f.Phase     = Param_Vals{i};
      case 'length'    , f.Length    = Param_Vals{i};
         if f.Length<=0, error('Signal length must be greater than or equal to 0.');, end
      case 'delay'     , f.Delay     = Param_Vals{i};
      end
   end
end
if ~isa(f,'ccosine');
   f = class(f,'ccosine');
end
