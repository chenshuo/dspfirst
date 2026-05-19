function h = newquestion(h,Answers)
% NewQuestion	Creates a new zdrill problem

% James H. McClellan, 1994-1995
%               Rev., 13-Sep-1999 by Jordan Rosenthal

nDIGITS = 3;           % Number of digits used in num2str(x,nDIGITS)

%----------------------------------------------------------------------------
% Get z1
%----------------------------------------------------------------------------
r     = pickone(Answers.r);
theta = pickone(Answers.theta);
h.z1  = r*exp(j*theta);

%----------------------------------------------------------------------------
% Get z2
%----------------------------------------------------------------------------
switch h.Operation
case {'Add','Subtract','Multiply','Divide'}
   r     = pickone(Answers.r);
   theta =  pickone(Answers.theta);
   h.z2 = r*exp(j*theta);
otherwise
   % Do nothing - leave z2 as is.
end

%----------------------------------------------------------------------------
% Get the answer
%----------------------------------------------------------------------------
h.z3.Add       = h.z1 + h.z2;
h.z3.Subtract  = h.z1 - h.z2;
h.z3.Multiply  = h.z1 * h.z2;
h.z3.Divide    = h.z1 / h.z2;
h.z3.Inverse   = 1 / h.z1;
h.z3.Conjugate = conj(h.z1);
%----------------------------------------------------------------------------
% Reset the guess
%----------------------------------------------------------------------------
h.Guess = j;
set(h.Edit.Radius,         'String', '1');
set(h.Edit.Angle,          'String', 'pi/2');
%----------------------------------------------------------------------------
% Finish up
%----------------------------------------------------------------------------
hObj = [h.Checkbox.ShowRectForm h.Checkbox.ShowVectorSum h.Checkbox.ShowAnswer];
set(hObj,'Value',0);
updatestrings(h);
h = makeplots(h);