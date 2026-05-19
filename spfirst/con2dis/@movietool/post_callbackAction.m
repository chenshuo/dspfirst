function  post_callbackAction(mt,varargin)
% @MOVIETOOL/POST_CALLBACKACTION Modifying function prior to main function
% callback evaluator.  
%
%   POST_CALLBACKACTION(mt,varargin) determines which callback "action" and its 
%   parameters are to be saved and/or retrieved when playing or recording
%   of the GUI. Stores and retrieves these desired parameters.
%
%       mt:         movietool object
%       varargin:   main GUI file varargin of the form: {action,[],handles}
%   
%   See also @MOVIETOOL/ ... PRE_CALLBACKACTION

%   Author(s): Greg Krudysz

%   DEVELOPERS: The following sections in this code are GUI DEPENDENT.  
%   Here "list" represents callbacks to be modified when recording or 
%   playing a movie.

if ishandle(mt.fig)
    
    % Reload MOVIETOOL and GUI handles
    mt = getappdata(mt.fig,'movietoolData');
    varargin{4} = guidata(mt.fig);
    %==========================================================================
    %                     P L A Y
    %==========================================================================
    if mt.play_flag
        callback = varargin{1};
        list = {'SomeFcn'};
        if any(strcmp(callback,list))
            playdata = get(mt.moviecontrols,'playdata');
            
            if strcmp(playdata{3},'next')
                index = 2; else index = 1;
            end
            %-begin-%%%%%%%%%%%%%%%%%%%%%%%%%%
            if strcmp(callback,'SomeFcn')   
            end
            %-end-%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
    end
    %==========================================================================
    %                   R E C O R D
    %==========================================================================
    if mt.rec_flag
        write_flag = 0; 
        obj = gcbo;   
        var1=[]; var2=[]; counter = 1;
           
        %  Initialize Movie
        if strcmp(varargin{1},'InitializeMovie')
            varargout = {[]}; % none needed for this GUI
        end
        
        % Record UICONTROL Objects
        [mt.guiobjects,var1,write_flag] = recordobject(mt.guiobjects,obj,var1);
        
        % Record Functions
        list = {'GetCurrentPoint'};       
        list_current = strcmp(varargin{1},list);
        
        if any(list_current)
            write_flag = 1;
            if strcmp(varargin{1},'GetCurrentPoint')

            end
            write_flag = 1;
            if strcmp(varargin{1},'GetCurrentPoint')
                %-------------------------------
                var  = get(varargin{4}.Axis4,'CurrentPoint');
                var  = var(1,1);
                var1 = {var ; var};
                obj  = [mt.filename ' MoveLine']; 
                %-------------------------------
            end
        end
        %-end-%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %-------------------------------%
        if and(write_flag , ~isempty(obj)) 
            mt.movielog = write(mt.movielog,{obj,var1,var2,counter});
            
            % Save MOVIETOOL object to figure data 'movietoolData'
            setappdata(mt.fig,'movietoolData',mt);
        end
    end
    %==========================================================================
    guidata(mt.fig,varargin{4});
end % e.o.:ishandle