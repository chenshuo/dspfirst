function f = cimpulse(varargin)
%CIMPULSE Create a CIMPULSE object.
%   f = CIMPULSE('Parameter1','Value1','Parameter2','Value2',...)
%   create an object of class 'pulse' with the given parameters.
%
%   f = CIMPULSE(Signal,'Parameter1','Value1','Parameter2','Value2',...)
%   uses the CIMPULSE object Signal as a template.
%
%   This function can be called with no arguments, or just a subset of
%   parameter/value pairs as well.  In that case, default values are substituted.
%
%   Parameter Names / Default Values
%   --------------------------------
%   'Name'      'Impulse'
%   'Area'           1
%   'Delay'          0
%   'PlotHeight'     1    ----> The height to use when plotted in an axis
%   'PlotScale'      1    ----> The scale for the arrow

% Jordan Rosenthal, 07-Nov-1999
%             Rev., 26-Oct-2000 Changed name to CIMPULSE

if (nargin > 0) & isa(varargin{1},'cimpulse')
   f = varargin{1};
   varargin = varargin(2:end);
   if nargin == 1, return;, end
else
   f.Name       = 'Impulse';
   f.Area       = 1;
   f.Delay      = 0;
   f.PlotHeight = 1;
   f.PlotScale  = 1;
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
      case 'name'       , f.Name       = Param_Vals{i};
      case 'area',      , f.Area       = Param_Vals{i};
      case 'delay'      , f.Delay      = Param_Vals{i};
      case 'plotheight' , f.PlotHeight = Param_Vals{i};
      case 'plotscale'  , f.PlotScale  = Param_Vals{i};
      end
   end
end
if ~isa(f,'cimpulse')
   f = class(f,'cimpulse');
end