function h = fig4update(h)
fs = get(h.slider2,'value')/60;
fm = get(h.slider1,'value')/60;

%Axes 2
set(h.p2,'visible','off','xdata',[-fs/2 fs/2 fs/2 -fs/2],'parent',h.axes2);
set(h.axes2,'xlim',[-1.5*fs,1.5*fs],'xtick',(-fs:fs:fs),'XTickLabel',{-fs,0,fs},'ylim',[0 1.5]);
set(h.p2,'visible','on');

%Axes5
set(h.line5,'color','b');
set(h.p5,'visible','off','xdata',[-fs/2 fs/2 fs/2 -fs/2],'parent',h.axes5);
set(h.axes5,'xlim',[-1.5*fs,1.5*fs],'xtick',(-fs:fs:fs),'XTickLabel',{-fs,0,fs},'ylim',[0 1.5]);
set(h.p5,'visible','on');

what = 2*pi*-fm/fs;
%Axes 3
%delta text
phin = pi/4 - (2*pi*fm/fs); % change initial loc as needed

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Enable these 2 lines if you want to display the full angle
% deltstr = sprintf('%.1f',what*180/pi);
% set(h.text13,'String',deltstr);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if what >= -pi % no aliasing
    %Axes 4
    %flag ='noal';
    set(h.line4w,'visible','on');
    set([h.line4a,h.text11],'visible','off');
    set(h.line4w(1),'Xdata',what);
    set(h.line4w(2),'Xdata',[what,what,NaN]);
    set(h.line4wa1(1),'Xdata',[what+2*pi,what+2*pi]);
    set(h.line4wa2(1),'Xdata',[what-2*pi,what-2*pi]);
    
    %     fsstr = sprintf('%.1f',fs);
    %     set(h.text9,'String',fsstr);
    
    set([h.line3v],'color','b'); %cannot combine since the matrices have different dimensions
    set(h.semi3c,'color','b');
    set(h.text33,'foregroundcolor',[0 0 1]);
    %set(h.line3d(2),'visible','on','color','b');
    set(h.line3d,'vis','on');
    set(h.line3d(1),'color','b');
    set(h.line3d(2),'facecolor','b');
    
    set(h.line3dalias(2),'visible','off');
    set(h.line5(1),'xdata',-fm,'color','b','markerfacecolor','b');
    set(h.line5(2),'xdata',[-fm,-fm,nan],'color','b');
else
    %flag = 'al';
    set(h.text11,'visible','on');
    c = 0;
    walias = what;
    while walias < -pi 
        walias = walias + 2*pi;
        c=c+1;
    end
    if c == 1 %the non-alias still falls within the viewing range
        set(h.line4w,'visible','on');
        set(h.line4a,'visible','off');
        set(h.line4w(1),'Xdata',what);
        set(h.line4w(2),'Xdata',[what,what,NaN]);
        set(h.line4wa1,'Xdata',[walias,walias]);
        set(h.line4wa2,'Xdata',[walias+2*pi,walias+2*pi]);
    else
        set(h.line4w,'visible','off');
        set(h.line4a,'visible','on');
        set(h.line4wa1,'Xdata',[walias,walias]);
        set(h.line4wa2,'Xdata',[walias+2*pi,walias+2*pi]);
        set(h.line4a,'Xdata',[walias-2*pi,walias-2*pi]); 
    end
    if walias > 0
        set(h.line3dalias(2),'visible','on');
        set(h.line3d,'visible','off');
    else
        set(h.line3d,'visible','on');
        set(h.line3d(1),'color','r');
        set(h.line3d(2),'facecolor','r');
        set(h.line3dalias(2),'visible','off');
    end
    
    %%axes 5
    falias = walias * fs/ (2*pi);
    set(h.line5(2),'xdata',[falias,falias,nan],'color','r');
    set(h.line5(1),'xdata',falias,'color','r','MarkerFaceColor','r');
    if (c > 0)
        set(h.line5,'color','r');
    end
