function [H,w] = freekz(b,a,w,two_pi_flag)
%FREEKZ   Frequency response for a rational (numerator/denominator) form.
%                                             -1                 -nb 
%               jw      B(z)      b(1) + b(2)z  + .... + b(nb+1)z
%            H(e  ) =   ----  =  -----------------------------------
%                                             -1                 -na
%                       A(z)      a(1) + a(2)z  + .... + a(na+1)z
%
%  usage:   [H,W] = FREEKZ(B,A,W)
%        - returns H at the frequencies specified in vector W
%            (See LOGSPACE to generate a non-uniform W).
%      B = filter coefficients of the numerator polynomial, B(z).
%      A = filter coefficients of the denominator polynomial, A(z).
%      W =  vector of frequencies (output is same as input).
%      H =  vector of complex frequency response values at W.
%  usage:   [H,W] = FREEKZ(B,A,N)
%        - where N is a positive integer
%      N = number of frequencies (equally spaced 0 to pi is the default)
%      H =  N-point vector of complex frequency response values
%      W =  N-point vector of frequencies (output)
%   H = FREEKZ(B,A,N,'whole') uses N frequencies from -pi to +pi.
%           ***** THIS IS DIFFERENT FROM freqz.m ****************
%    To plot the magnitude and phase of a filter over [-pi,pi):
%           [HH,ww] = freekz(bb,aa,N,'whole');
%           subplot(2,1,1), semilogy(ww,abs(HH))    %-- magnitude
%           subplot(2,1,2),     plot(ww,angle(HH))  %-- Phase
%
% NOTE: this version does NOT behave exactly the same as freqz.m.
%       For example, it does not create plots by itself.
%       AND, it does not allow the sampling frequency as an input.

% Jim McClellan, 12-August-98
% MODIFICATION of a Mathworks M-file called freqz() in the sig proc toolbox.
% updated comments, Jim McClellan, 15-April-2001
% Fixed 'whole' error found by Sam Li, 15-Oct-2002

if nargin<3, error('FREEKZ: you must specify the first 3 arguments');  end
if nargin==4 & ~ischar(two_pi_flag)
   disp('freekz does NOT support freqs in Hz together with a sampling frequency');
   disp('   For that feature, please use freqz in the SP toolbox');
   disp('   OR, create your own frequency vector as w = 2*pi*f/fs');
   error('FREEKZ: with 4 args, the last one must be a string');
end
b = b(:).';   a = a(:).';
pi_flag = ~(nargin==4); %-- two_pi_flag can be any STRING; pi_flag = NOT two_pi_flag
LFFT = round((1+pi_flag)*w(1));  %-- possible FFT length
w_flag = length(w)>1 | w<=0 | abs(w-round(w))>1e-6 | LFFT<max(length(a),length(b));
if ~w_flag
    H = fft(b,LFFT) ./ fft(a,LFFT);
    if pi_flag
        N = LFFT/2;  %-- will take first half of the FFT
        w = (pi*(0:N-1)/N).';
        H = H(1:N).';   %-- output a column, WHY I don't know
    else
        N = LFFT;  %-- use all of the FFT
        w = fftshift(2*pi*(0:N-1)/N).';  %-- move neg freqs to correct position
        w = w.*(w<pi) + (w-2*pi).*(w>=pi); %-- alias by 2pi to make neg freqs
        H = fftshift(H).';   %-- output a column, WHY I don't know
    end
else                     %-- w_flag=TRUE means we have a frequency vector
    if prod(size(w))~=max(size(w))
        error('FREEKZ: frequency vector is not a vector'); end
    %-- Since the frequency vector could be non-uniform, use Goertzel
    ejw = exp(-1i*w);
    a = [fliplr(a),0];  b = [fliplr(b),0];
    La = length(a);  Lb = length(b);
    for kk = 1:length(w)
        bk =  filter(1,[1 -ejw(kk)],b);
        ak =  filter(1,[1 -ejw(kk)],a);
        H(kk) = bk(Lb) ./ ak(La);       %-- outputs a row
    end
end
