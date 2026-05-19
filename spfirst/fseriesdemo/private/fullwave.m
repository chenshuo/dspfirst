function out = fullwave(t, T, signal)
% FULLWAVE creates a full-wave rectified Sine/Cosine wave
  
% Mustayeen Nayeem, August, 2002
% Rajbabu, Dec-24-2003 - Added option for sine/cosine
% JMc, 25-Nov-2011 - Corrected period of Full-Wave Rectified Sinusoids
  
%yy = zeros(1,length(t));
switch signal
 case 'sine'
  yy = sin(pi/T*t);   %- abs will halve the period
 case 'cosine'
  yy = cos(pi/T*t);   %- abs will halve the period
 otherwise
  error('Unknown signal type');
end

yy = abs(yy);
        
out = yy;

%endfunction fullwave

%eof: fullwave.m
