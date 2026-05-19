function y = feval(sig,t)
switch lower(sig.Causality)
case 'causal'
   y = sig.ScalingFactor * exp(-sig.ExpConstant*(t-sig.Delay)) .* ...
      ( sig.Delay<=t  &  t<=sig.Delay+sig.Length );
otherwise
   y = sig.ScalingFactor * exp(sig.ExpConstant*(t-sig.Delay)) .* ...
      ( sig.Delay-sig.Length<=t  &  t<=sig.Delay );
end
