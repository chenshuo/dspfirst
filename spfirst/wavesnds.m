function    wavesnds(A,F,Phi,tmax,Fs)
%WAVESNDS   generate wavforms as sum of sinusoids
%	   A = vector of amplitudes
%	   F = vector of frequencies
%	 Phi = vector of phases
%	tmax = maximum time 
%	  Fs = sampling frequency
%
% For DSP First book: 
%   wavesnds([1,0,-1/3,0,1/5],440*[1,0,sqrt(8),0,sqrt(27)],zeros(1,5),1.5,8000)
%

% NOTE: under version 4.2, the wavwrite() function does not always
%       produce valid .wav files on the Macintosh

write_wav_files = 0;   %-- FALSE, so don't write the .wav files
vvv = version;
ver_4 = (vvv(1)=='4');
figure(1), clf reset
subplot('Position',[0.14,0.1,0.8,0.6]);
tt = 0:(1/Fs):tmax;
Ltt = length(tt);
T0 = 1/F(1);
npline = round(0.025*Fs);
x1 = A(1)*cos( 2*pi*F(1)*tt+Phi(1) );
strips(x1(1:3*npline),npline/Fs,Fs)
set(get(gca,'Children'),'LineWidth',2)
title('Single Cosine Wave'); xlabel('time (in sec)')
disp('save as:   coswave.wav')
x1 = x1/max(abs(x1));
sound(x1,Fs)
pause
if write_wav_files,  wavwrisc(x1,Fs,'coswave.wav'),  end
%
x2 = cos(tt'*2*pi*F+ones(Ltt,1)*Phi)*A';
strips(x2(1:3*npline),npline/Fs,Fs)
set(get(gca,'Children'),'LineWidth',2)
title('Sum of Cosine Waves  (Not Periodic)'); xlabel('time (in sec)')
disp('save as:   irratfrq.wav')
x2 = x2/max(abs(x2));
sound(x2,Fs)
pause
if write_wav_files,  wavwrisc(x2,Fs,'irratfrq.wav'),  end
%
F3 = F(1)*((1:length(F)));
x3 = cos(tt'*2*pi*F3+ones(Ltt,1)*Phi)*A';
strips(x3(1:3*npline),npline/Fs,Fs)
set(get(gca,'Children'),'LineWidth',2)
title('Sum of Cosine Waves with Harmonic Frequencies');
xlabel('time (in sec)')
disp('save as:   square5h.wav')
x3 = x3/max(abs(x3));
sound(x3,Fs)
if write_wav_files,  wavwrisc(x3,Fs,'square5h.wav'),  end
