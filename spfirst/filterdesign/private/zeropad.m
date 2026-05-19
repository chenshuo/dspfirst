function z_out = zeropad(x,num_of_zeros)
%ZEROPAD                                         [jMc 7/89]
%     zeropad(x,L) will append L zeros to each column of x.
%       see also ZEROFILL

if size(x,1)==1   %------- input is a row vector
   z_out = [ x zeros(1,num_of_zeros) ];
else          %------- matrix or column
   [M,N] = size(x);
   z_out = [ x; zeros(num_of_zeros,N) ];
end
%
% (c) J. H. McClellan 1989  GT-EE-DSP
