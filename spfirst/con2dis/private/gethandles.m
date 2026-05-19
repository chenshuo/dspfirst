function h = gethandles(h)
%GETHANDLES Get all the handles used in the GUI
%   h = GETHANDLES(h) finds the handles used in the GUI and assigns them
%   to elements of the structure h
%
% Gregory Krudysz, 15-Oct-01: Extracted original code from con2dis 'Initialize' case
%                           : and created separate function.

h.Axis1       = findobj(gcf, 'Tag', 'Axis1');
h.Axis2       = findobj(gcf, 'Tag', 'Axis2');
h.Axis3       = findobj(gcf, 'Tag', 'Axis3');
h.Axis4       = findobj(gcf, 'Tag', 'Axis4');
h.AxisRef     = findobj(gcf, 'Tag', 'AxisRef');

h.Editbox1	  = findobj(gcf, 'Tag', 'EditText1');
h.Editbox2    = findobj(gcf, 'Tag', 'EditText2');
h.Editbox3	  = findobj(gcf, 'Tag', 'EditText3');

h.Slider1     = findobj(gcf, 'Tag', 'Slider1');
h.Slider2	  = findobj(gcf, 'Tag', 'Slider2');

h.Text        = findobj(gcf, 'Tag', 'text2');
h.TextRB1	  = findobj(gcf, 'Tag', 'TextRButton2');
h.TextRB12	  = findobj(gcf, 'Tag', 'TextRButton22');

h.Check       = findobj(gcf, 'Tag', 'Checkbox1');
h.UnfoldB     = findobj(gcf, 'Tag', 'UnfoldButton');
h.AllMenu     = findobj(gcf, 'Tag', '&ShowAllPlots');
h.ShowW       = findobj(gcf, 'Tag', 'ShowRadFreq');    
h.ShowW_hat   = findobj(gcf, 'Tag', 'ShowDiscreteRadFreq');    
h.ShowLF      = findobj(gcf, 'Tag', '&ShowLF');

h.RButton2	  = findobj(gcf, 'Tag', 'Radiobutton2');
h.RButton22	  = findobj(gcf, 'Tag', 'Radiobutton22');

h.Frame       = findobj(gcf, 'Tag', 'Frame');