%PUMPKIN    spectrogram with a face for Halloween
%   generates a frequency modulated signal with an
%   interesting trajectory, than plays the sound.
%
%  This is modified version of a function first written by Tom Krauss
% NOTE: requires the Signal Processing Toolbox
%
Fs = 8000;  t = 0:1/Fs:3;  % Sample frequency, time axis
x = real(sqrt(1-(t-1.5).^2));  % Half circle in time/x space
y = t*0;
ind= find((t>0.5)&(t<2.5));
y(ind) = vco(x(ind),[1000 4000],Fs) + vco(-x(ind),[1000 4000],Fs);
y(ind(1:200)) = y(ind(1:200)).*((1:200)/200); %-- Trapezoidal window
n = length(ind);                              %-- to reduce transient
y(ind(n-200:n)) = y(ind(n-200:n)).*(201-(1:201))/200;
x = -real(sqrt(1-((t-1.5)*2).^2))/2;   %-- Another half circle
ind= find((t>1)&(t<2));
y2 = vco(x(ind),[1000 3500],Fs);
y2(1:200) = y2(1:200).*(1:200)/200;
n = length(y2);
y2(n-200:n) = y2(n-200:n).*(201-(1:201))/200;
y(ind) = y(ind) + y2;
y = y + exp(-(t-1.25).^2*100).*cos(2*pi*t*3000);  %
y = y + exp(-(t-1.75).^2*100).*cos(2*pi*t*3000);
y = y + exp(-(t-1.5).^2*800).*cos(2*pi*t*2500)+randn(size(t))*.0001;
[B,F,T] = spectgr(y,1024,Fs,512,370);
B = abs(B);
B = B/max(B(:));
thresh = 1e-7;
B = B.*(B>thresh) + thresh*(B<=thresh);
imagesc(T,F,log(B)); axis xy;  grid off
colormap(hot)
drawnow
sound(y/max(abs(y)),Fs)
