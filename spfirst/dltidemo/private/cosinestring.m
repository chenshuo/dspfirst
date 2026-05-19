function s = cosinestring(Amp, Freq, Phase, Delay, DC)
%COSINESTRING Gets the formula string for the COSINE object.
%   s = COSINESTRING(Amp,Freq,Phase,Delay,DC) returns a formatted string s
%   representing the formula for a cosine signal of the form
%
%      DC + Amp*cos(Freq*pi*(n-Delay)+Phase*pi)

% Jordan Rosenthal, 4/6/98
% Rev. Budiyanto Junus 2/9/99
% Assumes Freq is normalized by pi
%         Phase is normalized by pi
% ** Rev. Jim McClellan 10-May-99   added argument for DC
% Rev. Greg Krudysz 25-Oct-04 : modified for case Freq = 0

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
   w0 = '';
elseif abs(w0-1)<TOL
	w0 = '\pi';
elseif abs(w0+1)<TOL
	w0 = '-\pi';
else
	w0 = [num2str(w0,ndigs) '\pi'];
end

% Phase
if abs(Phase) <= TOL
    Phase = '';
elseif abs(Phase-1)<TOL
    if Freq == 0
        Phase = '\pi';
    else
        Phase = ' + \pi';
    end
elseif abs(Phase+1)<TOL
    Phase = ' - \pi';
elseif Phase > 0
    if Freq == 0
        Phase =  [num2str(Phase,ndigs) '\pi'];    
    else
        Phase = [' + ' num2str(Phase,ndigs) '\pi'];
    end
else   
    Phase = [' - ' num2str(-Phase,ndigs) '\pi'];
end

% Delay
if Freq == 0
    n = '';
else
    if Delay == 0
        n = 'n';
    elseif Delay < 0
        n = ['[n + ' num2str(-Delay,ndigs) ']'];
    else
        n = ['[n - ' num2str(Delay,ndigs) ']'];
    end
end

if Amp ~= 0
    if Freq == 0 & isempty(Phase) & Delay == 0
            out = DC + Amp;
        s = {num2str(out)};
    else
        s = {[txtDC A 'cos(' w0 n Phase ')' ]};
    end
elseif length(txtDC)
    s = txtDC;
else
    s = '0';
end