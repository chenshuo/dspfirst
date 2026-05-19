function wrinotes(notes,durs,acc)
%WRINOTES
%
%   WRINOTES(notes,durs,acc) draws the musical notes described by "notes" and
%      "durs" on a musical staff.  The parameter "acc" determines whether the
%      black key notes will be written as sharps or flats.
%
%      The matrix "notes" contains the key numbers for the notes to be drawn, 
%      based on the 88-key piano keyboard.  The matrix "durs" contains the 
%      durations for each of the key numbers in "notes".  Notice that "notes" 
%      and "durs" must have the same dimensions.  Consult the HowTo menu in 
%      the MusicLab for more information on the notation for these two matrices.
%
%      The key numbers must have integer values between 16 and 66.  Duration 
%      values must be taken from the following table:
%
%          Note               Duration Value
%          ----               --------------
%          Whole              1
%          Dotted half        0.75
%          Half               0.5
%          Dotted quarter     0.375
%          Triplet Half       0.3333
%          Quarter            0.25
%          Dotted eighth      0.1875
%          Triplet quarter    0.1667
%          Eighth             0.125
%          Triplet Eighth     0.0833
%          Sixteenth          0.0625
%
%      Consult the HowTo menu in the MusicLab for more information on the notation
%      for these two matrices.
%
%      Although the rows in the notes and durs matrix must have the same number
%      of elements, musical harmony lines do not always have the same number of
%      notes.  If some of your harmony lines have less notes than others, then
%      use zeros at the ends of the rows to fill them out to the proper dimensions.
%      
%      Example:   notes = [40 42 44 45; 28 35 28 0]
%                 durs = [.25 .25 .25 .25; .5 .25 .25 0]
%      These two matrices describe two lines playing simultaneously.  The first row
%      contains four quarter notes, and the second row contains a half note and two
%      quarter notes.
%
%      Sometimes music contains breaks in the sound, called rests.  To describe a 
%      rest, use 0 as the key number.
%
%      Example:   notes = [40 44 47 0 52]
%                 durs = [.25 .25 .25 .25 .25]
%      These vectors describe a single melody line beginning with three quarter notes,
%      pausing for one quarter note duration, and then playing a final quarter note.
%
%      The parameter "acc" specifies whether accidental notes (the black keys on the
%      keyboard) are to be written as sharps or flats.  The parameter "acc" must 
%      have the value 'f' (for flat) or 's' (for sharp).

sz = .9;

StaffHandle = findobj('Tag','StaffAxes');
if (isempty(StaffHandle)),  
   wngui;
else
   axes(StaffHandle);
   cla;
end;

xlen = max(sum(durs,2))*4*6.5+3;
if (xlen<60),  xlen=60;  end;
ylen = 10*2+12;
hold off;
patch([0 xlen xlen 0],[0 0 ylen ylen],'w','EdgeColor','none');
hold on;
for l = 5:2:13,
   p=plot([1 xlen-1],[l l],'k');
   set(p,'LineWidth',2);
end;
for l = 17:2:25,
   p=plot([1 xlen-1],[l l],'k');
   set(p,'LineWidth',2);
end;
p=plot([1 1],[4.8 25.2],'k');
set(p,'LineWidth',2);
p=plot([xlen-1 xlen-1],[4.8 25.2],'k');

ScrollHandle = findobj(gcbf,'Tag','StaffScroll');
set(ScrollHandle,'Min',0);
set(ScrollHandle,'Max',xlen);
set(ScrollHandle,'Value',0);
set(ScrollHandle,'SliderStep',1);

drawtable = [1 0 2 0 3 4 0 5 0 6 0 7 8 0 9 0 10 11 0 12 0 13 0 14 15 0 16 0 17 18 0 19 0 20 0 21 22 0 23 0 24 25 0 26 0 27 0 28 29 0];

if (acc=='f'),
   drawnum = 1;
else
   drawnum = -1;
end;

drawnotes=notes;
for k = 1:size(drawnotes,1),
   
   for i = 1:size(drawnotes,2),
      
      if (drawnotes(k,i)~=0),
         
         if (drawtable(drawnotes(k,i)-15)==0),
            drawnotes(k,i)=drawnotes(k,i)+drawnum;
         end;
         
         x=sum(durs(k,1:i-1)*4*6.5)+3;
         y=drawtable(drawnotes(k,i)-15);
         
         set(p,'LineWidth',2);
         if ((y==1)|(y==3)|(y==15)|(y==27)|(y==29)),
            p=plot([x-1.2 x+1.2],[y y],'k');
         end;
         if ((y==28)|(y==29)),
            p=plot([x-1.2 x+1.2],[27 27],'k');
         end;
         if ((y==1)|(y==2)),
            p=plot([x-1.2 x+1.2],[3 3],'k');
         end; 
         
         a = 0;
         if (notes(k,i) > drawnotes(k,i)),       a = 0.6;        end;
         if (notes(k,i) < drawnotes(k,i)),       a = 0.4;        end;
         
         if (durs(k,i) == 1),        wnote(x,y,sz,a);			end;
         if (durs(k,i) == 0.75),     hnote_d(x,y,sz,a);		end;
         if (durs(k,i) == 0.5),      hnote(x,y,sz,a);			end;
         if (durs(k,i) == 0.375),    qnote_d(x,y,sz,a);		end;
         if (durs(k,i) == 0.3333),   hnote(x,y,sz,a);			end;
         if (durs(k,i) == 0.25),     qnote(x,y,sz,a);			end;
         if (durs(k,i) == 0.1875),   enote_d(x,y,sz,a);		end;
         if (durs(k,i) == 0.1667),   qnote(x,y,sz,a);			end;
         if (durs(k,i) == 0.125),    enote(x,y,sz,a);			end;
         if (durs(k,i) == 0.0833),   enote(x,y,sz,a);			end;
         if (durs(k,i) == 0.0625),   snote(x,y,sz,a);			end;
      end;
      
   end;
   
end;
   
axis([0 52 0 32]);
