function sharp(x,y,sz)
%SHARP   draws a sharp accent (#) for the Music GUI
%    (support function used in musicgui)

symin = y-1*sz;
symax = y+1*sz;
sxmin = x-2.5*sz;
sxmax = x-1.1*sz;


horizx = [sxmin sxmin sxmax sxmax];
horizy1 = [symax-0.7*sz symax-0.5*sz symax-0.2*sz symax-0.4*sz];
horizy2 = [symin+0.2*sz symin+0.4*sz symin+0.7*sz symin+0.5*sz];

patch(horizx,horizy1,'k');
patch(horizx,horizy2,'k');

vertx1 = [sxmin+0.4*sz sxmin+0.4*sz sxmin+0.42*sz sxmin+0.42*sz];
vertx2 = [sxmax-0.4*sz sxmax-0.4*sz sxmax-0.38*sz sxmax-0.38*sz];
verty = [symin symax symax symin];

patch(vertx1,verty,'k');  
patch(vertx2,verty,'k');                                                  