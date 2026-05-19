function stxt = cosformstring(r,phi,wt)
%COSFORMSTRING Proper string for cosine from polar form.
%   stxt = COSFORMSTRING(r,phi,wt)

% Jim McClellan, 20-Jan-01

if strcmp(phi,'0')|strcmp(phi,'-0')
   phi = '';
else
   phi = strrep([' + ',phi],' + -',' - ');
end
if strcmp(r,'1')
   stxt = ['cos(',wt,phi,')'];
elseif strcmp(r,'0')
   stxt = '0';
else
   stxt = [r,'cos(',wt,phi,')'];
end
stxt = strrep(stxt,'e^{j0}','');
stxt = strrep(stxt,'(1{t}','({t}');
stxt = strrep(stxt,'(1\pi{t}','(\pi{t}');
