function cltidemo(action,varargin)

% Last Update: 15-Feb-2018
%   : Revision history contained in readme.m file

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOTE: The GUI layout provided by CLTIGUI uses character units to be
% platform
%       independent.  CLTIDEMO calls CLTIGUI to provide the basic GUI layout
%       and then changes all units/fontunits to normalized to provide accurate
%       resizing response.
%       The actual response to a resize operation depends on the Matlab
%       version
%       (see the comments in the 'ResizeFcn' case).
%
%       Because of the changes made by CLTIDEMO to the layout from CLTIGUI, the
%       GUIDE layout tool should NOT be used on the figure created by CLTIDEMO.
%       When using the GUIDE tool for GUI layout, run CLTIGUI directly and keep
%       all units as characters.
%
%       The font setup in CLTIGUI is overriden by CLTIDEMO as well, so when
%       making font changes, it will be necessary to change the settings in the
%       SETUPFONTS file.
%
%       - Jordan Rosenthal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
NO = 0; YES = 1;
if nargin == 0
    action = 'Initialize';
else
    h = getappdata(gcbf, 'Handles');
    mt = getappdata(gcbf,'movietoolData');
    if ~isempty(mt), pre_callbackAction(mt,action,gcbo,[],h); end
end

switch action
    case 'Initialize'
        strVersion = '2.60';

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

        set(gcf, 'Name', ['CLTI (Linear Time Invariant) System Demo ver ' ,...
            strVersion]);
        % Sets the linewidth of the graph of mag. and phase of filters.
        h.LineWidth = 2.0;
        h.FigPos = get(gcf,'Pos');
        % Platform dependent code to determine SCALE parameter
        SCALE = getfontscale;
        % Setup fonts: override default fonts used in cltigui
        setfonts(gcf,SCALE);
        % Change all 'units'/'font units' to normalized
        configresize(gcf);
        % Get GUI graphic handles
        h = gethandles(h);
        % Create default plots
        h = defaultplots(h);

        if h.MATLABVER >= 6.0
            % ===== Movie-Tool call ========
            movietool('Initialize',gcf,mfilename,0.1);
            % ==============================
        end

        % Store handles as new userproperty
        setappdata(gcf, 'Handles', h);
        % Make figure inaccessible from command line
        set(gcf,'HandleVisibility','callback');
        %==================================
    case 'SetFigureSize'
        % Center figure on screen
        OldUnits = get([0; gcf], 'units');
        set([0; gcf],'units','pixels');
        ScreenSize = get(0,'ScreenSize');
        FigPos = get(gcf,'Position');
        newFigPos = [ (ScreenSize(3)-FigPos(3))/2  ,...
            (ScreenSize(4)-FigPos(4))/2  FigPos(3:4) ];
        set(gcf,'Pos',newFigPos);
        set([0; gcf],{'units'},OldUnits);
        %==================================
    case 'ResizeFcn'
        % Fix for bugs in normalized fontunits in Matlab 5.2.
        % Force constant figure aspect ratio if in Matlab 5.3.
        % Version dependent resize code
        FigPos = resizefcn(h.FigPos,gcbo,h.MATLABVER);
        switch computer
            case 'MAC2'
                % On MAC, baseline of text inside edit boxes remains at same
                % vertical position irregardless of change in font size.
                % To properly align text, here the old edit boxes are deleted
                % and new ones created with the proper size.
                hEd = findall(gcbf,'type','uicontrol','style','edit');
                OldFontUnits = get(hEd,'FontUnits');
                set(hEd,'FontUnits','Pixels');
                
                if h.MATLABVER<8.4
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
        % Store old position
        sethandles(h,'FigPos',FigPos);
        %==================================
    case {'ChangeAmpE','ChangeAmpS'}
        Tag = get(gcbo, 'Tag');
        MAKECHANGE = YES;

        if strcmp(Tag, 'SAmplitude')
            h.Amp = get(gcbo, 'Value');
        else
            NewAmp = str2num(get(gcbo, 'String'));
            if ( NewAmp < get(h.Slider.Amp,'Min') ) ...
                    | (NewAmp > get(h.Slider.Amp,'Max'))
                set(gcbo,'String',num2str(h.Amp,3));
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
                cosinestring(h.Amp, h.Freq, h.Phase, 0, h.DC));
            setappdata(gcbf,'Handles',h);
            changeplots(h);
        end
        %==================================
    case {'ChangeDCE','ChangeDCS'}
        Tag = get(gcbo, 'Tag');
        MAKECHANGE = YES;

        if strcmp(Tag, 'SDC')
            h.DC = get(gcbo, 'Value');
        else
            NewDC = str2num(get(gcbo, 'String'));
            if ( NewDC < get(h.Slider.DC,'Min') ) ...
                    | (NewDC > get(h.Slider.DC,'Max'))
                set(gcbo,'String',num2str(h.DC,3));
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
                cosinestring(h.Amp, h.Freq, h.Phase, 0, h.DC));
            setappdata(gcbf,'Handles',h);
            changeplots(h);
        end
        %==================================
    case {'ChangeFreqE','ChangeFreqS'}      
        Tag = get(gcbo, 'Tag');
        
        MAKECHANGE = YES;

        if strcmp(Tag, 'SFreq')
            NewFreq = get(gcbo, 'Value');
        else
            NewFreq = str2num(get(gcbo, 'String'));
            if ( NewFreq < get(h.Slider.Freq,'Min') ) ...
                    | (NewFreq > get(h.Slider.Freq,'Max'))
                set(gcbo,'String',num2str(h.Freq,3));
                MAKECHANGE = NO;
            end
        end
        h.Freq = NewFreq;

        if abs(h.Freq) <= 1e-7
            h.Freq = 0;
        end
        if MAKECHANGE
            set(h.Edit.Freq, 'String', num2str(h.Freq,3));
            set(h.Slider.Freq, 'Value', h.Freq);
            set(h.Text.Freq, 'String', ['Frequency = ' num2str(h.Freq,3)]);
            set(h.Text.InputTitle, 'String', ...
                cosinestring(h.Amp, h.Freq, h.Phase, 0, h.DC));
            setappdata(gcbf,'Handles',h);
            changeplots(h);
        end
        %==================================
    case {'ChangePhaseE','ChangePhaseS'}
        Tag = get(gcbo, 'Tag');
        MAKECHANGE = YES;

        if strcmp(Tag, 'SPhase')
            h.Phase = get(gcbo, 'Value');
        else
            NewPhase = str2num(get(gcbo, 'String'));
            if ( NewPhase < get(h.Slider.Phase,'Min') ) ...
                    | (NewPhase > get(h.Slider.Phase,'Max'))
                set(gcbo,'String',num2str(h.Phase,3));
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
                cosinestring(h.Amp, h.Freq, h.Phase, 0, h.DC));
            setappdata(gcbf,'Handles',h);
            changeplots(h);
        end
        %==================================
    case 'FilterChoice'
        h.PopUpValue = get(gcbo, 'Value');

        if any(h.PopUpValue == (1:8))
            set(h.Slider.FilterFreq1, 'Min', 0.0, 'Max', 100.0);
            set(h.UserhnGroup, 'Visible', 'Off');
            set(h.FilterSpecs, 'Visible', 'On');
            set(h.PhaseGroup, 'Visible', 'Off');
            set(h.FilterBWGroup, 'Visible', 'Off');
            set(h.Edit.FilterFreq1, 'CallBack', 'cltidemo FilterFreq1E');
            set(h.Edit.FilterFreq1, 'String', num2str(h.Filter.Freq1,3));
            set(h.Slider.FilterFreq1, 'Value', h.Filter.Freq1);
            set(h.Text.FilterFreq1, 'String', ['Cutoff Freq = ' ,...
                num2str(h.Filter.Freq1,3)]);
            %% xxx - Bandpass filter
            if any(h.PopUpValue==[3 4 7 8])
                set(h.Text.FilterFreq1, 'String', ['Center Freq = ' ,...
                    num2str(h.Filter.Freq1,3)]);
                if any(h.PopUpValue == [7 8])
                    set(h.FilterBWGroup, 'Visible', 'On');
                end
            end

            % Bandpass , Highpass
            if any(h.PopUpValue == [3,4,6,7,8])
                set(h.Slider.FilterFreq1, 'Min', 20, 'Max', 100);
                if any(h.PopUpValue == [3 4])
                    set(h.PhaseGroup, 'Visible', 'On');
                end
                if h.Filter.Freq1 < 20 | h.Filter.Freq1 > 100
                    h.Filter.Freq1 = 50;
                    set(h.Edit.FilterFreq1, 'String', num2str(h.Filter.Freq1,3));
                    set(h.Slider.FilterFreq1, 'Value', h.Filter.Freq1);
                    set(h.Text.FilterFreq1, 'String', ['Cutoff Freq = ' ,...
                        num2str(h.Filter.Freq1,3)]);
                    if any(h.PopUpValue==[3 4 7 8])
                        set(h.Text.FilterFreq1, 'String', ['Center Freq = ' ,...
                            num2str(h.Filter.Freq1,3)]);
                        set(h.Text.FilterBW, 'String', ['Bandwidth = ', ...
                            num2str(h.Filter.BW,3)]);
                    end
                end
            else
                set(h.Slider.FilterFreq1, 'Min', 10.0, 'Max', 100.0);
            end

            if any(h.PopUpValue == [5,6,7,8])
                if h.PopUpValue == 5
                    [h.Filter.Range, h.Filter.FFT] = ...
                        ctfirstorderfilter('Lowpass', h.Filter.Freq1, '');
                elseif h.PopUpValue == 6
                    [h.Filter.Range, h.Filter.FFT] = ...
                        ctfirstorderfilter('Highpass', h.Filter.Freq1, '');
                elseif  h.PopUpValue == 7
                    [h.Filter.Range, h.Filter.FFT] = ...
                        ctfirstorderfilter('Bandpass', h.Filter.Freq1, h.Filter.BW);
                else
                    [h.Filter.Range, h.Filter.FFT] = ...
                        ctfirstorderfilter('Bandreject', h.Filter.Freq1, h.Filter.BW);
                end
            elseif any(h.PopUpValue == [1,2,3,4])
                set(h.PhaseGroup, 'Visible', 'On');

                if abs(h.Filter.PhaseShift) < 1e-7
                    set(h.Text.FilterPhase, 'String','Phase Slope = 0');
                elseif abs(1-h.Filter.PhaseShift) < 1e-7
                    set(h.Text.FilterPhase, 'String','Phase Slope = \pi');
                elseif abs(1+h.Filter.PhaseShift) < 1e-7
                    set(h.Text.FilterPhase, 'String','Phase Slope = -\pi');
                else
                    set(h.Text.FilterPhase, 'String', ['Phase Slope = ' num2str(h.Filter.PhaseShift,3) ' \pi']);
                end

                [h.Filter.Range, h.Filter.FFT] = IdealFilter(h);
            end

            %elseif h.PopUpValue==9
            %	 set(h.FilterSpecs, 'Visible', 'Off');
            %	 set(h.Text.FilterFreq1, 'String', 'Filter Coeffs: b_k');
            %	 set(h.Edit.bk, 'String', h.Filter.bk);
            %	 eval( ['h.Filter.ImpResp = ',h.Filter.bk,';']);
            %	 h.Filter.FFT = [ ];
            %	 set(h.UserhnGroup, 'Visible', 'On');
        end
        setappdata(gcbf,'Handles',h);
        changeplots(h);
        %==================================
    case 'Userhn'
        Tag = get(gcbo, 'Tag');
        h.Filter.bk = get(gcbo, 'String');
        set(h.Edit.bk, 'String', h.Filter.bk);
        eval( ['h.Filter.ImpResp = ',h.Filter.bk,';']);
        h.Filter.FFT = [ ];
        setappdata(gcbf,'Handles',h);
        changeplots(h);

        %==================================
    case {'FilterFreq1','FilterFreq1E','FilterFreq1S'}
        Tag = get(gcbo, 'Tag');
        if any(h.PopUpValue==(1:8))
            MAKECHANGE = YES;

            if strcmp(Tag, 'FilterSFreq1')
                h.Filter.Freq1 = get(gcbo, 'Value');
            else
                NewFreq = str2num(get(gcbo, 'String'));
                if ( NewFreq < get(h.Slider.FilterFreq1,'Min') ) ...
                        | (NewFreq > get(h.Slider.FilterFreq1,'Max'))
                    set(gcbo,'String',num2str(h.Filter.Freq1,3));
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
                set(h.Text.FilterFreq1, 'String', ['Cutoff Freq = ' ,...
                    num2str(h.Filter.Freq1,3)]);
                %% xxx - Update for BandPass filter
                if any(h.PopUpValue==[3 4 7 8])
                    set(h.Text.FilterFreq1, 'String', ['Center Freq = ' ,...
                        num2str(h.Filter.Freq1,3)]);
                end
                if any(h.PopUpValue==[5,6,7,8])
                    if h.PopUpValue == 5
                        [h.Filter.Range, h.Filter.FFT] = ...
                            ctfirstorderfilter('Lowpass', h.Filter.Freq1, '');
                    elseif h.PopUpValue == 6
                        [h.Filter.Range, h.Filter.FFT] = ...
                            ctfirstorderfilter('Highpass', h.Filter.Freq1, '');
                    elseif h.PopUpValue == 7
                        [h.Filter.Range, h.Filter.FFT] = ...
                            ctfirstorderfilter('Bandpass', h.Filter.Freq1, h.Filter.BW);
                    else
                        [h.Filter.Range, h.Filter.FFT] = ...
                            ctfirstorderfilter('Bandreject', h.Filter.Freq1, h.Filter.BW);
                    end
                elseif any(h.PopUpValue==[1,2,3,4])
                    [h.Filter.Range, h.Filter.FFT] = IdealFilter(h);
                end

                setappdata(gcbf,'Handles',h);
                changeplots(h);
            end
        end
        %==================================

    case {'FilterBWE','FilterBWS'}
        Tag = get(gcbo, 'Tag');
        if any(h.PopUpValue== [7 8])
            MAKECHANGE = YES;

            if strcmp(Tag, 'FilterSBW')
                h.Filter.BW = get(gcbo, 'Value');
            else
                NewBW = str2num(get(gcbo, 'String'));
                if ( NewBW < get(h.Slider.FilterBW,'Min') ) ...
                        | (NewBW > get(h.Slider.FilterBW,'Max'))
                    set(gcbo,'String',num2str(h.Filter.BW,3));
                    MAKECHANGE = NO;
                else
                    h.Filter.BW = NewBW;
                end
            end

            if abs(h.Filter.BW) <= 1e-10
                h.Filter.BW = 10;
            end

            if MAKECHANGE
                set(h.Edit.FilterBW, 'String', num2str(h.Filter.BW,3));
                set(h.Slider.FilterBW, 'Value', h.Filter.BW);
                set(h.Text.FilterBW, 'String', ['Bandwidth = ' num2str(h.Filter.BW,3)]);
                %% xxx - Update for BandPass filter
                if h.PopUpValue == 7
                    %if h.PopUpValue ==
                    [h.Filter.Range, h.Filter.FFT] = ...
                        ctfirstorderfilter('Bandpass', h.Filter.Freq1, h.Filter.BW);
                    %end
                else
                    [h.Filter.Range, h.Filter.FFT] = ...
                        ctfirstorderfilter('Bandreject', h.Filter.Freq1, h.Filter.BW);
                end

                setappdata(gcbf,'Handles',h);
                changeplots(h);
            end
        end
        %==================================
    case {'FilterPhaseE','FilterPhaseS'}
        Tag = get(gcbo, 'Tag');
        MAKECHANGE = YES;

        if strcmp(Tag, 'FilterSPhase')
            h.Filter.PhaseShift = get(gcbo, 'Value');
        else
            NewPhase = str2num(get(gcbo, 'String'));
            if ( NewPhase < get(h.Slider.FilterPhase,'Min') ) ...
                    | (NewPhase > get(h.Slider.FilterPhase,'Max'))
                set(gcbo,'String',num2str(h.Filter.PhaseShift,3));
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
                set(h.Text.FilterPhase, 'String','Phase Slope = \pi');
            elseif abs(1+h.Filter.PhaseShift) < 1e-7
                set(h.Text.FilterPhase, 'String','Phase Slope = -\pi');
            else
                set(h.Text.FilterPhase, 'String', ['Phase Slope = ' num2str(h.Filter.PhaseShift,3) ' \pi']);
            end

            [h.Filter.Range, h.Filter.FFT] = IdealFilter(h);
            setappdata(gcbf,'Handles',h);
            changeplots(h);
        end
        %==================================
    case 'Answer'
        set(h.Text.OutputTitle, 'String', ...
            cosinestring(h.Output.Mag, h.Freq, ...
            h.Output.Phase, 0, h.Output.DC));
        %==================================
    case 'LineWidth'
        h.LineWidth = linewidthdlg(h.LineWidth);
        set(findobj(gcbf, 'Type', 'line'), 'LineWidth', h.LineWidth);
        setappdata(gcbf,'Handles',h);
        %==================================
    case 'Screenshot'
        screenshotdlg(gcbf);       
        %==================================
    case 'ShowMenu'
        check = get(findobj(gcbf, 'tag', 'ShowMenu'),'Checked');
        if strcmp(check,'off')
            set(gcbf,'MenuBar','figure');
            set(gcbo,'Checked','On');
        else
            set(gcbf,'MenuBar','none');
            set(gcbo,'Checked','Off');
        end
        %==================================     
    case 'Help'
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
                    'which is located in the DConvDemo help directory.'};
                errordlg(s,'Error launching browser.');
        end

        sTitlePage = { ...
            'Usage              - Using the CLTIDemo Graphical User Interface.'; ...
            'README             - Version history and other important information.'; ...
            'License            - License information.'; ...
            'About              - Acknowledgements and contact information.'};
        %helpwin(sTitlePage,'CLTIDemo Help');
        %==================================
    case 'CloseRequestFcn'
        delete(gcbf);
    otherwise
        error (['Illegal Action:' action]);
