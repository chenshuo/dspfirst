function display(f)
%DISPLAY Displays the USERSIGNAL objects data.
%   DISPLAY(f) displays the objects data.  It is automatically called from
%   when the object is entered in the command window without terminating semicolon.
%
%   See also USERSIGNAL

% Rajbabu Velmurugan, 2/17/2004

Param_Names = char( {'Amplitude: '});
Param_Vals = [f.Amplitude];
Divider(1:length(f.Name)) = '-';
disp(' ');
disp(f.Name);
disp(Divider);
for i = 1:size(Param_Names,1)
   disp([Param_Names(i,:) num2str(Param_Vals(i))]);
end
disp(' ');
