function f = usersignal(varargin)
%USERSIGNAL Create a USERSIGNAL object.
%   f = USERSIGNAL('Parameter1','Value1','Parameter2','Value2')
%   create an object of class 'usersignal' with the given parameters.
%
%   This function can be called with no arguments, or just a subset of
%   parameter/value pairs as well.  In that case, default values are substituted.
%
%   Parameter Names / Default Values
%   --------------------------------
%   'Name'      'User Signal'
%   'Amplitude' '[1 1 1 1]'

% Jordan Rosenthal, 12/16/97
% Rajbabu Velmurugan, 2/17/2004 - Adapted from 'Unit Sample'

  if (nargin > 0) & isa(varargin{1},'usersignal')
    f = varargin{1};
    varargin = varargin(2:end);
    if nargin == 1, return;, end
  else
    f.Name = 'User Signal';
    f.Amplitude = '[1 1 1 1]';
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
              case 'name' 
                  f.Name      = Param_Vals{i};
              case 'amplitude' 
                  f.Amplitude = Param_Vals{i};
          end
      end
  end
  if isstr(f.Amplitude)
      lasterr('');
      str = eval(f.Amplitude,'[1 1 1 1]');
      if ~isempty(lasterr)
        errordlg(lasterr,'dconvdemo - Error','modal');    
      end
      Amplitude = str;
  else
      Amplitude = f.Amplitude;
  end   
  
  f.XData = 0:1:length(Amplitude)-1;
  f.YData = Amplitude;
  if ~isa(f,'usersignal');
    f = class(f,'usersignal');
  end
  