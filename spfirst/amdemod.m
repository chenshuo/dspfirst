function dd = amdemod(xx,fc,fs,tau)
%AMDEMOD Demodulate an amplitude modulated waveform 
%        using a simple scheme consisting of a rectifier
%        followed by a leaky first-order hold scheme.
%               dd = amdemod(xx,fc,fs,tau)
% where
%       xx = the input AM waveform to be demodulated
%       fc = carrier frequency
%       fs = sampling frequency
%      tau = time constant of the RC circuit (OPTIONAL)
%             (default value is tau=0.97)
%       dd = demodulated message waveform
%
if (nargin == 3)
    tau = 0.97;
elseif (nargin < 3)
    error('AMDEMOD requires at least three inputs');
end
%-- Set up a vector for the demodulated waveform
dd = zeros(size(xx));
dd(1) = xx(1);
for j=2:length(xx),            %- loop and hit each peak
    dd(j) = dd(j-1) * tau;     %- model resister leakage
    dd(j) = max(xx(j),dd(j));  %-  and  diode capacitor charging
end;
