function hide(c)
% @MOVIECONTROLS/HIDE Hides extended movie controls.  
%
% See also @MOVIECONTROLS/... SHOW, CONFIGURE

% Author(s): Greg Krudysz     

MATLABVERSION = version;
MATLABVERSION = str2num(MATLABVERSION(1:3));

% --- Change Figure Units & disable ResizeFcn ---%
oldUnits = get(c.fig,'units');
oldResizeFcn = get(c.fig,'ResizeFcn');          
set(c.fig,'units','pixels','ResizeFcn','');
set([c.Hide,c.HideA(1:2),c.HideAu(1)],'units','pixels');

hGroup = findobj(c.fig,'units','normalized');
hGroup_vis = get(hGroup,'visible');
set(hGroup(2:end),'vis','off');
set(hGroup,'Units','Pixels');
hGroup_pos = get(hGroup,'position');

L = length(hGroup_pos);        

FigPos = get(c.fig,'Position');
FigPosNew = [FigPos(1) FigPos(2)+c.extendby*FigPos(4)/(c.extendby+1) ...
        FigPos(3) FigPos(4)/(c.extendby+1)];
figdiff = FigPos(4)-FigPosNew(4);

for k = 1:L
    if MATLABVERSION<8.4
        if or(strcmp(get(hGroup(k),'type'),'uicontrol') , strcmp(get(hGroup(k),'type'),'axes'))
            set(hGroup(k),'position',[0 -figdiff 0 0] + hGroup_pos{k,:});
        end
    else
        if or(isgraphics(hGroup( k ),'uicontrol') , isgraphics(hGroup( k ),'axes'))
            set(hGroup(k),'position',[0 -figdiff 0 0] + hGroup_pos{k,:});
        end
    end
end
% re-center figure
%         ScreenSize = get(0,'screensize');    
%         NewFigPos = [(ScreenSize(3)-FigSizeNew(3))/2 (ScreenSize(4)-FigSizeNew(4))/2 FigSizeNew(3) FigSizeNew(4)];

set(c.fig,'position',FigPosNew,'units',oldUnits,'ResizeFcn',oldResizeFcn);
set(hGroup,'Units','normalized',{'vis'},hGroup_vis);
set([c.Hide,c.HideA],'visible','off');
set([c.Hide,c.HideA(1:2),c.HideAu(1)],'units','norm');