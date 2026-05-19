function [f, h] = ctfirstorderfilter(filter_type, cutoff, bandwidth, freq)

% CTFIRSTORDERFILTER implements continuous time filters, to be used with 
% cltidemo. 
%   [f, h] = ctfirstorderfilter(filter_type, cutoff, bandwidth)
% where, 
%   filter_type - can be one of 'Lowpass', 'Highpass', 'Bandpass' or
%   'Bandreject'
%   cutoff - is the cutoff frequency in Hz. (Max - 200 Hz)
%   bandwidth - for Bandpass and Bandreject filters ( 10 to 50 Hz)
%
%   [f, h] = ctfirstorderfilter(filter_type, cutoff, bandwidth, freq)
% where,
%   freq - the frequency value at which the filter is evaluated


% Rev. Greg Krudysz,  7-Mar-2006 : changed 'type' to 'filter_type'
%                                  erased unused for loop in 'Bandreject' case
% Rev. Greg Krudysz, 25-Oct-2004 : added freq option for value evaluation. 
% Rev. Rajbabu , 27-Apr-2005: 
%                - fixed BPF and BRF to use fc^2 - f^2
%                - vectorized the equation

if nargin == 4
  f = freq;
else
  f = linspace(0,200,1001);
end

  fc = cutoff ;         % Cutoff Frequency
  bw = bandwidth;       % Bandpass & Bandreject filter - Bandwidth

  switch filter_type
   case 'Lowpass'
      h = 1./(1+j*f/fc);
   case 'Highpass'
      h = (j*f/fc)./(1+j*f/fc);
   case 'Bandpass'
      h = (j*f*bw)./(fc^2 - f.^2 + j*f*bw);
   case 'Bandreject'
      h = (fc^2 - f.^2)./(fc^2 - f.^2 + j*f*bw);
   otherwise
    error('Filter type unknown or unspecified');
  end
  
% endfunction ctfirstorderfilter
% eof: ctfirstorderfilter.m

