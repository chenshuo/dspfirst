function fs = suggestrate(sig,tRange)
fs = max(511/diff(tRange),40/sig.Period);