end

if nargin > 0 & ishandle(gcbf)
    h = getappdata(gcbf);
    if ~isempty(mt), post_callbackAction(mt,action,gcbo,[],h); end
end
% endfunction cltidemo

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% IDEAL FILTER DESIGN
function [ff,HH] = IdealFilter(h)
f = h.Filter.Freq1;
% bw = h.Filter.BW;
% Fixed bandwidth for Ideal filters
bw = 20;
phaseshift = h.Filter.PhaseShift;
ff = linspace(0,200,1001);
TOL = 1e-6;
HH = exp(j*2*pi*ff*phaseshift);

%------------
if h.PopUpValue == 1
    % Ideal Low Pass
    HH = HH.*(abs(ff)<=f+TOL);
elseif h.PopUpValue == 2
    % Ideal High Pass
    HH = HH.*(abs(ff)>=f-TOL);
elseif h.PopUpValue == 3
    % Ideal Band Pass
    HH = HH.*(abs(abs(ff)-f) <= (bw/2)+TOL);
elseif h.PopUpValue == 4
    % Ideal Band Reject
    HH = HH.*(abs(abs(ff)-f) >= (bw/2)+TOL);
else
    error('Ideal Filter must be 1,2,3 or 4');
end
set(h.FilterMagPlot,{'XData','YData'},{ff, abs(HH)});
set(h.FilterPhasePlot,{'XData','YData'},{ff, angle(HH)});

