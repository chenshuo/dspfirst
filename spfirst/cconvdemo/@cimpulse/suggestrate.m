function fs = suggestrate(sig,tRange)
% Use -inf so any code based on using the maximum rate
% will use the other signal's rate.

fs = -inf;