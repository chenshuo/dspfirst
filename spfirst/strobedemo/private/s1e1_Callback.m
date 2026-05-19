%=============================================================
function [fm,fs] = s1e1_Callback(fn,h,motor)
%=============================================================
if strcmp(fn,'s')
    if motor %adjusting the frequency slider
        freqpermin = get(h.slider1,'Value');
        freqperminstr = sprintf('%.1f',freqpermin);    
        set(h.edit1,'String',freqperminstr);    
        freq = freqpermin/60;
        freqstr = sprintf('%.1f',freq);
        set(h.edit2,'String',freqstr);    
    else %adjusting the flash frequency
        freqpermin = get(h.slider2,'value');
        freqperminstr = sprintf('%.1f',freqpermin);
        set(h.edit6,'String',freqperminstr);
        freq = freqpermin/60;
        freqstr = sprintf('%.1f',freq);
        set(h.edit7,'String',freqstr);    
    end
elseif strcmp(fn,'e1') %editbox for the frequencies per min
    if motor %rotations per min
        rpmstr = get(h.edit1,'String');
        rpm = str2double(rpmstr);
        rpmMax = get(h.slider1,'Max');
        rpmMin = get(h.slider1,'Min');    
        rpm = min(rpm,rpmMax);
        rpm = max(rpm,rpmMin);
        frpm = rpm/60;
        set(h.slider1,'Value',rpm);
        rpmstr = sprintf('%.1f',rpm);
        frpmstr = sprintf('%.1f',frpm);
        set(h.edit1,'String',rpmstr);
        set(h.edit2,'String',frpmstr);
    else  %flashes per min
        rpmstr = get(h.edit6,'String');
        rpm = str2double(rpmstr);
        rpmMax = get(h.slider2,'Max');
        rpmMin = get(h.slider2,'Min');    
        rpm = min(rpm,rpmMax);
        rpm = max(rpm,rpmMin);
        frpm = rpm/60;
        set(h.slider2,'Value',rpm);
        rpmstr = sprintf('%.1f',rpm);
        frpmstr = sprintf('%.1f',frpm);
        set(h.edit6,'String',rpmstr);
        set(h.edit7,'String',frpmstr);
    end
    
else %edit box for the motor frequency
    if motor %motor frequency
        frpmstr = get(h.edit2,'String');
        frpm = str2double(frpmstr);
        rpm = frpm*60;
        rpmMax = get(h.slider1,'Max');
        rpmMin = get(h.slider1,'Min');    
        rpm = min(rpm,rpmMax);
        rpm = max(rpm,rpmMin);
        frpm = rpm/60;
        set(h.slider1,'Value',rpm);
        rpmstr = sprintf('%.1f',rpm);
        frpmstr = sprintf('%.1f',frpm);
        set(h.edit1,'String',rpmstr);
        set(h.edit2,'String',frpmstr);
    else %flash frequency
        frpmstr = get(h.edit7,'String');
        frpm = str2double(frpmstr);
        rpm = frpm*60;
        rpmMax = get(h.slider2,'Max');
        rpmMin = get(h.slider2,'Min');    
        rpm = min(rpm,rpmMax);
        rpm = max(rpm,rpmMin);
        frpm = rpm/60;
        set(h.slider2,'Value',rpm);
        rpmstr = sprintf('%.1f',rpm);
        frpmstr = sprintf('%.1f',frpm);
        set(h.edit6,'String',rpmstr);
        set(h.edit7,'String',frpmstr);
    end
end

   fm = get(h.slider1,'value')/60;
   fs = get(h.slider2,'value')/60;
 if motor
    set(h.line2(1),'Xdata',-fm);
    set(h.line2(2),'Xdata',[-fm,-fm,NaN]);
else
%   do nothing
 end