%endfunction IdealFilter

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CHANGEPLOTS
function changeplots(h)
% Input Plot
hhin = h.DC + h.Amp*cos(2*pi*h.Freq*h.t + h.Phase*pi);
set(h.InputPlot,'xdata',h.t,'ydata',hhin);
%--- Following line was for discrete-time, not necessary in continuous-time
%h.Freqmod = h.Freq; while h.Freqmod>=0.5, h.Freqmod = h.Freqmod-1; end
h.Freqmod = h.Freq;  % Do this instead of search/replace for FreqMod

% Filter Plot
if isempty(h.Filter.FFT)
    error('Invalid Filter response');
end
h.Filter.Mag =  abs(h.Filter.FFT);
h.Filter.Phase =  angle(h.Filter.FFT);
filterplot(h.Filter.Range, h.Filter.Mag, h.FilterMagPlot);
Hmax = max(abs(h.Filter.Mag));
set(get(h.FilterMagPlot,'Parent'),'YLim',[0, max([1,ceil(Hmax-0.05)])+0.1]);
filterplot(h.Filter.Range, h.Filter.Phase, h.FilterPhasePlot);

% Output Plot
[qq,k0] = min(abs(h.Filter.Range));  %<-- find DC
[qq,kMag] = min(abs(h.Filter.Range-h.Freqmod));   %<-- find "positive" freq
[qq,kMag2] = min(abs(h.Filter.Range+h.Freqmod));  %<-- find "negative" freq
if any(h.PopUpValue==[1,2,3,4])
    % Ideal Filters
    FilterMag_0   = h.Filter.FFT(k0);
    FilterPhase_0 = h.Filter.Phase(k0);
    FilterMag_k   = h.Filter.Mag(kMag);
    FilterPhase_k = h.Filter.Phase(kMag);
