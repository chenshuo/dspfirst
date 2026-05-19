function V = setaxislims(hAxis,z)
% Set the axis limits for the ZDRILL plots
z = z(:);
x = real(z);
y = imag(z);
mx = 1.2*min([-1; x]); 
Mx = 1.2*max([1; x]);
my = 1.2*min([-1; y]); 
My = 1.2*max([1; y]);
set(hAxis,'XLim',[mx Mx],'YLim',[my My]);
V = [mx Mx my My];