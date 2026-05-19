function beat_result=beatconb(action,argv)
% For documentation see beatcon.m

% Ver 2.61 : G Krudysz, 30-Oct-2017: updated for R2017b
% Ver 2.60 : G Krudysz, 05-Jun-2015: updated for R2014b 
% Ver 2.51 : G Krudysz, 02-Mar-2005
%	 		 - Added formula string, fixed precision & text display
% Ver 2.42: G Krudysz, 12-Feb-2005
%				- Replaced 'popupmenus'with uimenus', changed color scheme
% Ver 1.1 - Removed 'unmatched' 'end' which causes error in Matlab 7.0
% 08/06/04

Fsamp = 8000;   %- for playing sound through D/A and speakers, not plotting

if nargin<1,
    action='new';
end;

if nargin<2
    argv=1;
end;

if ~(strcmp(action,'new') | strcmp(action,'error_test'))
    info_block = get(gcf,'userdata');
end;

%------- NEW -----------------------------
if strcmp(action,'new'),
    
    MATLABVERSION = version;
    MATLABVERSION = str2num(MATLABVERSION(1:3));
    
    % Preset Values Definitions
    dur   = 0.5;
    delf  = 50;
    amp_A = 20;
    amp_B = 0;
    fc    = 600;
    fs    = 8192;	%-Hz Starting Sampling Frequency FOR PLOTTING
    plo   = 0.01;

    %   set_rate(8000);
    %***************************************************************************
    % Initialize Main Panel
    %***************************************************************************
    % Create figure
    hf = figure('units','normal','pos',[0.20 0.10 .6 .80], ...
        'numbertitle','off','menubar','none','name','Beat Control Panel v2.61');
    
    if MATLABVERSION < 8.4
        set(hf,'doublebuffer','on');
    end

    % Create menu
    um_file 	= uimenu('label','File');
    um_load     = uimenu(um_file,'label','Load...');
    um_save     = uimenu(um_file,'label','Save...','callback','beatconb(''save'');');
    uimenu(um_file,'label','Exit','callback','beatconb(''exit'');','Separator','on');
    um_printops = uimenu('label','Print Options');
    um_toprinter= uimenu(um_printops,'label','To Printer','callback','beatconb(''print'');');
    um_toprinter= uimenu(um_printops,'label','To PS File','callback','beatconb(''pr_ps'');');
    um_toprinter= uimenu(um_printops,'label','To EPS File','callback','beatconb(''pr_eps'');');

    %t0=clock;
    %while (1>etime(clock,t0))  %Delayfor redraw of menus
    %end;
    %drawnow;

    %uicontrol(gcf, 'style','frame','units','normal','pos',[0 0.94 1 0.06], 'back',[.4 .4 .4] );

    % NOTE: Pop-down menus have been replaced by 'uimenus'
    %um_file=uicontrol('Max',0 ,'Min',1 ,'Units','norm','back',[.5 .5 .5],'fore',[1 1 1],...
    %   'Pos',[ 0.01 0.945 0.18 0.05 ],...
    %   'Style','popupmenu',...
    %   'string','<File...> |Load...|Save...|Exit');
    %uicontrol('Max',0 ,'Min',1 ,'Units','norm','back',[.5 .5 .5],'fore',[1 1 1],...
    %   'Call','beatconb(''ui_print'',gco);',...
    %   'Pos',[ 0.19 0.945 0.20 0.05 ],...
    %   'Style','popupmenu',...
    %   'string','<Print...> |To Printer |To PS File |To EPS File');

    plot_axes=axes('units','norm','pos',[0.1 0.50 0.84 0.40],'tag','666');

    %***************************************************************************
    % Define Frames
    %***************************************************************************
    beatconb('gen_frame',{'Frequency Controls','0.005','0.21','0.33','0.20'} );
    beatconb('gen_frame',{' ',                 '0.005','0.01','0.33','0.10'} );
    beatconb('gen_frame',{' ',                 '0.005','0.11','0.33','0.10'} );
    beatconb('gen_frame',{'Amplitude Controls','0.335','0.21','0.33','0.20'} );
    beatconb('gen_frame',{'Plot Controls',     '0.335','0.01','0.33','0.20'} );
    beatconb('gen_frame',{'Graph Options',     '0.665','0.01','0.33','0.20'} );
    beatconb('gen_frame',{' ',                 '0.665','0.21','0.33','0.20'} );
    %***************************************************************************
    % Define the Edit/Slider Combos
    %***************************************************************************
    id_fc  =beatconb('gen_combo',{'Fc (Hz):',      '0.005','0.30','0.33','100',   '1000', num2str(fc,3),'5','id_fc'});
    id_delf=beatconb('gen_combo',{'Delf (Hz):',    '0.005','0.22','0.33','-100',  '100',  num2str(delf,3), '2','id_delf'});
    id_dur =beatconb('gen_combo',{'Duration (s):', '0.005','0.13','0.33','0.1',     '5',  num2str(dur,3),  '1','id_dur'});
    id_ampa=beatconb('gen_combo',{'Amplitude A:',  '0.335','0.30','0.33','-20',   '+20',  num2str(amp_A,3),'3','id_ampa'});
    id_ampb=beatconb('gen_combo',{'Amplitude B:',  '0.335','0.22','0.33','-20',   '+20',  num2str(amp_B,3),'4','id_ampb'});
    id_plo =beatconb('gen_combo',{'Plot Time (s):','0.335','0.02','0.33','.001',  '0.5',  num2str(plo,3),  '7','id_plo'});
    id_fs  =beatconb('gen_combo',{'Fs (Hz):',      '0.335','0.10','0.33','100',   '20000',num2str(fs),'6','id_fs'});
    %***************************************************************************
    % Construct Text Equation
    %***************************************************************************
    ax = axes('units','norm','pos',[0.1 0.95 0.84 0.03],'vis','off');
    str = getFormula(amp_A,amp_B,fc,delf);
    
    if MATLABVERSION >= 8
        tx = text(0.5,0,['$' str '$'],'parent',ax,'tag','ftext','fontweight','bold','fontsize',20, ...
            'color',[0.2 0.2 1],'horiz','center','vertical','bottom','interpreter','latex');
    else
        tx = text(0.5,0,str,'parent',ax,'tag','ftext','fontweight','bold','fontsize',15, ...
            'color',[0.2 0.2 1],'horiz','center','vertical','bottom');
    end
    
    %***************************************************************************
    % Use External Button
    %***************************************************************************
    cb_ext_beat = uicontrol('style','checkbox','units','normal', 'back',[.4 .4 .7],'fore',[1 1 1],...
        'string','Use External ''beat()''', ...
        'pos',[0.015 0.03 0.31 0.05],...
        'val',0,...
        'call','beatconb(''ext_beat'',gco);');
    %***************************************************************************
    % Play Current Button
    %***************************************************************************
    uicontrol('style','push','units','normal', ...
        'string','Play As Sound','pos',[0.675 0.32 0.31 0.07],...
        'call','beatconb(''play_sound'');' );
    %***************************************************************************
    % -/- Play Example Button
    %***************************************************************************
    % Plays a simple example
    uicontrol('style','push','units','normal', ...
        'string','Play An Example','pos',[0.675 0.23 0.31 0.07],...
        'call','beatconb(''play_example'');' );
    %***************************************************************************
    % Plot Method Menu
    %***************************************************************************
    uicontrol('CallBack','beatconb(''change_plot_type'',get(gco,''val'') );',...
        'Max',0 ,'Min',1 ,'Units','norm','back',[1 1 1],'fore',[0 0 0],...
        'Pos',[ 0.675 0.10 0.31 0.05 ],...
        'Style','popupmenu',...
        'string','Use plot() |Use stem()');
    %***************************************************************************
    % Set Grid CB
    %***************************************************************************
    uicontrol('style','checkbox','units','normal','back',[.4 .4 .7],'fore',[1 1 1],...
        'string','Turn Grid On', ...
        'pos',[0.675 0.03 0.31 0.05],...
        'val',0,...
        'call','beatconb(''grid_tog'',gco);');
    %***************************************************************************
    % Final Inits
    %***************************************************************************
    % NOTE: Since pop-down menus have been replaced by 'uimenus', so have its callbacks
    %file_call = ['argv=get(gco,''val'');',...
    %    'set(gco,''val'',1);',...
    %    'if argv==2, ',...
    %    '   beatconb(''load'',[',num2str(id_dur(1),32), ' ',num2str(id_dur(2),32) ,' ',...
    %    num2str(id_delf(1),32),' ',num2str(id_delf(2),32),' ',...
    %    num2str(id_ampa(1),32),' ',num2str(id_ampa(2),32),' ',...
    %    num2str(id_ampb(1),32),' ',num2str(id_ampb(2),32),' ',...
    %    num2str(id_fc(1),32),' '  ,num2str(id_fc(2),32)  ,' ',...
    %    num2str(id_fs(1),32),  ' ',num2str(id_fs(2),32)  ,' ',...
    %    num2str(id_plo(1),32), ' ',num2str(id_plo(2),32) ,']);',...
    %    'end;',...
    %    'if argv==3, ',...
    %    '  beatconb(''save'');end;',...
    %    'if argv==4, ',...
    %    '  beatconb(''exit'');end;'];
    % set(um_file,'call',file_call)

    call_str = ['beatconb(''load'',[', ...
        'findobj(''tag'',''' get(id_dur(1),'tag') ''')', ' ','findobj(''tag'',''' get(id_dur(2),'tag') ''')',' ',...
        'findobj(''tag'',''' get(id_delf(1),'tag') ''')',' ','findobj(''tag'',''' get(id_delf(2),'tag') ''')',' ',...
        'findobj(''tag'',''' get(id_ampa(1),'tag') ''')',' ','findobj(''tag'',''' get(id_ampa(2),'tag') ''')',' ',...
        'findobj(''tag'',''' get(id_ampb(1),'tag') ''')',' ','findobj(''tag'',''' get(id_ampb(2),'tag') ''')',' ',...
        'findobj(''tag'',''' get(id_fc(1),'tag') ''')',  ' ','findobj(''tag'',''' get(id_fc(2),'tag') ''')',' ',...
        'findobj(''tag'',''' get(id_fs(1),'tag') ''')',  ' ','findobj(''tag'',''' get(id_fs(2),'tag') ''')',' ',...
        'findobj(''tag'',''' get(id_plo(1),'tag') ''')', ' ','findobj(''tag'',''' get(id_plo(2),'tag') ''')','])'];
    
    set(um_load,'callback',call_str);

    info_block=[ dur delf amp_A amp_B fc fs plo 666 0 1 -1 0];
    set(gcf,'userdata',info_block);
    beatconb('update');
    drawnow;
    %***************************************************************************
    % Error Checking
    %***************************************************************************
elseif strcmp(action,'error_test'),

    beat_result=0;

    if (exist('beat')==2)

        fs=Fsamp;
        %churn out some test numbers so the lengths can be compared
        tttmp=0:1/fs:0.5;
        xxample = 30*cos(2*pi*(199.5)*tttmp)+40*cos(2*pi*(200.5)*tttmp);
        eval('yyample = beat(30,40,200,1,fs,0.5);');

        %check to see if the lengths of the output are the same
        if size(xxample,2)~=size(yyample)
            sprintf(['Beat.m gave the wrong length of output. Length(computed)=',...
                num2str(size(yyample,2)),' / Length (expected)=',num2str(size(xxample,2))])
            beat_result=1;
        end,
    else
        sprintf('Did not find the ''beat.m'' file.'),
        beat_result=1;
    end;
    %***************************************************************************
    % Gen Frame
    %***************************************************************************
elseif strcmp(action,'gen_frame')

    text_height=0.03;
    our_pos=[str2num(argv{2}) str2num(argv{3}) str2num(argv{4}) str2num(argv{5})];

    % Set up a blank frame where specified
    uicontrol(gcf, 'style','frame','units','normal','pos', our_pos','back',[.4 .4 .7],'fore',[.4 .4 .8] );

    % Write up the text
    uicontrol('style','text','units','normal','back',[.4 .4 .7],'fore',[1 1 1],'fontsize',12,'fontweight','bold', ...
        'pos', [(our_pos(1)+.05*our_pos(3)),...
        (our_pos(2)+our_pos(4)-text_height -.5*text_height),...
        (.90*our_pos(3)), text_height ],...
        'horizontalalignment','center','string',argv{1});
    %***************************************************************************
    % Gen Slider/Edit combo
    %***************************************************************************
elseif strcmp(action,'gen_combo'),
    % Generates a Slider/Edit box combo based on the info passed

    ind_height  = 0.035;
    sli_height  = 0.02;
    ed_y_offset = 0.2*sli_height;

    loleft   =str2num(argv{2});
    lolo     =str2num(argv{3});
    frm_size =str2num(argv{4});
    val_min  =str2num(argv{5});
    val_max  =str2num(argv{6});
    val_start=str2num(argv{7});
    %--program_block index=argv(8,:)
    tag      =argv{9};

    tot_length=.90*frm_size;
    loleft=loleft+.05*frm_size;
    ed_offset=.50*tot_length;

    % Slider
    slider_id = uicontrol(gcf,...
        'Style','slider','units','normal','back',[1 1 1],'fore',[1 1 1],... % [.4 .4 .9]
        'Min',val_min,'Max',val_max,'val',val_start,...
        'pos',[loleft lolo tot_length sli_height],'tag',['slider_' tag]);

    % Edit
    edit_id = uicontrol('style','edit','units','normal','back',[1 1 1],'fore',[0 0 0],...
        'fontsize',12, ...
        'pos', [(loleft+ed_offset) (lolo+sli_height+ed_y_offset) (tot_length-ed_offset) ind_height], ...
        'string', argv{7}, 'val', val_start,'horizontalalignment','center','tag',['edit_' tag]);

    % Text
    uicontrol('style','text','units','normal','back',[.4 .4 .7],'fore',[1 1 1],...
        'pos', [loleft (lolo+sli_height) ed_offset ind_height],'fontsize',12, ...
        'horizontalalignment','left','string',argv{1},'tag',['text_' tag] );

    % Set Callbacks for the Slider and Edit box
    set(slider_id,'call',['beatconb(''set_edsli'',{ get(findobj(''tag'',''slider_' tag '''),''value'') ' , ...
        argv{5},' ',argv{6},' ',argv{8},' ','''slider_' tag '''',' ''edit_' tag ''' });']);
    
    set(edit_id,'call',['beatconb(''set_edsli'',{ str2num(get(gco,''string'')) ',...
        argv{5},' ',argv{6},' ',argv{8},' ','''slider_' tag '''',' ''edit_' tag ''' });']);      

    beat_result=[slider_id edit_id];
    %***************************************************************************
    % Change Plot/Stem
    %***************************************************************************
