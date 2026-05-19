function y = interpolate(x)

M = 200;
delta = ceil(M/length(x));
y = [];
for k = 1:length(x)-1
    y = [y linspace(x(k),x(k+1),delta)];
end