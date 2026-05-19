function dltidemo(action)

% Last Update: 15-Feb-2018
%   : Revision history contained in readme.m file

% This GUI is written by Budiyanto Junus for EE4902 (special topic course)
% under Professor James McClellan.
%
% Acknowledgement:
%  I would like to thank Jordan Rosenthal for all his assistance in
%  writing this GUI. I used and modified some of the functions he wrote.
%
% Budiyanto Junus, Winter 1999

%--------------------------------------------------------------------------------------
% NOTE: The GUI layout provided by LTIGUI uses character units to be platform
%       independent.  DLTIDEMO calls LTIGUI to provide the basic GUI layout and then
%       changes all units/fontunits to normalized to provide accurate resizing response.
%       The actual response to a resize operation depends on the Matlab version (see
%       the comments in the 'ResizeFcn' case).
%
%       Because of the changes made by DLTIDEMO to the layout from LTIGUI, the
%       GUIDE layout tool should NOT be used on the figure created by DLTIDEMO.  When
%       using the GUIDE tool for GUI layout, run LTIGUI directly and keep all units
%       as characters.
%
%       The font setup in LTIGUI is overriden by DLTIDEMO as well, so when making font
%       changes, it will be necessary to change the settings in the SETUPFONTS file.
%
%       - Jordan Rosenthal
%--------------------------------------------------------------------------------------

NO = 0; YES = 1;
if nargin == 0
    action = 'Initialize';
else
    h = getappdata(gcbf, 'Handles');
    mt = getappdata(gcbf,'movietoolData');
    if ~isempty(mt), pre_callbackAction(mt,action,gcbo,[],h); end
end