%     fsstr = sprintf('%.1f',fs);
%     set(h.text19,'String',fsstr);
    set([h.line3v],'color','r');
    set(h.semi3c,'color','r');
    set(h.text33,'foregroundcolor',[1 0 0]);
end

%Change the text in the middle of the screen
%text 27 f = 12.5Hz (750 rpm) motor
%text 26 f = 75Hz (4500 rpm)  flashes
fs = get(h.edit7,'String');
fm = get(h.edit2,'String');
fpm = get(h.edit6,'String');
rpm = get(h.edit1,'String');
set(h.text27,'String',['f = ',fm,'Hz ','(',rpm,' rpm)']);
set(h.text26,'String',['f = ',fs,'Hz ','(',fpm,' flash/min)']);

%Axes 3
axes(h.axes3);
deltstr = sprintf('%.1f',what*180/pi);
delt = str2double(deltstr);
while delt > 360
    delt = delt - 360;
end
while delt < -360
    delt = delt + 360;
end
if delt < -180
    delt = 360+delt;
end
if delt > 180 
    delt = 360-delt;
end

%display the angle next to the figure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Enable this if only the apparent angle needs to be displayed
set(h.text13,'String',delt);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%figure
phin2 = phin + delt*pi/180;
phin3 = phin2 + delt*pi/180;

%%%%%%%%% 1st Arrow %%%%%%%%%%%%%%%%
tt = arrow(phin,'line',.25,.1); 
set(tt,'visible','off');
set(h.line3n(1),'xdata',get(tt(1),'xdata'));
set(h.line3n(1),'ydata',get(tt(1),'ydata'));

set(h.line3n(2),'xdata',get(tt(2),'xdata'));
set(h.line3n(2),'ydata',get(tt(2),'ydata'));

set(h.line3n(3),'xdata',get(tt(3),'xdata'));
set(h.line3n(3),'ydata',get(tt(3),'ydata'));

%%%%%%%%% 2nd Arrow %%%%%%%%%%%%%%%%
tt = arrow(phin2,'line',.25,.1); 
set(tt,'visible','off');
set(h.line3n2(1),'xdata',get(tt(1),'xdata'));
set(h.line3n2(1),'ydata',get(tt(1),'ydata'));

set(h.line3n2(2),'xdata',get(tt(2),'xdata'));
set(h.line3n2(2),'ydata',get(tt(2),'ydata'));

set(h.line3n2(3),'xdata',get(tt(3),'xdata'));
set(h.line3n2(3),'ydata',get(tt(3),'ydata'));

%%%%%%%%% 3rd Arrow %%%%%%%%%%%%%%%%
tt = arrow(phin3,'line',.25,.1); 
set(tt,'visible','off');
set(h.line3n3(1),'xdata',get(tt(1),'xdata'));
set(h.line3n3(1),'ydata',get(tt(1),'ydata'));

set(h.line3n3(2),'xdata',get(tt(2),'xdata'));
set(h.line3n3(2),'ydata',get(tt(2),'ydata'));

set(h.line3n3(3),'xdata',get(tt(3),'xdata'));
set(h.line3n3(3),'ydata',get(tt(3),'ydata'));


set([h.line3n,h.line3n2,h.line3n3],'visible','on');
set([h.text33,h.text30,h.text31,h.text32],'visible','on');
if delt < 0 
    if abs(delt) < 120 %was 100
        %display 4 arrows
    elseif abs(delt) < 180 %was 140 
        %display 3 arrows
        set([h.line3n3],'visible','off');
        set(h.text32,'visible','off');    
    elseif abs(delt) < 180
        %disply 2 arrows
        set([h.line3n3,h.line3n2],'visible','off');
        set([h.text32,h.text31],'visible','off');
    end
else
    if delt > 180%was 140
        %display 2 arrows
        set([h.line3n3,h.line3n2], 'visible','off');        
        set([h.text32,h.text31], 'visible','off');        
    elseif delt > 120%was 100 
        %display 3 arrows
        set([h.line3n3],'visible','off');
        set([h.text32],'visible','off');
    end
end