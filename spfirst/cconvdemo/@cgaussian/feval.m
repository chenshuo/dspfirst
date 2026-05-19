function y = feval(sig,t)
% FEVAL generates Gaussian signal
  
  y = sig.ScalingFactor * exp(-sig.ExpConstant*(t-sig.Delay).^2);

  
