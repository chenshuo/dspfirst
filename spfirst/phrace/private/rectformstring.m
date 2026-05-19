function s = rectformstring(z,nDIGITS)
%RECTFORMSTRING Proper string for complex number in rectangular form.
%   s = RECTFORMSTRING(z,nDIGITS) finds the proper string x+jy for a complex
%   number z.  nDIGITS is the number of digits to use in NUM2STR function.
%
%   s = RECTFORMSTRING(z) uses nDIGITS = 3

% Jordan Rosenthal, 15-Sep-1999

TOL = 1e-7;
if nargin == 1
   nDIGITS = 3;
end

if isstruct(z)
   x = real(z.xy);
   y = imag(z.xy);
else
   x = real(z);
   y = imag(z);
end

if abs(x)<TOL, x = 0; end
if abs(y)<TOL, y = 0; end
if abs(x-1)<TOL, x = 1; end
if abs(y-1)<TOL, y = 1; end
if (x == 0)
   if y == -1
      s = '-j';
   elseif y == 0
      s = '0';
   elseif y == 1
      s = 'j';
   elseif y > 0
      s = ['j' num2str(y,nDIGITS)];
   else
      s = ['-j' num2str(-y,nDIGITS)];
   end
else
   sx = num2str(x,nDIGITS);
   if y == -1
      s = [sx ' - j'];
   elseif y == 0
      s = sx;
   elseif y == 1
      s = [sx ' + j'];
   elseif y > 0 
      s = [sx ' + j' num2str(y,nDIGITS)];
   else
      s = [sx ' - j' num2str(-y,nDIGITS)];
   end
end
