function y = feval(sig,t)
y = sig.Amplitude * ( sig.Delay<=t  &  t<sig.Delay+sig.Width );
%%y = sig.Amplitude * ( sig.Delay<t  &  t<sig.Delay+sig.Width );
%%y = y + sig.Amplitude/2 * (sig.Delay==t | sig.Delay==sig.Delay+sig.Width);
