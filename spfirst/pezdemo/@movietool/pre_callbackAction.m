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
        list = {'getcurrentpt';'UpdateState';'getclickpt';'movepez';'resetclickpt'; ...
                'menu_delpole_Callback';'menu_delzero_Callback';'menu_delall_Callback'; ...
                'pb_addpole_Callback';'pb_editpole_Callback';'pb_addzero_Callback'};
        list_current = strcmp(callback,list);
        
        if any(list_current)     
            if isempty(playdata)
                index = 2;
            else
                if strcmp(playdata{3},'next')
                    index = 2; else index = 1;
                end
            end
            %-------------------------------
            if strcmp(callback,'getcurrentpt')
                playdata = get(mt.moviecontrols,'playdata');
                set(varargin{4}.axes_pzplot,'userdata',playdata{1});
                %-------------------------------
            elseif strcmp(callback,'UpdateState') 
                %-------------------------------
                set(mt.guiobjects,'figure','arrow');
                %-------------------------------
            elseif strcmp(callback,'getclickpt')  
                %-------------------------------
                % Determine highlight object 
                switch varargin{5}
                    case 'addpole'
                        HL_object = varargin{4}.pb_pp;
                    case 'addzero'
                        HL_object = varargin{4}.pb_zz;
                    case 'addpz'
                        HL_object = varargin{4}.pb_pz;
                end  
            end          
            
            % Map Inverse Functions
            if (2-index) 
                if any(strcmp(callback,{'getclickpt','pb_addpole_Callback','pb_addzero_Callback'}))
                    if length(varargin) < 5
                        if strcmp(callback,'pb_addpole_Callback')
                            action = 'addpole';
                        elseif strcmp(callback,'pb_addzero_Callback')
                            action = 'addzero';
                        end
                    else
                        action = varargin{5};
                    end
                    switch action
                        case 'addpole'
                            %-------------------------------
                            data = playdata{1};
                            pole = data(1) + j*data(2);
                            tempvalue = find( abs(varargin{4}.poleloc - pole) == min(abs(varargin{4}.poleloc - pole)));
                            varargin{4}.tempvalue = tempvalue;
                            set(varargin{4}.listbox_pole,'Value',tempvalue);
                            varargin{1} = 'pb_delpole_Callback';
                            %-------------------------------
                        case 'addzero'
                            %-------------------------------
                            data = playdata{1};
                            zero = data(1) + j*data(2);
                            tempvalue = find( abs(varargin{4}.zeroloc - zero) == min(abs(varargin{4}.zeroloc - zero)));
                            varargin{4}.tempvalue = tempvalue;
                            set(varargin{4}.listbox_zero,'Value',tempvalue);
                            varargin{1} = 'pb_delzero_Callback';
                            %-------------------------------
                        case 'addpez'
                            %-------------------------------
                            data = playdata{1};
                            pole = data(1) + j*data(2);
                            zero = real(1/pole) + j*imag(1/pole);
                            tempvalue_pole = find( abs(varargin{4}.poleloc - pole) == min(abs(varargin{4}.poleloc - pole)));
                            tempvalue_zero = find( abs(varargin{4}.zeroloc - zero) == min(abs(varargin{4}.zeroloc - zero)));
                            set(varargin{4}.listbox_pole,'Value',tempvalue_pole);
                            set(varargin{4}.listbox_zero,'Value',tempvalue_zero); 
                            eval([mt.filename '(''pb_delzero_Callback'',[],[],guidata(gcbf))']);  
                            varargin{4} = guidata(mt.fig);
                            varargin{1} = 'pb_delpole_Callback';
                            %-------------------------------
                        case {'pole','zero','z_pez','p_pez','ray'}
                            %-------------------------------
                            disp('OTHER - pre_callbackaction')
                    end
                elseif any(strcmp(callback,{'menu_delpole_Callback','menu_delzero_Callback','menu_delall_Callback'}));
                    if length(varargin) == 5
                        switch varargin{5}
                            case 'delete_pole'
                                varargin{4}.poleloc = playdata{1};   
                                varargin{4}.a = poly(playdata{1});
                            case 'delete_zero'
                                varargin{4}.zeroloc = playdata{1};
                                varargin{4}.b = poly(playdata{1});
                            case 'delete_all'
                                varargin{4}.zeroloc = playdata{1}{1};
                                varargin{4}.poleloc = playdata{1}{2};
                                varargin{4}.b = poly(playdata{1});
                                varargin{4}.a = poly(playdata{1});
                        end 
                        varargin{1} = 'refresh_Callback';                   
                    end
                elseif strcmp(callback,'movepez')
                    % initialize movepez
                    eval([mt.filename '(''startdrag'',[],[],guidata(gcbf))']); 
                elseif strcmp(callback,'resetclickpt')
                    varargin{1} = 'DoNothing';
                elseif strcmp(callback,'pb_editpole_Callback')
                    set(varargin{4}.edit_poleloc,'string',playdata{1});
                    % NOTE: have no way of figuring out previous value, so that
                    % the pole moves back to its prev location - gk 
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
        index = strcmp(varargin{1},{'menu_delpole_Callback','menu_delzero_Callback','menu_delall_Callback'});
        if any(index)
            var1=[]; var2=[]; counter = 1;
            switch find( index == 1 )
                case 1
                    var1 = varargin{4}.poleloc;
                case 2
                    var1 = varargin{4}.zeroloc;
                case 3
                    var1 = {varargin{4}.zeroloc;varargin{4}.poleloc};
            end
            obj = varargin{2};
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