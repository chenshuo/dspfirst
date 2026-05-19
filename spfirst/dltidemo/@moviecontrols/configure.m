function configure(c,configuration,varargin)
%@MOVIECONTROLS/CONFIGURE Updates visual layout of movie controls and their properties.
%
%   CONFIGURE(c,configuration) configures movie controls object 'c' given 
%   movietool driver function 'configuration'.
%
% See also @MOVIECONTROLS/... SHOW, HIDE, GET, SET

% Author(s): Greg Krudysz

switch configuration
    case 'record'
        %---------------------------------------------------
        set(c.Hide,{'BackgroundColor'},c.HideColor);
        set(c.record,'for','r');
        set([c.play,c.ldfile,c.text,c.prev,c.next,c.recAudio],'enable','off','visible','off');
        set(c.stop,'enable','on','vis','on');
        
        % update bar
        set([c.bar,c.bara],'vis','off');
        set([c.barpatch,c.barpatcha],'xdata',[0 0 0 0],'vis','off');
        %---------------------------------------------------
    case 'stop'
        %---------------------------------------------------
        switch varargin{1}
            case 'save'
                set(c.text,'String',c.moviename);
                set([c.play,c.next,c.ldfile,c.text,c.recAudio],'enable','on','vis','on');
                set([c.bar,c.barpatch,c.prev],'vis','on');    
                set(c.record,'value',0,'string','Rec','for','k');
                set(c.stop,'value',0,'enable','off'); 
            case 'cancel'
                set([c.play,c.stop,c.prev,c.next],'enable','off','vis','on');
                set([c.ldfile,c.text,c.recAudio],'enable','on','vis','on');
                set([c.bar,c.barpatch],'vis','on')
                set(c.record,'value',0,'string','Rec','for','k');
                set(c.stop,'value',0,'enable','off');
            case 'cancel_loaded'
                set([c.play,c.ldfile,c.text,c.next,c.recAudio],'enable','on','vis','on');
                set([c.bar,c.barpatch,c.prev],'vis','on');  
                set(c.record,'value',0,'string','Rec','for','k');
                set(c.stop,'value',0,'enable','off'); 
            case 'play'
                set(c.stop,'enable','off');
                set([c.prev,c.next],'vis','on');
                set(c.next,'enable','off');
                set([c.Hide,c.pause],'enable','on');               
            otherwise
                error('Error in @MOVIECONTROLS/CONFIGURE: No appropriate method found')
        end
        %---------------------------------------------------
    case 'play'
        %---------------------------------------------------
        switch varargin{1}
            case 'global'
                set(c.stop,'enable','on');
                set([c.prev,c.next],'vis','off');
                set([c.record;c.play;c.next;c.ldfile],'enable','off');    
            case 'frame'
                k = varargin{2};
                L = varargin{3};

                set(c.barpatch,'xdata',[0 k/L(1) k/L(1) 0]);
                
                if k == L(1)
                    set(c.stop,'enable','off');
                    set([c.prev,c.next],'vis','on');
                    set(c.next,'enable','on');
                    set([c.barpatch,c.barpatcha],'xdata',[0 0 0 0]);
                    set([c.bara,c.barpatcha],'vis','off');
                else
                    %% set([c.bara,c.barpatcha],'vis','on');
                end          
                set([c.record;c.play;c.ldfile;c.pause],'enable','on');
        end    
        %---------------------------------------------------
    case 'loadfile'  
        %---------------------------------------------------
        switch varargin{1}   
            case 'open'
                set(c.text,'String',c.moviename);
                set([c.Hide(3:end),c.pause],'enable','on');
                set([c.barpatch,c.barpatcha],'xdata',[0 0 0 0]);
            case 'cancel'
                if isempty(c.moviename)
                    set(c.pause,'enable','off');
                    set(c.text,'String','None-Available');
                end
        end
        %---------------------------------------------------
    case 'playstep'
        %---------------------------------------------------
        %--- Update Audio ----%
        set([c.bara,c.barpatcha],'vis','off');    
        
        if c.frameNo == 1               
            set(c.prev,'enable','off');
        else
            set(c.prev,'enable','on');
        end
        
        m = varargin{1};
        n = varargin{2};
        
        set([c.next,c.stop],'enable','on');
        set(c.barpatch ,'xdata',[0 m m 0]);
        set(c.barpatcha,'xdata',[0 n n 0]); 
        %---------------------------------------------------
    case 'demos' 
        %---------------------------------------------------
        if strcmp(get(c.mtool,'checked'),'off')
            movietool('Display',c.fig);
            set(c.mtool,'checked','on');
        end
        
        set([c.Hide,c.HideA],'vis','on');
        set(c.barpatch,'xdata',[0 0 0 0]);
        
        fname = varargin{1};
        pname = varargin{2};
        
        if exist([pname fname '.mat'],'file')
            set(c.text,'String',fname);
            set([c.play,c.next,c.pause],'enable','on','vis','on');
            set([c.bar,c.barpatch,c.stop],'vis','on');
        else
            if isempty(c.moviename)
                set(c.text,'String','None-Available');
            end
        end 
        %---------------------------------------------------
    case 'pausemovie'
        %---------------------------------------------------
        if ~get(c,'pause_flag')
            set(c.pause,'checked','on');           
            set(c.Hide(1:end-2),'enable','off');     
        else
            set(c.pause,'checked','off'); 
            set(c.Hide,'enable','on');   
        end
        %---------------------------------------------------
    otherwise
        error('Error in @MOVIECONTROLS/CONFIGURE: No appropriate configuration found.')
end