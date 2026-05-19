function adjustpath(fname)
%ADJUSTPATH Adjust the Matlab path.
%   ADJUSTPATH(fname) checks that the file fname is on the MATLABPATH
%   in a single location.  Depending on fname the following will occur:
%
%      If the file is not found on Matlab's search path, an error is
%      returned saying the function cannot be found on the search path.
%
%      If the file is found in multiple places on Matlab's search path, 
%      an error is returned.  This serves as a safeguard against multiple
%      installations.
%
%      If the file is found in a single place on Matlab's search path,
%      it is then checked against the MATLABPATH.  The purpose is to 
%      distinguish between a file in the current directory from a file
%      which is truly on the MATLABPATH.  If it truly on the MATLABPATH the 
%      function returns with no error.  If it is not on the MATLABPATH 
%      (which means it must be in the current directory), the user is given 
%      an option to temporarily add the file's path to the the MATLABPATH 
%      for the current Matlab session.  If yes is chosen, it is added.  If 
%      no is chosen, an error is returned saying the file must be on the 
%      path to run.  

% Jordan Rosenthal, 05-Nov-2000
% Greg Krudysz, 15-Dec-2004 : added error message with path names
%                           : fixed lower case path names

w = which(fname,'-all'); 	%WHICH FUN -ALL  displays the paths to all functions with the name FUN
N = size(w,1); 				%see help size
switch N
    case 0
        msg = ['The function ' fname ' is not on Matlab''s search path.'];
        error(msg);
    case 1
        filePath = fileparts( w{1} );
        curPath = path;
        
        k = findstr(curPath,filePath);
        if isempty(k)
            k = findstr(lower(curPath),lower(filePath));
        end
        
        if isempty(k)
            quest = {'This program must be on the Matlab path to run correctly. ', ...
                    'Should ','', ...
                    ['     ' filePath],' ', ...
                    'be added to the path?  Note that any path change will remain', ...
                    'in effect for the current Matlab session only.'};
            ButtonName = questdlg(quest,'Add to Path?','Yes','No','Yes');
            switch ButtonName
                case 'Yes'
                    path(curPath,filePath);
                case 'No'
                    msg = 'This program must on the Matlab path to run correctly.';
                    error(msg);
            end
        end
    otherwise   
        % Construct an error message based on the number of multiple paths
        % found
        msg1 = sprintf('\nThe follwing multiple copies of this program have been found on the path:\n\n');
        
        msg2 = '';
        for n = 1:N
            str = strrep(w{n},'\','\\');
            msg2 = [str '\n' msg2];
        end
        msg2 = sprintf(msg2);
        msg3 = sprintf('\nPlease remove additional copies from the path.');
        error([msg1,msg2,msg3]);
end

%	FILEPARTS Filename parts.
%   [PATH,NAME,EXT,VER] = FILEPARTS(FILE) returns the path, filename, 
%   extension and version for the specified file.  VER will be non-empty
%   only on VMS.  FILEPARTS is platform dependent.
%   You can reconstruct the file from the parts using
%   fullfile(path,[name ext ver])

%	ButtonName=questdlg(Question,Title,Btn1,Btn2,DEFAULT);

%	PATH(P1,P2) changes the path to the concatenation of the two path
%   strings P1 and P2.  Thus PATH(PATH,P) appends a new directory to
%   the current path and PATH(P,PATH) prepends a new path.  If P1 or
%   P2 are already on the path, they are not added.
