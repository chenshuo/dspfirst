function supp = support(sig)
switch lower(sig.Causality)
case 'causal'
   supp = [sig.Delay sig.Delay+sig.Length];
otherwise
   supp = [sig.Delay-sig.Length sig.Delay];
end