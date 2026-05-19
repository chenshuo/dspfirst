function b = subsref(sig,S)

switch S.type
case '()'
   b = feval(sig,S.subs{:});
case '.'
   switch lower(S.subs)
   case {'amplitude','delay','width','name'}
      b = eval(['sig.' S.subs]);
   otherwise
      error(['The parameter ' S.subs ' does not exist.']);
   end
otherwise
   error('Cell subscripting not supported.');
end