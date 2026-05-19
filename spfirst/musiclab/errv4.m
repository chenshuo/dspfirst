function errv4(txt)
%ERRV4   report error 
%
disp('**************************************');
disp('**************************************');
ttt = '***                                ***';
Lt = length(ttt);
Ltxt = length(txt);
nb = Lt-Ltxt-6;
nb2 = round(nb/2);
tta = ['***',blanks(nb2),txt,blanks(nb-nb2),'***'];
disp(ttt);
disp(tta);
disp('***   does not work in version  4  ***');
disp(ttt);
disp('**************************************');
disp('**************************************');
