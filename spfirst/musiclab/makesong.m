function song = makesong(notes,dur)
%MAKESONG   creates the sinusoidal waveform for the song in Music GUI
%  usage:  song = makesong(notes,dur)
%    notes = array containing the keynumbers to be played
%      dur = array containing the durations for each key
%     song = the output signal vector.
%
%   The default sampling rate is 8000 Hz; chosen because it works
%   well on all platforms: UNIX, Mac, and Windows.

fs = 8000;
%%stretch=5.34;
stretch = 2;   % 2.67*2 = 5.34
         
song = zeros(1,round((max(sum(dur'))+.376)*stretch*fs));
for m = 1:size(notes,1);
   k1 = round(2.5*0.125*fs*stretch);
   n = notes(m,:);
   zerocount=0;
   for index=1:size(n,2),
      if n(index)==0,   zerocount=zerocount+1;   end;
      if n(index)~=0,   zerocount=0;             end;
   end;
   actualsize=size(n,2)-zerocount;
   for i=1:actualsize
         tt = 0:1/fs:(dur(m,i)*stretch);
         freq = 440 * (2.0.^((n(i)-49)/12));
         tone = (n(i)>0) .* sin(2*pi*freq*tt);
		 Ltone = length(tone);
         k2 = k1+Ltone-1;
		 tail = round( max([0.04*fs,0.05*Ltone]) );
         song(k1:k2) = song(k1:k2) + mg_env(Ltone,tail).*tone;         
         k1 = k2+1;
   end;
end; 
