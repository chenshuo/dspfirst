function mc = moviecontrols(c)
%MOVIECONTROLS Movie controls class constructor.  Object cretes movie
%controls visible under the "MovieTool" menu and GUI extended VCR-styled
%controls.  Object is a child of movietool class.
%
% Author(s): Greg Krudysz

if or( nargin == 0 , and( nargin == 1 , ~isa(c,'moviecontrols') ) )
    % inherit properties from parent object: movietool
    mc.fig       = c.fig;
    mc.extendby  = c.extendby;
    mc.moviename = c.moviename;
    mc.moviepath = c.moviepath;
    
    % (c)ontrols properties
    mc.frameNo   = 1;
    mc.time      = 0;
    mc.playdata  = [];
    
    % obtain geometry of parent GUI
    oldUnits = get([0,mc.fig],'units');
    set([0,mc.fig],'units','pixels');
    scn_size = get(0,'screensize');
    fig_size = get(mc.fig,'position');
    xy  = [fig_size(3) mc.extendby*fig_size(4)];
    xyh = xy(2)/2;
    
    % add menu (c)ontrols to the GUI
    menu = uimenu(mc.fig,'Label','Movie Tool');
    mc.mtool = uimenu('Parent',menu,'Callback','movietool(''Display'',gcbf,[]);', ...
        'Label','&Display','Tag','mtool');
    mc.pause = uimenu('Parent',menu,'Callback','movietool(''PauseMovie'',gcbf,[])', ...
        'Label','&Pause Movie','Tag','saveS','enable','off');
    mc.mdemos = uimenu('Parent',menu,'Label','Demos','Tag','mdemos');
    mc.mdemo1 = uimenu('Parent',mc.mdemos,'Callback','movietool(''Demos'',gcbf,[])', ...
        'Label','demo1');
    mc.mdemo2 = uimenu('Parent',mc.mdemos,'Callback','movietool(''Demos'',gcbf,[])', ...
        'Label','demo2'); 
    
    % create movie (c)ontrols handles
    mc.frame    =      axes('par',mc.fig,'units','pix','vis','off','pos',[2          2            xy(1)-2     xy(2)],'box','on','xtick',[],'ytick',[],'Color',[0.9 0.9 0.9]);
    mc.bar      =      axes('par',mc.fig,'units','pix','vis','off','pos',[0.35*xy(1) 0.2*xy(2) 0.25*xy(1) 0.6*xy(2)],'box','on','xtick',[],'ytick',[],'xlim',[0 1],'ylim',[0 1],'userdata',[1 0]);
    mc.barpatch =     patch('par',mc.bar              ,'vis','off','xdata' ,[0 0 0 0],'ydata',[0 0 1 1],'facecolor',[0.8 0.8 0.8],'vis','off');
    mc.record   = uicontrol('par',mc.fig,'units','pix','vis','off','pos',[0.05*xy(1) 0.2*xy(2) 0.05*xy(1) 0.6*xy(2)],'string','Rec','style','togglebutton','callback','(movietool(''Record'',gcbf))');
    mc.stop     = uicontrol('par',mc.fig,'units','pix','vis','off','pos',[0.10*xy(1) 0.2*xy(2) 0.05*xy(1) 0.6*xy(2)],'string','Stop','style','pushbutton','callback','(movietool(''Stop'',gcbf))','userdata',0);
    mc.play     = uicontrol('par',mc.fig,'units','pix','vis','off','pos',[0.15*xy(1) 0.2*xy(2) 0.05*xy(1) 0.6*xy(2)],'string','Play','callback','(movietool(''Play'',gcbf))');
    mc.prev     = uicontrol('par',mc.fig,'units','pix','vis','off','pos',[0.29*xy(1) 0.2*xy(2) 0.05*xy(1) 0.6*xy(2)],'string','<<','callback','(movietool(''PlayStep'',gcbf)),','enable','on');
    mc.next     = uicontrol('par',mc.fig,'units','pix','vis','off','pos',[0.61*xy(1) 0.2*xy(2) 0.05*xy(1) 0.6*xy(2)],'string','>>','callback','(movietool(''PlayStep'',gcbf)),','enable','on');
    mc.ldfile   = uicontrol('par',mc.fig,'units','pix','vis','off','pos',[0.70*xy(1) 0.2*xy(2) 0.10*xy(1) 0.6*xy(2)],'string','Load File','callback','(movietool(''LoadFile'',gcbf))','tag','loadbutton');
    mc.text     = uicontrol('par',mc.fig,'units','pix','vis','off','pos',[0.82*xy(1) 0.5*xy(2) 0.14*xy(1) 0.3*xy(2)],'string','None Available','style','text','horiz','left','backg',[0.9 0.9 0.9],'fore','b');
    mc.close    = uicontrol('par',mc.fig,'units','pix','vis','off','pos',[xy(1)-xyh+1    xyh+2      xyh-1     xyh-1],'string','X','callback','(movietool(''Hide'',gcbf))','fontw','bold');
    mc.detach   = uicontrol('par',mc.fig,'units','pix','vis','off','pos',[xy(1)-xyh+1        2      xyh-1     xyh-1],'string','=','callback','(movietool(''Separate'',gcbf))','fontw','bold');
    mc.recAudio = uicontrol('par',mc.fig,'units','pix','vis','off','pos',[0.82*xy(1) 0.1*xy(2) 0.14*xy(1) 0.3*xy(2)],'string','record audio','style','checkbox','backg',[0.9 0.9 0.9]);
    mc.bara     =      axes('par',mc.fig,'units','pix','vis','off','pos',[0.35*xy(1) 0.8*xy(2) 0.25*xy(1) .05*xy(2)],'box','on','xtick',[],'ytick',[],'xlim',[0 1],'ylim',[0 1],'userdata',[1 0]);
    mc.barpatcha=     patch('par',mc.bara             ,'vis','off','xdata' ,[0 0 0 0],'ydata',[0 0 1 1],'facecolor','r');
    
    % check for audio capability, available for versions > 6.0
    if c.Mver < 6.1
        mc.recAudio = [];
    end
    
    % group (c)ontrols handles for hiding and unit change
    mc.Hide     = [mc.stop,mc.prev,mc.record,mc.play,mc.ldfile,mc.text,mc.next,mc.recAudio,mc.close,mc.detach];
    mc.HideColor= get(mc.Hide,'back');
    mc.HideA    = [mc.frame,mc.bar,mc.barpatch];
    mc.HideAu   = [mc.bara,mc.barpatcha];
    
    % Initialize data structure for GUI event recording
    set(mc.record,'Value',0);
    set([mc.Hide,mc.HideA(1:2),mc.HideAu(1)],'units','norm');
    set(0,'units',oldUnits{1},'currentfigure',mc.fig); 
    set(mc.fig,'units',oldUnits{2});
    
    % create object moviecontrols
    mc = class(mc,'moviecontrols');
    
elseif isa(c,'moviecontrols')
    mc = c;
end