function a = pickone(list)
%PICKONE	Randomly picks an element from a list.
%   a = PICKONE(list) randomly picks one element a from
%   the vector list.

% James H. McClellan, 1994-1995

a = list( round((length(list)-1)*rand)+1 );
