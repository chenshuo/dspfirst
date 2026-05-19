function rotated = rotate(x,num_places)
%ROTATE                                                [jMc 2/89]
%    rotate(V,r) circularly shifts the elements in the columns of V
%        by r places right (r>0); or r places left (r<0).
%        (Right is down; left is up.)
%        If the input is a row or column vector, the shift is
%        performed on the vector.
%        If the input is a signal matrix, each column is shifted
%  see also SHIFTM, SHIFT, ZEROPAD

[M,N] = size(x);
if M > 1              % ------- rotate columns ----------------
   num_places = mod(num_places,M);         % make num_places in range [0,M-1]
%    num_places=ceil(num_places);
   rotated = [ x(M-num_places+1:M,:); x(1:M-num_places,:) ];
elseif N > 1          % ------- rotate row vector -------------
   num_places = mod(num_places,N);         % make num_places in range [0,N-1]
     num_places=round(num_places);
   rotated = [ x(N-num_places+1:N) x(1:N-num_places) ];
end
