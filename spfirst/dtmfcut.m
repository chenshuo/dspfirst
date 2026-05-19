function [nstart,nstop] = dtmfcut(xx,fs)
%DTMFCUT   find the DTMF tones within x[n]
%  usage:
%       indx = dtmfmain(xx,fs)
%
%   length of nstart = M = number of tones found
%      nstart is the set of STARTING indices
%      nstop is the set of ENDING indices
%    xx = input signal vector
%    fs = sampling frequency  
%
%  Looks for silence regions which must at least 10 millisecs long.
%  Also the tones must be longer than 100 msec

xx = xx(:)'/max(abs(xx));   %-- normalize xx
Lx = length(xx);
Lz = round(0.01*fs);
setpoint = 0.02;      %-- make everything below 2% zero
xx = filter( ones(1,Lz)/Lz, 1, abs(xx) );
xx = diff(xx>setpoint);
jkl = find(xx~=0)';
%%%xx(jkl)
if xx(jkl(1))<0, jkl = [1;jkl];  end
if xx(jkl(end))>0, jkl = [jkl;Lx]; end
jkl';
indx = [];
while length(jkl)>1
	if jkl(2)>(jkl(1)+10*Lz)
		indx = [indx, jkl(1:2)];
	end
	jkl(1:2) = [];
end
nstart = indx(1,:);
nstop = indx(2,:);
