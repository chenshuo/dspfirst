function movietool(method,hobj,fig_filename,extendby)
%MOVIETOOL Graphical movietool object created by a constructor, it serves
%as a driver for user interface with the GUI and movie controls.
%
%   MOVIETOOL() is a default movietool object constructor, it adds a
%   movietool menu to a default figure as no FIGURE_HANDLE is
%   specified.
%
%   MOVIETOOL('Initialize',FIGURE_HANDLE,FIGURE_FILENAME) movietool
%   object constructor, it adds movietool menu to figure with
%   FIGURE_HANDLE and figure's file script FIGURE_FILENAME.
%
%   MOVIETOOL('Initialize',FIGURE_HANDLE,FIGURE_FILENAME,EXTENDBY)
%   movietool object constructor as above with EXTENDBY indicating a
%   percentage by which GUI should be extended to create movietool.
%
%   METHODS:
%
%   MOVIETOOL               Constructor
%   GET                     Get MovieTool object property
%   SET                     Set MovieTool object property
%   DISPLAY                 Display MovieTool object in MATLAB
%   PRE_CALLBACKACTION      Pre-callback modifying function
%   POST_CALLBACKACTION     Post-callback modifying function
%
%   DRIVER SUBFUCTIONS:
%
%   INITIALIZE              add movie-tool and movie-tool menu to parent GUI
%   DISPLAY                 display movie-tool as an extension of GUI
%   HIDE                    hide movie-tool from GUI
%   RECORD                  record GUI activity
%   STOP                    stop the recording in progress
%   PLAY                    plays back the recorded movie continuously
%   PLAYSTEP                plays back the recorded movie frame by frame
%   LOADFILE                prompts for a file to be loaded for playback
%   DEMOS                   load movie files designated as demos
%   PAUSEMOVIE              pause the recording in progress
%
%   See also @MOVIETOOL/... GET, SET, DISPLAY, PRE_CALLBACKACTION, and
%   POST_CALLBACKACTION

%   Author(s): Greg Krudysz
%   Revision: 3.81  Date: 12/18/2004
%======================================================================
if or((nargin == 0),strcmp(method,'Initialize'))

    % Define MOVIETOOL constructor

    switch nargin
        case 0
            hobj = figure;
            fig_filename = 'default';
            extendby = 0.1;
            method = 'Initialize';
        case 3
            extendby = 0.1;
    end

    % Private Data
    Matlabver = version;
    mt.Mver        = str2double(Matlabver(1:3));
    mt.version     = '3.6';         % movietool class object version
    mt.fig         = hobj;          % main figure handle
    mt.filename    = fig_filename;  % main figure name
    mt.extendby    = extendby;      % extend figure by X%
    mt.moviename   = [];            % loaded movie file name
    mt.moviepath   = [];            % loaded movie path name
    mt.rec_flag    = 0;             % record GUI flag
    mt.play_flag   = 0;             % play GUI flag
    mt.hili_flag   = 1;             % highlight flag
    mt.stop_flag   = 0;

    % Define MovieTool children constructors
    % NOTE: placed GUIOBJECTS before MOVIECONTROLS so that mo.name includes
    % only GUI UI Objects (excludes control objects defined in mc)

    mo = guiobjects(mt);    % (o)bjects in GUI
    mc = moviecontrols(mt); % (c)ontrols for movietool
    ml = movielog(mt);      % (l)og file for recorded GUI properties
    ma = movieaudio(mt);    % (a)udio

    % Class constructor
    if ~isa(mt,'movietool');
        mt = class(mt,'movietool',mc,mo,ml,ma);
    end

else
    % Load MOVIETOOL object from figure data 'movietoolData'
    mt = getappdata(hobj,'movietoolData');
