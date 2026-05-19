function hFormulasText = textbox(h)
%TEXTBOX Make the text formulas for the text box.
%   hFormulasText = TEXTBOX(h) makes the text formulas for the text box.
%   h is the handle structure of the cconvdemo GUI.
%
%   See also CCONVDEMO

% Jordan Rosenthal, 11/03/98
%             Rev., 26-Oct-2000

switch h.State.SignalToFlip
case 'Flip x(t)'
   BlueSignal = 'h(\tau) = blue';
   RedSignal = ['x(t-\tau) = red'];
   sMultiply = ['h(\tau)x(t-\tau)'];
   sConvolution = 'y(t) = \inth(\tau)x(t-\tau)d\tau';
case 'Flip h(t)'
   BlueSignal = 'x(\tau) = blue';
   RedSignal = ['h(t-\tau) = red'];
   sMultiply = ['x(\tau)h(t-\tau)'];
   sConvolution = 'y(t) = \intx(\tau)h(t-\tau)d\tau';
end

Props_Common = {'Tag','TextBoxText','FontUnits','normalized', ...
   'FontWeight','Bold','VerticalAlignment','Top','FontSize',[]};
PropNames_Unique = {'String','HorizontalAlignment','color','Position'};
FONTSIZE = 1/9;
nSections = 3;
Props_Common{end} = FONTSIZE;
PropVals_Unique = { ...
      'Signal Axis:'               , 'left'   , 'k' , [] ;
   BlueSignal                   , 'center' , 'b' , [] ;
   RedSignal                    , 'center' , 'r' , [] ;
   'Multiplication Axis:'       , 'left'   , 'k' , [] ;
   sMultiply                    , 'center' , 'b' , [] ;
   'Convolution Axis:'          , 'left'   , 'k' , [] ;
   sConvolution                 , 'center' , 'b' , [] };

SPACING = (1 - FONTSIZE*(2*nSections+1)) / (3*nSections);
PropVals_Unique(1:3,end) = { [0.05,0.5*SPACING]; ...
   [0.5,FONTSIZE+1.5*SPACING]; [0.5,2*FONTSIZE+2.5*SPACING] };
OFFSET = 3*FONTSIZE + 3.5*SPACING;
FORMULAEXTENT = 2*FONTSIZE + 3*SPACING;
for i = 2:nSections
    PropVals_Unique{2*i,end} = ...
       [ 0.05 , (i-2)*FORMULAEXTENT + OFFSET ];
    PropVals_Unique{2*i+1,end} = ...
       [ 0.5 , (i-2)*FORMULAEXTENT + (FONTSIZE+SPACING) + OFFSET ];
end

set(gcbf,'currentAxes',h.Axis.Text);  % Matlab won't set this with the text command
cla; 
nLines = size(PropVals_Unique,1);
hFormulasText = text(zeros(nLines,1),zeros(nLines,1),'',Props_Common{:});
set(hFormulasText,PropNames_Unique,PropVals_Unique);
