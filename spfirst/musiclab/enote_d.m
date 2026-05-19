function enote_d(x,y,sz,a)
%ENOTE_D   draws a dotted eighth note for the Music GUI
%      (support function used in musicgui)
%    The dotted 8-th note plays 75% as long as an 8-th note.

w = 0:pi/20:2*pi;
notex = sz*cos(w)+x;
notey = 0.8*sz*sin(w)+y;
stemx = [0.8*sz sz sz 2*sz sz 0.8*sz]+x;
stemy = [0 0 3.2*sz 2.8*sz 4*sz 4*sz]+y;

patch(notex,notey,'k');
patch(stemx,stemy,'k');

dotx=[x+1.1 x+1.1 x+1.3 x+1.3];
doty=[y-0.8 y-0.6 y-0.6 y-0.8];
patch(dotx,doty,'k');

if (a==0.4),    flat(x,y,sz);   end;

if (a==0.6),    sharp(x,y,sz);  end;