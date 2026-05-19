function drawlines(dur)
%MG_DLINE    draw the horizontal lines needed in a musical score
%      (used as a support function for musicgui)
%   dur = array of note durations

StaffHandle = findobj(gcbf,'Tag','Staff');
axes(StaffHandle);
cla;

xlen = max(sum(dur,2))*4*6.5+3;
ylen = 10*2+12;

hold off;
patch([0 xlen xlen 0],[0 0 ylen ylen],'w','EdgeColor','none');
hold on;
axis([0 xlen 0 ylen ])

for l = 5:2:13,
   p=plot([0 xlen-1],[l l],'k');
   set(p,'LineWidth',2);
end;

for l = 17:2:25,
   p=plot([0 xlen-1],[l l],'k');
   set(p,'LineWidth',2);
end;                                                                                                           
