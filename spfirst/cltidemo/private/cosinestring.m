function s = cosinestring(Amp, Freq, Phase, Delay, DC)
%COSINESTRING Gets the formula string for the COSINE object.
%   s = COSINESTRING(Amp,Freq,Phase,Delay,DC) returns a formatted string s
%   representing the formula for a cosine signal of the form
%
%      DC + Amp*cos(2*pi*Freq*(t-Delay)+Phase*pi)

% Jordan Rosenthal, 4/6/98
% Rev. Budiyanto Junus 2/9/99
% Assumes Phase is normalized by pi
% ** Rev. Jim McClellan 10-May-99   added argument for DC
% ** Rev. Jordan Rosenthal 11-Sep-1999  
%         Changed time axis from n to t
%         Changed frequency term from x*pi to 2*pi*x
%         Freq no longer normalized by pi
%         Increased ndigs from 3-->4

TOL   = 1e-7;
ndigs = 3;

if nargin <= 4
   DC = 0;
end
if nargin <= 3
   Delay = 0;
end

if abs(DC) > TOL
   txtDC = [num2str(DC,ndigs) ' '];
   if Amp>TOL
       txtDC = [txtDC,'+ '];
   end
else
    txtDC = '';
end

if abs(Amp) <= TOL
   Amp = 0;
end

if abs(Amp-1) <= TOL
    A = '';
elseif abs(Amp+1) <= TOL
    A = '-';
else
    A = [num2str(Amp,ndigs) ' '];
end

w0 = Freq;
if abs(w0) <= TOL
   w0 = '0';
elseif abs(w0-1)<TOL
    w0 = '\pi';
elseif abs(w0+1)<TOL
	w0 = '-\pi';
elseif w0>0
   w0 = [ num2str(2*w0,ndigs) '\pi' ];
else
   w0 = [ num2str(-2*w0,ndigs) '-2\pi'];
end
if abs(Phase) <= TOL
    Phase = '';
elseif abs(Phase-1)<TOL
    Phase = ' + \pi';
elseif abs(Phase+1)<TOL
    Phase = ' - \pi';
elseif Phase > 0
    Phase = [' + ' num2str(Phase,ndigs) '\pi'];
else   
    Phase = [' - ' num2str(-Phase,ndigs) '\pi'];end
if Delay == 0
   t = 't';
elseif Delay < 0
   t = ['[t + ' num2str(-Delay,ndigs) ']'];
else
   t = ['[t - ' num2str(Delay,ndigs) ']'];
end

if Amp ~= 0
   s = {[txtDC A 'cos(' w0 t Phase ')' ]};
elseif length(txtDC)
    s = txtDC;
else
   s = '0';
end

% endfunction cosinestring
% eof: cosinestring.m