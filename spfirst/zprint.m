function zprint(z)
%ZPRINT   printout complex # in rect and polar form
%------
%  usage:   zprint(z)
%    z = vector of complex numbers; each one will be printed
%         in a format showing real, imag, mag and phase
%
z = z(:);
L = length(z);
disp(' Z =     X    +     jY     Magnitude    Phase    Ph/pi   Ph(deg)')
disp( [ mattostr( [real(z), imag(z), abs(z)], '%12.4g'),...
        mattostr( [angle(z), angle(z)/pi], '%9.3f'),...
        mattostr( angle(z)*180/pi, '%9.2f')  ] ) 
disp(' ')
