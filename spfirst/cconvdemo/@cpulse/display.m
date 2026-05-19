function display(f)
%DISPLAY Displays the CPULSE objects data.
%   DISPLAY(f) displays the objects data.  It is automatically called from
%   when the object is entered in the command window without terminating semicolon.
%
%   See also CPULSE

% Jordan Rosenthal, 02-Nov-1999
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
disp(['   ' s]);
