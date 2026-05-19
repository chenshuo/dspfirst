function hFormulasText = textbox(h)
%TEXTBOX Make the text formulas for the text box.
%   hFormulasText = TEXTBOX(h) makes the text formulas for the text box.
%   h is the handle structure of the dconvdemo GUI.
%
%   See also DCONVDEMO

% Jordan Rosenthal, 05-May-1998
%             Rev., 06-Nov-2000 Changed comments for CONVDEMO to 
%                               DCONVDEMO name change.
%             Rev., 24-Jan-2015 R2014b update 

colorM = [0.1 0.6 0.2];
if verLessThan('matlab','8.4.0')
    switch h.State.SignalToFlip
        case 'Flip x[n]'
            BlueSignal = 'o = h[k]';
            RedSignal = ['o = x[n-k]'];
            sMultiply = ['h[k]x[n-k]'];
            sConvolution = 'y[n] = \Sigmah[k]x[n-k]';
        case 'Flip h[n]'
            BlueSignal = 'o = x[k]';
            RedSignal = ['o = h[n-k]'];
            sMultiply = ['x[k]h[n-k]'];
            sConvolution = 'y[n] = \Sigmax[k]h[n-k]';
    end
    sCircConvolution = 'y_c[n] = \Sigmay[n-Nr]';
    
    Props_Common = {'Tag','TextBoxText','FontUnits','normalized', ...
        'FontWeight','Bold','VerticalAlignment','Top','units','data','FontSize',[]};
    PropNames_Unique = {'String','HorizontalAlignment','color','Position'};
    if h.State.CircularMode
        FONTSIZE = 1/13;
        nSections = 4;
        Props_Common{end} = FONTSIZE;
        PropVals_Unique = { ...
            'Signal Axis:'               , 'left'   , 'k' , [] ;
            BlueSignal                   , 'center' , 'b' , [] ;
            RedSignal                    , 'center' , 'r' , [] ;
            'Multiplication Axis:'       , 'left'   , 'k' , [] ;
            sMultiply                    , 'center' , colorM , [] ;
            'Linear Convolution Axis:'   , 'left'   , 'k' , [] ;
            sConvolution                 , 'center' , 'b' , [] ;
            'Circular Convolution Axis:' , 'left'   , 'k' , [] ;
            sCircConvolution             , 'center' , 'b' , [] };
    else
        FONTSIZE = 1/9;
        nSections = 3;
        Props_Common{end} = FONTSIZE;
        PropVals_Unique = { ...
            'Signal Axis:'               , 'left'   , 'k' , [] ;
            BlueSignal                   , 'center' , 'b' , [] ;
            RedSignal                    , 'center' , 'r' , [] ;
            'Multiplication Axis:'       , 'left'   , 'k' , [] ;
            sMultiply                    , 'center' , colorM , [] ;
            'Convolution Axis:'          , 'left'   , 'k' , [] ;
            sConvolution                 , 'center' , 'b' , [] };
        nLines = 7;
    end
    
    axes(h.Axis.Text);  % Matlab won't set this with the text command
    cla;
    
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
    
    nLines = size(PropVals_Unique,1);
    hFormulasText = text(zeros(nLines,1),zeros(nLines,1),'',Props_Common{:});
    set(hFormulasText,PropNames_Unique,PropVals_Unique);
    
else
    % execute code for R2014b or later
    switch h.State.SignalToFlip
        case 'Flip x[n]'
            BlueSignal = '$$\bf\bullet = h[k]$$';
            RedSignal = ['$$\bf\bullet = x[n-k]$$'];
            sMultiply = ['$$\bf\bullet = h[k]x[n-k]$$'];
            sConvolution = '$$\bf y[n] = \sum h[k]x[n-k]$$';
        case 'Flip h[n]'
            BlueSignal = '$$\bf\bullet = x[k]$$';
            RedSignal = ['$$\bf\bullet = h[n-k]$$'];
            sMultiply = ['$$\bf\bullet = x[k]h[n-k]$$'];
            sConvolution = '$$\bf y[n] = \sum x[k]h[n-k]$$';
    end
    sCircConvolution = '$$\bf y_c[n] = \sum y[n-Nr]$$';
    
    Props_Common = {'Tag','TextBoxText','FontUnits','normalized', ...
        'FontWeight','Bold','VerticalAlignment','Top','units','data','FontSize',[]};
    PropNames_Unique = {'String','HorizontalAlignment','color','Position'};
    if h.State.CircularMode
        FONTSIZE = 1/13;
        nSections = 4;
        Props_Common{end} = FONTSIZE;
        PropVals_Unique = { ...
            'Signal Axis:'               , 'left'   , 'k' , [] ;
            BlueSignal                   , 'center' , 'b' , [] ;
            RedSignal                    , 'center' , 'r' , [] ;
            'Multiplication Axis:'       , 'left'   , 'k' , [] ;
            sMultiply                    , 'center' , colorM , [] ;
            'Linear Convolution Axis:'   , 'left'   , 'k' , [] ;
            sConvolution                 , 'center' , 'b' , [] ;
            'Circular Convolution Axis:' , 'left'   , 'k' , [] ;
            sCircConvolution             , 'center' , 'b' , [] };
    else
        FONTSIZE = 1/9;
        nSections = 3;
        Props_Common{end} = FONTSIZE;
        PropVals_Unique = { ...
            'Signal Axis:'               , 'left'   , 'k' , [] ;
            BlueSignal                   , 'left' , 'b' , [] ;
            RedSignal                    , 'left' , 'r' , [] ;
            'Multiplication Axis:'       , 'left'   , 'k' , [] ;
            sMultiply                    , 'left' , colorM , [] ;
            'Convolution Axis:'          , 'left'   , 'k' , [] ;
            sConvolution                 , 'left' , 'b' , [] };
        nLines = 7;
    end
    
    axes(h.Axis.Text);  % Matlab won't set this with the text command
    cla;
    
    % execute code for R2014b or later
    SPACING = (1 - FONTSIZE*(2*nSections+1)) / (3*nSections);
    PropVals_Unique(1:3,end) = { [0.95,1-0.5*SPACING]; ...
        [1-0.4,1-(FONTSIZE-SPACING)]; [1-0.4,1-(2*FONTSIZE-0.5*SPACING)] };
    OFFSET = 3*FONTSIZE + 1.5*SPACING;
    FORMULAEXTENT = 2*FONTSIZE + 3*SPACING;
    for i = 2:nSections
        PropVals_Unique{2*i,end} = ...
            [ 0.95 , 1-((i-2)*FORMULAEXTENT + OFFSET) ];
        PropVals_Unique{2*i+1,end} = ...
            [ 0.6 , 1-((i-2)*FORMULAEXTENT + (FONTSIZE+SPACING) + OFFSET) ];
    end
    
    nLines = size(PropVals_Unique,1);
    hFormulasText = text(zeros(nLines,1),zeros(nLines,1),'',Props_Common{:});
    set(hFormulasText,PropNames_Unique,PropVals_Unique,'interpreter','latex');
end
