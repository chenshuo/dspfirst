function SCALE = getfontscale()
%GETFONTSCALE Platform dependent code to get font scale.
%   SCALE = GETFONTSCALE determines the platform dependent value
%   for the SCALE parameter used with the SETFONTS function.
%
%   See also SETFONTS

% Jordan Rosenthal, 22-Jun-99

switch upper(computer)
case 'MAC2'
   SCALE = 1.4;
otherwise
   if isunix
      SCALE =1.2; 
   else
      SCALE = 1;
   end
end
