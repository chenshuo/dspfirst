function display(f)
%DISPLAY Displays the CIMPULSE objects data.
%   DISPLAY(f) displays the objects data.  It is automatically called from
%   when the object is entered in the command window without terminating semicolon.
%
%   See also CIMPULSE

% Jordan Rosenthal, 03-Nov-1999
%             Rev., 26-Oct-2000 Revised comments

if isequal(get(0,'FormatSpacing'),'compact')
   disp([inputname(1), ' = ']);
   dispf(f);
else
   disp(' ');
   disp([inputname(1), ' = ']);
   disp(' ');
   dispf(f);
end

function dispf(f)
s = formulastring(f);
s = strrep(s,'\rm','');
s = strrep(s,'\it','');
s = strrep(s,'\','');
switch s(1:2)
case {'-d',' d'}
   % Do nothing
otherwise
   s = strrep(s,'delta','*delta');
end
disp(['   ' s]);