else
    % Non-Ideal Filters
    % NOTE: Need to evaluate the true input frequency value, not one of closest
    %       bin values.
    filter = {'Lowpass','Highpass','Bandpass','Bandreject'};
    [f, H] = ctfirstorderfilter(filter{h.PopUpValue-4},h.Filter.Freq1,h.Filter.BW,[0 h.Freq]);

    FilterMag_0   = abs(H(1));
    FilterPhase_0 = angle(H(1));
    FilterMag_k   = abs(H(2));
    FilterPhase_k = angle(H(2));
end

h.Output.Mag = FilterMag_k*h.Amp;
h.Output.Phase = FilterPhase_k/pi + h.Phase;
h.Output.DC = FilterMag_0*h.DC;

hhout = h.Output.DC + h.Output.Mag*cos(2*pi*h.Freq*h.t + h.Output.Phase*pi);
set(h.OutputPlot,'xdata',h.t,'ydata',hhout);

% Calculating and plotting the frequency markers
if h.DC~=0
    set(h.Line.FreqMagMark0,{'XData','YData'},{0,FilterMag_0});
    set(h.Line.FreqPMark0,{'XData','YData'},{0,FilterPhase_0});
    set(h.Line.FreqMagMark0, 'Visible', 'On');
    set(h.Line.FreqPMark0, 'Visible', 'On');
