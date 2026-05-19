function fs = suggestrate(sig,tRange)
fs = 511/diff(tRange);
%fs = 511/sig.ExpConstant
