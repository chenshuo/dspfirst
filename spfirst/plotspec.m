function him = plotspec(xx,fsamp,Lsect)
%PLOTSPEC   plot a Spectrogram as an image
%         (take care of all the default settings)
%  usage:   him = plotspec(xx,fsamp,Lsect)
%      him = handle to the image object
%       xx = input signal
%    fsamp = sampling rate
%    Lsect = section length (integer number of samples, should be power of 2)
%              amount of data to Fourier analyze at one time
%
% USE this function ONLY if you do NOT have specgram

% 18-Oct-98 J McClellan
% 26-Oct-98 added window length
% 20-Sept-00 changed window length to section length


% if( exist('specgram'))
% 	disp(' ')
% 	disp('??? Why are you using this function, you seem to have SPECGRAM');
% 	disp(' ')
% end
if( nargin<3 )
	Lsect = 256;
end
if( nargin<2 )
	disp('PLOTSPEC: Sampling Frequency defaulting to 8000 Hz')
	fsamp = 8000;
end
if( length(xx)<1000 )
	warning('PLOTSPEC: Signal length must be greater than 1000 to get a reasonable spectrogram')
end
Lfft = Lsect;
Noverlap = round(Lsect/2);  %-- overlap defaults to 50%
[B,F,T] = spectgr(xx,Lfft,fsamp,Lsect,Noverlap);
him = imagesc(T,F,abs(B));
axis xy
colormap(1-gray)   %-- use colormap(jet) if you like bright colors !
