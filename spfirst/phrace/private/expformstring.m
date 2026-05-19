function stxt = expformstring(r,phi,wt)
%EXPFORMSTRING Proper string for exponential from polar form.
%   stxt = EXPFORMSTRING(r,phi,wt)

% Jim McClellan, 20-Jan-01

phi = strrep(['j',phi],'j-','-j');
stxt = ['e^{',phi,'}'];
if nargin==3
   wt = strrep(['j',wt],'j-','-j');
   stxt = [stxt,'e^{',wt,'}'];
end
if strcmp(r,'0')
   stxt = '0';
else
   stxt = [r,stxt];
end
stxt = strrep(stxt,'e^{j0}','');
stxt = strrep(stxt,'e^{-j0}','');
stxt = strrep(stxt,'j1{t}','j{t}');
stxt = strrep(stxt,'j1\pi{t}','j\pi{t}');
if size(stxt, 2) > 2
  stxt = [strrep(stxt(1:2),'1e','e'),stxt(3:end)];
end
