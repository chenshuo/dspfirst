function jext =  chkpair(E,jext)

magE = abs(E);
if mod(length(magE),2)
    r = 1:2:length(magE)-1;
else
    r = 1:2:length(magE);
end
sumE = magE(r) + magE(r+1);
ind = find(sumE == min(sumE));
jext(ind*2-1) = [];
jext(ind*2-1) = [];
jext = jext;
     
% Test case  
%    -0.0565
%     0.0625
%    -0.0737
%     0.0565
%    -0.0565
%     0.2553
%    -0.4335
%     0.0565
%    -0.1401
%     0.0790
%    -0.0608
%     0.0566