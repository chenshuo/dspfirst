function x = tri(T,sT,Ns)
% TRI   Generate samples of a triangular waveform with period T seconds, 
%       sampling frequency sT samples/second, and Ns samples.
 
x=-1 + 4*abs(round([0:Ns-1]/sT/T)-[0:Ns-1]/sT/T);

