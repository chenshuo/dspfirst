function handlesout = plot_imp(handles)
% Plot Impulse Response.

pt = length(handles.hn);
x = 0:pt-1;
tempi = imag(handles.hn);

xx = zeros(1,3*pt);
xx(1:3:3*pt) = x;
xx(2:3:3*pt) = x;
xx(3:3:3*pt) = NaN;

tol = 0.0001;
if all(abs(tempi)<tol)
    set([handles.lineimpimg_cir, handles.showplot_h.lineimpimg_cir],'Visible','off');
    set([handles.lineimpimg_lin, handles.showplot_h.lineimpimg_lin],'Visible','off');
    set(findall(0,'tag','system_real'),'String','real','ForegroundColor',[0,0,0]);
else
    yy = zeros(1,3*pt);
    yy(2:3:3*pt) = tempi;
    yy(3:3:3*pt) = NaN;
    set ([handles.axes_imp, handles.showplot_h.axes_imp], ...
         'XLim',[0,pt],'YLim',[min([-1,yy,tempi])*1.2, max([1,yy,tempi])*1.2]);
    set([handles.lineimpimg_cir, handles.showplot_h.lineimpimg_cir],'XData',x,'YData',tempi,'Visible','on');
    set([handles.lineimpimg_lin, handles.showplot_h.lineimpimg_lin],'XData',xx,'YData',yy,'Visible','on');
    set(findall(0,'tag','system_real'),'String','imaginary','ForegroundColor',[1,0,0]);
end

yy = zeros(1,3*pt);
yy(2:3:3*pt) = real(handles.hn);
yy(3:3:3*pt) = NaN;

set ([handles.axes_imp, handles.showplot_h.axes_imp], ...
    'XLim',[0,pt],'YLim',[min([-1,yy])*1.2, max([1,yy])*1.2]);
set ([handles.lineimp_cir, handles.showplot_h.lineimp_cir],'XData',x,'YData',real(handles.hn));
set ([handles.lineimp_lin, handles.showplot_h.lineimp_lin],'XData',xx,'YData',yy);

if isempty(find(((real(handles.poleloc).^2 + imag(handles.poleloc).^2) - 1) > tol))
    set(findall(0,'tag','system_stable'),'String','stable','ForegroundColor',[0,0,0]);
else
    set(findall(0,'tag','system_stable'),'String','unstable','ForegroundColor',[1,0,0]);
end

handlesout = handles;

