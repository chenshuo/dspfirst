function  zdrill( action )
%ZDRILL GUI to ask students for complex number questions
%
%   Tests knowledge of:
%
%               1. Addition
%               2. Subtraction
%               3. Multiplication
%               4. Division
%               5. Inverse
%               6. Conjugate

% Dr. James H. McClellan, 1994-1995
%                  v2.00, 16-SEP-1999 by Jordan Rosenthal
%                  v2.01, 21-SEP-1999 by Jordan Rosenthal
%                  v2.02, 02-FEB-2000 by Jordan Rosenthal
%                  v2.03, 26-MAR-2000 by Jordan Rosenthal
%                  v2.04, 10-AUG-2000 by Jordan Rosenthal
%                  v2.05, 05-NOV-2000 by Jordan Rosenthal
%                  v2.08, 05-Dec-2002 by Rajbabu & JMc
%                  v2.09, 03-Jan-2005 by Rajbabu for ver 7.0
%                  v2.10, 27-Nov-2005 by Rajbabu for ver 7.1
%                  v2.11, 26-Jan-2015 by Krudysz for ver 8.4 (2014b)
%                  v2.13, 30-Mar-2016 by Krudysz for ver 9.0 (2016a)
%                  v2.14, 14-Mar-2017 by Krudysz for ver 9.3 (2017b)

% NOTE: The GUI layout provided by ZDRILL uses character units to be platform
%       independent.  ZDRILL calls GUI to provide the basic GUI layout and then
%       changes all units/fontunits to normalized to provide accurate resizing response.
%       The actual response to a resize operation depends on the Matlab version (see
%       the comments in the 'ResizeFcn' case).
%
%       Because of the changes made by ZDRILL to the layout from GUI, the
%       GUIDE layout tool should NOT be used on the figure created by ZDRILL.
%       It is much safer to just edit GUI directly instead of using GUIDE if at all
%       possible.  ( If you must use GUIDE for some reason then, run GUI directly and
%       keep all units as characters.  Starting GUI directly will usually cause an
%       error because it cannot find the 'CreateFcn' or 'CloseRequestFcn'.  This is
%       expected and can be ignored.  When finished editing, you can delete the figure
%       with the command delete(findall(0,'Tag','ZDRILL'));  Also, the
%       'HandleVisibility', 'Toolbar', and 'FileName' (Matlab 5.3) properties of the
%       figure should be deleted from GUI before running ZDRILL or an error will occur.)
%
%       The font and color setup in GUI is overriden by ZDRILL as well, so when making
%       font or color changes, it will be necessary to change the settings in the
%       SETFONTS and SETCOLORS files.
%
%       - Jordan Rosenthal

NO = 0; YES = 1;
if nargin==0
    action = 'Initialize';
else
    h = get(gcbf,'UserData');
end

