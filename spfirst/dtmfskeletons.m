%==========================================
function dtmfsig = dtmfdial(nums,fs)
%DTMFDIAL  Create a vector of tones which will dial 
%           a DTMF (Touch Tone) telephone system.
%
% usage:  dtmfsig = dtmfdial(nums) 
%      nums = vector of numbers ranging from 1 to 12
%        fs = sampling frequency
%   dtmfsig = vector containing the corresponding tones.
 
tone_cols = ones(4,1)*[1209,1336,1477];
tone_rows = [697;770;852;941]*ones(1,3);
%==========================================
function keys = dtmfrun(xx,L,fs)
%DTMFRUN    keys = dtmfrun(xx,L,fs)
%    returns the list of key numbers corresponding
%      to the DTMF waveform, xx.
%      L = filter length
%     fs = sampling freq  

freqs = [697,770,852,941,1209,1336,1477];
hh = dtmfdesign( freqs,L,fs );
%   hh = MATRIX of all the filters. Each column contains the impulse
%        response of one BPF (bandpass filter)

[nstart,nstop] = dtmfcut(xx,fs);   %<--Find the tone bursts
%==========================================
function  sc = dtmfscore(xx, hh)
%DTMFSCORE
%          sc = dtmfscore(xx, hh)
%    returns a score based on the maximum amplitude of the filtered output
%     xx = input DTMF signal
%     hh = impulse response of ONE bandpass filter
%
% The signal detection is done by filtering xx with a length-L
% BPF, hh, and then finding the maximum amplitude of the output.
% The score is either 1 or 0.
%      sc = 1 if max(|y[n]|) is greater than, or equal to, 0.95
%      sc = 0 if max(|y[n]|) is less than 0.95

xx = xx*(2/max(abs(xx)));   %---Scale x[n] to the range [-2,+2]
%==========================================
function  hh = dtmfdesign(fcent, L, fs)
%DTMFDESIGN
%     hh = dtmfdesign(fcent, L, fs)
%       returns a matrix where each column is the
%       impulse response of a BPF, one for each frequency
%  fcent = vector of center frequencies
%      L = length of FIR bandpass filters
%     fs = sampling freq  
%
% The BPFs must be scaled so that the maximum magnitude
% of the frequency response is equal to one.
%==========================================