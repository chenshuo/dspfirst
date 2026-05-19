function initializeMovie(mt,handles)   
% @MOVIETOOL/INITIALIZEMOIVE Initialize movie settings.
%
% initializeMovie(mt,handles)
%
%            mt:   movietool object
%       handles:   main GUI file varargin of the form: {action,[],handles} 
%   
%   See also @MOVIETOOL/ ... PRE_CALLBACKACTION, POST_CALLBACKACTION

%   Author(s): Greg Krudysz
%
%   DEVELOPERS: Add GUI DEPENDENT code under "GUI Dependent Code".  

%=================================================%
% Do Not Edit
%=================================================%
% InitializeFunctions
setstate(mt.guiobjects,1);

% undo-hightlight 
highlight(mt.guiobjects,'all','off');

%=================================================%
% GUI Dependent Code 
%=================================================%
eval([mt.filename '(''menu_delall_Callback'',[],[],guidata(gcbf))']);     
handles = guidata(mt.fig);

% initialize ray position
set(handles.lineray_main ,'xdata',[0 1/sqrt(2)],'ydata',[0 1/sqrt(2)]);
set([handles.lineray_mag,handles.lineray_phase],'xdata',[pi/4 pi/4]);
%=================================================%