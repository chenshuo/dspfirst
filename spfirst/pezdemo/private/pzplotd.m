function [plothandle] = pzplotd(zeros,poles);
%PZPLOTD Pole-zero plot for digital filters in Matlab
%
%       PZPLOTD(zeros,poles) 
%
%       Displays a pole-zero plot of a digital filter.
%       Use tf2zp to find the poles and zeros from B(z)/A(z).
%
nc = 100; c = exp(j*2*pi*[0:nc-1]/(nc-1)); % unit circle 
plot(c,'--'); title('Pole-Zero Plot'); 
xlabel('Re(z)'); ylabel('Im(z)');
axis([-1.1,1.1,-1.1,1.1]); axis('square');
hold on;
rmin = 0.1;  rstep = rmin;  rmax = 1.0-rstep;
for r=rmin:rstep:rmax
  plot(r*c,':'); % radial coordinate axes
end
l = [rmin:1/nc:1];  tmin = pi/16;
for t=tmin:tmin:2*pi
  r = cos(t)*l + j*sin(t)*l;
  plot(real(r),imag(r),':'); % angle coordinate axes
end
if length(zeros)>0,
      ph = plot(real(zeros),imag(zeros),'o');
      set(ph,'MarkerSize',5); set(ph,'LineWidth',1.5);
end;
if length(poles)>0,
      ph = plot(real(poles),imag(poles),'x');
      set(ph,'MarkerSize',8); set(ph,'LineWidth',1.5);
end;
hold off;
plothandle = gcf;
