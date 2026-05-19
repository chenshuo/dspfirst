function   sindrill( action )
%SINDRILL GUI to ask students for cosine wave parameters
%   This program tests the users ability to determine basic parameters
%   of a sinusoid.  After a plot of a sinusoid is displayed, the user
%   must correctly guess its amplitude, frequency, and phase.

% Dr. James H. McClellan, 1994-1995
%   Rev., 09-SEP-1999 by Jordan Rosenthal
%   Rev., 02-FEB-2000 by Jordan Rosenthal
%   Rev., 26-MAR-2000 by Jordan Rosenthal
%   Rev., 05-NOV-2000 by Jordan Rosenthal
%   Rev., 19-JUN-2002 by Rajbabu. Added HTML 'help'
%   Rev., 05-Dec-2002 by JMc, final release SP First; changed a few comments
%   Rev., 2.08, 03-Jan-2005 by Rajbabu for ver 7.0
%   Rev., 2.09, 25-Nov-2005 by Krudysz for ver 7.1
%   Rev., 2.10, 26-Jan-2015 by Krudysz for ver 8.4 (2014b)
%   Rev., 2.12, 30-Mar-2016 by Krudysz for ver 9.0 (2016a)
%   Rev., 2.14, 14-Mar-2018 by Krudysz for ver 9.3 (2017b)
%   Rev., 2.15, 15-May-2021 by Krudysz for ver 9.9 (2020b)

% NOTE: The GUI layout provided by SINDRILL uses character units to be platform
%       independent.  SINDRILL calls GUI to provide the basic GUI layout and then
%       changes all units/fontunits to normalized to provide accurate resizing response.
%       The actual response to a resize operation depends on the Matlab version (see
%       the comments in the 'ResizeFcn' case).
%
%       Because of the changes made by SINDRILL to the layout from GUI, the
%       GUIDE layout tool should NOT be used on the figure created by SINDRILL.
%       It is much safer to just edit GUI directly instead of using GUIDE if at all
%       possible.  ( If you must use GUIDE for some reason then, run GUI directly and
%       keep all units as characters.  Starting GUI directly will usually cause an
%       error because it cannot find the 'CreateFcn' or 'CloseRequestFcn'.  This is
%       expected and can be ignored.  When finished editing, you can delete the figure
%       with the command delete(findall(0,'Tag','SINDRILL'));  Also, the
%       'HandleVisibility', 'Toolbar', and 'FileName' (Matlab 5.3) properties of the
%       figure should be deleted from GUI before running SINDRILL or an error will occur.)
%
%       The font setup in GUI is overriden by SINDRILL as well, so when making font
%       changes, it will be necessary to change the settings in the SETUPFONTS file.
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
        strVersion = '2.15';           % Version string for figure title
        set(gcf,'Name', ['Reading Sinusoids Drill v' strVersion]);
        h.LineWidth = 2;
        h.FigPos = get(gcf,'Pos');
        
        SCALE = getfontscale;          % Platform dependent code to determine SCALE parameter
        setfonts(gcf,SCALE);           % Setup fonts: override default fonts used in ltigui
        configresize(gcf);             % Change all 'units'/'font units' to normalized
        
        h = gethandles(h);             % Get GUI graphic handles
        h = setcolors(h);              % Set the colors for the GUI
        h = defaultplots(h);           % Create default plots
        
        rand('seed',sum(100*clock));
        
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
        % Fix for bugs in normalized fontunits in Matlab 5.2.
        % Force constant figure aspect ratio if in Matlab 5.3.
        FigPos = resizefcn(h.FigPos,gcbo,h.MATLABVER);  % Version dependent resize code
        switch computer
            case 'MAC2' %{'MAC2','GLNX86','GLNXA64'}
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
        A = str2num(get(h.Edit.Amplitude,'String'));
        f0 = str2num(get(h.Edit.Frequency,'String'));
        phi = str2num(get(h.Edit.Phase,'String'));
        CONTINUE = YES;
        if isempty(A) | isempty(f0) | isempty(phi)
            CONTINUE = NO;
        end
        if ~isa(A,'double') | ~isa(f0,'double') | ~isa(phi,'double')
            CONTINUE = NO;
        end
        if CONTINUE
            %---  Plot guess and change title string  ---%
            t = h.t(1) : 1/(100*h.Frequency) : h.t(end);
            set(h.Line.Guess,'XData',t,'YData',A*cos(2*pi*f0*t+phi));
            set(h.Title,'String',cosinestring(A,f0,phi/pi,0,0));
            setaxislimits(h);
            
            %---  Change Period string  ---%
            if f0 == 0
                s = ['Period = Inf'];
            else
                s = ['Period = ' num2str(abs(1/f0*1000),'%5.3g'),' ms'];
            end
            set(h.Text.Period,'String',s);
        end       
        %-----------------------------------------------------------
    case 'NewQuiz'
        %-----------------------------------------------------------
        h = newquiz(h);        
        %-----------------------------------------------------------
    case 'ShowGuess'
        %-----------------------------------------------------------
        if get(gcbo,'Value')
            set([h.Line.Guess h.Title],'Visible','on');
        else
            set([h.Line.Guess h.Title],'Visible','off');
        end
        setaxislimits(h);        
        %-----------------------------------------------------------
    case 'SelectLevel'
        %-----------------------------------------------------------
        set(allchild(get(gcbo,'Parent')),'checked','off');
        set(gcbo,'Checked','on');
        h.UserLevel = get(gcbo,'Tag');
        set(gcbf,'UserData',h);
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
    case 'LineWidth'
        %-----------------------------------------------------------
        h.LineWidth = linewidthdlg(h.LineWidth);
        set(findobj(gcbf, 'Type', 'line'), 'LineWidth', h.LineWidth);
        set(gcbf,'UserData',h);        
        %-----------------------------------------------------------
    case 'Help'
        %-----------------------------------------------------------
        hBar = waitbar(0.25,'Opening internet browser...');
        DefPath = which(mfilename);
        DefPath = ['file:///' strrep(DefPath,filesep,'/') ];
        URL = [ DefPath(1:end-10) , 'help/','index.html'];
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
                    'which is located in the SinDrill help directory.'};
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