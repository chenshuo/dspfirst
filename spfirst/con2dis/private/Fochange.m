function Fochange(h,FoN,FsN,stime1)
% Fochange - (Repetitive Code) to be used with con2dis.m
% Update all four plots due to new Fo
% Axes are numbered as follows:     1 | 2 | 5
%                                  -----------
%                                   4 | 3 | 6
% Fo  = {string} frequency of the signal (Hz)
% FoN = {number} frequency of the signal (Hz)
% FsN = {number} sampling frequency (Hz)
% time1 = time of the sinusoid
%
% Gregory Krudysz

if h.wflag == 1
    pi2 = 2*pi;
end

if FoN > 1.5*FsN
    FoN = 1.5*FsN;
    
    if h.wflag == 1;
        WoN = 2*pi*FoN;
        WoSS = sprintf('%.1f',WoN);
        set(h.Editbox1,'String',WoSS);
    else   
        FoSS = sprintf('%.1f',FoN);
        set(h.Editbox1,'String',FoSS);
    end    
else   
    if h.wflag == 1
        WoN = pi2*FoN;
        WoSS = sprintf('%.1f',WoN);
        set(h.Editbox1,'String',WoSS);
    else
        FoSS = sprintf('%.1f',FoN);
        set(h.Editbox1,'String',FoSS);
    end
    
end

R = FoN/FsN;
if (abs(mod(R,0.5))<1e-3 )
    Xsp = abs(cos(h.phaseN));
else
    Xsp = 0.5;
end
P = pi;

FoNc2 = phaseText(h,FoN,FsN,R);

% Slider1
sliderLIM = get(h.Slider1,'max');

if h.wflag == 1
    FoNv = FoN*pi2;
    % Prevent h.Sider1 from maxing-out 
    if abs(FoNv) > sliderLIM
        FoNv = sliderLIM;
    end      
    set(h.Slider1,'Value',FoNv);
else
    if abs(FoN) > sliderLIM
        FoN = sliderLIM;
    end
    set(h.Slider1,'Value',FoN);
end

% Axes1 --------------------
time2 = 0:1/FsN:1;
c1 = cos(2*P*FoN*h.time1 + h.phaseN);
c2 = cos(2*P*FoNc2*time2 + h.phaseN);
set([h.Line1; h.Line11],'YData',c1);

% Axes2 ---------------------
stemdata(time2,c2,[],h.Line2);

% Axes4  --------------------- 
if (abs(FoN)<1e-3 )
    XCsp = abs(cos(h.phaseN));
else
    XCsp = 0.5;
end
stemdata(FoN,XCsp,[],h.Line4);
stemdata(-FoN,XCsp,[],h.Line4c);

% Axes3 ---------------------
stemdata([-2+R -1+R 1+R  2+R],Xsp*[1,1,1,1],[],h.Line3out);
stemdata([-2-R -1-R 1-R  2-R],Xsp*[1,1,1,1],[],h.Line3outC);
stemdata(R,Xsp,[],h.Line3in);   
stemdata(-R,Xsp,[],h.Line3inC);   

% Axes6 --------------------  
pink = 0.9*[1 0.95 0.95];
if FoN > FsN/2
    dpink = [0.7 0 0];
    set([h.Line6,h.Line6c],'Color','r');
    set(h.Axis6,'Color', pink);
    set(h.TextAlie,'Visible','On');
    if any(get(h.TextClick,'color'))   %-- changing the color to 'k' will turn off this "tip"
       set(h.TextClick, 'Visible','On');
    else
       set(h.TextClick, 'Visible','Off');
    end
    set([h.TextOut,h.Line5],'Color',dpink);
elseif FoN == FsN/2
    set([h.Line6,h.Line6c,h.TextOut],'Color','m');
    set(h.Axis6,'Color', pink);
    set([h.TextAlie,h.TextClick],'Visible','Off');
    set([h.TextOut,h.Line5],'Color','r');
else
    nile = [0 0.4470 0.7410];
    set([h.Line6,h.Line6c,h.TextOut,h.TextOut],'Color','b');
    set(h.Axis6,'Color','w');
    set([h.TextAlie,h.TextClick],'Visible','Off');
    set(h.Line5,'Color',nile);
end

% TextFo
if h.wflag == 1
    if h.MATLABVER>=8.4
        set(h.TextFo,'String',['\bf $$\omega_o = ' sprintf('%.1f',pi2*FoN) '$$ (rad/s)'],'Interpreter','Latex');
    else
        set(h.TextFo,'String',sprintf('\\omega_o = %.1f (rad/s)',pi2*FoN),'Interpreter','tex');
    end
else
    if h.MATLABVER>=8.4
        set(h.TextFo,'String',['\bf $$f_o = ' sprintf('%.1f',FoN) '$$ (Hz)'],'Interpreter','Latex');
    else
        set(h.TextFo,'String',sprintf('f_o = %.1f (Hz)',FoN),'Interpreter','tex');
    end
end