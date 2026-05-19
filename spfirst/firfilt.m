function yy = firfilt(bb, xx)
%FIRFILT   FIR filter implemented as a difference equation
%
%   usage:   yy = firfilt(bb, xx) 
%
%    implements the FIR filter difference equation:
%
%                   M-1
%                   __
%                   \
%           y[n]=   /  b[k] * x[n-k]
%                   --
%                   k=0
%
%     The length of the resulting vector is  length(bb)+length(xx)-1.
%
% NOTE:
%   Convolution, polynomial multiplication, and FIR digital filtering
%   are all equivalent operations. The Matlab function CONV
%   also does convolution---it is identical to FIRFILT
%             yy = conv(bb, xx)
%    convolves vectors bb and xx. If bb and xx are vectors of
%    polynomial coefficients, convolving them is equivalent
%    to multiplying the two polynomials.

% updated 10-Oct-01 JMc
%      accommodate 2-D inputs because filter() will filter the columns
% updated 23-April-01 JMc
%      detect the shorter signal and make it the 1st arg to filter()
%

if( length(bb)==1 )
   yy = bb(1)*xx;
elseif( length(xx)==1 )
   yy = xx(1)*bb;
elseif ndims(xx)==2   %- Every MATLAB matrix has at least dim=2
   if min(size(bb))>1
      error('>>>FIRFILT: filter coefficients cannot be a matrix')
   elseif min(size(xx))>1
      warning('>>>FIRFILT: filtering the columns of the matrix xx')
      xx( size(xx,1)+length(bb)-1,1 ) = 0;  %-- force filter() to make all of y[n]
      yy = filter( bb, 1, xx );      
   elseif( length(bb)<=length(xx) )
      xx( length(xx)+length(bb)-1 ) = 0;  %-- force filter() to make all of y[n]
      yy = filter( bb, 1, xx );
   else
      needTranspose = (size(xx,1)==1);
      bb( length(xx)+length(bb)-1 ) = 0;  %-- force filter() to make all of y[n]
      yy = filter( xx, 1, bb(:) );
      if needTranspose, yy = yy'; end
   end
else
   error('>>>FIRFILT: does not work for more than two dimensions')
end