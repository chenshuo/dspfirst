function [sMag,sPhi] = polarformstring(z,nDIGITS)
%POLARFORMSTRING Proper string for complex number in polar form.
%   [sMag,sPhi] = POLARFORMSTRING(z,nDIGITS) finds the proper strings
%   f for the magnitude and phase of the complex number z.  nDIGITS is 
%   the number of digits to use in NUM2STR function.
%
%   [sMag,sPhi] = POLARFORMSTRING(z) uses nDIGITS = 3

% Jordan Rosenthal, 15-Sep-1999

TOL = 1e-7;
if nargin == 1
   nDIGITS = 3;
end

r   = abs(z);
Phi = angle(z);

if      abs(r)<TOL, r = 0;     end
if    abs(Phi)<TOL, Phi = 0;   end
if abs(Phi-pi)<TOL, Phi = pi;  end
if abs(Phi+pi)<TOL, Phi = -pi; end

if r == 0
   sMag = '0';
else
   sMag = num2str(r,nDIGITS);
end

if Phi == 0
   sPhi = '0';
elseif Phi == -pi
   sPhi = '-pi';
elseif Phi == pi
   sPhi = 'pi';
else
   sPhi = [num2str(Phi/pi,nDIGITS) '*pi'];
end
