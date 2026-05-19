% ----------------------------------------------------------------------------
% Using the PhasorRaces Graphical User Interface
% ----------------------------------------------------------------------------
%
% ----------------------------------------------------------------------------
% Overview
% ----------------------------------------------------------------------------
% 
% This program provides a "drill" scenario to test fluecny in the following 
% Signal/System related operations:
%  - Add Complex numbers (in Rectangular/Polar form)
%  - Conversion and manipulations using Euler's form of representation 
%  - Determining normalized sample times
%  - Relate Z-transforms and Pole-Zero locations
% and a few related operations. A timer is provided, so that one can see how
% fast they can solve a problem. Solutions are provided to verify accuracy of 
% the results they calculate.
%
% ----------------------------------------------------------------------------
% PhasorRace (phrace) Controls
% ----------------------------------------------------------------------------
% Creating a new question:
%
%  When the program first starts or when the 'New Question' button is pressed, 
%  an arbitrary question is formed. The type of Question depends on the 
%  'Type of Test' selection. On starting the tool, the default type is 
%  'Complex'. If you need to look at the next question,
%    - Press 'New Question' if you want the same type of test as shown in 
%      'Type of Test'. (or) 
%    - for a different type, select the desired type from the drop-down box 
%      'Type of Test'. The type selected is displayed at the top of the main 
%      screen with a brief description about the operation.
%
% Starting the Timer to see the question:
%
%   After having selected a Question type, press 'Start Timer', and the new 
%   question will be displayed in the 'question  section' of the GUI and the 
%   TIMER starts counting the time you take to answer the question. 
%
% Stopping the Timer:
%
%   When you are done with your calculation and ready to check your answer,
%   press 'Stop Timer'. This will stop the TIMER from ticking, and the time
%   you took to answer the question is displayed next to TIMER:
%
% Checking your Answer: 
%
%   Having stopped the timer, press 'Show Answer' to validate the result you 
%   have calculated against the actual soultion, which will be displayed in the 
%   'answer section' of the GUI.
%
% Changing the type of test:
%
%  You can change the operation on which you are being tested by selecting
%  an option in the 'Type of Test' drop down box.
%  The type of tests and a brief description about them:
%    o) Complex - Addition of Complex numbers in Phasor/Rectangular form.
%    o) Sinusoid - Addition of Sinusiods.
%    o) RealPart - Real part of complex exponential to cosine signal.
%    o) Spectrum - Conversion to/from Complex exponential from/to Cosine forms.
%    o) Sampling - Finding normalized radian frequency from sampling period.
%    o) ZTransform - Locating Pole/Zeros for given transfer function.
%    o) All - Any one of the above types, choosen at random.
%
% Checking the answer:
%  
%  After having found out the solution for a question and having stopped the 
%  Timer, your answer for the question can be verified. Press the 'Show Answer' 
%  button to look at the answer for the question.
%
% Changing the question difficulty:
%
%  By checking either the 'Novice' or 'Pro' items in the 'Options...Level' 
%  menu, you can change the difficulty of the questions.
%
% Rectangular Form:
% 
%  When the 'Type of Test' is set to 'Complex', a checkbox for 'Rectangular 
%  Form' is displayed. If this option is checked, the rectangular form of 
%  the input number(s) and output number is displayed instead of their polar 
%  forms.
%
% Alternate Answers:
%  
%  If the 'Type of Test' is either 'Sinusoid' or 'RealPart' the pushbutton for 
%  'Alternate Answers' is displayed when the 'Show Answer' button is pressed.
%  Pressing this button shows answers that have a phase +/- 2*pi from the 
%  original answer.
%

% eof: usage.m