function fs = suggestrate(sig,tRange)
fs = max(1,511/diff(tRange));
