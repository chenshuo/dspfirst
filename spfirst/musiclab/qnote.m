function qnote(x,y,sz,a)
%QNOTE   draws a quarter note for the Music GUI
%    (support function used in musicgui)

w = 0:pi/20:2*pi;
notex = sz*cos(w)+x;
notey = 0.8*sz*sin(w)+y;
stemx = [0.8*sz sz sz 0.8*sz]+x;
stemy = [0 0 4*sz 4*sz]+y;

patch(notex,notey,'k');
patch(stemx,stemy,'k');

if (a==0.4),    flat(x,y,sz);   end;

if (a==0.6),    sharp(x,y,sz);  end;                                         