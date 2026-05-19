function [X,w] = showspec(x,fs)
%SHOWSPEC  Plot a simple estimate of the spectrum of a signal.  
%    usage:   [X,w] = SHOWSPEC(x,fs)
%        x = the signal
%       fs = the sample rate  (if omitted, it defaults to 2)
%        X = the magnitude of the spectrum
%        w = the corresponding frequency vector
% 
%    If no output arguments are used SHOWSPEC plots the spectrum.
%    Otherwise, no spectrum is plotted.
%
%-- Updated by jMc (10/98) include Hamming window as in-line code.
%

if nargin < 2,
    fs = 2;
end
if nargin < 1,
    error('SHOWSPEC expects 1 or 2 input arguments');
end
x = x(:);
L = 2^ceil(log2(length(x)));
%--
   Lx = length(x);
   HammW = 0.54 - 0.46*cos(2*pi*(0:Lx-1)'/(Lx-1));
%--
XX = abs(fft(HammW.*x,L))/length(x)*3.86;
XX = XX(1:L/2);
ww = [0:L/2-1]/L*fs;

if nargout == 0,
    plot(ww,XX);
    grid on;
    zoom on;
    xlabel('Frequency in Hz');
    ylabel('Approximate Amplitude');
else
    X = XX;
    w = ww;
end
