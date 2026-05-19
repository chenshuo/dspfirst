function 	[y1,y2] = woodwenv(a,s,r,Fs)
%WOODWENV	produces amplitude and mod. index envelope functions 
%		for woodwinds
%	   usage: [y1,y2] = woodwenv(a,s,r,Fs);
%		where a = attack TIME
%		      s = sustain TIME
%		      r = release TIME
%		     Fs = sampling frequency (Hz)
%		returns:
%		     y1 = amplitude envelope
%		     y2 = modulation index envelope
%  note: attack is exponential, sustain is constant, release is exponential

ta = 0:(1/Fs):(a-1/Fs);
y1 = exp(ta/a*1.5)-1;
y1 = y1/max(y1);

y1 = [y1 ones(1,round(s*Fs))];

tr = 0:(1/Fs):(r/2-1/Fs);
y3 = exp((r/2-tr)/r*3)-1;
y3 = y3/max(y3)/2;
y4 = 1-y3(length(y3):-1:1);

y2 = [y1 ones(1,round(r*Fs))];
y1 = [y1 y4 y3 0];

len = min([length(y1) length(y2)]);
y1 = y1(1:len);
y2 = y2(1:len);