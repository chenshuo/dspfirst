% This modifies h.TextIn, h.TextMiddle, and h.TextOut text objects.
% h - application data h.xxx, defined in con2dis (main)
% FoN - Signal frequency (Hz)
% FsN - Samplign frequency (Hz)
% R   - Ratio FoN/FsN
%
% 08/10/01 G.Krudysz

function [FoNout] = phaseText(h,FoN,FsN,R)

P = pi;

if FoN <= FsN/2
    FoNm = FoN;
else
    FoNm = FoN - FsN;
end

atPI = 0;
at2PI = 0;
if (abs(FoNm)<1e-3)   %- at omega-hat = 0, 2pi
    at2PI = 1;
    XCsp = abs(cos(h.phaseN));
    Aout = cos(h.phaseN);
    PhOut = 0;
    if Aout<0, Aout = abs(Aout); PhOut = pi; end
    Astr = sprintf('%.2f',Aout);
elseif ( abs(2*FoNm-FsN)<0.001*FsN )  %- at omega-hat = pi
    atPI = 1;
    XCsp = 0.5*abs(cos(h.phaseN));
    Aout = cos(h.phaseN);
    PhOut = 0;
    if Aout<0, Aout = abs(Aout); PhOut = pi; end
    Astr = sprintf('%.2f',Aout);
else
    XCsp = 0.5;
    PhOut = h.phaseN*(1-2*(FoNm<0));
    Aout = 1;
    Astr = '';
end

stemdata(FoNm,XCsp,[],h.Line6);
stemdata(-FoNm,XCsp,[],h.Line6c);

if atPI | at2PI
    set([h.Line5;h.Line52],'YData',Aout*cos(2*P*FoNm*h.time1 + PhOut));
else
    set([h.Line5;h.Line52],'YData',Aout*cos(2*P*FoNm*h.time1 + h.phaseN));
end

if h.wflag == 1
    pi2 = 2*P;
    WoN = pi2*FoN;
    
    if abs(h.phaseN)<1e-3
        if h.MATLABVER>=8.4
            set(h.TextIn,'String',['Input: $$\bf x(t) = \cos\left(' sprintf('%.1f',WoN) '\,t\right)$$'],'Interpreter','Latex');
            set(h.TextMiddle,'String',['$$\bf x[n] = \cos\left(' sprintf('%.2f',pi2*R) '\,n\right)$$'],'Interpreter','Latex');
        else
            set(h.TextIn,'String',sprintf('Input: x(t) = cos(%.1f t)',WoN),'Interpreter','tex');
            set(h.TextMiddle,'String',sprintf('x[n] = cos(%.2f n)',pi2*R),'Interpreter','tex');
        end
    elseif h.phaseN<0
        
        if h.MATLABVER>=8.4
            set(h.TextIn,'String',['Input: $$\bf x(t) = \cos\left(' sprintf('%.1f',WoN) '\,t - ' sprintf('%.2f',-h.phaseN) '\right)$$'],'Interpreter','Latex');
            set(h.TextMiddle,'String',['$$\bf x[n] = \cos\left(' sprintf('%.2f',pi2*R) '\,n - ' sprintf('%.2f',-h.phaseN) '\right)$$'],'Interpreter','Latex');
        else
            set(h.TextIn,'String',sprintf('Input: x(t) = cos(%.1f t - %.2f)',WoN,-h.phaseN),'Interpreter','tex');
            set(h.TextMiddle,'String',sprintf('x[n] = cos(%.2f n - %.2f)',pi2*R,-h.phaseN),'Interpreter','tex');
        end
        
    elseif h.phaseN>0
        
        if h.MATLABVER>=8.4
            set(h.TextIn,'String',['Input: $$\bf x(t)=\cos\left(' sprintf('%.1f',WoN) '\,t + ' sprintf('%.2f',h.phaseN) '\right)$$'],'Interpreter','Latex');
            set(h.TextMiddle,'String',['$$\bf x[n] = \cos\left(' sprintf('%.2f',pi2*R) '\,n + ' sprintf('%.2f',h.phaseN) '\right)$$'],'Interpreter','Latex');
        else
            set(h.TextIn,'String',sprintf('Input: x(t) = cos(%.1f t + %.2f)',WoN,h.phaseN),'Interpreter','tex');
            set(h.TextMiddle,'String',sprintf('x[n] = cos(%.2f n + %.2f)',pi2*R,h.phaseN),'Interpreter','tex');
        end
    end
    FoNout = abs(FoNm)*pi2;
    
    if h.MATLABVER>=8.4
        if abs(PhOut)<1e-3
            set(h.TextOut,'String',['Output: $$\bf y(t)=' sprintf('%s',Astr) '\cos\left(' sprintf('%.1f',FoNout) '\,t\right)$$']);
        elseif abs(abs(PhOut)-pi)<1e-3
            set(h.TextOut,'String',['Output: $$\bf y(t)=' sprintf('%s',Astr) '\cos\left(' sprintf('%.1f',FoNout) '\,t + \pi\right)$$']);
        elseif PhOut<0
            set(h.TextOut,'String',['Output: $$\bf y(t)=' sprintf('%s',Astr) '\cos\left(' sprintf('%.1f',FoNout) '\,t - ' sprintf('%.2f',-PhOut) '\right)$$']);
        elseif PhOut>0
            set(h.TextOut,'String',['Output: $$\bf y(t)=' sprintf('%s',Astr) '\cos\left(' sprintf('%.1f',FoNout) '\,t + ' sprintf('%.2f',PhOut) '\right)$$']);
        end
    else
        if abs(PhOut)<1e-3
            set(h.TextOut,'String',sprintf('Output: y(t) = %scos(%.1f t)',Astr,FoNout),'Interpreter','tex');
        elseif abs(abs(PhOut)-pi)<1e-3
            set(h.TextOut,'String',sprintf('Output: y(t) = %scos(%.1f t + \\pi)',Astr,FoNout),'Interpreter','tex');
        elseif PhOut<0
            set(h.TextOut,'String',sprintf('Output: y(t) = %scos(%.1f t - %.2f)',Astr,FoNout,-PhOut),'Interpreter','tex');
        elseif PhOut>0
            set(h.TextOut,'String',sprintf('Output: y(t) = %scos(%.1f t + %.2f)',Astr,FoNout,PhOut),'Interpreter','tex');
        end
    end
