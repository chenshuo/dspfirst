function fouriergui_callbacks(action)

% This has the callback routines for Fourier Series Demo.
% For revision history please see readme.m file.
%
% J McClellan 29-Jan-2024 (ver. 1.45), Corrected Rectified Cosines
%   Display Phase as odd symmetric, i.e., -pi for some negative freqs
%
% J McClellan 26-Nov-2011 (ver. 1.30), Corrected Full-Wave Rectified Sines
%                                      fixed changeplots() function below

NO = 0; YES = 1; OFF = 0; ON = 1;
%-------------------------------------------------------------------------------
% Default Settings
%-------------------------------------------------------------------------------
if nargin == 0
    action = 'Initialize';
else
    h = getappdata(gcbf, 'Handles');
    mt = getappdata(gcbf,'movietoolData');
    if ~isempty(mt), pre_callbackAction(mt,action,gcbo,[],h); end
end

switch(action)
    %---------------------------------------------------------------------------
    case 'Initialize'
        %---------------------------------------------------------------------------
        try
            % All error checking moved to the DCONVDEMO function.  Keep this here as
            % well because we need the Matlab version number for some of the bug
            % workarounds.
            h.MATLABVER = versioncheck(5.2);     % Check Matlab Version
            
            %---  Set up GUI  ---%
            fouriergui;
            strVersion = '1.45';           % Version string for figure title v1.3 (JMc 25-Nov-2011)
            set(gcf, 'Name', ['Fourier Series Demo v' strVersion]);
            h.LineWidth = 0.5;
            h.FigPos = get(gcf,'Pos');
            
            SCALE = getfontscale;          % Platform dependent code to determine
            % SCALE parameter
            setfonts(gcf,SCALE);           % Setup fonts: override default fonts used 
            % in fouriergui
            
            configresize(gcf);             % Change all 'units'/'font units' to normalized
            
            h = gethandles(h);             % Get GUI graphic handles
            h = defaultplots(h);           % Create default plots
            
            if h.MATLABVER >= 6.0
                %--User-Data Acquisition (movietool object)--%
                movietool('Initialize',gcf,mfilename,0.08);
                %-------------------------%
            end
            
            setappdata(gcf,'Handles',h);
            
            % correct fontsize (why ??)
            font_size = get(h.Axis.Magnitude,'fontsize');
            set(h.Axis.Phase,'fontsize',font_size);
            
            set(gcf,'WindowButtonMotionFcn',[mfilename ' WindowButtonMotionFcn']); 
            set(gcf,'HandleVisibility','callback'); % Make figure inaccessible 
            % from command line
            
        catch
            %---  Delete any GUI figures and remove from path if necessary  --%
            delete(findall(0,'type','figure','tag','fseriesdemo'));
            
            %---  Display the error to the user and exit  ---%
            errordlg(lasterr,'Error Initializing Figure');
            return;
        end      
        %---------------------------------------------------------------------------
    case 'SetFigureSize'
        %---------------------------------------------------------------------------
        OldUnits = get(0, 'Units');
        set(0, 'Units','pixels');
        ScreenSize = get(0,'ScreenSize');
        set(0, 'Units', OldUnits);
        FigSize = [0.1*ScreenSize(3), 0.15*ScreenSize(4), 0.8*ScreenSize(3), 0.7*ScreenSize(4)];
        set(gcbf, 'Position', FigSize);    
        %--------------------------------------------------------------------------
    case 'Help'
        %--------------------------------------------------------------------------
        hBar = waitbar(0.25,'Opening internet browser...');
        DefPath = which(mfilename);
        DefPath = ['file:///' strrep(DefPath,filesep,'/') ];
        URL = [ DefPath(1:end-22) , 'help/','index.html'];
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
                        'which is located in the Fourier help directory.'};
                errordlg(s,'Error launching browser.');
        end
        %--------------------------------------------------------------------------
    case 'Screenshot'
        %--------------------------------------------------------------------------
        screenshotdlg(gcbf);
        %--------------------------------------------------------------------------
    case 'ShowMenu'
        %--------------------------------------------------------------------------
        check = get(gcbo,'Checked');
        if strcmp(check,'off')
            set(gcbf,'MenuBar','figure');
            set(gcbo,'Checked','On');
        else
            set(gcbf,'MenuBar','none');
            set(gcbo,'Checked','Off');
        end
        %--------------------------------------------------------------------------
    case 'Close'
        %--------------------------------------------------------------------------
        close(gcbf);   
        %--------------------------------------------------------------------------
    case 'LineWidth'
        %--------------------------------------------------------------------------
        h.LineWidth = linewidthdlg(h.LineWidth);
        set(findobj(gcbf, 'Type', 'line'), 'LineWidth', h.LineWidth);
        setappdata(gcbf,'Handles',h); 
        %--------------------------------------------------------------------------
    case {'SignalType','SignalType1'}
        %--------------------------------------------------------------------------
        popValue = get(h.PopUpMenu.Signal, 'Value');
        
        if  popValue == 1
            % Square wave
            h.yval  = sqar(2*pi*h.freq.*h.timeaxis);
            
        elseif  popValue == 2
            % Triangle wave	  
            timeaxis = h.timeaxis(h.timeaxis >= 0);
            yval = tri(10/h.freq,1,length(timeaxis));           
            h.yval = -[fliplr(yval(2:end)) yval];
            
        elseif  popValue == 3
            % Ramp wave	  
            T = 1/h.freq;
            timeaxis = h.timeaxis(h.timeaxis >= 0);
            yval = (mod(timeaxis+T/2,T)-T/2)/T*2; 
            h.yval = [-fliplr(yval(2:end)) yval];
            
        elseif  popValue == 4
            % Full-wave Rectified Sine wave
            h.yval = fullwave(h.timeaxis,1/h.freq,'sine');
            
        elseif  popValue == 5
            % Full-wave Rectified Cosine wave	  
            h.yval = fullwave(h.timeaxis,1/h.freq, 'cosine'); 
            
        elseif  popValue == 6
            % Half-wave Rectified Sine wave
            h.yval = halfwave(h.timeaxis,1/h.freq, 'sine'); 
            
        elseif  popValue == 7
            % Full-wave Rectified Cosine wave
            h.yval = halfwave(h.timeaxis,1/h.freq, 'cosine'); 
            
        end
        changeplots(h);
        setappdata(gcbf,'Handles',h);
        
        %--------------------------------------------------------------------------
    case {'FourCoeff1','FourCoeff2'}
        %--------------------------------------------------------------------------
        Tag = get(gcbo, 'Tag');
        MAKECHANGE = YES;
        
        if strcmp(Tag, 'FourCoeffSlider')
            h.Slider.CoeffValue = round(get(gcbo, 'Value'));
        else
            NewCoeffValue = str2num(get(gcbo, 'String'));
            if ( NewCoeffValue < get(h.Slider.NumCoeff,'Min') ) ...
                    | (NewCoeffValue > get(h.Slider.NumCoeff,'Max'))
                set(gcbo,'String',num2str(h.Slider.CoeffValue));
                MAKECHANGE = NO;
            else
                h.Slider.CoeffValue = round(NewCoeffValue);
            end
        end
        if MAKECHANGE
            set(h.Edit.NumCoeff, 'String', num2str(h.Slider.CoeffValue));
            set(h.Slider.NumCoeff, 'Value', h.Slider.CoeffValue);     
            
            if get(h.Slider.NumCoeff, 'Value')
                set(h.Text.SliderText, 'String', sprintf('Coefficients from k = -%d  to  k = %d',h.Slider.CoeffValue,h.Slider.CoeffValue ));
            else
                set(h.Text.SliderText, 'String','DC Coefficient: k = 0');
            end   
            
            setappdata(gcbf,'Handles',h);       
        end
        
        changeplots(h);      
        %--------------------------------------------------------------------------
    case {'changex','changex1'}
        %-------------------------------------------------------------------------- 
        xlabel = -15:5:15;
        if get(findobj('tag','changex'),'value')        
            set(findobj('tag','MagnitudeAxis'),'xtick',xlabel,'xticklabel',round(1000.*h.freq*xlabel)/1000);
            set(findobj('tag','PhaseAxis'),'xtick',xlabel,'xticklabel',round(1000.*h.freq*xlabel)/1000);
            set([get(h.Axis.Magnitude,'XLabel'),get(h.Axis.Phase,'XLabel')],'String','Frequency (Hz)');
        else
            set(findobj('tag','MagnitudeAxis'),'xtick',xlabel,'xticklabel',xlabel);
            set(findobj('tag','PhaseAxis'),'xtick',xlabel,'xticklabel',xlabel);
            set([get(h.Axis.Magnitude,'XLabel'),get(h.Axis.Phase,'XLabel')],'String','Number of Fourier Coefficients');
        end
        %--------------------------------------------------------------------------
    case 'ShowError'
        %--------------------------------------------------------------------------
        if get(findobj('tag','showerror'),'value')
            set([h.Signal.Waveform,h.Signal.RecWaveform,h.DCtext],'vis','off');
            set(h.Signal.ErrorWaveform,'vis','on');
            set([findobj('tag','origsig'),findobj('tag','syntsig')],'vis','off');
            set(findobj('tag','errosig'),'vis','on');
        else
            set([h.Signal.Waveform,h.Signal.RecWaveform],'vis','on');
            set(h.Signal.ErrorWaveform,'vis','off');
            coeffValue = get(h.Slider.NumCoeff, 'Value');
            if coeffValue == 0
                set(h.DCtext,'vis','on');
            end
            set([findobj('tag','origsig'),findobj('tag','syntsig')],'vis','on');
            set(findobj('tag','errosig'),'vis','off');
            
            changeplots(h); 
        end    
        %--------------------------------------------------------------------------
    case 'ChangePeriod'
        %--------------------------------------------------------------------------
        T0 = get(gcbo,'value');
        set(findobj('tag','TextforPeriodSignal'),'string',['Choose the Signal Period: T = ' num2str(T0)]);
        h.timeaxis = -30:0.1:30;
        h.freq = 1/T0;
        setappdata(gcbf,'Handles',h);
        fouriergui_callbacks changex1
        fouriergui_callbacks SignalType1
        %--------------------------------------------------------------------------       
    case 'WindowButtonMotionFcn'
        %--------------------------------------------------------------------------
        [mouse_x,mouse_y,fig_size] = mousepos;
        old_unitsMag = get(h.Axis.Magnitude,'units');
        set([h.Axis.Magnitude,h.Axis.Phase],'units','pixels');
        axMag = get(h.Axis.Magnitude,'pos');
        axPha = get(h.Axis.Phase,'pos');
        set([h.Axis.Magnitude,h.Axis.Phase],'units',old_unitsMag);
        
        % Cursor over object axes flag
        over_axesMag_flg = any( (mouse_x > axMag(1)) & (mouse_x < axMag(1)+axMag(3)) &  ...
            (mouse_y > axMag(2)) & (mouse_y < axMag(2)+axMag(4)) );
        over_axesPha_flg = any( (mouse_x > axPha(1)) & (mouse_x < axPha(1)+axPha(3)) &  ...
            (mouse_y > axPha(2)) & (mouse_y < axPha(2)+axPha(4)) );
        
        if over_axesMag_flg
            % pointer over Magnitude axes   
            current_pt = get(h.Axis.Magnitude,'CurrentPoint');
            
            xvals = get(h.Spectrum.Magnitude(1),'xdata');
            yvals = get(h.Spectrum.Magnitude(1),'ydata');
            xtoll = 0.45;
            ytoll = 0.02;
            
            [xindex] = find(abs(xvals-current_pt(1)) < xtoll);          
            
            if ~isempty(xindex)
                if  yvals(xindex) == 0 & (current_pt(3) <= ytoll)
                    % mag = 0
                    set(h.Line.Magnitude,'xdata',xvals(xindex),'ydata',0,'vis','on');
                    set(h.Text.Magnitude,'position',[xvals(xindex) yvals(xindex)+ytoll],'string',0,'horiz','center','vert','bottom');
                elseif (current_pt(3) <= (yvals(xindex)+ytoll))
                    if xvals(xindex) >= 0
                        horiz = 'left';
                    else
                        horiz = 'right';
                    end
                    set(h.Text.Magnitude,'pos',[xvals(xindex) yvals(xindex)+ytoll],'string',num2str(round(1000*yvals(xindex))/1000), ...
                            'horiz',horiz,'vert','bottom');
                    set(h.Line.Magnitude(1),'xdata', xvals(xindex),'ydata',yvals(xindex),'vis','on');
                    set(h.Line.Magnitude(2),'xdata', [xvals(xindex) xvals(xindex)],'ydata',[0 yvals(xindex)],'vis','on');
                end
            else
                set(h.Text.Magnitude,'string','');
                set(h.Line.Magnitude,'vis','off');
            end
        elseif over_axesPha_flg
            % pointer over Phase axes           
            current_pt = get(h.Axis.Phase,'CurrentPoint');
            xvals = get(h.Spectrum.Phase(1),'xdata');
            yvals = get(h.Spectrum.Phase(1),'ydata');
            xtoll = 0.2;
            ytoll = 1.1;
            ytollM = 1e-7;
            
            [xindex] = find(abs(xvals-current_pt(1)) < xtoll);        
            
            if ~isempty(xindex)
                if (yvals(xindex) == 0) & (abs(current_pt(3)) < ytoll)
                    set(h.Line.Phase,'xdata',[xvals(xindex) xvals(xindex)],'ydata',[0 0],'vis','on');
                    set(h.Text.Phase,'position',[xvals(xindex) ytoll],'string','0');
                elseif (current_pt(3) <= yvals(xindex)) & (current_pt(3) >= 0)
                    set(h.Line.Phase(1),'xdata', xvals(xindex),'ydata',yvals(xindex),'vis','on');
                    set(h.Line.Phase(2),'xdata', [xvals(xindex) xvals(xindex)],'ydata',[0 yvals(xindex)],'vis','on');
                    if abs(yvals(xindex) - pi) < ytollM
                        set(h.Text.Phase,'position',[xvals(xindex) yvals(xindex)+ytoll],'string','\pi');
                    elseif abs(yvals(xindex) - pi/2) < ytollM
                        set(h.Text.Phase,'position',[xvals(xindex) yvals(xindex)+ytoll],'string','0.5\pi');
                    else
                        set(h.Text.Phase,'position',[xvals(xindex) yvals(xindex)+ytoll],'string',num2str(round(1000*yvals(xindex))/1000));
                    end
                elseif (current_pt(3) >= yvals(xindex)) & (current_pt(3) <= 0)
                    set(h.Line.Phase(1),'xdata', xvals(xindex),'ydata',yvals(xindex),'vis','on');
                    set(h.Line.Phase(2),'xdata', [xvals(xindex) xvals(xindex)],'ydata',[0 yvals(xindex)],'vis','on');
                    if abs(yvals(xindex) + pi) < ytollM
                        set(h.Text.Phase,'position',[xvals(xindex) yvals(xindex)-ytoll],'string','-\pi');
                    elseif abs(yvals(xindex) + pi/2) < ytollM
                        set(h.Text.Phase,'position',[xvals(xindex) yvals(xindex)-ytoll],'string','-0.5\pi');
                    else
                        set(h.Text.Phase,'position',[xvals(xindex) yvals(xindex)-ytoll],'string',num2str(round(1000*yvals(xindex))/1000));
                    end
                else
                    set(h.Text.Phase,'string','');
                    set(h.Line.Phase,'vis','off');  
                end
            else
                % pointer neither over Magnitude or Phase axes
                set([h.Text.Magnitude,h.Text.Phase],'string','');
                set([h.Line.Magnitude,h.Line.Phase],'vis','off');
            end
        end
        %--------------------------------------------------------------------------
    otherwise
        %--------------------------------------------------------------------------
        error('Illegal Action');
