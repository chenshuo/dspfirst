function drawaxes1(h)
phiStr = get(h.edit2,'String');
phi = str2num(phiStr);
set(h.line1v(1),'XData',[0,real(loc),nan]);
set(h.line1v(1),'YData',[0,imag(loc),nan]);

newphi = phi - deltaorig;
newloc = exp(j * newphi);
h.line1vnew = quiver(0,0,real(newloc),imag(newloc),'-');
set(h.line1vnew,'parent',h.axes1);