else
    if h.MATLABVER>=8.4
        if abs(h.phaseN)<1e-3
            set(h.TextIn,'String',['Input: $$\bf x(t)=\cos\left(2\pi(' sprintf('%.1f',FoN) ')\,t\right)$$'],'Interpreter','Latex');
            set(h.TextMiddle,'String',['$$\bf x[n] = \cos\left(2\pi(' sprintf('%.2f',R) ')\,n\right)$$'],'Interpreter','Latex');
        elseif h.phaseN<0
            set(h.TextIn,'String',['Input: $$\bf x(t)=\cos\left(2\pi(' sprintf('%.1f',FoN) ')\,t - ' sprintf('%.2f',-h.phaseN) '\right)$$'],'Interpreter','Latex');
            set(h.TextMiddle,'String',['$$\bf x[n] = \cos\left(2\pi(' sprintf('%.2f',R) ')\,n - ' sprintf('%.2f',-h.phaseN) '\right)$$'],'Interpreter','Latex');
        elseif h.phaseN>0
            set(h.TextIn,'String',['Input: $$\bf x(t)=\cos\left(2\pi(' sprintf('%.1f',FoN) ')\,t + ' sprintf('%.2f',h.phaseN) '\right)$$'],'Interpreter','Latex');
            set(h.TextMiddle,'String',['$$\bf x[n] = \cos\left(2\pi(' sprintf('%.2f',R) ')\,n + ' sprintf('%.2f',h.phaseN) '\right)$$'],'Interpreter','Latex');
        end
    else
        if abs(h.phaseN)<1e-3
            set(h.TextIn,'String',sprintf('Input: x(t) = cos(2\\pi %.1f t)',FoN),'Interpreter','tex');
            set(h.TextMiddle,'String',sprintf('x[n] = cos(2\\pi %.2f n)',R),'Interpreter','tex');
        elseif h.phaseN<0
            set(h.TextIn,'String',sprintf('Input: x(t) = cos(2\\pi %.1f t - %.2f)',FoN,-h.phaseN),'Interpreter','tex');
            set(h.TextMiddle,'String',sprintf('x[n] = cos(2\\pi %.2f n - %.2f)',R,-h.phaseN),'Interpreter','tex');
        elseif h.phaseN>0
            set(h.TextIn,'String',sprintf('Input: x(t) = cos(2\\pi %.1f t + %.2f)',FoN,h.phaseN),'Interpreter','tex');
            set(h.TextMiddle,'String',sprintf('x[n] = cos(2\\pi %.2f n + %.2f)',R,h.phaseN),'Interpreter','tex');
        end
    end
    %
    FoNout = abs(FoNm);
    if h.MATLABVER>=8.4
        if abs(PhOut)<1e-3
            set(h.TextOut,'String',['Output: $$\bf y(t)=' sprintf('%s',Astr) '\cos\left(2\pi(' sprintf('%.1f',FoNout) ')\,t\right)$$'],'Interpreter','Latex');
        elseif abs(abs(PhOut)-pi)<1e-3
            set(h.TextOut,'String',['Output: $$\bf y(t)=' sprintf('%s',Astr) '\cos(2\pi\left(' sprintf('%.1f',FoNout) ')\,t + \pi\right)$$'],'Interpreter','Latex');
        elseif PhOut<0
            set(h.TextOut,'String',['Output: $$\bf y(t)=' sprintf('%s',Astr) '\cos(2\pi\left(' sprintf('%.1f',FoNout) ')\,t - ' sprintf('%.2f',-PhOut) '\right)$$'],'Interpreter','Latex');
        elseif PhOut>0
            set(h.TextOut,'String',['Output: $$\bf y(t)=' sprintf('%s',Astr) '\cos(2\pi\left(' sprintf('%.1f',FoNout) ')\,t + ' sprintf('%.2f',PhOut) '\right)$$'],'Interpreter','Latex');
        end       
    else
        if abs(PhOut)<1e-3
            set(h.TextOut,'String',sprintf('Output: y(t) = %scos(2\\pi %.1f t)',Astr,FoNout));
        elseif abs(abs(PhOut)-pi)<1e-3
            set(h.TextOut,'String',sprintf('Output: y(t) = %scos(2\\pi %.1f t + \\pi)',Astr,FoNout));
        elseif PhOut<0
            set(h.TextOut,'String',sprintf('Output: y(t) = %scos(2\\pi %.1f t - %.2f)',Astr,FoNout,-PhOut));
        elseif PhOut>0
            set(h.TextOut,'String',sprintf('Output: y(t) = %scos(2\\pi %.1f t + %.2f)',Astr,FoNout,PhOut));
        end
    end
end

FoNout = FoNm;