elseif strcmp(action,'change_plot_type'),
    info_block(10)=argv;
    set(gcf,'userdata',info_block);
    beatconb('update');
    %***************************************************************************
    % Toggle Grid
    %***************************************************************************
elseif strcmp(action,'grid_tog'),

    info_block(12)=get(argv,'val');
    axes(findobj('tag',num2str(info_block(8))));
    if info_block(12)
        grid on;
    else
        grid off;
    end;
    set(gcf,'userdata',info_block);
    %***************************************************************************
    % Handle changes
    %***************************************************************************
elseif strcmp(action,'set_edsli'),
    % Generic range check for slider/edit combo. Checks to see if the change
    % is valid, then updates the relevant objects. Needs argv input as:
    %    (1) new value  (2) range min (3) range max
    %    (4) Index of var in info_block
    %    (5) slider id  (6) edit id

    made_a_change=0;

    if ( (argv{2} <= argv{1} ) & (argv{1} <= argv{3}) )
        set_value=argv{1};
        info_block( argv{4} )=set_value;
        made_a_change=1;
    else
        set_value=info_block( argv{4} ); %-bad value-reset
    end;

    set( findobj('tag',argv{5}),'val',set_value);            %-sets slider

    if set_value >= 1e4
        set( findobj('tag',argv{6}),'string',num2str(set_value,5));%-sets edit
    else
        set( findobj('tag',argv{6}),'string',num2str(set_value,4));%-sets edit
    end

    set( findobj('tag',argv{6}),'val',set_value );

    set(gcf,'userdata',info_block);

    % Update Text
    str = getFormula(info_block(3),info_block(4),info_block(5),info_block(2));
    
    MATLABVERSION = version;
    MATLABVERSION = str2num(MATLABVERSION(1:3));
    
    if MATLABVERSION >= 8
        set(findobj(gcf,'tag','ftext'),'string',['$' str '$'],'interpreter','latex');
    else   
        set(findobj(gcf,'tag','ftext'),'string',str);
    end

    if made_a_change
        beatconb('update');
    end;
    %***************************************************************************
    % Gen new data and update
    %***************************************************************************
