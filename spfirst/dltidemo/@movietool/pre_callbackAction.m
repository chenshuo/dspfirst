function varargin = pre_callbackAction(mt,varargin)
% @MOVIETOOL/PRE_CALLBACKACTION Modifying function after the main function
% callback evaluator. 
%
%   POST_CALLBACKACTION(mt,varargin) determines which callback "action" is relavant during
%   recording or playing of the GUI.  Callback parameters are recorded
%   and played according to "action" callback.
%
%   varargin = pre_callbackAction(mt,varargin)
%
%       mt:         movietool object
%       varargin:   main GUI file varargin of the form: {action,[],handles} 
%   
%   See also @MOVIETOOL/ ... POST_CALLBACKACTION

%   Author(s): Greg Krudysz 
%
%   DEVELOPERS: The following sections in this code are GUI DEPENDENT.  
%   Here "list" represents callback "action" to be modified when 
%   recording or playing a movie.
if ~isempty(mt)
    %==========================================================================
    %                     P L A Y
    %==========================================================================
    if mt.play_flag
        HL_object = [];    % highlight object    
        callback = varargin{1};
        playdata = get(mt.moviecontrols,'playdata');
        setobject(mt.guiobjects,callback,playdata);
        
        % Play Functions
        list = {'FilterFreq1E'};
        list_current = strcmp(callback,list);
        
        if any(list_current)     
            if isempty(playdata)
                index = 2;
            else
                if strcmp(playdata{3},'next')
                    index = 2; else index = 1;
                end
            end
            
            if strcmp(list,'FilterFreq1E')
                if any(varargin{4}.PopUpValue==(3:8))
                    Tag = 'FilterEdFreq1';
                    object = findobj(gcbf,'Tag','FilterEdFreq1');
                    set(object,'string',playdata{1}{index});
                    set(gcbf,'CurrentObject',object);
                    HL_object = object; % highlight
                end
            end
            %-------------------------------      
            
            % Map Inverse Functions
            if (2-index) 
                if any(strcmp(callback,{'someFcn'}))
                end
            end       
        end %eof: list_current
        
        % highlight
        if ~isempty(HL_object)
            highlight(mt.guiobjects,HL_object);
        end
        
        % End audio playback if closing figure
        if findstr(lower(get(mt.fig,'CloseRequestFcn')),lower(callback))
            stopplaying(mt.movieaudio);
        end
        
        % Update handles
        guidata(mt.fig,varargin{4});
    end  %eof: flag
    %==========================================================================
    %                   R E C O R D
    %==========================================================================
    if mt.rec_flag
        index = strcmp(varargin{1},{'someFcn'});
        if any(index)
            var1=[]; var2=[]; counter = 1;
            
            mt.movielog = write(mt.movielog,{obj,var1,var2,counter});
            % Save MOVIETOOL object to figure data 'movietoolData'      
            setappdata(mt.fig,'movietoolData',mt); 
        end
        
        % End audio recording if closing figure
        if findstr(lower(get(mt.fig,'CloseRequestFcn')),lower(varargin{1}))
            stop(mt.movieaudio,1);
        end
    end
    %==========================================================================
end