function obj = spfirst_error(hParent,objpos,msgType,msg,varargin)
% spfirst_dialog - internal error dialog
%
% spfirst_dialog
% spfirst_dialog(hFigure)
% spfirst_dialog(hFigure,'property_name','property_value', ...)
% obj = spfirst_dialog
%
%   METHODS:
%
%   spfirst_dialog  Constructor
%   get             Get object property
%   set             Set object property
%
%   See also ... @spfirst_dialog\ ... get, set

% Author(s): Greg Krudysz
% Revision: 0.2  Date: 4-Dec-2007
%
% NOTES: implemented in filterdesign ver 2.66
%==============================================================

if nargin > 0 & isa(hParent,mfilename)
    % Load object from figure data 'spfirst_dialog_DATA'
    obj = getappdata(hobj,[mfilename '_DATA']);
else
    % Private Data (OD: object data)
    if nargin == 0
        hParent = figure;
        objpos  = [0.2 0.1 0.7 0.1];
        msgType = 'warn';  % error | warn | help
        msg = 'This is an error!';
    end

    % Handle objects
    OD.Figure = hParent;    
    OD.Object = axes('parent',OD.Figure,'units','norm','pos',objpos,'xtick',[],'ytick',[],'box','on');
    OD.Icon   = axes('parent',OD.Figure,'units','norm','pos',[objpos(1)-objpos(4)-0.01 objpos(2) objpos(4) objpos(4)], ...
        'xtick',[],'ytick',[],'box','off','vis','off','userdata',msgType);
    OD.Img    = image('cdata',eye(50,50),'parent',OD.Icon);
    OD.Text   = text('parent',OD.Object,'pos',[0.5 0.5],'string',msg,'fontunits','norm','fontsize',0.45, ...
                    'Horiz','center');
                
    del = 0.001;
    OD.Close = uicontrol('parent',OD.Figure,'units','norm','back','w','foreg','k','str','', ...
        'pos',[objpos(1)+objpos(3)-0.3*objpos(4)-del objpos(2)+0.7*objpos(4)-1.5*del 0.3*objpos(4) 0.3*objpos(4)], ... 
    'callback',['buttonfcn(getappdata(gcbf,''' mfilename '_DATA''),''ButtonDown'')']);            
                
%    OD.Button = uicontrol(button,'buttondown',['buttonfcns(getappdata(gcbf,''' mfilename OD.var '_DATA''),''ButtonDown'')'] );
%    OD.Close  = axes('parent',OD.Figure,'units','norm', ...
%         'pos',[objpos(1)+objpos(3)-0.25*objpos(4) objpos(2)+0.75*objpos(4) 0.25*objpos(4) 0.25*objpos(4)], ...
%         'xtick',[],'ytick',[],'box','on','vis','off');
    %x1 = line('parent',OD.Close,'xdata',[0.1 0.9],'ydata',[0.1 0.9],'linewidth',1);
    %x2 = line('parent',OD.Close,'xdata',[0.1 0.9],'ydata',[0.9 0.1],'linewidth',1);
%    OD.CloseT = text('parent',OD.Close,'pos',[0.45 0.45],'string','x','fontunits','norm'); 
    
    % Class constructor
    obj = class(OD,mfilename);

    % Update object properties
    if nargin > 0
        set(obj,varargin{1:end});
    end

    OD = set(obj,'type',msgType);
    
    % Save spfirst object to figure data 'spfirst_dialog_DATA'
    setappdata(OD.Figure,[mfilename '_DATA'],obj);
end

% n = 0;
% while(n < 3)
%     p = 0.005*cos(n*pi);
%     set(hErr,'pos',[0.2+p 0.1 0.7 0.1]);
%     set(hIco,'pos',[0.1+p 0.1 0.1 0.1]);
%     n = n+1;
%     pause(0.1)
% end