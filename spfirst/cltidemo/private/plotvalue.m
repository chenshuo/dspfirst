function plotvalue(action,XLabel,YLabel)
%PLOTVALUE Create right-click popup to show plot values.
%   PLOTVALUE(hLine,XLabel,YLabel) is a function that enhances
%   the display of plots.  When the user right-clicks on a line with
%   handle hLine, text will popup at the mouse location giving the x
%   and y values of plot at that point.
%
%   The variables XLabel and YLabel are strings used in the text of the
%   popup.  Both the XLabel and YLabel arguments should be passed as an
%   input or they should both be left out.  Leaving out the two variables
%   implies the defaults XLabel = 'x' and YLabel = 'y' will be used.
%
%   For example,
%
%       h = plot(0:5,1:6);
%       xlabel('t (sec)');
%       ylabel('Amplitude');
%       plotvalue(h,'t','Amplitude');
%
%   If the user then right-clicks on the line at t=2, a popup box
%   would display:
%
%       't = 2'
%       'Amplitude = 3'
%
%   See also PLOT

% Jordan Rosenthal, jr@ece.gatech.edu
%    18-May-2000 (Based on STEMVALUE dated 30-Jun-1999)
%    28-Jun-2000 Fixed some errors in comments and added forgotten semicolon
%    31-Mar-2001 Really fixed the forgotten semicolon this time.
%    Rev. Greg Krudysz 4-Mar-2015 : Fixed "cd" bug for spaces in filename

if ~isstr(action)
    hLine = action;
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
        
        myPath = which(mfilename);
        MyDir = myPath(1:end-12);
        CallingDir = evalin('caller','pwd');
        if strcmp(MyDir,CallingDir)
            % plotvalue.m in same directory as calling function so is in path
            sCallback = 'plotvalue ShowXY';
        else
            % plotvalue.m not in same directory so it may not be in path when called
            % This is especially true if it is within a private directory
            sCallback = [ ...
                'cd(''' MyDir ''');' ...
                'feval(''plotvalue'',''ShowXY'');' ...
                'cd(''' CallingDir ''');' ];
        end
        
        hCMenu = uicontextmenu('Callback',sCallback);
        hXMenu = uimenu(hCMenu);
        hYMenu = uimenu(hCMenu);
        h.Menus = [hXMenu; hYMenu];
        set(hCMenu,'UserData',h);
        
        set(hLine,'uicontextmenu',hCMenu);
        
    case 'ShowXY'
        
        h = get(gcbo,'UserData');
        CurrPt = get(gca,'CurrentPoint');
        [x,y] = deal(CurrPt(1,1),CurrPt(1,2));
        sx = [ h.XLabel num2str(x) ];
        sy = [ h.YLabel num2str(y) ];
        set(h.Menus,{'Label'},{sx; sy});
        
    otherwise
        error('Illegal action.');
end
