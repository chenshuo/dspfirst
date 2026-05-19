function [notes,drawnotes,dur] = concat(notes,newnotes,drawnotes,newdrawnotes,dur,newdur)
%CONCAT   Adds more notes to the musical score for Music GUI
%    This function is a support function for musicgui
%    It adds another harmony line or bass line to the song
%     which is stored in the 2-D array notes.  Each row
%     of notes is a set of consecutive notes to be played.
%     The separate rows are added together to produce the song.
%

if (size(notes,2)>length(newnotes)),
   for n=length(newnotes)+1:size(notes,2),
      newnotes(n)=0;
   end;
end;
if (size(notes,2)<length(newnotes)),
   for n=size(notes,2)+1:length(newnotes),
      for i=1:size(notes,1),
         notes(i,n)=0;
      end;
   end;
end;
notes=[notes;newnotes];

if (size(drawnotes,2)>length(newdrawnotes)),
   for n=length(newdrawnotes)+1:size(drawnotes,2),
      newdrawnotes(n)=0;
   end;
end;
if (size(drawnotes,2)<length(newdrawnotes)),
   for n=size(drawnotes,2)+1:length(newdrawnotes),
      for i=1:size(drawnotes,1),
         drawnotes(i,n)=0;
      end;
   end;
end;
drawnotes=[drawnotes;newdrawnotes];

if (size(dur,2)>length(newdur)),
   for n=length(newdur)+1:size(dur,2),
      newdur(n)=0;
   end;
end;
if (size(dur,2)<length(newdur)),
   for n=size(dur,2)+1:length(newdur),
      for i=1:size(dur,1),
         dur(i,n)=0;
      end;
   end;
end;
dur=[dur;newdur];