elseif strcmp(action,'update'),
    ha = findobj('tag',num2str(info_block(8)));
    axes(ha);
    
    tt=0:1/info_block(6):info_block(7);
    if (info_block(9)==1)
        eval('xxtemp=beat(info_block(3),info_block(4),info_block(5),info_block(2),info_block(6),info_block(7));');
    else
        xxtemp = info_block(3)*cos(2*pi*(info_block(5)-info_block(2))*tt) + ...
            info_block(4)*cos(2*pi*(info_block(5)+info_block(2))*tt);
    end;
    if (info_block(10)==1)
        plot(ha,tt,xxtemp(1:length(tt)));
    else
        stem(ha,tt,xxtemp(1:length(tt)),'filled');
    end;
    amp_max=1.25*(max(abs(xxtemp)))+.0001;
    axis([0 info_block(7) -amp_max amp_max]);
    if info_block(12)
        grid on;
    else
        grid off;
    end;
    set(ha,'tag',num2str(info_block(8)));
    title('Sum of Cosines');
    xlabel('Time (s)');
    ylabel('Amplitude');

    beat_result=xxtemp;
    %***************************************************************************
    % Play Current
    %***************************************************************************
elseif strcmp(action,'play_sound'),

    if info_block(9)==1
        eval('xxtemp=beat(info_block(3),info_block(4),info_block(5),info_block(2),Fsamp,info_block(1));');
    else
        tttmp=0:1/Fsamp:info_block(1);
        xxtemp = info_block(3)*cos(2*pi*(info_block(5)-info_block(2))*tttmp) + ...
            info_block(4)*cos(2*pi*(info_block(5)+info_block(2))*tttmp);
    end;
    sound( xxtemp/max(abs(xxtemp)), Fsamp );    %--jMc 20-Oct-1997
    %***************************************************************************
    % Play Example
    %***************************************************************************
