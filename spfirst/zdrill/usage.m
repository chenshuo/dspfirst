%----------------------------------------------------------------------------
%Using the ZDrill Graphical User Interface
%----------------------------------------------------------------------------
%
%----------------------------------------------------------------------------
%Overview
%----------------------------------------------------------------------------
%This program tests the users ability to calculate the result of simple
%operations of complex numbers.  The following six operations are supported:
%
%   Add, Subtract, Multiply, Divide, Inverse, Conjugate
%
% The program emphasized the vectorial view of a complex number.
%
%----------------------------------------------------------------------------
%Theory
%----------------------------------------------------------------------------
%The general form for a complex number is:
%
%     z = x + j*y           (Rectangular form)
%       = r * exp(j*theta)  (Polar form)
%
%where
%
%       x = Real part of z
%       y = Imaginary part of z
%       r = Magnitude of z
%       theta = Angle of z
%
%To convert between formats one can use the following equations:
%
%       x = r*cos(theta)
%       y = r*sin(theta)
%       r = sqrt( x^2 + y^2 )
%       theta = atan2(y,x)
%
%Vectorial view of a complex number
%----------------------------------
%If the real part of a complex number is plotted on the x axis of a graph
%and the imaginary part of the complex number is plotted on the y axis,
%then the complex number can be viewed as a VECTOR.  The length of the
%vector is r, its angle from the positive x axis is theta.  Its projection
%along the x axis is x and its projection along the y axis is y.
%
%Thus, adding two complex numbers can be viewed as adding two vectors.
%This program emphazises the vectorial view of complex numbers.
%
%----------------------------------------------------------------------------
%ZDrill Controls
%----------------------------------------------------------------------------
%Creating a new question:
%
%  When the program first starts or when the 'New Quiz' button is pressed,
%  two complex numbers z1 and z2 are arbitrarily formed.  Their parameters
%  are given in the left column of the screen and their corresponding vectors
%  are plotted in the lower left graph.  (Note: only z1 is shown if the 
%  operation is inverse or conjugate).  It is your job to determine the 
%  radius and angle of the complex number that results from performing the 
%  operation given in the OPERATION drop down box.
%
%Changing the operation:
%
%  You can change the operation on which you are being tested by selecting
%  an option in the OPERATION drop down box.
%
%Changing your guess:
%
%  The radius and angle of your guess can be changed using the two edit boxes
%  in the middle of the screen.  After you have changed your guess, the 
%  corresponding vector is drawn in the lower right graph.  For your 
%  reference, the corresponding rectangular form is shown beneath your guess.
%  Note that you can use any Matlab expression such as pi/2 in these boxes.
%
%Checking the answer:
%  
%  The answer for the current question is always given in the drop down menu
%  called Answers.  If the checkbox 'Show Answer' is checked, then the answer
%  will be plotted as a vector in the lower right graph.
%
%Changing the question difficulty:
%
%  By checking either the 'Novice' or 'Pro' items in the 'Options...Level' menu, 
%  you can change the difficulty of the questions.
%
%Changing the arrow widths:
%
%  Use the 'Options...Set Arrow Width' menu to change the arrow widths of the
%  plot.  The value given must be a positive number.
%
%Show Rect Form:
% 
%  When the 'Show Rect Form' option is checked, the rectangular form of 
%  the input number(s) and your guess is displayed below the corresponding
%  polar form.
%
%See Vector Sum:
%
%  If the operation is either add or subtract, then a checkbox with the label
%  'Show Vector Sum/Difference' is displayed.  By checking this box, the 
%  vector sum or difference will be plotted in the lower right graph.  It is
%  sometimes useful to also check the 'Show Answer' box to see how the 
%  vector sum/difference forms the answer.