end

if nargin > 0 & ishandle(gcbf)
    h = getappdata(gcbf);
    if ~isempty(mt), post_callbackAction(mt,action,gcbo,[],h); end
end

%% endfunction fouriergui_callbacks ============================================
%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------
function changeplots(h)
% CHANGEPLOTS
coeffValue = get(h.Slider.NumCoeff, 'Value');
popValue = get(h.PopUpMenu.Signal, 'Value');

index_coeff = round(coeffValue);
magVec = [];
h.recFinal = zeros(1,length(h.timeaxis));

switch popValue
    %--------------- Square wave ------------------------
    case 1
        for n = -index_coeff:index_coeff
            if n == 0 | mod(n,2)==0
                magSpec = 0;
            else 
                magSpec = (-2*j)/(n*pi);
            end
            recSig = magSpec * exp(j*2*pi*h.freq*n*h.timeaxis);
            magVec = [magVec;magSpec];
            h.recFinal = h.recFinal+recSig;
            
            if coeffValue == 0 & ~get(findobj('tag','showerror'),'value')
                set(h.DCtext,'pos',[0.4,0.3],'vis','on');    
            else
                set(h.DCtext,'vis','off');
            end
            set(h.Axis.Magnitude,'ylim',[0 0.78]);
        end      
        %--------------- Triangle wave ----------------------
    case 2
        for n = -index_coeff:index_coeff
            if n == 0 | mod(n,2)==0
                magSpec = 0;
            else     
                magSpec = 4/((n*pi)^2);
            end
            recSig = magSpec * exp(j*2*pi*h.freq*n*h.timeaxis);
            magVec = [magVec;magSpec];
            h.recFinal = h.recFinal+recSig;
            
            if coeffValue == 0 & ~get(findobj('tag','showerror'),'value')
                set(h.DCtext,'pos',[9,.3],'vis','on');    
            else
                set(h.DCtext,'vis','off');
            end  
            set(h.Axis.Magnitude,'ylim',[0 0.5]);
        end       
        %--------------- Ramp/Sawtooth wave -----------------
    case 3
        for n = -index_coeff:index_coeff
            if n == 0 
                magSpec = 0;
            else 
                magSpec = ((-1)^n)*(j)/(n*pi);
            end
            recSig = magSpec * exp(j*2*pi*h.freq*n*h.timeaxis);
            magVec = [magVec;magSpec];
            h.recFinal = h.recFinal+recSig;
            
            if coeffValue == 0 & ~get(findobj('tag','showerror'),'value')
                set(h.DCtext,'pos',[-2,0.3],'vis','on');    
            else
                set(h.DCtext,'vis','off');
            end          
            set(h.Axis.Magnitude,'ylim',[0 0.4]);
        end       
        %------------------- Full-wave Rectified (Sine / Cosine) ----------------------
    case {4, 5}
        for n = -index_coeff:index_coeff
            % We DO NEED to have special cases  %JMc 01/24/24
            
            % Sine wave coeff
