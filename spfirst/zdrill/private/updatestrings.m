function updatestrings(h)
% Updates the strings in the ZDRILL GUI

nDIGITS = 3;   % Number of significant digits

%----------------------------------------------------------------------------
% z1
%----------------------------------------------------------------------------
[str.Radius,str.Angle] = polarformstring(h.z1);
str.Radius   = ['    r = ' str.Radius];
str.Angle    = ['    theta = ' str.Angle];
str.RectForm = ['z1 = ' rectformstring(h.z1,nDIGITS)];
set(h.Text.z1.Radius,   'string', str.Radius);
set(h.Text.z1.Angle,    'string', str.Angle);
set(h.Text.RectForm.z1, 'string', str.RectForm);

%----------------------------------------------------------------------------
% z2
%----------------------------------------------------------------------------
switch h.Operation
case {'Add','Subtract','Multiply','Divide'}
   [str.Radius,str.Angle] = polarformstring(h.z2);
   str.Radius   = ['    r = ' str.Radius];
   str.Angle    = ['    theta = ' str.Angle];
   str.RectForm = ['z2 = ' rectformstring(h.z2,nDIGITS)];
   set(h.Text.z2.Radius,   'string', str.Radius);
   set(h.Text.z2.Angle,    'string', str.Angle);
   set(h.Text.RectForm.z2, 'string', str.RectForm);
otherwise
   % Do nothing - leave z2 as is.
end

%----------------------------------------------------------------------------
% Answer
%----------------------------------------------------------------------------
TOL = 1e-7;
z3 = getfield(h.z3,h.Operation);
[str.Radius,str.Angle] = polarformstring(z3,nDIGITS);
str.RectForm = rectformstring(z3,nDIGITS);
set(h.Menu.Radius,     'Label', ['r = ' str.Radius]);
set(h.Menu.Angle,      'Label', ['theta = ' str.Angle]);
set(h.Menu.RectForm,   'Label', ['z = ' str.RectForm]);

%----------------------------------------------------------------------------
% Guess
%----------------------------------------------------------------------------
str.RectForm = ['z = ' rectformstring(h.Guess,nDIGITS)];
set(h.Text.RectForm.Guess, 'String', str.RectForm);

%----------------------------------------------------------------------------
% If checkbox marked show RectForm, else hide
%----------------------------------------------------------------------------
hObj = [h.Text.RectForm.Guess h.Text.RectForm.z1 h.Text.RectForm.z2];
if get(h.Checkbox.ShowRectForm,'Value')
   set(hObj,'Visible','On');
else
   set(hObj,'Visible','Off');
end