elseif strcmp(action,'play_example'),

    tttmp=0:1/Fsamp:2;
    xxtemp=20*sin(2*pi*499.2*tttmp)+17*sin(2*pi*500.8*tttmp);
    sound( xxtemp/max(abs(xxtemp)), Fsamp );    %--jMc 20-Oct-1997
    %***************************************************************************
    % External Beat Change
    %***************************************************************************
elseif strcmp(action,'ext_beat'),

    if (~info_block(9) & ~beatconb('error_test') )
        set(argv,'val',1);
        info_block(9)=1;
    else
        set(argv,'val',0);
        info_block(9)=0;
    end;

    set(gcf,'userdata',info_block);

    beatconb('update');
    %***************************************************************************
    % Save Data
    %***************************************************************************
elseif strcmp(action,'save'),

    global beat_duration beat_delf beat_amp_a beat_amp_b beat_fc beat_fs beat_plot_time beat_sample;

    beat_duration =info_block(1);
    beat_delf     =info_block(2);
    beat_amp_a    =info_block(3);
    beat_amp_b    =info_block(4);
    beat_fc       =info_block(5);
    beat_fs       =info_block(6);
    beat_plot_time=info_block(7);
    tttmp=0:1/info_block(6):info_block(1);
    beat_sample=beat_amp_a*cos(2*pi*(beat_fc-beat_delf)*tttmp)+beat_amp_b*cos(2*pi*(beat_fc+beat_delf)*tttmp);

    [fn,pth] = uiputfile('*.mat','Save Plots');
    if fn
        eval(['save ',pth,fn,...
            ' beat_duration beat_delf beat_amp_a beat_amp_b beat_fc',...
            ' beat_fs beat_plot_time beat_sample' ]);
    end;

    clear beat_duration beat_delf beat_amp_a beat_amp_b beat_fc beat_fs beat_plot_time beat_sample;
    %***************************************************************************
    % Load Data
    %***************************************************************************
