function flat(x,y,sz)
%FLAT   draws a flat accidental (b) for the Music GUI
%    (support function used in musicgui)

fx = x-1.8*sz;
fy = y;

w = -pi/2:pi/20:pi/2;
roundx = 0.4*sz*cos(w)+fx;
roundy = 0.6*sz*sin(w)+fy;
stemx = [0.95*sz sz sz 0.95*sz]+fx-0.8;
stemy = [0 0 2.5*sz 2.5*sz]+fy-0.6;
holex = 0.3*sz*cos(w)+fx;
holey = 0.5*sz*sin(w)+fy;

patch(roundx,roundy,'k');
patch(stemx,stemy,'k');
patch(holex,holey,'w');    