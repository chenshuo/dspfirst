function  phrace( action )
%PHRACE GUI to test speed of phasor operations
%
%   Tests knowledge of:
%
%               1. Adding Complex Numbers in Polar Form
%               2. Adding Sinusoids
%               3. Normalized radian frequency in Sampling
%               4. Identifying Pole-Zero location from Transfer function

% Dr. James H. McClellan, 2001
%       v1.00, 18-Jan-01 by Jim McClellan, only for v5.2 and higher
%       v1.01, 20-Jan-01 by JMc, added spectrum testing
%       v1.0x, Fall-2001, Mehdi Javaramand
%       v1.1,  03-Aug-02 by Rajbabu,
%               - cleaned up the layout of the GUI
%               - enabled 'novice'/'pro' options
%       v1.11,  05-Dec-02 by JMc, final cleanup for SP First release
%       v1.12,  03-Jan-2005 by Rajbabu for ver 7.0
%       v1.13,  29-Dec-2005 by Krudysz for ver 7.1
%       v1.14,  24-Feb-2015 by Krudysz for R2014b

% NOTE: The GUI layout provided by PHRACE uses character units to be platform
%       independent.  PHRACE calls PHGUI to provide the basic GUI layout and
%       then changes all units/fontunits to normalized to provide accurate
%       resizing response. The actual response to a resize operation depends on
%       the Matlab version (see the comments in the 'ResizeFcn' case).
%
%       Because of the changes made by PHRACE to the layout from PHGUI, the
%       GUIDE layout tool should NOT be used on the figure created by PHRACE.
%       It is much safer to just edit PHGUI directly instead of using GUIDE if
%       at all possible.  ( If you must use GUIDE for some reason then, run
%       PHGUI directly and keep all units as characters.  Starting PHGUI
%       directly will usually cause an error because it cannot find the
%       'CreateFcn' or 'CloseRequestFcn'.  This is expected and can be ignored.
%       When finished editing, you can delete the figure with the command
%       delete(findall(0,'Tag','PHRACE'));  Also, the 'HandleVisibility',
%       'Toolbar', and 'FileName' (Matlab 5.3) properties of the figure should
%       be deleted from PHGUI before running PHRACE or an error will occur.)
%
%       The font and color setup in PHGUI is overridden by PHRACE as well, so
%       when making font or color changes, it will be necessary to change the
%       settings in the SETFONTS and SETCOLORS files.
%
%       - Jordan Rosenthal

NO = 0; YES = 1;
global phasecounter
if nargin==0
    action = 'Initialize';
else
    h = get(gcbf,'UserData');
end