elseif strcmp(action,'load'),

    [fn,pth] = uigetfile('*.mat','Load Plot');

    if fn
        eval(['load ',pth,fn,';']);

        info_block(1)=beat_duration;
        set(argv(1),'val',beat_duration);
        set(argv(2),'string',num2str(beat_duration,3));
        info_block(2)=beat_delf;
        set(argv(3),'val',beat_delf);
        set(argv(4),'string',num2str(beat_delf,3));
        info_block(3)=beat_amp_a;
        set(argv(5),'val',beat_amp_a);
        set(argv(6),'string',num2str(beat_amp_a,3));
        info_block(4)=beat_amp_b;
        set(argv(7),'val',beat_amp_b);
        set(argv(8),'string',num2str(beat_amp_b,3));
        info_block(5)=beat_fc;
        set(argv(9),'val',beat_fc);
        set(argv(10),'string',num2str(beat_fc,3));
        info_block(6)=beat_fs;
        set(argv(11),'val',beat_fs);
        set(argv(12),'string',num2str(beat_fs,3));
        info_block(7)=beat_plot_time;
        set(argv(13),'val',beat_plot_time);
        set(argv(14),'string',num2str(beat_plot_time,3));

        set(gcf,'userdata',info_block);
        beatconb('update');
    end;
    %***************************************************************************
    % Print Window Gen
    %***************************************************************************
