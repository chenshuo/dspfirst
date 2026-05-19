function [B,F,T] = spectgr( xx, Nfft, fs, window, Noverlap )
%SPECTGR    compute the spectrogram of a signal vector
% usage:
%  [B,F,T] = spectgr( xx, Nfft, fs, window, Noverlap )
%
%  B = spectrogram values
%  F = analysis frequencies from FFT (in Hz)
%  T = window position times (in sec)
%
%      xx = input signal vector. Must be column or row.
%    Nfft = length of FFT
%      fs = sampling frequency
%  window = window values. If a scalar is given it is
%           taken to be the window length.
%  Noverlap = number of samples points common to consecutive sections
%             Thus, the shift between sections is:  Nfft-Noverlap
%
% NOTE: all input arguments must be given; there are no defaults.
%
% This function is similar to the MATLAB function called specgram,
%  but is implemented in a more straightforward manner.  It does not
%  make the spectrogram plot.  Instead you must use plotspec.m
%

% 02-Dec-01 For COMPLEX input, generate negative freqs.

if nargout==0
   disp('WARNING: spectgr does NOT plot automatically')
   disp('..if you want a plot, use plotspec() instead.')
   disp('..it calls this function and then does the plot.')
   disp('.....do   help plotspec   for more information.')
   disp('.....NOTE: plotspec() has different args from specgram().')
   disp('.....')
end
if nargin<5
   error('SPECTGR: must give all five input arguments')
end
L = length(window);
if L<=1
   if( L==0 ), L = Nfft, end
   L = window;
   window = 0.5 * (1-cos(2*pi*(1:L)'/(L+1)));
end
if size(xx,1)==1
   xx = xx(:);
end
shift = L-Noverlap;
if( shift<0 )
   error('SPECTGR: overlap must be less than window length')
end
Nfft2 = floor(Nfft/2) + 1;
if( any(abs(imag(xx)))>eps )
   NB = Nfft;
   COMPLEX = 1;
else
   NB = Nfft2;
   COMPLEX = 0;
end

Lx = length(xx);
num_segs = 1 + fix( (Lx-L)/shift );
B = zeros( NB, num_segs );     %- Pre-allocate the matrix
iseg = 0;
while( iseg<num_segs ) 
    nstart = 1 + iseg*shift;
    xsegw = window .* xx( nstart:nstart+L-1);
    XX = fft( xsegw, Nfft );
    iseg = iseg + 1;
    B(:,iseg) = XX(1:NB);    
end
T = (L/2 + shift*(0:num_segs-1) ) / fs;
if COMPLEX
   B = [ B(Nfft2+1:Nfft,:); B(1:Nfft2,:)];   %- same as fftshift()
   F = ((Nfft2-Nfft):(Nfft2-1))/Nfft * fs;
else
   F = (0:(NB-1))/Nfft * fs;
end
