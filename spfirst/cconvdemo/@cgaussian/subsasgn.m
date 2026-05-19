function f = subasgn(f,S,b)

% Rajbabu Velmurugan, 15-Feb-2004, Adapted from 'subsasgn' for exponential
%                                  signal
  
  switch S.type
   case '.'
    switch lower(S.subs)
     case {'scalingfactor','expconstant','length','delay'}
      eval(['f.' S.subs '=b;']);
     otherwise
      error(['The parameter ' char(39) S.subs char(39) ' does not exist.']);
    end
   otherwise
    error('Illegal subscripts.');
  end

% endfunction subsasgn