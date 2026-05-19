function musicgui()
%MUSICGUI        HOW TO USE MUSICGUI                                                     
%------------------------------------                                                     
%                                                                          
% 1) Enter a melody into the box labeled "Enter a melody:".  Use the       
%    following format for each note, separating the notes with spaces:     
%                                                                          
%               <note name><sharp or flat><octave number>                  
%                                                                          
%    All notes must have a note name and an octave number, but accidentals 
%    (sharps and flats) are used only when necessary.  The note name must  
%    be a capital letter A..G; the octave number must be an integer 2..6.  
%    Use a lower-case "b" for a flat and a pound symbol "#" for a sharp.   
%                                                                          
%    All entered notes must be within the range C2..C6.  Please see the    
%    Staff Note Diagram and the Keyboard Diagram to see the range of notes 
%    possible.                                                             
%                                                                          
% 2) Enter the corresponding note durations in the box labeled "Enter      
%    the note durations:".  Use the following format, separating the       
%    entries with spaces:                                                  
%                                                                          
%                     <note duration><time adjustment>                     
%                                                                          
%    The note duration is required; the time adjustment is optional.  You  
%    must type a duration entry for every note you entered in the melody   
%    box.  The table below summarizes the possible duration entries:       
%                                                                          
%         Duration Entry     Type of Note              Number of Beats     
%         --------------     ------------              ---------------     
%               W            Whole note                   4 beats          
%               H            Half note                    2 beats          
%               Q            Quarter note                 1 beat           
%               E            Eighth note                  1/2 beat         
%               Hd           Dotted Half note             3 beats          
%               Qd           Dotted Quarter note          3/2 beats        
%               Ed           Dotted Eighth note           3/4 beat         
%               Ht           Triplet Half note            4/3 beat         
%               Qt           Triplet Quarter note         2/3 beat         
%               Et           Triplet Eighth note          1/3 beat         
%                                                                          
%    Please see the Note Diagram to see what each type of note looks like. 
%    In MusicLab, triplet notes will look just like their standard notes;  
%    for example, the triplet eighth note "Et" will look the same as the   
%    regular eighth note "E."  (In professional sheet music, triplet notes 
%    are usually indicated by grouping them under brackets labeled with the
%    number "3."                                                           
%                                                                          
% 3) Once you have entered all of the notes and durations, click the       
%    button labeled "Apply."  The melody you have entered will appear in   
%    the upper display box, and a spectrogram of your melody will appear in
%    the lower display box.                                                
%                                                                          
% 4) You can hear what your melody sounds like by clicking the "Play       
%    Song" button.  If your entire melody is not displayed in the windows, 
%    you can scroll through your melody using the arrow buttons in the     
%    bottom left corner.  The "Back to Beginning" button will scroll the   
%    melody back to the original display.                                  
%                                                                          
% 5) You can add a second melody or harmony to your composition.  To do    
%    this, first delete the notes from your first melody.  (Delete them    
%    manually -- not with the "Clear" button.)  Now, follow steps 1 and 2  
%    again, this time with the notes from the second melody.  Once you have
%    entered all the notes and durations, click the "Add Harmony" button.  
%    Now, both melody lines will appear in the display windows.  As before,
%    you can listen to your song or scroll through it.                     
%                                                                          
% 6) You may add as many melody lines as you like by repeating step 5.     
%    When you are finished working with your song, you can click the       
%    "Clear" button to clear both display windows and to remove all notes  
%    from memory.  IMPORTANT: "Clear" will clear all notes from all        
%    melodies, not just the notes from the last melody entered. 

vvv = version;
if( strcmp('4',vvv(1)) )   %-- fixed for ver 6 (J McClellan, 31-August-2001)
   errv4('MUSICGUI');
else
   eval('musicg_x');
end
