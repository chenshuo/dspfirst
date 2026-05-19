function drawstaf
%DRAWSTAF   draws the staffs for Music GUI
%     (used as a callback within musicgui)
%
ClefHandle = findobj(gcbf,'Tag','Clefs');
axes(ClefHandle);
cla;

xlen = 8;
ylen = 10*2+12;

hold off;
patch([0 xlen xlen 0],[0 0 ylen ylen],'w','EdgeColor','none');
hold on;
p=plot([2 2],[5 25],'k');
set(p,'LineWidth',3)
axis([1 xlen 0 ylen ])

tclef(3,16,1);     

for l = 5:2:13,
   p=plot([2 xlen],[l l],'k');
   set(p,'LineWidth',2);
end;

for l = 17:2:25,
   p=plot([2 xlen],[l l],'k');
   set(p,'LineWidth',2);
end;                                                                                                           