elseif strcmp(action,'print_gen'),

    plot_data=beatconb('update');

    if ~any( get(0,'children') == info_block(11) );
        main_win=gcf;
        info_block(11)=figure('visible','off');
        set(main_win,'userdata',info_block);
    else
        figure(info_block(11));
    end;

    %num_samples = info_block(6)*info_block(7);
    tt=linspace(0,info_block(7),info_block(6)*info_block(7));

    if (info_block(10)==1)
        plot(tt,plot_data(1:length(tt)));
    else
        stem(tt,plot_data(1:length(tt)));
    end;

    amp_max=1.25*(max(abs(plot_data)))+.0001;
    axis([0 info_block(7) -amp_max amp_max]);

    xlabel('Time');
    ylabel('Amplitude');

    username=getenv('USER');
    if ~isempty(username)
        username=[' by user ',username];
    end;

    title(['Beat Summation for Fc=',num2str(info_block(5),3),...
        ', DelF=',num2str(info_block(2),3),...
        ', A=',num2str(info_block(3),3),...
        ', B=',num2str(info_block(4),3),...
        ', Fs=',num2str(info_block(6)),username ]);

    beat_result=info_block(11);

    %***************************************************************************
    %  Normal Print
    %***************************************************************************
elseif strcmp(action,'print'),

    pr_id=beatconb('print_gen');
    figure(pr_id);
    eval('print ');
    set(pr_id,'visible','off');
    %***************************************************************************
    %  Normal Print
    %***************************************************************************
