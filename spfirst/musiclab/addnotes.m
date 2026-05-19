function addnotes(notes,drawnotes,dur,scroll)
%ADDNOTES   Adds more notes to the musical score drawn for the Music GUI
%    This function is a support function for musicgui.
%    It draws the actual notes on the screen.

TOL = 1e-4;

StaffHandle = findobj(gcbf,'Tag','Staff');
axes(StaffHandle);
hold on;

sz = .9;

mg_dline(dur);

drawtable = [1 0 2 0 3 4 0 5 0 6 0 7 8 0 9 0 10 11 0 12 0 13 0 14 15 0 16 0 17 18 0 19 0 20 0 21 22 0 23 0 24 25 0 26 0 27 0 28 29];

for k = 1:size(notes,1),
   for i = 1:size(notes,2),
      if (notes(k,i)~=0),
         x=sum(dur(k,1:i-1)*4*6.5) + 1 - (scroll-1)*6.5;
         y=drawtable(floor(drawnotes(k,i))-15);
         if ((y==1)|(y==3)|(y==15)|(y==27)|(y==29)),
            p=plot([x-1.2 x+1.2],[y y],'k');
            set(p,'LineWidth',2);
         end;
         if ((y==28)|(y==29)),
            p=plot([x-1.2 x+1.2],[27 27],'k');
            set(p,'LineWidth',2);
         end;
         if ((y==1)|(y==2)),
            p=plot([x-1.2 x+1.2],[3 3],'k');
            set(p,'LineWidth',2);
         end; 
         a = 0;
         if (notes(k,i) > drawnotes(k,i)),       a = 0.6;        end;
         if (notes(k,i) < drawnotes(k,i)),       a = 0.4;        end;
         
         if (abs(dur(k,i)-1)<TOL),        wnote(x,y,sz,a);     end;
         if (abs(dur(k,i)-0.75)<TOL),     hnote_d(x,y,sz,a);   end;
         if (abs(dur(k,i)-0.5)<TOL),      hnote(x,y,sz,a);     end;
         if (abs(dur(k,i)-0.375)<TOL),    qnote_d(x,y,sz,a);   end;
         if (abs(dur(k,i)-0.3333)<TOL),   hnote(x,y,sz,a);     end;
         if (abs(dur(k,i)-0.25)<TOL),     qnote(x,y,sz,a);     end;
         if (abs(dur(k,i)-0.1875)<TOL),   enote_d(x,y,sz,a);   end;
         if (abs(dur(k,i)-0.1667)<TOL),   qnote(x,y,sz,a);     end;
         if (abs(dur(k,i)-0.125)<TOL),    enote(x,y,sz,a);     end;
         if (abs(dur(k,i)-0.0833)<TOL),   enote(x,y,sz,a);     end;
         if (abs(dur(k,i)-0.0625)<TOL),   snote(x,y,sz,a);     end;
            
      end;
   end;
   
   axis([0 52 0 32]);
   
end;
