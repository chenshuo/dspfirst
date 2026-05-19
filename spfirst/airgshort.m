% These are the piano key numbers and the corresponding durations for
% the song Air on a G-String by J.S. Bach.
% This is the SHORT version which his available for debugging
%
% There are 6 matrices defined:
%   tnotes, tdur, bnotes, bdur, b2notes and b2dur.
% tnotes contains the note for the treble clef,
%   which is the upper part of the score.
% bnotes and b2notes define the bass clef, or lower part.
%
% In tdur (and also bdur and b2dur), the type of note is coded as follows:
%   1 = whole note
%   2 = half note
%   4 = quarter note
%   8 = eighth note
%  16 = sixteenth note
%   ..... etc.
%  fractions are used if necessary, e.g., 1.6 means a note that is
%  longer than a half note, but shorter than a whole note.  Its actual
%  duration is 25% longer than a half note, because 1/1.6 = 1.25*(1/2) 
%
% A note value of 0 is a rest.
% In this song there might be times when the treble clef has two notes
% together, in these cases the second treble note is actually placed in one
% of the bass clef arrays (where there is an open slot).
%
%  The formatting of this file should help in spotting
%  which measure the notes are from.

tnotes = [ 
      46      46      51      47 ... 
      44      42      41      42 ... 
      41      39      37
 ];

tdur = [ 
       2     1.6      16      16 ... 
      16      16      16      16 ... 
       4      16     5.333
 ];

bnotes = [ 
      30      42      41      29 ... 
      27      39      37      25 ... 
      23      35      36      24 ... 
      25      37      35      23 ... 
 ];

bdur = [ 
       8       8       8       8 ... 
       8       8       8       8 ... 
       8       8       8       8 ... 
       8       8       8       8 ... 
 ];

b2notes = [ 
      18      29      15      25 ... 
      11      24      13      23 ... 
  ];

b2dur = [ 
       4       4       4       4 ... 
       4       4       4       4 ... 
   ];

