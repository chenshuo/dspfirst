function [notes,drawnotes,dur] = noteread(melody,durstring)
%NOTEREAD    translates the music notation to keynumbers
%       (used as a support file for musicgui)
%      melody = string array with notes in "C4 B#4" notation
%   durstring = strong with durations as "Q H E" etc.
%       notes = array of key numbers
%   drawnotes = same info as notes
%         dur = array of note durations

durindex = 1;
x=length(durstring);
err_flag = 0;   %-- FALSE
lookfornote='true';
dur=[];

durstring = upper(durstring);
for n = 1:x,
   if (strcmp(lookfornote,'true') & not(isspace(durstring(n)))),
      if durstring(n)=='E',
         dur(durindex)=0.125;
         lookfornote='false';
         durindex=durindex+1;
      elseif durstring(n)=='Q',
         dur(durindex)=0.25;
         lookfornote='false';
         durindex=durindex+1;
      elseif durstring(n)=='H',
         dur(durindex)=0.5;
         lookfornote='false';
         durindex=durindex+1;
      elseif durstring(n)=='W',
         dur(durindex)=1;
         lookfornote='false';
         durindex=durindex+1;
      elseif durstring(n)=='S',
         dur(durindex)=0.0625;
         lookfornote='false';
         durindex=durindex+1;
      else err_flag = 1;  %-- TRUE
      end;
   else
      if durstring(n)=='D',
         dur(durindex-1)=1.5 * dur(durindex-1);
         dur(durindex-1)=round(10000*dur(durindex-1))/10000;
         lookfornote='true';
      elseif durstring(n)=='T',
         dur(durindex-1)=(2/3) * dur(durindex-1);
         dur(durindex-1)=round(10000*dur(durindex-1))/10000;
         lookfornote='true';
      elseif isspace(durstring(n)),
         lookfornote='true';
      else err_flag = 1;  %-- TRUE
      end;
   end;
end;

if err_flag
   error('NOTEREAD: error in duration format. Must use W, H, Q, E, S, etc.')
end

%%dur = 0.8*dur;    %- change the durations for faster tempo

keytable =     [ 1  3  0  0  0  0  0
                13 15  4  6  8  9 11
                25 27 16 18 20 21 23
                37 39 28 30 32 33 35
                49 51 40 42 44 45 47
                61 63 52 54 56 57 59
                73 75 64 66 68 69 71
                85 87 76 78 80 81 83                                        
                 0  0 88  0  0  0  0];

noteindex = 1;
acc = 'n';
x = length(melody);
melody(x+1) = ' ';

melody = upper(melody);
for n = 1:x,
   
   if ( melody(n)=='R'),
      notes(noteindex) = 0;
      drawnotes(noteindex) = 0;
      noteindex=noteindex+1;
    
   elseif not(isspace(melody(n))),

      if (n==1), note = melody(n);                                        
         
      elseif isspace(melody(n-1)),
         note = melody(n);
         
      elseif ( melody(n)=='B'),
         acc = 'b';

      elseif (melody(n)=='#'),
         acc = '#';
                                                                            
      elseif isspace(melody(n+1)),
          octave = double( melody(n) ) - 47;
          if( octave<2 | octave>6 ), error('NOTEREAD: octave out of range'), end
          jnote = double(note) - 64;
          if( jnote<1 | jnote>7 )
             error('NOTEREAD: note must be A, B, C, D, E, F, or G')
          end
          notes(noteindex) = keytable(octave,jnote);
          drawnotes(noteindex) = notes(noteindex);
          if (acc == 'b'),
             notes(noteindex) = notes(noteindex) - 1;
          elseif (acc == '#'),
             notes(noteindex) = notes(noteindex) + 1;
          end;
          noteindex = noteindex + 1;
          acc = 'n';
      end;
                 
   end;

end; 

Lnotes = length(notes);
Ldur = length(dur);
if Lnotes<Ldur
   disp(['WARNING in noteread: fewer notes (',num2str(Lnotes),...
          ') than durations (',num2str(Ldur),')'])
   dur = dur(1:Lnotes);
elseif Lnotes>Ldur
   disp(['WARNING in noteread: more notes (',num2str(Lnotes),...
          ') than durations (',num2str(Ldur),')'])
   notes = notes(1:Ldur);
end          
