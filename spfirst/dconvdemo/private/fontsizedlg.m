function fontsize = fontsizedlg(action)
%FONTSIZEDLG Font size dialog box.
%  w = FONTSIZEDLG creates a modal dialog box that returns the font size
%  of the font selected in the dialog box.
%
%  w = FONTSIZEDLG(x) uses the default font size of x.  Set x >= 8

% Revision 1.1,     12/16/2014 Greg Krudysz (based on linewidthdlg.m)
% Revision 1.2,      1/24/2015 Greg Krudysz R2014b

if nargin == 1 & isstr(action)
    %------------------------%
    % Perform action
    %------------------------%
    switch action
        case 'SetFontSize'
            hTx = findobj(gcbf,'Type','text');
            hAx = findobj(gcbf,'Type','axes');
            SliderValue = get(findobj(gcbf,'Style','slider'), 'Value');
            set([hTx;hAx;get(hAx,'Title')], 'FontSize', SliderValue);
        case 'OK'
            set(gcbf,'UserData',1);
        otherwise
            error('Illegal action');
    end
elseif nargin == 0 | ~isstr(action)
    if nargin == 0
        DefFontSize = get(0,'DefaultAxesFontSize');
    elseif action >= 8
        DefFontSize = action;
    else
        error('Illegal value for default font size.');
    end
    ver = version;
    %------------------------%
    % Setup Dialog
    %------------------------%
    OldUnits = get(0, 'Units');
    set(0, 'Units','pixels');
    ScreenSize = get(0,'ScreenSize');
    set(0, 'Units', OldUnits);
    DlgPos = [0.35*ScreenSize(3), 0.325*ScreenSize(4), 0.3*ScreenSize(3), 0.35*ScreenSize(4)];
    dlg_color = get(0,'defaultfigurecolor');
    hDlg = dialog( ...
        'Color',dlg_color, ...
        'Name','Font Size', ...
        'CloseRequestFcn','fontsizedlg OK', ...
        'Position',DlgPos, ...
        'UserData',0);
    %------------------------%
    % Setup Axis
    %------------------------%
    hAxes = axes('Parent',hDlg,'box','on', ...
        'NextPlot','Add', ...
        'Position',[0.15 0.35 0.7 0.55], ...
        'Xlim',[-3 3],'Ylim',[-0.28 2], ...
        'FontUnits','points', ...
        'FontSize',DefFontSize);
    title('Set Font Size');
    hText = text(1,1.5,'$$\leftarrow\frac{\sin(\pi n)}{(\pi n)}$$','parent',hAxes,'interpreter','latex','FontSize',DefFontSize);
    %------------------------%
    % Setup Lines
    %------------------------%
    xdata = kron([-3:0.3:3],[1 1 NaN]);
    peak_idx = find(xdata == 0);
    xdata(peak_idx) = 1;
    ydata = sin(3*xdata(xdata ~= 0))./(3*xdata(xdata ~= 0));
    ydata(peak_idx) = 1;
    xdata(peak_idx) = 0;
    line_markers = line(xdata,ydata,'Parent',hAxes,'marker','d');
    ydata(1:3:end) = 0;
    line_stems = line(xdata,ydata,'Parent',hAxes,'color','r');
    
    xdata = [-pi:0.1:pi];
    zero_idx = find(xdata == 0);
    xdata(zero_idx) = 1;
    ydata = sin(3*xdata)./(3*xdata);
    ydata(zero_idx) = 1;
    for k = 1:6
        line_cos = line(xdata,k^(0.75)*0.25 + ydata ,'Parent',hAxes,'color',[0 0 1/sqrt(k)]);
    end
    %------------------------%
    % Setup Slider
    %------------------------%
    hSlider = uicontrol('Parent',hDlg, ...
        'Units','Normalized', ...
        'Callback','fontsizedlg SetFontSize', ...
        'Min',8, ...
        'Max',16, ...
        'Position',[0.15 0.17 0.7 0.07], ...
        'SliderStep',[0.1 0.2], ...
        'Style','slider', ...
        'Value',DefFontSize );
    %------------------------%
    % Setup OK Button
    %------------------------%
    uicontrol('Parent',hDlg, ...
        'Units','normalized', ...
        'Callback','fontsizedlg OK', ...
        'FontWeight','Bold', ...
        'Position',[0.375 0.04 0.25 0.1], ...
        'String','OK', ...
        'Style','pushbutton');
    %------------------------%
    % Wait for user to hit OK and return result
    % For some reason I can't use just waitfor() and uiresume() when this
    % function is in a private directory.
    waitfor(hDlg,'UserData');
    fontsize = get(hSlider, 'Value');
    delete(hDlg);
else
    error('Too many input arguments.');
end