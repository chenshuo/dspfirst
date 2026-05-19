function keys = dtmfdeco(xx,fs)
%DTMFDECO   decode the DTMF waveform into keys that were pressed
%  usage:    keys = dtmfdeco(xx,fs)
%
%     xx = input waveform
%     fs = sampling rate (it defaults to 8000)
%   keys = list out keys pressed

if nargin<2,  fs = 8000; end

fl = 256;
wl = 1024;
tt = [ 697  697  697  770  770  770  852  852  852  941  941  941;
      1209 1336 1477 1209 1336 1477 1209 1336 1477 1336 1209 1477 ];

keys = [];
xx = xx(:);
rmsx = sqrt(sum(xx.^2)/length(xx));
old_key = 0;
old_valid = 0;

for i=1:fl:length(xx)-fl,
    valid = 1;
    hammwin = 0.54 - 0.46*cos(2*pi/(wl-1)*(0:wl-1)');
    w = hammwin.*[xx(i:i+fl-1); zeros(wl-fl,1)];
    W = abs(fft(w))/fl*8;
    W = W(1:length(W)/2);
    W = W.*(W>rmsx/2); W([1 length(W)])  =  [0;0];
    W = W/max([W;0.01]);
    p = zeros(2,3);
    ip = 1;
    for k=find(W>0)',
	if (W(k)>W(k-1) & W(k)>W(k+1)),
	    p(1,ip) = k/wl*fs;
	    p(2,ip) = W(k);
	    ip = ip+1;
	end
        if (ip > 3),
	    valid = 0;
	    break;
	end
    end;
    score = abs(p(1,1)-tt(1,:)) + abs(p(1,2)-tt(2,:)) + ...
		   400*(abs(p(2,1)-1) + abs(p(2,2)-1) + p(2,3));
    [s,si] = min(score);
    if (s > 40),
	valid = 0;
    end;
    if (valid)
	if (si ~= old_key)
	    keys = [keys si];
	    old_key = si;
	end
    else
	old_key = 0;
    end
end