end
%======================================================================
switch method
    case 'Initialize'
        %======================================================================
        mt.guiobjects = savestate(mt.guiobjects,1);    % save initial state settings

        % Save MOVIETOOL object to figure data 'movietoolData'
        setappdata(mt.fig,'movietoolData',mt);
        %======================================================================
    case 'Display'
        %======================================================================
        if strcmp(get(gcbo,'checked'),'off')
            set(gcbo,'checked','on');
            show(mt.moviecontrols);
        else
            movietool('Hide',mt.fig);
        end
        %======================================================================
    case 'Hide'
        %======================================================================
        set(mt,'play_flag',0,'rec_flag',0); % Update flags
        set(mt.moviecontrols,'mdisplay','off');

        hide(mt.moviecontrols);
        %======================================================================
    case 'Record'
        %======================================================================
        if get(gcbo,'value')
            set(gcbo,'value',1);

            % Updata movie controls
            mt.moviecontrols = set(mt.moviecontrols,'frameNo',1,'time',0);
            configure(mt.moviecontrols,'record')

            % Undo-Hightlight
            highlight(mt.guiobjects,'all','off');

            % Initialize recording flag
            mt = set(mt,'play_flag',0,'rec_flag',1);

            % Set Initial GUI State
            setstate(mt.guiobjects,1);

            % Save Current GUI State
            mt.guiobjects = savestate(mt.guiobjects);

            % Initialize data structure for recording
            audio_flag = get(mt.moviecontrols,'audio_flag');
            mt.movielog = set(mt.movielog,'time0',clock);

            % Record Audio
            if audio_flag
                mt.movieaudio = record(mt.movieaudio);
            end

            % Save MOVIETOOL object to figure data 'movietoolData'
            setappdata(mt.fig,'movietoolData',mt);
        else
            set(gcbo,'value',1);
        end
        %======================================================================
    case 'Stop'
        %======================================================================
        if mt.rec_flag
            % SAVE DATA: end recording, save data structure to file

            % Stop Audio
            mt.movieaudio = stop(mt.movieaudio);

            % Save Data to log file
            [fname,pname] = save(mt.movielog,mfilename);

            if ischar(fname)
                % Save Audio to file
                mt.movieaudio = save(mt.movieaudio,fname,pname);

                mt = set(mt,'rec_flag',0);
                mt.moviecontrols = set(mt.moviecontrols,'moviename',fname,'moviepath',pname);
                configure(mt.moviecontrols,'stop','save');
            else
                if isempty(get(mt.moviecontrols,'moviename'))
                    % no movie loaded upon "Cancel"
                    configure(mt.moviecontrols,'stop','cancel');
                else
                    % movie already loaded upon "Cancel"
                    configure(mt.moviecontrols,'stop','cancel_loaded');
                end
            end
        else
            % STOP MOVIE: movie is playing, stop & pause audio
            if mt.play_flag
                mt = getappdata(mt.fig,'movietoolData');
                mt.movieaudio = pause(mt.movieaudio);

                configure(mt.moviecontrols,'stop','play');
                mt.stop_flag = 1;
                set(mt,'stop_flag',1);
                set(mt.guiobjects,'figure','arrow');
                set(mt.guiobjects,'enable','on');
            end
        end
        %======================================================================
    case 'Play'
        %======================================================================
        %--- Get File ----%
        file = get(mt.moviecontrols,'moviename');
        path = get(mt.moviecontrols,'moviepath');

        if ischar(file)
            Movie = load([path,file]);
            L = size(Movie.data);
            ML = (Movie.data{end,4}); % movie length (sec)

            %--- update global movie controls ----%
            configure(mt.moviecontrols,'play','global');
            set(mt.guiobjects,'enable','off');

            %--- get previous frame ----%
            frameNo = get(mt.moviecontrols,'frameNo');
            time = get(mt.moviecontrols,'time');

            if ~isempty(frameNo)
                N1 = frameNo; N2 = L(1); else
                N1 = 1; N2 = L(1);
            end

            %--- Update movie control flags ----%
            mt = set(mt,'play_flag',1,'rec_flag',0);

            %--- set up timestamp ----%
            if N1 == 1
                offset = 0; else
                offset = time;
            end
            time0 = clock;
            time_buffer = 0.05;

            % Play Audio
            mt.movieaudio = play(mt.movieaudio,file,path,time);

            if mt.movieaudio.bar_flag
                set(mt.moviecontrols,'bars','on');
            else
                set(mt.moviecontrols,'bars','off');
            end

            if N1 > N2
                N1 = N2;
            end
            %--- PLAY FRAME ---%
            for k=N1:N2
                if k == 1
                    mt = set(mt,'hili_flag',0);
                else
                    mt = set(mt,'hili_flag',1);
                end

                %--- Save movie frame 'playdata' ----%
                playdata = [Movie.data(k,2:3) {'next'}];
                mt.moviecontrols = set(mt.moviecontrols,'playdata',playdata);
                setappdata(mt.fig,'movietoolData',mt);

                if ~mt.stop_flag
                    set(mt.guiobjects,'figure','arrow');

                    %--- update movie controls ----%
                    mt.moviecontrols = set(mt.moviecontrols,'playdata',[]);

                    %--- Update time-stamp ----%
                    time = etime(clock,time0) + offset;
                    while time + time_buffer < Movie.data{k,4};
                        if mt.stop_flag
                            break
                        end
                        pause(time_buffer)
                        mt = getappdata(mt.fig,'movietoolData');
                        set(mt.moviecontrols,'barpatcha',time/ML);
                        time = etime(clock,time0)+offset;
                    end
                    set(mt.moviecontrols,'barpatcha',time/ML);

                    %--- Undo-Hightlight ----%
                    highlight(mt.guiobjects,'all','off');

                    % test audio to frame synchronization:
                    % [audio time, frame time-stamp]
                    % t1 = [etime(clock,time0),Movie.data{k,4}]

                    %--- run callbacks ----%
                    eval(Movie.data{k,1});

                    % update movietool object
                    mt = getappdata(mt.fig,'movietoolData');
                end

                %---- If "STOP" while playing ----%
                if get(mt,'stop_flag')
                    mt.moviecontrols = set(mt.moviecontrols,'frameNo',k+1,'time',time);
                    set(mt,'stop_flag',0,'play_flag',0);
                    return
                end

                if k == L(1)
                    mt.moviecontrols = set(mt.moviecontrols,'frameNo',1,'time',0);
                else
                    mt.moviecontrols = set(mt.moviecontrols,'frameNo',k+1,'time',Movie.data{k+1,4});
                end
                configure(mt.moviecontrols,'play','frame',k,L)
            end %for
            %--------------------------%

            set(mt.guiobjects,'figure','current');
            set(mt.guiobjects,'enable','on');
        end %ischar

        %--- Undo-Hightlight ----%
        highlight(mt.guiobjects,'all','off');

        mt = set(mt,'play_flag',0);
        %======================================================================
    case 'PlayStep'
        %======================================================================
        %--- Get File ----%
        file = get(mt.moviecontrols,'moviename');
        path = get(mt.moviecontrols,'moviepath');

        if ischar(file)
            Movie = load([path,file],'data');
            L = size(Movie.data);
            ML = (Movie.data{end,4}); % movie length (sec)

            %--- get next frame number ----%
            frameNo = get(mt.moviecontrols,'frameNo');

            %--- update frame and load data ---%
            if strcmp(get(gcbo,'string'),'>>')
                play_method = 'next';
                if (frameNo-1) == L(1)
                    frameNo = 1;
                end
                kud = frameNo+1;
            elseif strcmp(get(gcbo,'string'),'<<')
                play_method = 'prev';
                frameNo = frameNo-1; kud = frameNo;
            end

            %--- Update Flags ----%
            mt = set(mt,'play_flag',1,'rec_flag',0);
            mt.moviecontrols = set(mt.moviecontrols,'frameNo',frameNo);

            if frameNo == 1
                mt = set(mt,'hili_flag',0);
            else
                mt = set(mt,'hili_flag',1);
            end

            %--- Save movie frame 'playdata' ----%
            playdata = [Movie.data(frameNo,2:3) {play_method}];
            mt.moviecontrols = set(mt.moviecontrols,'playdata',playdata);
            setappdata(mt.fig,'movietoolData',mt);

            %--- Undo-Hightlight ----%
            highlight(mt.guiobjects,'all','off');

            %--- run callbacks ----%
            eval(Movie.data{frameNo,1});
            %----------------------%

            set(mt.guiobjects,'figure','initial');

            %--- update movie controls ----%
            configure(mt.moviecontrols,'playstep',frameNo/L(1),Movie.data{frameNo,4}/ML)
            mt.moviecontrols = set(mt.moviecontrols,'frameNo',kud,'time',Movie.data{frameNo,4},'playdata',[]);
        end %ischar

        %--- Update Handles ----%
        mt = set(mt,'play_flag',0,'rec_flag',0);
        %======================================================================
    case 'LoadFile'
        %======================================================================
        % load movie file from "...\@movietool\movies\" directory
        filepath  = which(mfilename);

        if mt.Mver >= 6.5
            p_name = [filepath(1:end-length(mfilename)-2) 'movies\']; else
            p_name = [filepath(1:end-11) 'movies\'];
        end

        [fname,pname] = uigetfile([p_name '*.mat'],'Open Movie File');

        if ischar(fname)
            mt.moviecontrols = set(mt.moviecontrols,'moviename',fname,'moviepath',pname,'frameNo',1,'time',0);
            configure(mt.moviecontrols,'loadfile','open');
        else
            mt.moviecontrols = set(mt.moviecontrols,'moviename',[]);
            configure(mt.moviecontrols,'loadfile','cancel');
        end
        %======================================================================
    case 'Demos'
        %======================================================================
        fname = get(gcbo,'Label');
        filepath  = which(mfilename);

        if mt.Mver >= 6.5
            pname = [filepath(1:end-length(mfilename)-2) 'movies\']; else
            pname = [filepath(1:end-11) 'movies\'];
        end

        if exist([pname fname '.mat'],'file')
            mt.moviecontrols = set(mt.moviecontrols,'moviename',fname,'moviepath',pname,'frameNo',1,'time',0);
            configure(mt.moviecontrols,'demos',fname,pname);
        else
            file = get(mt.moviecontrols,'moviename');
            if ~isempty(file)
                mt.moviecontrols = set(mt.moviecontrols,'moviename',[]);
            end
            msg = {[fname ' file does not exist!'],[], ...
                ['Please create ' fname ' file in'], ...
                ['@movietool/movietool folder.']};
            msgbox(msg);
        end
        %======================================================================
    case 'PauseMovie'
        %======================================================================
        configure(mt.moviecontrols,'pausemovie');

        if get(mt.moviecontrols,'pause_flag')

            %--- Pause Audio ---%
            %mt.movieaudio = pause(mt.movieaudio);

            mt = set(mt,'play_flag',0,'rec_flag',0);

            %--- Update Figure Window Props ---%
            set(mt.guiobjects,'figure','initial');

            %--- Undo-Hightlight ----%
            highlight(mt.guiobjects,'all','off');

            mt.guiobjects = savestate(mt.guiobjects);
        else
            %_________% LOAD MOVIE %__________%
            %--- Get File ----%
            file = get(mt.moviecontrols,'moviename');
            path = get(mt.moviecontrols,'moviepath');

            if ischar(file)
                Movie = load([path,file]);
                L = size(Movie.data);
                % ML = (Movie.data{end,4}); % movie length (sec)

                %--- update global movie controls ----%
                %             configure(mt.moviecontrols,'play','global');

                %--- get next frame ----%
                N2 = get(mt.moviecontrols,'frameNo');

                %--- Update movie control flags ----%
                mt = set(mt,'play_flag',1,'rec_flag',0);

                % Set figure children's visibility to: off
                resizeFcn = get(mt.fig,'ResizeFcn');
                set(mt.fig,'ResizeFcn','');
                chv = findobj(get(mt.fig,'children'),'visible','on');
                set(chv,'vis','off');

                %--- PLAY FRAME ---%
                hBar = waitbar(0,'Loading movie ...');

                for k=1:N2-1
                    %--- Save movie frame 'playdata' ----%
                    mt.moviecontrols = set(mt.moviecontrols,'playdata',[Movie.data(k,2:3) {'next'}]);
                    setappdata(mt.fig,'movietoolData',mt);

                    % optimize file loading
                    %mvn = optimizeLoadFile(mt,Movie.data,k,N2);
                    mvn = [];

                    if isempty(mvn)
                        waitbar(k/N2)

                        %--- run callbacks ----%
                        eval(Movie.data{k,1});

                        % update movietool object
                        mt = getappdata(mt.fig,'movietoolData');
                    end

                    if k == N2-2
                        %--- Undo-Hightlight ----%
                        highlight(mt.guiobjects,'all','off');
                    end
                end %for

                close(hBar);

                % Set figure children's visibility to: on
                set(chv,'vis','on');
                set(mt.fig,'ResizeFcn',resizeFcn);
                %_________________________________%

                %--- update movie controls ----%
                set(mt.guiobjects,'figure','initial');
                set(mt.guiobjects,'enable','on');
                configure(mt.moviecontrols,'stop','play');
                set(mt,'stop_flag',1);

                mt.moviecontrols = set(mt.moviecontrols,'playdata',[]);
                set(mt.moviecontrols,'barpatch',k/L(1));
                %set(mt.moviecontrols,'barpatcha',time/ML);

                if k == L(1)
                    mt.moviecontrols = set(mt.moviecontrols,'frameNo',1,'time',0);
                else
                    mt.moviecontrols = set(mt.moviecontrols,'frameNo',k+1,'time',Movie.data{k+1,4});
                end
                %--------------------------%
            end %ischar
        end %if get(...flag')
        %======================================================================
    case 'Separate'
        %======================================================================
        disp(sprintf(['%s' '\n' '%s'],'Separate Movie-Tool from the main figure', ...
            '- NOT YET IMPLEMENTED -'))
        %======================================================================
    otherwise
        %======================================================================
        error('Error in movietool.m: cannot find appropriate driver method');
        %======================================================================
end
% Save MOVIETOOL object to figure data 'movietoolData'
setappdata(mt.fig,'movietoolData',mt);