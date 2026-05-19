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
%  but is implemented in a more straightforward manner
%
if nargin<5
   error('SPECTGR: must give all five input arguments')
end
L = length(window);
if L<=1
   if( L==0 ), L = Nfft, end
   L = window;
   window = hanning(L);
end
if size(xx,1)==1
   xx = xx(:);
end
shift = L-Noverlap;
if( shift<0 )
   error('SPECTGR: overlap must be less than window length')
end
Lx = length(xx);
num_segs = 1 + fix( (Lx-L)/shift );
B = zeros( Nfft/2+1, num_segs );     %- Pre-allocate the matrix
iseg = 0;
while( iseg<num_segs ) 
    nstart = 1 + iseg*shift;
    xsegw = window .* xx( nstart:nstart+L-1);
    XX = fft( xsegw, Nfft );
    iseg = iseg + 1;
    B(:,iseg) = XX(1:Nfft/2+1);    
end
F = (0:(Nfft/2))/Nfft * fs;
T = (L/2 + shift*(0:num_segs-1) ) / fs;
