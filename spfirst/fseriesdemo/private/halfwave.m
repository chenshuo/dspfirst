function out = halfwave(t, T, signal)
% HALFWAVE creates a half-wave rectified sine/cosine wave. 
% Mustayeen Nayeem, August, 2002
% Rajbabu, 24-Dec-2003 - Added option for sine/cosine wave
  
switch signal
 case 'sine'
  yy = sin(2*pi/T*t);
 case 'cosine'
  yy = cos(2*pi/T*t);
 otherwise
  error('Unknown signal type');
end

for n=1:length(yy)
    if yy(n) >= 0
        yy(n) = yy(n);
    else
        yy(n)= 0;
    end
end
   
out = yy;

% endfunction halfwave
% eof: halfwave.m