switch action
    %--------------------------------------------------------------------------------------
    case 'Initialize'
        %--------------------------------------------------------------------------------------

        %---  Check the installation, the Matlab Version, and the Screen Size  ---%
        errCmd = 'errordlg(lasterr,''Error Initializing Figure''); error(lasterr);';
        cmdCheck1 = 'installcheck;';
        cmdCheck2 = 'h.MATLABVER = versioncheck(5.1);';
        cmdCheck3 = 'screensizecheck([800 600]);';
        cmdCheck4 = ['adjustpath(''' mfilename ''');'];
        eval(cmdCheck1,errCmd);       % Simple installation check
        eval(cmdCheck2,errCmd);       % Check Matlab Version
        eval(cmdCheck3,errCmd);       % Check Screen Size
        eval(cmdCheck4,errCmd);       % Adjust path if necessary

        %---  Set up GUI  ---%
        if h.MATLABVER == 5.1
            gui51;
        else
            gui;
        end
        strVersion = '2.77';           % Version string for figure title
        set(gcf, 'Name', ['Discrete LTI (Linear Time Invariant) System Demo ver ' strVersion]);
        h.LineWidth = 2.0;
        h.FigPos = get(gcf,'Pos');

        SCALE = getfontscale;          % Platform dependent code to determine SCALE parameter
        setfonts(gcf,SCALE);           % Setup fonts: override default fonts used in ltigui
        configresize(gcf);             % Change all 'units'/'font units' to normalized

        h = gethandles(h);             % Get GUI graphic handles
        h = defaultplots(h);           % Create default plots

        if h.MATLABVER >= 6.0
            % ===== Movie-Tool call ========
            movietool('Initialize',gcf,mfilename,0.1);
            % ==============================
        end

        set(h.Text.Freq, 'String', ['Frequency = 2\pi (' num2str(h.Freq,3) ')']);

        setappdata(gcf, 'Handles', h);   % Store handles as new userproperty
        set(gcf,'HandleVisibility','callback');    % Make figure inaccessible from command line

        %--------------------------------------------------------------------------------------
    case 'SetFigureSize'
        %--------------------------------------------------------------------------------------
        % Center figure on screen
        OldUnits = get([0; gcf], 'units');
        set([0; gcf],'units','pixels');
        ScreenSize = get(0,'ScreenSize');
        FigPos = get(gcf,'Position');
        newFigPos = [ (ScreenSize(3)-FigPos(3))/2  (ScreenSize(4)-FigPos(4))/2  FigPos(3:4) ];
        set(gcf,'Pos',newFigPos);
        set([0; gcf],{'units'},OldUnits);

        %--------------------------------------------------------------------------------------
    case 'ResizeFcn'
        %--------------------------------------------------------------------------------------
        % Fix for bugs in normalized fontunits in Matlab 5.2.  Force constant figure aspect ratio
        % if in Matlab 5.3.
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
        sethandles(h,'FigPos',FigPos);                  % Store old position

        %--------------------------------------------------------------------------------------
    case {'ChangeAmpE','ChangeAmpS'}
        %--------------------------------------------------------------------------------------
        if h.MATLABVER<8.4
           co = get(gcbf,'CurrentObject');
        else
           co = gcbo;
        end
        Tag = get(co, 'Tag');
        MAKECHANGE = YES;

        if strcmp(Tag, 'SAmplitude')
            h.Amp = get(co, 'Value');
        else
            NewAmp = str2num(get(co, 'String'));
            if ( NewAmp < get(h.Slider.Amp,'Min') ) ...
                    | (NewAmp > get(h.Slider.Amp,'Max'))
                set(co,'String',num2str(h.Amp,3));
                MAKECHANGE = NO;
            else
                h.Amp = NewAmp;
            end
        end
        if MAKECHANGE
            set(h.Edit.Amp, 'String', num2str(h.Amp,3));
            set(h.Slider.Amp, 'Value', h.Amp);
            set(h.Text.Amp, 'String', ['Amplitude = ' num2str(h.Amp,3)]);
            set(h.Text.InputTitle, 'String',...
                cosinestring(h.Amp, 2*h.Freq, h.Phase, 0, h.DC));
            setappdata(gcbf,'Handles',h);
            changeplots(h);
        end
        %--------------------------------------------------------------------------------------
    case {'ChangeDCE','ChangeDCS'}
        %--------------------------------------------------------------------------------------
        if h.MATLABVER<8.4
            co = get(gcbf,'CurrentObject');
        else
            co = gcbo;
        end
        Tag = get(co, 'Tag');
        MAKECHANGE = YES;

        if strcmp(Tag, 'SDC')
            h.DC = get(co, 'Value');
        else
            NewDC = str2num(get(co, 'String'));
            if ( NewDC < get(h.Slider.DC,'Min') ) ...
                    | (NewDC > get(h.Slider.DC,'Max'))
                set(co,'String',num2str(h.DC,3));
                MAKECHANGE = NO;
            else
                h.DC = NewDC;
            end
        end
        if abs(h.DC) <= 1e-7
            h.DC = 0;
        end
        if MAKECHANGE
            set(h.Edit.DC, 'String', num2str(h.DC,3));
            set(h.Slider.DC, 'Value', h.DC);
            set(h.Text.DC, 'String', ['DC Level = ' num2str(h.DC,3)]);
            set(h.Text.InputTitle, 'String',...
                cosinestring(h.Amp, 2*h.Freq, h.Phase, 0, h.DC));
            setappdata(gcbf,'Handles',h);
            changeplots(h);
        end

        %--------------------------------------------------------------------------------------
    case {'ChangeFreqE','ChangeFreqS'}
        %--------------------------------------------------------------------------------------
        if h.MATLABVER<8.4
           co = get(gcbf,'CurrentObject');
        else
           co = gcbo;
        end
        Tag = get(co, 'Tag');
        MAKECHANGE = YES;

        if strcmp(Tag,'SFreq')
            NewFreq = get(co, 'Value');
        else
            NewFreq = str2num(get(co, 'String'));
            if ( NewFreq < get(h.Slider.Freq,'Min') ) ...
                    | (NewFreq > get(h.Slider.Freq,'Max'))
                set(co,'String',num2str(h.Freq,3));
                MAKECHANGE = NO;
            end
        end

        h.Freq = NewFreq;

        if abs(h.Freq) <= 1e-7
            h.Freq = 0;
        elseif abs(1-h.Freq) < 1e-7
            h.Freq = 1;
        end

        if MAKECHANGE

            set(h.Edit.Freq, 'String', num2str(h.Freq,3));
            set(h.Slider.Freq, 'Value', h.Freq);

            if h.Freq == 0
                set(h.Text.Freq,'string','Frequency = 0');
            elseif h.Freq == 1
                set(h.Text.Freq, 'String','Frequency = 2\pi');
            else
                set(h.Text.Freq, 'String', ['Frequency = 2\pi (' num2str(h.Freq,3) ')']);
            end

            set(h.Text.InputTitle, 'String', cosinestring(h.Amp, 2*h.Freq, h.Phase, 0, h.DC));
            setappdata(gcbf,'Handles',h);
            changeplots(h);
        end
        %--------------------------------------------------------------------------------------
    case {'ChangePhaseE','ChangePhaseS'}
        %--------------------------------------------------------------------------------------
        if h.MATLABVER<8.4
           co = get(gcbf,'CurrentObject');
        else
           co = gcbo;
        end
        Tag = get(co, 'Tag');
        MAKECHANGE = YES;

        if strcmp(Tag, 'SPhase')
            h.Phase = get(co, 'Value');
        else
            NewPhase = str2num(get(co, 'String'));
            if ( NewPhase < get(h.Slider.Phase,'Min') ) ...
                    | (NewPhase > get(h.Slider.Phase,'Max'))
                set(co,'String',num2str(h.Phase,3));
                MAKECHANGE = NO;
            else
                h.Phase = NewPhase;
            end
        end

        if abs(h.Phase) <= 1e-7
            h.Phase = 0;
        elseif abs(1-h.Phase) < 1e-7
            h.Phase = 1;
        elseif abs(1+h.Phase) < 1e-7
            h.Phase = -1;
        end

        if MAKECHANGE
            set(h.Edit.Phase, 'String', num2str(h.Phase,3));
            set(h.Slider.Phase, 'Value', h.Phase);

            if h.Phase == 0
                set(h.Text.Phase, 'String','Phase = 0');
            elseif h.Phase == 1
                set(h.Text.Phase, 'String','Phase = \pi');
            elseif h.Phase == -1
                set(h.Text.Phase, 'String','Phase = -\pi');
            else
                set(h.Text.Phase, 'String', ['Phase = ' num2str(h.Phase,3) ' \pi']);
            end

            set(h.Text.InputTitle, 'String',...
                cosinestring(h.Amp, 2*h.Freq, h.Phase, 0, h.DC));
            setappdata(gcbf,'Handles',h);
            changeplots(h);
        end
        %--------------------------------------------------------------------------------------
    case 'FilterChoice'
        %--------------------------------------------------------------------------------------
        if h.MATLABVER<8.4
           co = get(gcbf,'CurrentObject');
        else
           co = gcbo;
        end
        h.PopUpValue = get(co, 'Value');

        if any(h.PopUpValue == (3:8))
            set(h.Slider.FilterFreq1, 'Min', 0.01, 'Max', 0.4);
            set(h.UserhnGroup, 'Visible', 'Off');
            set(h.FilterSpecs, 'Visible', 'On');
            set(h.PhaseGroup, 'Visible', 'Off');
            set(h.Slider.Averager, 'Visible', 'Off');
            set(h.Edit.FilterFreq1, 'CallBack', [ mfilename ' FilterFreq1E']);
            set(h.Edit.FilterFreq1, 'String', num2str(h.Filter.Freq1,3));
            set(h.Slider.FilterFreq1, 'Value', h.Filter.Freq1);
            set(h.Text.FilterFreq1, 'String', ['Cutoff Freq = 2\pi (' num2str(h.Filter.Freq1,3) ')']);
            if any(h.PopUpValue==[5 8])
                set(h.Text.FilterFreq1, 'String', ['Center Freq = 2\pi (' num2str(h.Filter.Freq1,3) ')']);
            end

            if any(h.PopUpValue == [5,7,8])
                set(h.Slider.FilterFreq1, 'Min', 0.18, 'Max', 0.38);
                if h.PopUpValue == 5
                    set(h.PhaseGroup, 'Visible', 'On');
                end
                if h.Filter.Freq1 < 0.18 | h.Filter.Freq1 > 0.38
                    h.Filter.Freq1 = 0.25;
                    set(h.Edit.FilterFreq1, 'String', num2str(h.Filter.Freq1,3));
                    set(h.Slider.FilterFreq1, 'Value', h.Filter.Freq1);
                    set(h.Text.FilterFreq1, 'String', ['Cutoff Freq = 2\pi (' num2str(h.Filter.Freq1,3) ')']);
                    if any(h.PopUpValue==[5 8])
                        set(h.Text.FilterFreq1, 'String', ['Center Freq = 2\pi (' num2str(h.Filter.Freq1,3) ')']);
                    end
                end
            else
                set(h.Slider.FilterFreq1, 'Min', 0.01, 'Max', 0.4);
            end

            if any(h.PopUpValue == [6,7,8])
                h.Filter.ImpResp = FIRFilter(h);
                h.Filter.FFT = [ ];
            elseif any(h.PopUpValue == [3,4,5])
                set(h.PhaseGroup, 'Visible', 'On');
                if abs(h.Filter.PhaseShift) < 1e-7
                    set(h.Text.FilterPhase, 'String','Phase Slope = 0');
                elseif abs(1-h.Filter.PhaseShift) < 1e-7
                    set(h.Text.FilterPhase, 'String','Phase Slope = 1');
                elseif abs(1+h.Filter.PhaseShift) < 1e-7
                    set(h.Text.FilterPhase, 'String','Phase Slope = -1');
                else
                    set(h.Text.FilterPhase, 'String', ['Phase Slope = ' num2str(h.Filter.PhaseShift,3)]);
                end
                [h.Filter.Range, h.Filter.FFT] = IdealFilter(h);
            end

        elseif h.PopUpValue==1
            set(h.UserhnGroup, 'Visible', 'Off');
            set(h.PhaseGroup, 'Visible', 'Off');
            set(h.AveragerGroup, 'Visible', 'On');
            set(h.Slider.FilterFreq1,'Visible','off');
            set(h.Edit.FilterFreq1, 'CallBack', [mfilename ' AveragerLengthE']);
            set(h.Edit.FilterFreq1, 'String', num2str(h.Averager.Length,3));
            set(h.Slider.Averager, 'Value', h.Averager.Length);
            set(h.Text.FilterFreq1, 'String', ['Length = ' num2str(h.Averager.Length,3) ' pts']);

            h.Filter.ImpResp = [ ones(1, h.Averager.Length) ]/h.Averager.Length;
            h.Filter.FFT = [ ];
        elseif h.PopUpValue==2
            set(h.FilterSpecs, 'Visible', 'Off');
            set(h.UserhnGroup, 'Visible', 'Off');
            set(h.Text.FilterFreq1, 'String', 'b\_k = [0.5, -0.5]');
            set(h.Text.FilterFreq1, 'Visible', 'On');
            h.Filter.ImpResp = [ 0.5  -0.5 ];
            h.Filter.FFT = [ ];
        elseif h.PopUpValue==9
            set(h.FilterSpecs, 'Visible', 'Off');
            set(h.Text.FilterFreq1, 'String', 'Filter Coeffs: b\_k');
            set(h.Edit.bk, 'String', h.Filter.bk);
            eval( ['h.Filter.ImpResp = ',h.Filter.bk,';']);
            h.Filter.FFT = [ ];
            set(h.UserhnGroup, 'Visible', 'On');
        end

        setappdata(gcbf,'Handles',h);
        changeplots(h);

        %--------------------------------------------------------------------------------------
    case 'Userhn'
        %--------------------------------------------------------------------------------------
        if h.MATLABVER<8.4
           co = get(gcbf,'CurrentObject');
        else
           co = gcbo;
        end
        Tag = get(co, 'Tag');
        h.Filter.bk = get(co, 'String');
        set(h.Edit.bk, 'String', h.Filter.bk);
        eval( ['h.Filter.ImpResp = ',h.Filter.bk,';']);
        h.Filter.FFT = [ ];
        setappdata(gcbf,'Handles',h);
        changeplots(h);

        %--------------------------------------------------------------------------------------
    case {'FilterFreq1E','FilterFreq1S'}
        %--------------------------------------------------------------------------------------
        if h.MATLABVER<8.4
           co = get(gcbf,'CurrentObject');
        else
           co = gcbo;
        end
        Tag = get(co, 'Tag');
        if any(h.PopUpValue==(3:8))
            MAKECHANGE = YES;

            if strcmp(Tag, 'FilterSFreq1')
                h.Filter.Freq1 = get(co, 'Value');
            else
                NewFreq = str2num(get(co, 'String'));
                if ( NewFreq < get(h.Slider.FilterFreq1,'Min') ) ...
                        | (NewFreq > get(h.Slider.FilterFreq1,'Max'))
                    set(co,'String',num2str(h.Filter.Freq1,3));
                    MAKECHANGE = NO;
                else
                    h.Filter.Freq1 = NewFreq;
                end
            end

            if abs(h.Filter.Freq1) <= 1e-10
                h.Filter.Freq1 = 0;
            end

            if MAKECHANGE
                set(h.Edit.FilterFreq1, 'String', num2str(h.Filter.Freq1,3));
                set(h.Slider.FilterFreq1, 'Value', h.Filter.Freq1);
                set(h.Text.FilterFreq1, 'String', ['Cutoff Freq = 2\pi (' num2str(h.Filter.Freq1,3) ')']);
                if any(h.PopUpValue==[5 8])
                    set(h.Text.FilterFreq1, 'String', ['Center Freq = 2\pi (' num2str(h.Filter.Freq1,3) ')']);
                end
                if any(h.PopUpValue==[6,7,8])
                    h.Filter.ImpResp = FIRFilter(h);
                    h.Filter.FFT = [ ];
                elseif any(h.PopUpValue==[3,4,5])
                    [h.Filter.Range, h.Filter.FFT] = IdealFilter(h);
                end

                setappdata(gcbf,'Handles',h);
                changeplots(h);
            end
        end
        %--------------------------------------------------------------------------------------
    case {'FilterPhaseE','FilterPhaseS'}
        %--------------------------------------------------------------------------------------
        if h.MATLABVER<8.4
           co = get(gcbf,'CurrentObject');
        else
           co = gcbo;
        end
        Tag = get(co, 'Tag');
        MAKECHANGE = YES;

        if strcmp(Tag, 'FilterSPhase')
            h.Filter.PhaseShift = get(co, 'Value');
        else
            NewPhase = str2num(get(co, 'String'));
            if ( NewPhase < get(h.Slider.FilterPhase,'Min') ) ...
                    | (NewPhase > get(h.Slider.FilterPhase,'Max'))
                set(co,'String',num2str(h.Filter.PhaseShift,3));
                MAKECHANGE = NO;
            else
                h.Filter.PhaseShift = NewPhase;
            end
        end

        if abs(h.Filter.PhaseShift) <= 1e-10
            h.Filter.PhaseShift = 0;
        end

        if MAKECHANGE
            set(h.Edit.FilterPhase, 'String', num2str(h.Filter.PhaseShift,3));
            set(h.Slider.FilterPhase, 'Value', h.Filter.PhaseShift);
            if abs(h.Filter.PhaseShift) < 1e-7
                set(h.Text.FilterPhase, 'String','Phase Slope = 0');
            elseif abs(1-h.Filter.PhaseShift) < 1e-7
                set(h.Text.FilterPhase, 'String','Phase Slope = 1');
            elseif abs(1+h.Filter.PhaseShift) < 1e-7
                set(h.Text.FilterPhase, 'String','Phase Slope = -1');
            else
                set(h.Text.FilterPhase, 'String', ['Phase Slope = ' num2str(h.Filter.PhaseShift,3)]);
            end
            [h.Filter.Range, h.Filter.FFT] = IdealFilter(h);
            setappdata(gcbf,'Handles',h);
            changeplots(h);
        end

        %--------------------------------------------------------------------------------------
    case {'AveragerLengthE','AveragerLengthS'}
        %--------------------------------------------------------------------------------------
        if h.MATLABVER<8.4
           co = get(gcbf,'CurrentObject');
        else
           co = gcbo;
        end
        Tag = get(co, 'Tag');
        MAKECHANGE = YES;

        if strcmp(Tag, 'AveragerSLength')
            h.Averager.Length = round(get(co, 'Value'));
        else
            NewLength = str2num(get(co, 'String'));
            if ( NewLength < get(h.Slider.Averager,'Min') ) ...
                    | (NewLength > get(h.Slider.Averager,'Max'))
                set(co,'String',num2str(h.Averager.Length,3));
                MAKECHANGE = NO;
            else
                h.Averager.Length = round(NewLength);
            end
        end
        if MAKECHANGE
            set(h.Edit.FilterFreq1, 'String', num2str(h.Averager.Length,3));
            set(h.Slider.Averager, 'Value', h.Averager.Length);
            set(h.Text.FilterFreq1, 'String', ['Length = ' num2str(h.Averager.Length,3) ' pts']);
            h.Filter.ImpResp = [ ones(1, h.Averager.Length) ]/h.Averager.Length;
            h.Filter.FFT = [ ];
            setappdata(gcbf,'Handles',h);
            changeplots(h);
        end
        %--------------------------------------------------------------------------------------
    case 'Answer'
        %--------------------------------------------------------------------------------------
        set(h.Text.OutputTitle, 'String', ...
            cosinestring(h.Output.Mag, 2*h.Freq, h.Output.Phase, 0, h.Output.DC));
        %--------------------------------------------------------------------------------------
    case 'LineWidth'
        %--------------------------------------------------------------------------------------
        h.LineWidth = linewidthdlg(h.LineWidth);
        set(findobj(gcbf, 'Type', 'line'), 'LineWidth', h.LineWidth);
        setappdata(gcbf,'Handles',h);
        %--------------------------------------------------------------------------------------
    case 'Screenshot'
        %--------------------------------------------------------------------------------------
        screenshotdlg(gcbf);        
        %--------------------------------------------------------------------------------------
    case 'ShowMenu'
        %--------------------------------------------------------------------------------------
        check = get(gcbo,'Checked');
        if strcmp(check,'off')
            set(gcbf,'MenuBar','figure');
            set(gcbo,'Checked','On');
        else
            set(gcbf,'MenuBar','none');
            set(gcbo,'Checked','Off');
        end
        %--------------------------------------------------------------------------------------        
    case 'Help'
        %--------------------------------------------------------------------------------------
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
                    'which is located in the DLTIdemo help directory.'};
                errordlg(s,'Error launching browser.');
        end
        %--------------------------------------------------------------------------------------
    case 'CloseRequestFcn'
        %--------------------------------------------------------------------------------------
        delete(gcbf);
        %--------------------------------------------------------------------------------------
    otherwise
        %--------------------------------------------------------------------------------------
        error (['Illegal Action:' action]);
end

if nargin > 0 & ishandle(gcbf)
    h = getappdata(gcbf);
    if ~isempty(mt), post_callbackAction(mt,action,gcbo,[],h); end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%--------------------------------------------------------------------------------------
% FIRFILTER (FIRFILTER DESIGN)
%--------------------------------------------------------------------------------------
function hn = FIRFilter(h)
% FIRFILTER(h) will calculate the impulse response and FFT of
%   the low/high-pass filter for given handle using FIR1 function
%   hn is the impulse response
%
% Budiyanto Junus, 1/20/99

if h.PopUpValue == 6
    % Low Pass Filter
    hn = myfir1(14, 2*h.Filter.Freq1);
elseif h.PopUpValue == 7
    % High Pass Filter
    hn = myfir1(14, 2*h.Filter.Freq1, 'high');
elseif h.PopUpValue == 8
    % Band Pass Filter
    F1 = h.Filter.Freq1 - (h.Filter.BW/2);
    F2 = h.Filter.Freq1 + (h.Filter.BW/2);
    hn = myfir1(20, 2*[F1 F2]);
else
    error('FIR Filter design must be 6, 7, or 8');
end

%--------------------------------------------------------------------------------------
% MYFIR1 (FIRFILTER DESIGN)
%--------------------------------------------------------------------------------------
function hn = myfir1(M,wc,FIR_type)
% MYFIR mimics the MATLAB function called fir1, but it uses the Hamming window
%    instead of the Kaiser window.
%    The length of this filter must be odd, so the order M must be even.
%    The cutoff frequency, wc, is a scalar.
%
% jMcClellan, 17-May-99

if nargin<3,  FIR_type = 'lowpass'; end
if length(wc)==2
    wcenter = sum(wc)/4;
    wc = diff(wc)/2;
    FIR_type = 'bandpass';
end
if strcmp(FIR_type,'high'),  wc = 1.0-wc; end
if rem(M,2)==1
    disp('Making the order even in myfir1')
    M = 2*ceil(M/2)
end
nn = -M/2:M/2;
nn = nn + (nn==0)*1e-8;
hn = sin(pi*wc*nn)./(pi*nn);
hamm = 0.54 + 0.46*cos(2*pi*nn/M);
hn = hamm.*hn;
hn = hn/sum(hn);
if strcmp(lower(FIR_type(1:4)),'high')
    hn = hn .* (-1).^(0:M);
elseif strcmp(FIR_type,'bandpass')
    hn = 2*hn .* cos(2*pi*wcenter*(0:M));
    Hpeak = hn*exp(-j*2*pi*wcenter*(0:M)');
    hn = hn/abs(Hpeak);
end

%--------------------------------------------------------------------------------------
% IDEALFILTER (IDEAL FILTER DESIGN)
%--------------------------------------------------------------------------------------
function [ff,HH] = IdealFilter(h)

f = h.Filter.Freq1;
phaseshift = h.Filter.PhaseShift;

ff = linspace(-0.5,0.5,1001);
TOL = 1e-6;
HH = exp(j*2*pi*ff*phaseshift);

if h.PopUpValue == 3
    % Ideal Low Pass
    HH = HH.*(abs(ff)<=f+TOL);
elseif h.PopUpValue == 4
    % Ideal High Pass
    HH = HH.*(abs(ff)>=f-TOL);
elseif h.PopUpValue == 5
    % Ideal Band Pass
    HH = HH.*(abs(abs(ff)-f)<=0.1+TOL);
else
    error('Ideal Filter must be 3,4, or 5');
end

set(h.FilterMagPlot,{'XData','YData'},{ff, abs(HH)});
set(h.FilterPhasePlot,{'XData','YData'},{ff, angle(HH)});

%--------------------------------------------------------------------------------------
% CHANGEPLOTS
%--------------------------------------------------------------------------------------
function changeplots(h)
tol = 1e6;      % tolerance
% Input Plot
hhin = h.DC + h.Amp*cos(2*pi*h.Freq*h.n + h.Phase*pi);
stemdata(h.n,hhin,[],h.InputPlot);

h.Freqmod = h.Freq; while h.Freqmod>=0.5, h.Freqmod = h.Freqmod-1; end

% Filter Plot
if isempty(h.Filter.FFT)
    [h.Filter.FFT, h.Filter.Range] = ...
        feval(h.Filter.freqzMethod,h.Filter.ImpResp, 1, 512, 'whole');
    h.Filter.Range = h.Filter.Range/2/pi - 0.5;
    h.Filter.FFT =  fftshift(h.Filter.FFT);
end
h.Filter.Mag =  abs(h.Filter.FFT);
h.Filter.Phase =  angle(h.Filter.FFT);
filterplot(h.Filter.Range, h.Filter.Mag, h.FilterMagPlot);
Hmax = max(abs(h.Filter.Mag));
set(get(h.FilterMagPlot,'Parent'),'YLim',[0, max([1,ceil(Hmax-0.05)])+0.1]);
filterplot(h.Filter.Range, h.Filter.Phase, h.FilterPhasePlot);

% Output Plot
[qq,k0] = min(abs(h.Filter.Range));               %<-- find DC
[qq,kMag] = min(abs(h.Filter.Range-h.Freqmod));   %<-- find "positive" freq
[qq,kMag2] = min(abs(h.Filter.Range+h.Freqmod));  %<-- find "negative" freq
if any(h.PopUpValue==[3,4,5])
    h.Output.Mag = h.Filter.Mag(kMag)*h.Amp;  %h.Filter.Range(kMag), h.Freqmod
    h.Output.Phase = h.Filter.Phase(kMag)/pi + h.Phase;
    h.Output.DC = h.Filter.FFT(k0)*h.DC;
else
    HHH = feval(h.Filter.freqzMethod,h.Filter.ImpResp,1,2*pi*[0,h.Freq,-h.Freq]);
    h.Output.Mag = abs(HHH(2))*h.Amp;
    h.Output.Phase = angle(HHH(2))/pi + h.Phase;
    h.Output.DC = real(HHH(1))*h.DC;
end
hhout = h.Output.DC + h.Output.Mag*cos(2*pi*h.Freq*h.n + h.Output.Phase*pi);
stemdata(h.n,hhout,[],h.OutputPlot);

% Calculating and plotting the frequency markers
% NOTE: Need to evaluate the true input frequency value, not one of closest
%       bin values.
if any(h.PopUpValue==[3,4,5])
    FilterMag_0   = h.Filter.Mag(k0);
    FilterPhase_0 = h.Filter.Phase(k0);
    FilterMag_w   = h.Filter.Mag(kMag);
    FilterPhase_w = h.Filter.Phase(kMag);
else
    FilterMag_0   = abs(HHH(1));
    FilterPhase_0 = angle(HHH(1));
    FilterMag_w   = abs(HHH(2));
    FilterPhase_w = angle(HHH(2)).*(FilterMag_w>1e-6);
end

if h.DC~=0
    set(h.Line.FreqMagMark0,{'XData','YData'},{0,FilterMag_0});
    set(h.Line.FreqPMark0,{'XData','YData'},{0,FilterPhase_0});
    set([h.Line.FreqMagMark0,h.Line.FreqPMark0], 'Visible', 'On');
else
    set([h.Line.FreqMagMark0,h.Line.FreqPMark0], 'Visible', 'Off');
end

if h.Freqmod==0 & h.DC~=0
    set([h.Line.FreqMagMark1,h.Line.FreqMagMark2,h.Line.FreqPMark1], 'Visible', 'Off');
else
    set(h.Line.FreqMagMark1, 'Visible','On');
    set(h.Line.FreqMagMark1,{'XData','YData'},{h.Freqmod,FilterMag_w});
    set(h.Line.FreqPMark1, 'Visible','On');
    set(h.Line.FreqPMark1,{'XData','YData'},{h.Freqmod,FilterPhase_w});
    if abs(h.Freq)<1e-5
        set(h.Line.FreqMagMark2, 'Visible','Off');
    else
        set(h.Line.FreqMagMark2, 'Visible','On');
        set(h.Line.FreqMagMark2,{'XData','YData'},{-h.Freqmod,FilterMag_w});
    end
end

% Clearing the Output Title
set(h.Text.OutputTitle, 'String', '');
setappdata(gcbf,'Handles',h);

%--------------------------------------------------------------------------------------
% SETHANDLES
%--------------------------------------------------------------------------------------
function Handles = sethandles(Handles,field,value)
%SETHANDLES
%   Handles = sethandles(Handles,field,value) sets the field to the
%   given value within the structure Handles and then saves the
%   structure in the current figure using setappdata.
%
%   See also setappdata
%
% Jordan Rosenthal

Handles = setfield(Handles,field,value);
setappdata(gcbf, 'Handles', Handles);

%--------------------------------------------------------------------------------------
% FILTERPLOT
%--------------------------------------------------------------------------------------
function filterplot(x,y, hLines)
%FILTERPLOT Create Filter plot
%   FILTERPLOT(x,y,hLines) changes the plot of the filter given by the handles
%   in hLines to the new data x and y.
%
%   The input x and y should be equal length vectors.
% Budiyanto Junus, 1/20/99
% Modified from Jordan Rosenthal's STEMDATA

set(hLines,{'XData','YData'},{x, y});