else
    set(h.Line.FreqMagMark0, 'Visible', 'Off');
    set(h.Line.FreqPMark0, 'Visible', 'Off');
end
if h.Freqmod==0 & h.DC~=0
    set(h.Line.FreqMagMark1, 'Visible', 'Off');
    set(h.Line.FreqMagMark2, 'Visible', 'Off');
    set(h.Line.FreqPMark1, 'Visible', 'Off');
else
    set(h.Line.FreqMagMark1, 'Visible', 'On');
    set(h.Line.FreqMagMark1,{'XData','YData'},{h.Freqmod,FilterMag_k});
    set(h.Line.FreqPMark1, 'Visible', 'On');
    set(h.Line.FreqPMark1,{'XData','YData'},{h.Freqmod,FilterPhase_k});
    if abs(h.Freq)<1e-5
        set(h.Line.FreqMagMark2, 'Visible', 'Off');
    else
        set(h.Line.FreqMagMark2, 'Visible', 'On');
        set(h.Line.FreqMagMark2,{'XData','YData'},...
            {-h.Freqmod,FilterMag_k});
    end
end

% Clearing the Output Title
set(h.Text.OutputTitle, 'String', '');
setappdata(gcbf,'Handles',h);

% endfunction changeplots

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETHANDLES
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

% endfunction sethandles

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FILTERPLOT
function filterplot(x,y, hLines)
%FILTERPLOT Create Filter plot
%   FILTERPLOT(x,y,hLines) changes the plot of the filter given by the handles
%   in hLines to the new data x and y.
%
%   The input x and y should be equal length vectors.
% Budiyanto Junus, 1/20/99
% Modified from Jordan Rosenthal's STEMDATA
set(hLines,{'XData','YData'},{x, y});

% endfunction filterplot
% eof: cltidemo.m