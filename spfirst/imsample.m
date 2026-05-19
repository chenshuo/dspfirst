function  yy = imsample(xx, P)
%IMSAMPLE    Function for sub-sampling an image
%  usage:  yy = imsample(xx,P)
%    xx = input image to be sampled
%     P = sub-sampling period (a small integer like 2, 3, etc.)
%    yy = output image
%
[M,N] = size(xx);
S = zeros(M,N);
S(1:P:M,1:P:N) = ones(length(1:P:M), length(1:P:N));
yy = xx .* S;
