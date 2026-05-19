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

%=================================================%