switch action
    %-----------------------------------------------------------
    case 'Initialize'
        %-----------------------------------------------------------
        phasecounter = 0;
        %---  Check the installation, the Matlab Version, and the Screen Size  ---%
        errCmd = 'errordlg(lasterr,''Error Initializing Figure''); error(lasterr);';
        cmdCheck1 = 'installcheck;';
        cmdCheck2 = 'h.MATLABVER = versioncheck(5.2);';
        cmdCheck3 = 'screensizecheck([800 600]);';
        cmdCheck4 = ['adjustpath(''' mfilename ''');'];
        eval(cmdCheck1,errCmd);       % Simple Installation Check
        eval(cmdCheck2,errCmd);       % Check Matlab Version
        eval(cmdCheck3,errCmd);       % Check Screen Size
        eval(cmdCheck4,errCmd);       % Adjust path if necessary
        
        %---  Set up GUI  ---%
        if h.MATLABVER == 5.1
            error('NOT YET working for version 5.1');
        else
            phgui;
        end
        strVersion = '1.16';           % Version string for figure title
        set(gcf, 'Name', ['Phasor Race v' strVersion]);
        h.LineWidth = 0.5;
        h.FigPos = get(gcf,'Pos');
        
        %SCALE = getfontscale; % Platform dependent code to determine SCALE parameter
        %setfonts(gcf,SCALE);  % Setup fonts: override default fonts used in ltigui
        %configresize(gcf);     % Change all 'units'/'font units' to normalized
        
        h = gethandles(h);             % Get GUI graphic handles
        h = setcolors(h);              % Set the colors for the GUI
        % h.phasecounter = 2;
        
        axes(h.Text.Area);
        h.Running = 0;
        h.ShowNew = 0;
        % New line character. Common to all platforms.
        h.cr = sprintf('\n');
        
        h.Text.fz.Large = .1;
        h.Text.fz.Med = .08;
        h.Text.fz.Small = .06;
        h.Text.fz.Tiny = .04;
        h.Text.fz.Timer = 0.05;
        h.Text.fz.Question = h.Text.fz.Small;
        h.Text.fz.Questionden = h.Text.fz.Small;
        h.Text.fz.Questionline = h.Text.fz.Small;
        h.Text.fz.Answer = h.Text.fz.Small;
        
        % Problem with interpreter in UNIX for Tex characters
        if isunix
            h.FontWeight = 'normal';
        else
            h.FontWeight = 'normal';
        end
        %h.Title = 'Phasor Races';
        h.Title = 'Complex: Adding Complex Amplitudes';
        h.ShowAnswer = 0;
        
        
        Alternhandle = findobj(gcbf,'Tag','AlternateAnswers');
        set(Alternhandle,'Visible','off');
        
        set(h.Text.Title,...
            'fontsize',h.Text.fz.Tiny,'fontweight','bold');
        set(h.Text.Timer,...
            'fontsize',h.Text.fz.Timer,'fontweight','bold');
        % Initial screen values
        h.Question = 'Sample Question: e^{j0.5\pi} + e^{j\pi} ';
        h.recQuestion = 'Sample Question: -1 + j';
        h.Questionline = '';
        h.Questionden = '';
        h.Answer = 'The Answer: \surd{2} e^{j0.75\pi}';
        h.recAnswer = 'The Answer: -1 + j';
        
        set(h.Text.Question,'String', h.Question);
        set(h.Text.Questionline,'String', h.Questionline);
        set(h.Text.Questionden,'String', h.Questionden);
        
        set(h.Text.Question,...
            'fontsize',h.Text.fz.Question,'fontweight',h.FontWeight);
        set(h.Text.Questionline,...
            'fontsize',h.Text.fz.Questionline,'fontweight',h.FontWeight);
        set(h.Text.Questionden,...
            'fontsize',h.Text.fz.Questionden,'fontweight',h.FontWeight);
        
        set(h.Text.Answer,'String',h.Answer,...
            'fontsize',h.Text.fz.Answer,'fontweight',h.FontWeight);
        
        h.time.MAX = 999;
        h.UserLevel = 'Novice';
        h.Operation = 'Add';
        
        % Create Data and plots
        rand('seed',sum(100*clock));
        set(gcf,'DefaultLineLineWidth',h.LineWidth);
        Answers.r = [1 1.5];                              % Possible values for r
        Answers.theta = pi*[-0.5 -0.25 0 0.25 0.5 1];     % Possible values for theta
        h = newquestion(h, Answers);                      % Create new question
        
        % TestType
        strOps = {'Complex','Sinusoid','RealPart','Spectrum',...
            'Sampling','ZTransform','All'};
        h.TestType = strOps{get(h.Popup.TestType,'value')};
        
        configresize(gcf);
        % Set UserData
        set(gcf,'UserData',h);
        set(gcf,'HandleVisibility','callback'); % Make figure inaccessible
        % from command line
        
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
        h.FigPos = get(gcf,'Pos');
        ver = version;
        h.MATLABVER =str2num(ver(1:3));
        
        FigPos = resizefcn(h.FigPos,gcbo,h.MATLABVER); %Version dependent resize code
        switch computer
            case 'MAC2'
                % On MAC, baseline of text inside edit boxes remains at same
                % vertical position regardless of change in font size.
                % To properly align text, here the old edit boxes are deleted
                % and new ones created with the proper size.
                hEd = findall(gcbf,'type','uicontrol','style','edit');
                OldFontUnits = get(hEd,'FontUnits');
                set(hEd,'FontUnits','Pixels');
                hEdNew = zeros(size(hEd));
                
                if h.MATLABVER < 8.4
                    hEdNew = zeros(size(hEd));
                else
                    hEdNew = gobjects(size(hEd));
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
    case 'StartTimer'
        %-----------------------------------------------------------
        
        if h.Running
            return
        else
            h.Running = 1;
            h.ShowNew = 1;
            h.ShowAnswer = 1;
        end
        
        boxhandle = findobj(gcbf,'Tag','ShowRectForm');
        if(get(boxhandle,'value')) & (strcmp(h.TestType,'Complex'))
            set(h.Text.Question,'string',h.recQuestion,'FontSize',h.Text.fz.Question);
        else
            set(h.Text.Question,'string',h.Question,'FontSize',h.Text.fz.Question);
        end
        
        if (strcmp(h.TestType, 'ZTransform'))
            set(h.Text.Question,'string',h.Question,'FontSize',h.Text.fz.Question);
            set(h.Text.Questionline,'string',h.Questionline,...
                'FontSize',h.Text.fz.Questionline);
            set(h.Text.Questionden,'string',h.Questionden,...
                'FontSize',h.Text.fz.Questionden);
        elseif strcmp(h.TestType, 'Sampling')
            set(h.Text.Questionden, 'string',h.Questionden ,...
                'FontSize',h.Text.fz.Questionden);
        end
        
        set(h.Text.Title,'string',h.Title);
        h.time.start = clock;
        h.time.limit = h.time.MAX;
        h.time.displayed = 0;
        set(h.Text.Timer,'string','TIMER: 0 secs');
        GRAN = 10;
        
        % Update Clock in steps of 0.1 secs
        while(h.time.displayed<h.time.limit)
            h.time.displayed = round(GRAN*etime(clock,h.time.start))/GRAN;
            cltxt = sprintf('TIMER: %3.1f secs',h.time.displayed);
            set(h.Text.Timer,'string',cltxt,'visible','on');
            %drawnow
            set(gcbf,'UserData',h);
            ttt = 0;
            while(ttt<(1/GRAN))
                drawnow
                ttt = etime(clock,h.time.start) - h.time.displayed;
                drawnow
            end
            h = get(gcbf,'UserData');
        end
        set(gcbf,'UserData',h);
        
        %-----------------------------------------------------------
    case 'StopTimer'
        %-----------------------------------------------------------
        if h.Running
            h.time.limit = h.time.displayed-1;
            h.Running = 0;
            h.ShowAnswer = 0;
        end
        set(h.Text.Answer,'string',['Press ''Show Answer'' for solution',h.cr,...
            'or ''New Question'' for next question'],...
            'FontSize',h.Text.fz.Tiny);
        set(gcbf,'UserData',h);
        
        %-----------------------------------------------------------
    case 'ShowAnswer'
        %-----------------------------------------------------------
        if h.Running | ~h.ShowNew
            return
        end
        
        h.ShowAnswer = 0;
        switch h.TestType
            case 'Complex'
                Alternhandle = findobj(gcbf,'Tag','AlternateAnswers');
                set(Alternhandle,'Visible','off');
            case 'Sinusoid'
                Alternhandle = findobj(gcbf,'Tag','AlternateAnswers');
                set(Alternhandle,'Visible','on');
                set(Alternhandle,'tooltipstring',h.AlternateAnswerString);
            case 'RealPart'
                Alternhandle = findobj(gcbf,'Tag','AlternateAnswers');
                set(Alternhandle,'Visible','on');
                set(Alternhandle,'tooltipstring',h.AlternateAnswerString);
            case 'ZTransform'
                axes(h.Zplane.Area);
                set(h.Zplane.Area,'Visible','on');
                h.Answer = '';
                set(h.Text.Answer,'string',h.Answer,'FontSize',h.Text.fz.Answer);
                set(h.Zplane.Area,'nextplot','add');
                set(get(h.Zplane.Area,'Parent'),'nextplot','add');
                % zzplane is a modified version of 'zplane' used with dspfirst
                [hz,hp] = zzplane(h.zeros,h.poles);
                set(h.Zplane.Area,'nextplot','replace');
                set(get(h.Zplane.Area,'Parent'),'nextplot','replace');
                set(hz, 'color','r');
                set(hp, 'color','k');
            otherwise
                %     Alternhandle = findobj(gcbf,'Tag','AlternateAnswers');
                %     set(Alternhandle,'Visible','on');
                %     mystring = h.Answer
                %     set(Alternhandle,'tooltipstring',h.AlternateAnswerString);
        end
        
        % Show Rectangular form of output for 'Complex' test type
        boxhandle = findobj(gcbf,'Tag','ShowRectForm');
        if(strcmp(h.TestType,'ZTransform')~= 1)
            if strcmp(get(boxhandle,'Visible'),'on')
                if(get(boxhandle,'value'))
                    set(h.Text.Answer,'string',h.recAnswer, 'FontSize',h.Text.fz.Answer);
                else
                    set(h.Text.Answer,'string',h.Answer,'FontSize',h.Text.fz.Answer);
                end
            else
                set(h.Text.Answer,'string',h.Answer,'FontSize',h.Text.fz.Answer);
            end
        end
        
        %-----------------------------------------------------------
    case 'NewQuestion'
        %-----------------------------------------------------------
        if h.Running
            return
        else
            h.ShowNew = 0;
        end
        
        set(get(h.Zplane.Area,'children'),'visible','off');
        set(h.Zplane.Area,'visible','off');
        strOps = {'Complex','Sinusoid','RealPart','Spectrum',...
            'Sampling','ZTransform','All'};
        h.Questionline = '';
        h.Questionden = '';
        set(h.Text.Questionline, 'string',h.Questionline,...
            'FontSize',h.Text.fz.Question);
        set(h.Text.Questionden, 'string',h.Questionden,...
            'FontSize',h.Text.fz.Question);
        h.TestType = strOps{get(h.Popup.TestType,'value')};
        if strcmp(h.TestType,strOps{end})
            h.TestType = strOps{floor((length(strOps)-1.01)*rand)+1};
        end
        
        phasecounter = 0;
        
        switch h.TestType
            case 'Complex'
                Answers.r     = [0.5:1.1, 1.5, 2];
                Answers.theta = [pi/4*(-5:2:5), pi/10*(-21:17)];
                %code added
                boxhandle = findobj(gcbf,'Tag','ShowRectForm');
                set(boxhandle,'Visible','on');
                
            case 'Sinusoid'
                Answers.r     = [0.5:1.1, 1.5, 2];
                Answers.theta = pi/(10)*[-21:-1,1:15];
                boxhandle = findobj(gcbf,'Tag','ShowRectForm');
                set(boxhandle,'Visible','off');
                
            otherwise
                Answers.r     = [0.5:1.1, 1.5, 2];
                Answers.theta = pi/(10)*[-21:-1,1:15];
                boxhandle = findobj(gcbf,'Tag','ShowRectForm');
                set(boxhandle,'Visible','off');
                
        end
        
        % Check for Userlevel and set this values for 'Novice'
        if strcmp(h.UserLevel, 'Novice')
            Answers.r     = [1:.5:3];
            Answers.theta = [pi/6 pi/4 pi/3 pi/2 pi 2*pi];
        end
        
        h = newquestion(h, Answers);
        
        sz1 = polarformstring(h.z1);
        sz2 = polarformstring(h.z2);
        
        %h.Tsampling = [0 0];
        sAns = polarformstring(h.z3.Add);
        % xxx This is only for 'Sampling'
        for kk=1:2
            if rand>0.5
                freqvalue1 = round(8.9*rand+0.51);
                mu1 = 1/(2*freqvalue1);
                sigma1 = .05*mu1;
                h.Tsampling{kk} = mu1-sigma1*randn; %normrnd(mu1,sigma1,1,1);
                h.wt{kk} = [num2str(freqvalue1,2),'\pi{t}'];
                h.wtdiscrete{kk} = [num2str(h.Tsampling{kk}*freqvalue1,2),'\pi{n}'];
                if(kk==1)
                    h.randsamp = 1;
                else
                    h.randsamp = 2;
                end
            else
                freqvalue = round(98.9*rand+0.51);
                mu = 1/(2*freqvalue);
                sigma = .2*mu;
                h.Tsampling{kk} =  mu-sigma*randn; %normrnd(mu,sigma,1,1);
                h.wt{kk} = [num2str(freqvalue, 2),'{t}'];
                h.wtdiscrete{kk} = [num2str(h.Tsampling{kk}*freqvalue,2),'{n}'];
            end
            
        end
        
        switch h.TestType
            case 'Complex'
                h.Title = 'Complex: Adding Complex Amplitudes';
                h.Question = [expformstring(sz1.Mag,sz1.Phi),...
                    ' + ',expformstring(sz2.Mag,sz2.Phi)];
                h.recQuestion = [rectformstring(h.z1,3),...
                    ' + ',rectformstring(h.z2,3)];
                h.recQuestion = strrep(h.recQuestion, '+-','-');
                h.recQuestion = strrep(h.recQuestion, '+ -','-');
                h.Answer = [expformstring(sAns.Mag,sAns.Phi),...
                    '  or, ',expformstring(sAns.Mag,sAns.PhiRad)];
                %mycode
                rect_form_ans = h.z1.xy + h.z2.xy;
                h.recAnswer = [rectformstring(rect_form_ans,3)];
                
            case 'Sinusoid'
                h.Title = 'Sinusoid: Adding Sinusoids';
                h.Question = [cosformstring(sz1.Mag,sz1.Phi,h.wt{1}),...
                    ' + ...', h.cr, cosformstring(sz2.Mag,sz2.Phi,h.wt{1})];
                h.Question = strrep(h.Question, '+-','-');
                h.Question = strrep(h.Question, '+ -','-');
                h.Answer = {cosformstring(sAns.Mag,sAns.Phi,h.wt{1}),...
                    ['  or ',cosformstring(sAns.Mag,sAns.PhiRad,h.wt{1})]};
                
                for I=1:5,
                    % h.z1 = h.z1.theta +2*pi;
                    newangle = (angle(h.z3.Add)+2*pi*I)/pi;
                    sAns.Phi = [num2str(newangle,2),'\','pi'];
                    %  justtesting = sAns.Phi
                    h.AltAnswer(I) = {cosformstring(sAns.Mag,sAns.Phi,h.wt{1})};
                    h.AlternateAnswerString = [cosformstring(sAns.Mag,sAns.Phi,h.wt{1})];
                    
                end
                
            case {'Spectrum'}
                cosQuestion = rand>0.5;
                plusDC = rand>0.5;
                hDC = num2str(round(20*rand+1));
                if cosQuestion
                    h.Title = 'Spectrum: Write in exponential form';
                    h.Question = cosformstring(sz1.Mag,sz1.Phi,h.wt{1});
                    if plusDC, h.Question = [hDC,' + ',h.Question];  end
                    h.z1.r = h.z1.r/2;
                    h.z1.theta = angle(h.z1.xy);;
                    sz1h = polarformstring(h.z1, 2);
                    h.z1.theta = -h.z1.theta;
                    sz1hc = polarformstring(h.z1, 2);
                    h.Answer = [expformstring(sz1h.Mag,sz1h.Phi,h.wt{1}),' + ',...
                        expformstring(sz1hc.Mag,sz1hc.Phi,['-',h.wt{1}])];
                    if plusDC, h.Answer = [hDC,' + ',h.Answer];  end
                    
                    %********************for alternate answers*****************************
                    %for I=1:5,
                    % h.z1 = h.z1.theta +2*pi;
                    %newangle = (h.z1.theta+2*pi*I)/pi;
                    %sAns.Phi = [num2str(newangle),'\','pi'];
                    %justtesting = sAns.Phi;
                    %h.AltAnswer(I) = [cosformstring(sAns.Mag,sAns.Phi,h.wt{1})]
                    %h.AlternateAnswerString = [cosformstring(sAns.Mag,sAns.Phi,h.wt{1})];
                    %end
                    %*************************end for alternate answers********************
                else
                    h.Title = 'Spectrum: Reduce to cosine form';
                    h.z1.r = h.z1.r/2;
                    sz1h = polarformstring(h.z1, 2);
                    h.z1.theta = -h.z1.theta;
                    sz1hc = polarformstring(h.z1, 2);
                    h.Question = [expformstring(sz1h.Mag,sz1h.Phi,h.wt{1}),' + ...',h.cr,...
                        expformstring(sz1hc.Mag,sz1hc.Phi,['-',h.wt{1}])];
                    h.Question = strrep(h.Question, '+-', '-');
                    if plusDC, h.Question = [hDC,' + ',h.Question];  end
                    h.z1.r = 2*h.z1.r;
                    h.z1.theta = angle(h.z1.xy);
                    sz1h = polarformstring(h.z1, 2);
                    h.Answer = [cosformstring(sz1h.Mag,sz1h.Phi,h.wt{1})];
                    if plusDC, h.Answer = [hDC,' + ',h.Answer];  end
                    h.Answer = strrep(h.Answer, '+ -', '- ');
                    
                    %********************for alternate answers*****************************
                    %for I=1:5,
                    % h.z1 = h.z1.theta +2*pi;
                    %newangle = (angle(h.z1.theta)+2*pi*I)/pi;
                    %sAns.Phi = [num2str(newangle),'\','pi'];
                    %  justtesting = sAns.Phi
                    %h.AltAnswer(I) = [cosformstring(sAns.Mag,sAns.Phi,h.wt{1})]
                    %h.AlternateAnswerString = [cosformstring(sAns.Mag,sAns.Phi,h.wt{1})];
                    %end
                    %*************************end for alternate answers********************
                    
                end
                h.Text.fz.Question = h.Text.fz.Small;
                h.Text.fz.Answer = h.Text.fz.Small;
                
            case{'Sampling'}
                
                h.Title = 'Sampling: Find x[n] after C/D conversion';
                
                h.Question = ['x(t) = ', ...
                    cosformstring(sz1.Mag,sz1.Phi,h.wt{h.randsamp}),', '];
                h.Questionden = ['T_{s} = ',num2str(h.Tsampling{h.randsamp}, 3)];
                % For 'Pro' display fs instead of Ts
                if strcmp(h.UserLevel, 'Pro')
                    if rand > 0.5
                        h.Question = ['x(t) = ', ...
                            cosformstring(sz1.Mag,sz1.Phi,h.wt{h.randsamp}),', '];
                        h.Questionden = ['f_{s} = ',num2str(1/h.Tsampling{h.randsamp}, 3)];
                    end
                end
                %if plusDC, h.Question = [hDC,' + ',h.Question];  end
                h.z1.r = h.z1.r/2;
                h.z1.theta = angle(h.z1.xy);
                sz1h = polarformstring(h.z1, 2);
                h.z1.theta = -h.z1.theta;
                sz1hc = polarformstring(h.z1, 2);
                h.Answer = ['x[n] = ' cosformstring(sz1.Mag, sz1.Phi, ...
                    h.wtdiscrete{h.randsamp})];
                
                
            case {'ZTransform'}
                h.Title = 'Z-Transform: Plot poles and zeros on z-plane';
                
                switch h.UserLevel
                    case 'Pro'
                        %a = [1, -1.2, 0.9];
                        %b = [0,2,0,0,-3];
                        asize = ceil(6*rand(1,1));
                        bsize = ceil(6*rand(1,1));
                        
                        if ((asize >3)|(bsize > 3)|(asize == 1))
                            asize = 3;
                            bsize = 3;
                        end
                        
                        % Degree of Numerator(zeros) <= Degree of Denmintor (poles)
                        if bsize > asize
                            bsize = bsize -1;
                        end
                        
                        a = ceil(2*rand(1,asize));
                        b = ceil(2*rand(1,bsize));
                        % Make sure that, all poles and zeros overlay each other
                        if isequal(a,b) | isequal(a,2*b) | isequal(2*a,b)
                            if asize ~= 3
                                asize = asize +1;
                                a = ceil(2*rand(1,asize));
                            else
                                bsize = bsize - 1;
                                b = ceil(2*rand(1,bsize));
                            end
                        end
                        
                    case 'Novice'
                        choice_ab = {[1] [1 1] [1 -1] [1 2 1] [1 -2 1] [1 0 1] [1 0 -1]};
                        bs = ceil(7*rand(1,1));
                        as = ceil(6*rand(1,1))+1;
                        b = choice_ab{bs};
                        a = choice_ab{as};
                        % Degree of Numerator(zeros) <= Degree of Denmintor (poles)
                        if size(b,2) > size(a,2)
                            bs = ceil(3*rand(1,1));
                            b = choice_ab{bs};
                        end
                        % Pole/Zero pair loction are not allowed to be same
                        if isequal(a,b)
                            if as ~= length(choice_ab)
                                a = choice_ab{as+1};
                            else
                                b = choice_ab{bs-1};
                            end
                        end
                        
                        asize = size(find(a~=0),2);
                        bsize = size(find(b~=0),2);
                        
                    otherwise
                        error(['Unkown User-level provided:' h.UserLevel]);
                end
                
                
                sb = [zpolystr(b)];
                sa = [zpolystr(a)];
                
                if(asize == 3)
                    sa = ['  ' zpolystr(a)];
                elseif (asize == 2)
                    sa = [ '' zpolystr(a)];
                elseif (asize == 1)
                    sa = [ ''  zpolystr(a)];
                end
                
                if(bsize == 3)
                    sb = ['  ' zpolystr(b)];
                elseif (bsize == 2)
                    sb = [ '' zpolystr(b)];
                elseif (bsize == 1)
                    sb = [ ''  zpolystr(b)];
                end
                h.Questionden = sa;
                
                h.Question = sb;
                %set(h.Question, 'string',sb);
                if asize==3 | bsize==3
                    h.Questionline = '---------------------';
                else
                    h.Questionline = '------------';
                end
                %h.Questionline = line([0.5 0.5],[0.5 0.5]);
                h.poles = roots(a);
                h.zeros = roots(b);
                
                
            case {'RealPart'}
                h.Title = 'Real Part: Simplify to cosine';
                h.Answer = [cosformstring(sz2.Mag,sz2.Phi,h.wt{1})];
                h.Question = ['\Re\{(',...
                    strrep(rectformstring(h.z2,3),'j*','j'),')',...
                    expformstring('1','0',h.wt{1}),'\}'];
                
                
                %********************for alternate answers*******************************
                
                for I=1:5,
                    % h.z1 = h.z1.theta +2*pi;
                    newangle = (h.z2.theta + 2*pi*(I-3))/pi;
                    sAns.Phi = [num2str(newangle, 2),'\','pi'];
                    %  justtesting = sAns.Phi
                    h.AltAnswer(I) = {cosformstring(sz2.Mag,sAns.Phi,h.wt{1})};
                    h.AlternateAnswerString = [cosformstring(sz2.Mag,sAns.Phi,h.wt{1})];
                    
                end
                
                %*************************end for alternate answers *********************
                
            otherwise
                h.Title = 'ERROR';
                h.Question = 'ERROR';
                h.Answer = 'ERROR';
        end
        
        Alternhandle = findobj(gcbf,'Tag','AlternateAnswers');
        set(Alternhandle,'Visible','off');
        set(Alternhandle,'String','Alternate Answers');
        
        h.time.limit = h.time.MAX;
        
        set(h.Text.Timer,'string','TIMER: 0 secs');
        set(h.Text.Title,'string',h.Title);
        % set(h.Text.Question,'string','Ready to Start Timer');
        set(h.Text.Question,'string',['Press ''Start Timer'' for next question'],...
            'FontSize',h.Text.fz.Tiny);
        set(h.Text.Answer,'string','Answer after Stop Timer',...
            'FontSize',h.Text.fz.Tiny);
        set( gcbf, 'UserData', h );
        
        %-----------------------------------------------------------
    case 'ShowRectForm'
        %------------------------------------------------------------
        
        if ~h.ShowNew
            return
        end
        
        if(get(gcbo,'Value'))
            set(h.Text.Question,'string',h.recQuestion,'FontSize',h.Text.fz.Question );
        else
            set(h.Text.Question,'string',h.Question,'FontSize',h.Text.fz.Question);
        end
        
        if h.Running | ~h.ShowNew
            return
        end
        
        if ~h.ShowAnswer
            if(get(gcbo,'Value'))
                set(h.Text.Answer,'string',h.recAnswer, 'FontSize',h.Text.fz.Answer);
            else
                set(h.Text.Answer,'string',h.Answer,'FontSize',h.Text.fz.Answer);
            end
            
        end
        
        %------------------------------------------------------------
    case 'AlternateAnswers'
        %------------------------------------------------------------
        
        if h.Running | ~h.ShowNew
            return
        end
        
        h.ShowAnswer = 0;
        
        switch h.TestType
            case 'Complex'
                Alternhandle = findobj(gcbf,'Tag','AlternateAnswers');
                set(Alternhandle,'Visible','off');
                
            otherwise
                Alternhandle = findobj(gcbf,'Tag','AlternateAnswers');
                set(Alternhandle,'Visible','on');
                
        end
        
        %Alternhandle = findobj(gcbf,'Tag','AlternateAnswers');
        %  buttontitle = get(Alternhandle,'String');
        %  if strcmp(buttontitle,'AlternateAnswers')
        %       h.phasecounter = 1;
        %   else
        
        %
        if( phasecounter < 5)
            phasecounter = phasecounter + 1;
        else
            phasecounter = 1;
        end
        set(Alternhandle,'String','Next');
        %set(Alternhandle,'tooltipstring','hello123');
        %set(h.Text.fz.Answer,'tooltipstring','hello123');
        
        theone = phasecounter;
        theone = h.AltAnswer(phasecounter);
        set(h.Text.Answer,'string',h.AltAnswer(phasecounter), ...
            'FontSize',h.Text.fz.Answer);
        %------------------------------------------------------------
    case 'SelectLevel'
        %------------------------------------------------------------
        set(allchild(get(gcbo,'Parent')),'checked','off');
        set(gcbo,'Checked','on');
        h.UserLevel = get(gcbo,'Tag');
        set(gcbf,'UserData',h);
        %------------------------------------------------------------
    case 'Screenshot'
        %------------------------------------------------------------
        screenshotdlg(gcbf);        
        %------------------------------------------------------------
    case 'ShowMenu'
        %------------------------------------------------------------
        check = get(gcbo,'Checked');
        if strcmp(check,'off')
            set(gcbf,'MenuBar','figure');
            set(gcbo,'Checked','On');
        else
            set(gcbf,'MenuBar','none');
            set(gcbo,'Checked','Off');
        end
        %------------------------------------------------------------
    case 'Help'
        %------------------------------------------------------------
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
                    'which is located in the DConvDemo help directory.'};
                errordlg(s,'Error launching browser.');
        end      
        %------------------------------------------------------------
    case 'CloseRequestFcn'
        %------------------------------------------------------------
        delete(gcbf);
        
        %------------------------------------------------------------
    otherwise
        %------------------------------------------------------------
        error('Unknown action string,')
end


% endfunction phrace
