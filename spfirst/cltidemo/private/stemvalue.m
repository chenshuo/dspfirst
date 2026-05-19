function stemvalue(action,XLabel,YLabel)
%STEMVALUE Create right-click popup to show stem plot values.
%   STEMVALUE(hStemPlot,XLabel,YLabel) is a function that enhances
%   the display of plots created with the stem command.  When the
%   user right-clicks on the stem or marker of the stem plot, text
%   will popup at the mouse location giving the x and y values of
%   the stem plot at that point.
%
%   The input variable hStemPlot should be the vector of handles
%   returned by the stem command.  The variables XLabel and YLabel
%   are strings used in the text of the popup.  Both the XLabel and
%   YLabel arguments should be passed as an input or they should both
%   be left out.  Leaving out the two variables implies the defaults
%   XLabel = 'x' and YLabel = 'y' will be used.
%
%   For example,
%
%       h = stem(0:5,1:6);
%       xlabel('t (sec)');
%       ylabel('Amplitude');
%       stemvalue(h,'t','Amplitude');
%
%   If the user then right-clicks on the x=2 stem line, a popup box
%   would display:
%
%       't = 2'
%       'Amplitude = 3'
%
%   See also STEM

% Rev. Greg Krudysz 4-Mar-2015 : Fixed "cd" bug for spaces in filename
% Jordan Rosenthal, 6/30/99

if ~isstr(action)
    hStemPlot = action;
    action = 'Initialize';
end

switch action
    case 'Initialize'
        if nargin == 1
            h.XLabel = 'x = ';
            h.YLabel = 'y = ';
        else           
            ver = version;
            if str2num(ver(1:3)) < 8
                error(nargchk(3,3,nargin));  %-- Error check number of input arguments
            else
                narginchk(3,3);
            end
            
            h.XLabel = [XLabel ' = '];
            h.YLabel = [YLabel ' = '];
        end
        
        myPath = which('stemvalue.m');
        MyDir = myPath(1:end-12);
        CallingDir = evalin('caller','pwd');
        if strcmp(MyDir,CallingDir)
            % stemvalue.m in same directory as calling function so is in path
            
            sCallback = 'stemvalue ShowXY';
            
        else
            % stemvalue.m not in same directory so it may not be in path when called            
            % This is especially true if it is within a private directory.
            
            sCallback = [ ...
                'cd(''' MyDir ''');' ...
                'feval(''stemvalue'',''ShowXY'');' ...
                'cd(''' CallingDir ''';' ];            
        end
        
        hCMenu = uicontextmenu('Callback',sCallback);
        hXMenu = uimenu(hCMenu);
        hYMenu = uimenu(hCMenu);
        h.Menus = [hXMenu; hYMenu];
        h.Markers = hStemPlot(1);
        set(hCMenu,'UserData',h);
        
        set(hStemPlot,'uicontextmenu',hCMenu);
        
    case 'ShowXY'
        
        h = get(gcbo,'UserData');
        CurrPt = get(gca,'CurrentPoint');
        [x,y] = deal(CurrPt(1,1),CurrPt(1,2));
        XData = get(h.Markers,'XData');
        YData = get(h.Markers,'YData');
        [m,k] = min(abs(XData-x));
        sx = [ h.XLabel num2str(XData(k)) ];
        sy = [ h.YLabel num2str(YData(k)) ];
        set(h.Menus,{'Label'},{sx; sy});
        
    otherwise
        error('Illegal action.');
end