switch action
    %-----------------------------------------------------------
    case 'Initialize'
        %-----------------------------------------------------------
        
        %---  Check the installation, the Matlab Version, and the Screen Size  ---%
        errCmd = 'errordlg(lasterr,''Error Initializing Figure''); error(lasterr);';
        cmdCheck1 = 'installcheck;';
        cmdCheck2 = 'h.MATLABVER = versioncheck(5.1);';
        cmdCheck3 = 'screensizecheck([800 600]);';
        cmdCheck4 = ['adjustpath(''' mfilename ''');'];
        eval(cmdCheck1,errCmd);       % Simple Installation Check
        eval(cmdCheck2,errCmd);       % Check Matlab Version
        eval(cmdCheck3,errCmd);       % Check Screen Size
        eval(cmdCheck4,errCmd);       % Adjust path if necessary
        
        %---  Set up GUI  ---%
        if h.MATLABVER == 5.1
            gui51;
        else
            gui;
        end
        strVersion = '2.14';           % Version string for figure title
        set(gcf, 'Name', ['Complex Number Operations Drill v' strVersion]);
        h.LineWidth = 0.5;
        h.FigPos = get(gcf,'Pos');
        
        SCALE = getfontscale;          % Platform dependent code to determine SCALE parameter
        setfonts(gcf,SCALE);           % Setup fonts: override default fonts used in ltigui
        configresize(gcf);             % Change all 'units'/'font units' to normalized
        
        h = gethandles(h);             % Get GUI graphic handles
        h = setcolors(h);              % Set the colors for the GUI
        
        % Create Data and plots
        rand('seed',sum(100*clock));
        set(gcf,'DefaultLineLineWidth',h.LineWidth);
        h.UserLevel = 'Novice';
        h.Operation = 'Add';
        h.ArrowScale = 1;
        Answers.r = [1 1.5];                              % Possible values for r
        Answers.theta = pi*[-0.5 -0.25 0 0.25 0.5 1];     % Possible values for theta
        h = newquestion(h, Answers);                      % Create new question
        
        set(gcf,'UserData',h);
        set(gcf,'HandleVisibility','callback');    % Make figure inaccessible from command line
        
        %-----------------------------------------------------------
    case 'SetFigureSize'
        %-----------------------------------------------------------
        % Center figure on screen
        OldUnits = get([0; gcf], 'units');
        set([0; gcf],'units','pixels');
        ScreenSize = get(0,'ScreenSize');
        FigPos = get(gcf,'Position');
        newFigPos = [ (ScreenSize(3)-FigPos(3))/2  (ScreenSize(4)-FigPos(4))/2  FigPos(3:4) ];
        set(gcf,'Pos',newFigPos);
        set([0; gcf],{'units'},OldUnits);
        
        %-----------------------------------------------------------
    case 'ResizeFcn'
        %-----------------------------------------------------------
        % For Matlab 5.1, this will not be called because 'Resize' = 'off'
        % Fix for bugs in normalized fontunits in Matlab 5.2.
        % Force constant figure aspect ratio if in Matlab 5.3.
        FigPos = resizefcn(h.FigPos,gcbo,h.MATLABVER);  % Version dependent resize code
        switch computer
            case 'MAC2'
                % On MAC, baseline of text inside edit boxes remains at same
                % vertical position irregardless of change in font size.
                % To properly align text, here the old edit boxes are deleted
                % and new ones created with the proper size.
                hEd = findall(gcbf,'type','uicontrol','style','edit');
                OldFontUnits = get(hEd,'FontUnits');
                set(hEd,'FontUnits','Pixels');
                
                if h.MATLABVER >=8.4
                    hEdNew = gobjects(size(hEd));
                else
                    hEdNew = zeros(size(hEd));
                end
                relHeightChange = FigPos(4)/h.FigPos(4);
                for i = 1:length(hEd)
                    Props = get(hEd(i));
                    FontSize = relHeightChange*Props.FontSize;
                    Props = rmfield(Props,{'Extent','Type','FontSize','FontUnits'});
                    delete(hEd(i));
                    hEdNew(i) = uicontrol('FontUnits','Pixels', ...
                        'FontSize',FontSize,Props);
                end
                set(hEdNew,{'FontUnits'},OldFontUnits);
                h = gethandles(h);
                setappdata(gcbf,'Handles',h);
        end
        h.FigPos = FigPos;         % Store old position
        set(gcbf,'UserData',h);
        
        %-----------------------------------------------------------
    case 'ChangeValue'
        %-----------------------------------------------------------
        r     = str2num(get(h.Edit.Radius,'String'));
        theta = str2num(get(h.Edit.Angle,'String'));
        CONTINUE = YES;
        if isempty(r) | isempty(theta)
            CONTINUE = NO;
        end
        if ~isa(r,'double') | ~isa(theta,'double')
            CONTINUE = NO;
        end
        if CONTINUE
            h.Guess = r*exp(j*theta);
            updatestrings(h);
            h = makeplots(h);
            set(gcbf,'UserData',h);
        else
            set(h.Text.RectForm.Guess,'string','z = NaN');
            set(h.Patch.Guess,'Visible','off');
        end
        
        %-----------------------------------------------------------
    case 'NewQuiz'
        %-----------------------------------------------------------
        switch h.UserLevel
            case 'Novice'
                Answers.r     = [1 1.5];
                Answers.theta = pi*[-0.5 -0.25 0 0.25 0.5 1];
            otherwise
                Answers.r     = [0.5 0.6 0.8 1 1.5 2];
                Answers.theta = pi/8*[-10:10];
        end
        h = newquestion(h, Answers);
        set( gcbf, 'UserData', h );
        
        %-----------------------------------------------------------
    case 'ShowRectForm'
        %-----------------------------------------------------------
        hObj = [h.Text.RectForm.Guess h.Text.RectForm.z1 h.Text.RectForm.z2];
        if get(gcbo,'Value')
            set(hObj,'Visible','on');
            switch h.Operation
                case {'Inverse','Conjugate'}
                    set(h.Text.RectForm.z2,'Visible','Off');
            end
        else
            set(hObj,'Visible','Off');
        end
        
        %-----------------------------------------------------------
    case 'ShowVectorSum'
        %-----------------------------------------------------------
        z.Answer = getfield(h.z3,h.Operation);
        if get(gcbo,'Value')
            set(h.Patch.VectorSum,'Visible','on');
            setaxislims(h.Axis.Answer,[z.Answer h.Guess h.z1 h.z2]);
        else
            set(h.Patch.VectorSum,'Visible','off');
            if get(h.Checkbox.ShowAnswer,'value')
                setaxislims(h.Axis.Answer,[z.Answer h.Guess]);
            else
                setaxislims(h.Axis.Answer,h.Guess);
            end
        end
        
        %-----------------------------------------------------------
    case 'ShowAnswer'
        %-----------------------------------------------------------
        z.Answer = getfield(h.z3,h.Operation);
        if get(gcbo,'Value')
            set(h.Patch.Answer,'Visible','on');
            if get(h.Checkbox.ShowVectorSum,'value')
                setaxislims(h.Axis.Answer,[z.Answer h.Guess h.z1 h.z2]);
            else
                setaxislims(h.Axis.Answer,[z.Answer h.Guess]);
            end
        else
            set(h.Patch.Answer,'Visible','off');
            if ~get(h.Checkbox.ShowVectorSum,'value')
                setaxislims(h.Axis.Answer,h.Guess);
            end
        end
        
        %-----------------------------------------------------------
    case 'SelectOperation'
        %-----------------------------------------------------------
        strOps = {'Add','Subtract','Multiply','Divide','Inverse','Conjugate'};
        
        OldOperation = h.Operation;
        h.Operation = strOps{get(h.Popup.Operation,'value')};
        
        % Show/Hide the ShowVectorSum checkbox and turn it off
        set(h.Checkbox.ShowVectorSum,'value',0);
        switch OldOperation
            case {'Add','Subtract'}
                switch h.Operation
                    case {'Multiply','Divide','Inverse','Conjugate'}
                        set(h.Checkbox.ShowVectorSum,'visible','off');
                end
            otherwise
                switch h.Operation
                    case {'Add','Subtract'}
                        set(h.Checkbox.ShowVectorSum,'visible','on')
                end
        end
        
        % Hide the answer and rect form
        set([h.Checkbox.ShowRectForm h.Checkbox.ShowAnswer],'value',0);
        
        % Show/Hide z2
        switch h.Operation
            case {'Inverse','Conjugate'}
                set(h.Group.z2,'visible','off');
            otherwise
                set(h.Group.z2,'visible','on');
        end
        
        % Change 'Show vector sum/difference' if necessary
        switch h.Operation
            case 'Add'
                set(h.Checkbox.ShowVectorSum,'string','Show Vector Sum');
            case 'Subtract'
                set(h.Checkbox.ShowVectorSum,'string','Show Vector Diff');
        end
        
        updatestrings(h);
        h = makeplots(h);
        
        set( gcbf, 'UserData', h );
        
        %-----------------------------------------------------------
    case 'SelectLevel'
        %-----------------------------------------------------------
        set(allchild(get(gcbo,'Parent')),'checked','off');
        set(gcbo,'Checked','on');
        h.UserLevel = get(gcbo,'Tag');
        set(gcbf,'UserData',h);
        
        %-----------------------------------------------------------
    case 'SetArrowWidth'
        %-----------------------------------------------------------
        dlgPrompt = 'Enter arrow width (must be a positive number)';
        dlgTitle  = 'Enter arrow width';
        dlgLineNo = 1;
        defAns    = { num2str( h.ArrowScale ) };
        AddOpts.Resize      = 'off';
        AddOpts.WindowStyle = 'modal';
        AddOpts.Interpreter = 'none';
        Ans = inputdlg(dlgPrompt,dlgTitle,dlgLineNo,defAns,AddOpts);
        if ~isempty(Ans)
            s = str2num( Ans{1} );
            if ~isempty(s)  &  ( s > 0 )
                h.ArrowScale = s;
                set( gcbf, 'UserData', h);
                h = makeplots(h);
            else
                msg           = 'The arrow width must be a positive number.';
                dlgTitle      = 'Error';
                dlgCreateMode = 'modal';
                msgbox(msg,dlgTitle,dlgCreateMode);
            end
        end
        %-----------------------------------------------------------
    case 'Screenshot'
        %-----------------------------------------------------------
        screenshotdlg(gcbf);
        %-----------------------------------------------------------
    case 'ShowMenu'
        %-----------------------------------------------------------
        check = get(gcbo,'Checked');
        if strcmp(check,'off')
            set(gcbf,'MenuBar','figure');
            set(gcbo,'Checked','On');
        else
            set(gcbf,'MenuBar','none');
            set(gcbo,'Checked','Off');
        end
        %-----------------------------------------------------------
    case 'Help'
        %-----------------------------------------------------------
        hBar = waitbar(0.25,'Opening internet browser...');
        DefPath = which(mfilename);
        DefPath = ['file:///' strrep(DefPath,filesep,'/') ];
        URL = [ DefPath(1:end-8) , 'help/','index.html'];
        if h.MATLABVER >= 6
            STAT = web(URL,'-browser');
        else
            STAT = web(URL);
        end
        waitbar(1);
        close(hBar);
        switch STAT
            case {1,2}
                s = {'Either your internet browser could not be launched or' , ...
                    'it was unable to load the help page.  Please use your' , ...
                    'browser to read the file:' , ...
                    ' ', '     index.html', ' ', ...
                    'which is located in the Zdril help directory.'};
                errordlg(s,'Error launching browser.');
        end
        
        %-----------------------------------------------------------
    case 'CloseRequestFcn'
        %-----------------------------------------------------------
        delete(gcbf);
        
        %-----------------------------------------------------------
    otherwise
        %-----------------------------------------------------------
        error('Unknown action string,')
end
