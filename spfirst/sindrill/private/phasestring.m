function s = phasestring(Phase)
%PHASESTRING Parse
%   s = COSINESTRING(Phase) returns a formatted string s
%   representing the Phase normalized by pi.

% Jordan Rosenthal, 11-Sep-1999

ndigs = 3;
TOL = 1e-7;
if abs(Phase) <= TOL
	s = '0';
elseif abs(Phase-pi)<TOL
	s = 'pi';
elseif abs(Phase+pi)<TOL
	s = '-pi';
else
	s = [num2str(Phase/pi,ndigs) 'pi'];
end
