function swptcos = chirp_spec(t0,t1,f0,alpha)
f = (pi*(alpha)*t0) + (2*pi*f0);
swptcos = cos(f.*t0);
end