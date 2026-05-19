function mg_spec(song,scroll)
%MG_SPEC    compute and display spectrogram of the song
%      (used as a support function for musicgui)
%   song = signal vectors containing all the sinusoids
%   scroll = scrolling position along the horizontal axis
%
SpecHandle = findobj(gcbf,'Tag','Spec');
axes(SpecHandle);
cla;

fs = 8000;
stretch = 2;
fs2 = fs/2;      %-- we can now use a shorter FFT
song = song(1:2:length(song));

tmin = scroll*1.3-1;
tmax = scroll*1.3+11;
fmin = 0;
fmax = 1100;

Lw = 400;   %-- exactly 100 milliseconds at fs/2 = 4000 Hz
Nfft = 512;
[B,F,T] = spectgr(song,Nfft,fs2,Lw,Lw/2);
jkl = find( F>=fmin & F<=fmax );
B = abs(B(jkl,:));
Bmax = max(B(:));

%-- Put the logarithmic display in the colormap
hc = imagesc(T,F(jkl),B,[0,Bmax]); axis xy;  grid on
dBmin = 40;   %- without minus sign
gg = logspace(0, -dBmin/20, 64);   %-- could use 256 or 16 levels
colormap(gg'*[0.4,0.7,1])   %-- Blue Color
set(SpecHandle,'XTick',[0:0.5:(length(song)/fs2)],'YTick',[0:200:fmax])
axis([tmin/(5.34/stretch) tmax/(5.34/stretch) fmin fmax]);
axis on;
