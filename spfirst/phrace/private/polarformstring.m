function sZ = polarformstring(z,nDIGITS)
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

if isstruct(z)
   r = z.r;
   Phi = z.theta;
else
   r   = abs(z);
   Phi = angle(z);
end

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
   sPhi = [num2str(Phi/pi,nDIGITS) 'pi'];
end
   sPhi2 = [num2str(Phi,nDIGITS)];


ssMag = sMag;
ssPhi = ['e^{j',sPhi,'}'];
ssPhi2 = ['e^{j',sPhi2,'}'];
if Phi<0
   ssPhi = ['e^{-j',sPhi(2:end),'}'];
   ssPhi2 = ['e^{-j',sPhi2(2:end),'}'];
end

if abs(Phi)<1e-8
   ssPhi = '';
end
ssPhi = strrep(ssPhi,'*','');
%ssPhi2 = strrep(ssPhi2,'*','');
ssPhi = strrep(ssPhi,'pi','\pi');
sZ.pi = [ssMag,ssPhi];
sZ.rad = [ssMag,ssPhi2];
sZ.Mag = sMag;
sZ.Phi = strrep(sPhi,'pi','\pi');
sZ.PhiRad = sPhi2;
