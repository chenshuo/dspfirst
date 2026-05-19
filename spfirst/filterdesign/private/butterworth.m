function [b,a,error_flag] = butterworth(N,Wp,delta_p)
%	usage:
%
%		b  = numerator coefficients
%		a  = denominator coefficients
%       error_flag - throws 'Unable to design filter with these parameters'
% 
%		N  = order
%		Wp = cutoff frequency
%		delta_p = passband error
% ========================================================================

error_flag = 0;
K = (1/((1-delta_p)^2)-1)^(1/(2*N))/tan(Wp*pi/2);	 	% where K=constant in s=K*(1-z^(-1))/(1+z(-1)) (bilinear transformation)
k = 0:2*N-1;											% there are 2N poles
if mod(N,2) == 1                                      	% if N is odd
    poles_s = exp(j*2*pi*k/(2*N));
else                                                    % if N is even
    poles_s = exp(j*pi/(2*N)+j*2*pi*k/(2*N));
end

i = 1;
LHSpoles = [];
for p = 1:length(poles_s) 								% check all poles to extract those in left half plane
    if real(poles_s(p)) < 0
        LHSpoles(i) = poles_s(p);
        i = i+1;
    end
end

if isempty(LHSpoles)
    error_flag = 'Unable to design filter with these parameters';
    a = [];
    b = [];
else
    i = 1:length(LHSpoles);
    poles_z = (1-LHSpoles(i)/K)./(1+LHSpoles(i)./K);       % mapping

    % these poles are obtained in the decreasing order of z-1. in order to obtain coefficients, they
    % need to flipped around so that they are arranged in the increasing order of z-1
    flip_a = poly(poles_z);
    a = fliplr(flip_a);

    %------------- check this if there are problems ----------------------
    if imag(a)>10^(-13)                                    % check if imaginany part is small
        'WARNING: SIGNIFICANT IMAGINARY PART IN VECTOR "A"'
    end
    a = real(a);                                           % ignore imaginary parts
    %---------------------------------------------------------------------

    flip_b = poly(-1*ones(1,length(poles_z)));             % all zeros at z = -1
    b = fliplr(flip_b);
end