%--->  magSpec = -(exp(-2i*pi*n) + 1)/(pi*(4*n^2 -1)) %has ROUNDING errors
            if popValue == 4
                magSpec = -2/(pi*(4*n^2 -1));
                if(n<0), magSpec = (1 + j*1e-8)*magSpec; end %JMc 01/24/24
            end 
            if popValue == 5
                % Cosine wave
                %magSpec = exp(-j*n*pi)*magSpec;
                magSpec = 2*cos(n*pi) / (pi*(1-4*n^2));
                if(n<0), magSpec = (1 + j*1e-8)*magSpec; end %JMc 01/24/24
            end
            recSig = (magSpec * exp(j*2*pi*h.freq*n*h.timeaxis));
            magVec = [magVec;magSpec];
            h.recFinal = h.recFinal+recSig;
            
            if coeffValue == 0 & ~get(findobj('tag','showerror'),'value')
                if popValue == 4
                    set(h.DCtext,'pos',[-1,0.95],'vis','on');    
                else 
                    set(h.DCtext,'pos',[4,0.95],'vis','on'); 
                end
            else
                set(h.DCtext,'vis','off');
            end

            set(h.Axis.Magnitude,'ylim',[0 0.77]);
        end        
        %-------------------- Half-wave Rectified (Sine / Cosine) ---------------------
    case {6,7}
        for n = -index_coeff:index_coeff
            % Cosine wave coeffs  
            if n == 0 
                magSpec = 1/(pi);
            elseif n== -1 | n== 1
                magSpec = 1/4;
            else
                magSpec = ( cos(n*pi/2))/pi/(1-n^2);
