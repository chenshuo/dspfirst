function him = plotspecDB(xx,fsamp,Lsect,DBrange)
%PLOTSPECDB   plot a Spectrogram as an image
%         (display magnitude in decibels)
%  usage:   him = plotspec(xx,fsamp,Lsect,DBrange)
%      him = handle to the image object
%       xx = input signal
%    fsamp = sampling rate
%    Lsect = section length (integer, power of 2 is a good choice)
%              amount of data to Fourier analyze at one time
%  DBrange = defines the minimum dB value; max is 0 dB

% 16-Feb-2013 J McClellan, created from plotspec.m

if( nargin<4 )
    disp('PLOTSPECDB: DB range defaulting to 60 dB')
    DBrange = 60;
end
if( nargin<3 )
	Lsect = 256;  %- default section length is 256
end
if( nargin<2 )
	disp('PLOTSPECDB: Sampling Frequency defaulting to 8000 Hz')
	fsamp = 8000;
end
if( length(xx)<1000 )
	warning('PLOTSPECDB: Signal length must be greater than 1000 to get a reasonable spectrogram')
end
Lfft = Lsect;
Noverlap = round(Lsect/2);  %-- overlap defaults to 50%
[B,F,T] = spectgr(xx,Lfft,fsamp,Lsect,Noverlap);
Bdb = 20*log10(abs(B));
Bmax = max(Bdb(:));
Bdb = Bdb - Bmax;
Bmin = - DBrange;
Bdb = Bdb.*(Bdb>=Bmin) + Bmin.*(Bdb<Bmin);
him = imagesc(T,F,Bdb);
axis xy
colormap(1-gray)   %-- use colormap(jet) if you like bright colors !