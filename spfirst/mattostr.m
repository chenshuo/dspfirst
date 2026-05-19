function y = mattostr(x,style)
%MATTOSTR
%-------
%   usage:  mattostr(X,STYLE)
%   convert an entire matrix X to formatted numbers,
%       using a C format in STYLE, e.g., '%3.f'

%  version 4.x only....v4 handles NaN in printf

[N,M] = size(x);
tt = sprintf(style,x.');
Lt = length(tt);
y = reshape( tt, Lt/N, N ).';
