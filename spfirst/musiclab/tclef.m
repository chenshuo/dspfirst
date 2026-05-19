function tclef(x,y,sz)
%TCLEF   draws a treble clef for the Music GUI
%    (support function used in musicgui)

xx=[2 2 4 4 2 4 3 4 6 8  7  6  5  4  4  5  6  7  7  1  0  0 3 6 9 10 10  7  4  4];
yy=[4 2 2 4 4 2 2 0 0 2 11 17 20 22 26 27 27 26 23 16 14 10 6 6 8 10 12 15 13 11];

xx=xx/3;
yy=yy/2.8;
p=plot(x+xx*sz,y+yy*sz,'k');
set(p,'LineWidth',3);
                                                                               