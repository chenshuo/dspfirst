function [H,w] = freekz(b,a,N,two_pi_flag)
%FREEKZ	  Frequency response for a rational (numerator/denominator) form.
%	                                          -1                 -nb 
%	            jw	    B(z)      b(1) + b(2)z  + .... + b(nb+1)z
%	         H(e  ) =   ----  =  -----------------------------------
%	                                          -1                 -na
%	    	            A(z)      a(1) + a(2)z  + .... + a(na+1)z
%
%  usage:   [H,W] = FREEKZ(B,A,N)
%      B = filter coefficients of the numerator polynomial, B(z).
%      A = filter coefficients of the denominator polynomial, A(z).
%      N = number of frequencies (equally spaced 0 to pi is the default)
%      H =  N-point vector of complex frequency response values
%      W =  N-point vector of frequencies
%	H = FREEKZ(B,A,N,'whole') uses N frequencies from 0 to 2*pi.
%	H = FREEKZ(B,A,W) returns H at the frequencies specified in vector W
%                     (See LOGSPACE to generate a non-uniform W).
%	 To plot the magnitude and phase of a filter:
%           [HH,ww] = freekz(bb,aa,N,'whole');
%           subplot(2,1,1), semilogy(ww,abs(HH))    %-- magnitude
%           subplot(2,1,2),     plot(ww,angle(HH))  %-- Phase
%
% NOTE: this version does NOT behave exactly the same as freqz.m.
%       For example, it does not create plots by itself.

% Jim McClellan, 12-August-98
% MODIFICATION of a Mathworks M-file called freqz() in the sig proc toolbox.

if nargin<3, error('FREEKZ: you must specify the first 3 arguments');  end
b = b(:).';   a = a(:).';
pi_flag = ~(nargin==4);	%-- two_pi_flag can be anything
LFFT = (1+pi_flag)*N(1);
w_flag = length(N)>1 | N<=0 | abs(N-round(N))>1e-6 | LFFT<max(length(a),length(b));
if ~w_flag 
    w = (2/(1+pi_flag)*pi*(0:N-1)/N)';
    H = fft(b,LFFT) ./ fft(a,LFFT);
    H = H(1:N).';   %-- output a column, WHY I don't know
else
    w = N;
    if prod(size(w))~=max(size(w))
		error('FREEKZ: frequency vector is not a vector'); end
%--- Since the frequency vector could be non-uniform, use Goertzel
    ejw = exp(-1i*w);
    a = [fliplr(a),0];  b = [fliplr(b),0];
    La = length(a);  Lb = length(b);
    for kk = 1:length(w)
        bk =  filter(1,[1 -ejw(kk)],b);
        ak =  filter(1,[1 -ejw(kk)],a);
        H(kk) = bk(Lb) ./ ak(La);		%-- outputs a row
    end
end
