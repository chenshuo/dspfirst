function post_callbackAction(mt,varargin)
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
        list = {'resetclickpt','getcurrentpt'};
        if any(strcmp(callback,list))
            %-begin-%%%%%%%%%%%%%%%%%%%%%%%%%%
            if strcmp(callback,'resetclickpt')   
                set(mt.guiobjects,'figure','arrow');
            elseif strcmp(callback,'getcurrentpt')
                playdata = get(mt.moviecontrols,'playdata');
                set(varargin{4}.axes_pzplot,'userdata',playdata{1});
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
        list = {'getcurrentpt';'menu_addpole_Callback';'menu_addzero_Callback';'menu_addpez_Callback'; ...
                'menu_delpole_Callback';'menu_delzero_Callback';'menu_delall_Callback';'resetclickpt'; ...
                'pb_addpole_Callback';'pb_editpole_Callback';'pb_addzero_Callback';'pb_editzero_Callback'; ...
                'getXY';'check_connection'};       
        list_current = strcmp(varargin{1},list);
        
        if any(list_current)
            if strcmp(varargin{1},'getcurrentpt')
                currentpt = get(varargin{2},'userdata');
                
                if isempty(varargin{5})
                    obj = get(varargin{4}.axes_pzplot,'ButtonDownFcn');
                    var1 = currentpt;               
                elseif any(strcmp(varargin{5},{'addpole','addzero','addpez'}))
                    obj = get(varargin{4}.axes_pzplot,'ButtonDownFcn');      
                    var1 = currentpt;   
                elseif any(strcmp(varargin{5},{'pole','zero','z_pez','p_pez','ray'}))
                    obj = get(mt.fig,'WindowButtonMotionFcn');
                    var1 = currentpt;
                end
            elseif any(strcmp(varargin{1},{'menu_addpole_Callback','menu_addzero_Callback','menu_addpez_Callback', ...
                        'menu_delpole_Callback','menu_delzero_Callback','menu_delall_Callback','check_connection', ...
                        'pb_addpole_Callback','pb_editpole_Callback','pb_addzero_Callback','pb_editzero_Callback'}))
                obj = [];
            elseif strcmp(varargin{1},'getXY')
                switch varargin{5}
                    case 'add_pole'
                        obj  = varargin{4}.pb_addpole;
                        var1 = get(varargin{4}.edit_poleloc,'string');
                    case 'edit_pole'
                        obj  = varargin{4}.pb_editpole;
                        var1 = get(varargin{4}.edit_poleloc,'string');
                    case 'add_zero'
                        obj  = varargin{4}.pb_addzero; 
                        var1 = get(varargin{4}.edit_zeroloc,'string');
                    case 'edit_zero'
                        obj  = varargin{4}.pb_editzero;
                        var1 = get(varargin{4}.edit_zeroloc,'string');
                end
                %var1 = varargin{6};   
            elseif strcmp(varargin{1},'resetclickpt')
                obj =  [mt.filename, '(''resetclickpt'',[],[],guidata(gcbo))'];
            end
            write_flag = 1;
            if strcmp(varargin{1},'InitializeState')
                %-------------------------------
                write_flag = 0;
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