function supp = support(sig)
% SUPPORT gives the support (time) range for a Gaussian signal

% Rajbabu Velmurugan, 15-Feb-2004, Adapted from 'support' for exponential
%                                  signal
  
  supp = [sig.Delay-sig.Length/2 sig.Delay+sig.Length/2];
  
% endfunction support
