function wavwrisc(xx, fs, file)
%WAVWRISC  scales xx and saves it as a .wav file.
%     in version 4, we do 8-bit .wav files
%     in version 5, we let it do the default (16-bit .wav files)
%  usage:    wavwrisc(xx, fs, file)
%      xx = signal vector containing sound (unscaled, floating-point)
%      fs = sampling rate (Hz)
%    file = file name (string)
%
vvv = version;
ver_4 = (vvv(1)=='4')
if ver_4,
   xmax = max(abs(xx));
   wavwrite(round( xx/xmax * 127), fs, file)
else  %-- version 5.x
   xx = xx/max(abs(xx));
   wavwrite( xx, fs, file );   %-- defaults to 16-bit .wav files in v5
end
