function handlesout = plot_gph(handles)
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
    %    set([handles.unstable, handles.showplot_h.unstable],'Visible','off');
    set([handles.pzpatch, handles.showplot_h.pzpatch, handles.ucpatch, handles.showplot_h.ucpatch],'Visible','off')
else
    set(findall(0,'tag','system_stable'),'String','unstable','ForegroundColor',[1,0,0]);
    %    set([handles.unstable', handles.showplot_h.unstable'],'Visible','on');
    set([handles.pzpatch, handles.showplot_h.pzpatch, handles.ucpatch, handles.showplot_h.ucpatch],'Visible','on')
end

% Plot Frequency Response(Magnitude).
pt = length(handles.hn);
x = 0:pt-1;

set ([handles.axes_mag, handles.showplot_h.axes_mag], ...
    'XLim', [-pi,pi], 'YLim', [min([-1,abs(handles.hz)])*1.2, max([2,abs(handles.hz)])*1.2], ...
    'Xtick',[-pi -pi/2 0 pi/2 pi]);
if handles.MATLABVER<8.4
    set([handles.axes_mag, handles.showplot_h.axes_mag],'FontName','Symbol','XTickLabel',{'-p';'-p/2';'0';'p/2';'p'});
else
    set([handles.axes_mag, handles.showplot_h.axes_mag],'XTickLabel',{'-\pi';'-0.5\pi';'0';'0.5\pi';'\pi'});
end

set(handles.lineray.mag,'Ydata',[min([-1,abs(handles.hz)])*1.2, max([2,abs(handles.hz)])*1.2]);

% Plot Frequency Response(Phase).
set ([handles.axes_phase, handles.showplot_h.axes_phase], ...
    'XLim', [-pi,pi], 'YLim', [min([-pi,angle(handles.hz)])*1.2, max([pi,angle(handles.hz)])*1.2], ...
    'Xtick',[-pi -pi/2 0 pi/2 pi]);

if handles.MATLABVER<8.4
    set([handles.axes_phase, handles.showplot_h.axes_phase],'FontName','Symbol','XTickLabel',{'-p';'-p/2';'0';'p/2';'p'});
else
    set([handles.axes_phase, handles.showplot_h.axes_phase],'XTickLabel',{'-\pi';'-0.5\pi';'0';'0.5\pi';'\pi'});
end

set ([handles.linemag, handles.showplot_h.linemag], ...
    'XData', -pi : 2*pi/length(abs(handles.hz)) : pi-2*pi/length(abs(handles.hz)), ...
    'YData', abs(handles.hz));
set ([handles.linephase, handles.showplot_h.linephase], ...
    'XData', -pi : 2*pi/length(abs(handles.hz)) : pi-2*pi/length(abs(handles.hz)), ...
    'YData', angle(handles.hz));

set([handles.linepezpole, handles.showplot_h.linepezpole],...
    'XData',[real(handles.poleloc), handles.pole0],...
    'YData',[imag(handles.poleloc), handles.pole0]);
set([handles.linepezzero, handles.showplot_h.linepezzero],...
    'XData',[real(handles.zeroloc), handles.zero0],...
    'YData',[imag(handles.zeroloc), handles.zero0]);

handlesout = handles;

% Check axes_pzplot limits
pezdemo('axis_limit_check',[],[],handles);