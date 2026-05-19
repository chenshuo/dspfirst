function show(c)
% @MOVIECONTROLS/SHOW Show movie controls by extending the GUI.  
%
% See also @MOVIECONTROLS/... SHOW, CONFIGURE

% Author(s): Greg Krudysz
% 

% NOTE: In order for movietool to display correctly set all object 'unit'
%       property to 'normalized'.
    
    % --- Change Figure Units & disable ResizeFcn ---%
    oldUnits = get(c.fig,'units');
    oldResizeFcn = get(c.fig,'ResizeFcn');          
    set(c.fig,'units','pixels','ResizeFcn','');
    set([c.Hide,c.HideA(1:2),c.HideAu(1)],'units','pixels');
    
    % ---- Find all other objects -------------------% 
    hGroup = findobj(c.fig,'units','normalized');
    set(hGroup,'units','pixels');
    Group = struct('position',{get(hGroup,'position')},'visible',{get(hGroup,'vis')},'type',{get(hGroup,'type')}); 
    FigPos = get(c.fig,'Position');
    FigPosNew = FigPos + [0 -c.extendby*FigPos(4) 0 c.extendby*FigPos(4)];   
    figdiff = c.extendby*FigPos(4);
    
    for k = 1:length(hGroup);
        if any(strcmp(Group.type(k),{'uicontrol','axes'}))
            if strcmp(Group.type(k),'axes')    
                set(hGroup(k),'position',[0 figdiff 0 0] + Group.position{k}); 
            else 
                set(hGroup(k),'vis','off','position',[0 figdiff 0 0] + Group.position{k});
            end
        end
    end
    
    % re-center figure if outside of screen
    ScrnPos = get(0,'screensize');    
    if or(FigPosNew(2) < 0 , (FigPosNew(2)+FigPosNew(4) > ScrnPos) )
        % NEED CODE HERE           
    end
    
    if strcmp('None Available',get(c.text,'string'))
        % Reposition REC and LOADFILE buttons
        %                 init_objs = [handles.movie.record,handles.movie.ldfile];
        %                 init_pos = get(init_objs,'pos');
        %                 set(init_objs,{'userdata'},init_pos);
        %                 set(init_objs,{'pos'},{[(FigPos(3)/2)-init_pos{1}(3) init_pos{1}(2:end)];[(FigPos(3)/2)+init_pos{1}(3) init_pos{2}(2:end)]});
        %                 set([handl'pos',[(FigPos(3)/2)-init_pos{1}(3) init_pos{1}(2:end)]);
        %                 set(handles.movie.ldfile,'pos',[(FigPos(3)/2)+init_pos{1}(3) init_pos{2}(2:end)]);
        %set([handles.movie.frame,handles.movie.record,handles.movie.ldfile],'visible','on'); 
        set([c.Hide,c.HideA],'vis','on');
    else
        set([c.Hide,c.HideA],'vis','on');
    end      
    
    set(c.fig, 'position',FigPosNew);
    set(c.fig,'units',oldUnits,'ResizeFcn',oldResizeFcn);
    set(hGroup,'units','normalized')
    set(hGroup,{'visible'},Group.visible);
    set([c.Hide,c.HideA(1:2),c.HideAu(1)],'units','norm');
    
    set([c.play,c.stop,c.prev,c.next],'enable','off');