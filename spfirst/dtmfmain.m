function d = dtmfmain(x)
%DTMFMAIN   run the entire DTMF decoder
%  usage:
%       d = dtmfmain(x)
%
%    x = input signal vector
%    d = decoded output
%
% NOTE: the user must provide the function called dtmfdeco.m
%

setpoint1 = 0.01; setpoint2 = 0.02;
d   = [];
z   = conv([1 1 1],abs(x));
N   = length(x);
n1  = 1; n2 = 1;
while (sum(z(n2:N)) > setpoint2),
    q	= find(z(n2:N)>setpoint2)+n2;
    n1	= q(1);
    if (n1 > N) break; end;
    q	= find(z(n1:N)<setpoint1)+n1;
    if (~isempty(q)), n2 = q(1);
    else n2 = N; end;
    if (n1 == n2) break; end;
    if (exist('dtmfdeco')==2)
        d = [d dtmfdeco(x(n1:n2))];
    elseif (exist('dtmfdecod')==2)
        d = [d dtmfdecod(x(n1:n2))];
    else
	error('dtmfdeco function not found, you must write this function.');
    end
end;