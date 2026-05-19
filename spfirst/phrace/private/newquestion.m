function h = newquestion(h,Answers)
% NewQuestion	Creates a new zdrill problem

% James H. McClellan, 1994-1995
%               Rev., 13-Sep-1999 by Jordan Rosenthal

nDIGITS = 3;           % Number of digits used in num2str(x,nDIGITS)

%----------------------------------------------------------------------------
% Get z1
%----------------------------------------------------------------------------
h.z1.r     = pickone(Answers.r);
h.z1.theta = pickone(Answers.theta);
h.z1.xy  = h.z1.r * exp(j*h.z1.theta);
h.z1.Conjugate = conj(h.z1.xy);

%----------------------------------------------------------------------------
% Get z2
%----------------------------------------------------------------------------
switch h.Operation
case {'Add','Subtract','Multiply','Divide'}
   h.z2.r     = pickone(Answers.r);
   h.z2.theta =  pickone(Answers.theta);
   if mod(abs(h.z1.theta-h.z2.theta),2*pi)<1e-5
      h.z2.theta = h.z1.theta + sign(h.z1.theta)*3*pi/2;
   end
   h.z2.xy = h.z2.r * exp(j*h.z2.theta);
   h.z2.Conjugate = conj(h.z2.xy);
otherwise
   % Do nothing - leave z2 as is.
end

%----------------------------------------------------------------------------
% Get the answer
%----------------------------------------------------------------------------
h.z3.Add       = h.z1.xy + h.z2.xy;
h.z3.Subtract  = h.z1.xy - h.z2.xy;
h.z3.Multiply  = h.z1.xy * h.z2.xy;
h.z3.Divide    = h.z1.xy / h.z2.xy;
h.z3.Inverse   = 1 / h.z1.xy;
h.z3.Conjugate = conj(h.z1.xy);