%                 if(n<0), magSpec = (1 - j*1e-8)*magSpec; end %JMc 01/24/24
            end
            
            % Change coefficient depending cosine / sine
            if popValue == 6
                % Sine wave 
                magSpec = exp(-j*n*pi/2)*magSpec; 
            end
            if popValue == 7
                if(n<0), magSpec = (1 + j*1e-8)*magSpec; end %JMc 01/24/24
            end
            recSig = magSpec * exp(j*2*pi*h.freq*n*h.timeaxis);
            magVec = [magVec;magSpec];
            h.recFinal = h.recFinal+recSig;
            
            if coeffValue == 0 & ~get(findobj('tag','showerror'),'value')
                set(h.DCtext,'pos',[10,0.6],'vis','on');    
            else
                set(h.DCtext,'vis','off');
            end
            set(h.Axis.Magnitude,'ylim',[0 0.41]);
        end
    otherwise
        error('Invalid Signal Type');
end

h.magVec = magVec;
h.SpectrumXval = -index_coeff:index_coeff;
h.magVec(abs(h.magVec) < sqrt(eps)) = 0;
%plot & Stem
set(h.Signal.Waveform, 'XData',h.timeaxis,'YData', h.yval);
set(h.Signal.RecWaveform, 'XData',h.timeaxis,'YData', real(h.recFinal));
set(h.Signal.ErrorWaveform,'XData',h.timeaxis,'Ydata',h.yval-real(h.recFinal));
stemdata(h.SpectrumXval,abs(h.magVec),[],h.Spectrum.Magnitude);
stemdata(h.SpectrumXval,angle(h.magVec),[],h.Spectrum.Phase);
setappdata(gcbf,'Handles',h);

% endfunction changeplots
% eof: fouriergui_callbacks.m
