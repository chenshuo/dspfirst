function D = dirichlet( omega, L )
%DIRICH   compute sin(L*omega/2)/Lsin(omega/2)   
%------
%   Usage:   D = dirich(omega, L)
%
%   omega : argument of Dirichlet function   (works for matrix omega)
%       L : length of corresponding FIR filter
%
%     see also DIRIC in the Signal Processing Toolbox



denom = sin(0.5*omega);
zdenom = abs(denom) < 1e-10;

D = zdenom + (~zdenom).*sin((L/2)*omega)./(L*denom + zdenom);