elseif strcmp(action,'pr_ps'),

    [fn,pth] = uiputfile('*.ps','Print PostScript');
    if fn
        pr_id=beatconb('print_gen');
        figure(pr_id);
        eval(['print -dps ',pth,fn,]);
        set(pr_id,'visible','off');
    end;
    %***************************************************************************
    % Normal Print
    %***************************************************************************
elseif strcmp(action,'pr_eps'),

    [fn,pth] = uiputfile('*.eps','Print Encapsulated PostScript');
    if fn
        pr_id=beatconb('print_gen');
        figure(pr_id);
        eval(['print -deps ',pth,fn]);
        set(pr_id,'visible','off');
    end;
    %***************************************************************************
    % Exit
    %***************************************************************************
elseif strcmp(action,'exit'),
    if any( get(0,'children') == info_block(11) );
        close(info_block(11));
    end;
    close(gcf);
    %***************************************************************************
    % Change Print
    %***************************************************************************
elseif strcmp(action,'ui_print'),
    the_val=get(argv,'val');
    set(gco,'val',1);
    if the_val==2
        beatconb('print');
    elseif the_val==3
        beatconb('pr_ps');
    elseif the_val==4
        beatconb('pr_eps');
    end;
    %***************************************************************************
end;

%==========================================================================
function formula_str = getFormula(A,B,fc,del)
%==========================================================================
tol = 1e-4;
As = num2str(A,3);
Abs = num2str(abs(A),3);

if fc-del > 1000
    prec1 = 4;
else
    prec1 = 3;
end

if fc+del > 1000
    prec2 = 4;
else
    prec2 = 3;
end

% A string
if abs(A) < tol | abs(1-A) < tol
    Astr = '';
elseif abs(1+A) < tol
    Astr = ' - ';
elseif A < 0
    Astr = [ ' - ' Abs];
elseif A > 0
    Astr = As;
end

% cos string
if abs(A) < tol % A=0
    c1str = '';
else
    if abs(fc-del) < tol % f1=0
        if A < 0
            Astr = [' - ' Abs];
        else
            Astr = As;
        end
        c1str = '';
    else
        c1str = [ ' cos( 2\pi (' num2str(fc-del,prec1) ') t )'];
    end
end

% B string
%if abs(A) < tol % A = 0
if abs(B) < tol
    Bstr = '';
elseif abs(1-B) < tol
    if abs(A) < tol
        Bstr = '';
    elseif abs(fc+del) < tol
        Bstr = ' + 1';
    else
        Bstr = ' + ';
    end
elseif abs(1+B) < tol
    if abs(fc+del) <tol
        Bstr = ' - 1 ';
    else
        Bstr = ' - ';
    end
elseif B > 0
    if abs(A) < tol
        Bstr = num2str(B,3);
    else
        Bstr = [' + ' num2str(B,3)];
    end
elseif B < 0
    Bstr = [' - ' num2str(abs(B),3)];
end

% cos string 2
if abs(B) < tol | abs(fc+del) < tol
    c2str = '';
else
    c2str = [ ' cos( 2\pi (' num2str(fc+del,prec2) ') t )'];
end

if and(abs(A)<tol,abs(B)<tol)
    formula_str = '\bf x(t) = 0';
else
    formula_str = ['\bf x(t) = ' Astr c1str Bstr c2str];
end

%--- Render: tex or latex
MATLABVERSION = version;
MATLABVERSION = str2num(MATLABVERSION(1:3));

if MATLABVERSION >= 8
    formula_str = regexprep(formula_str,'cos','\\cos');
end
%==========================================================================
