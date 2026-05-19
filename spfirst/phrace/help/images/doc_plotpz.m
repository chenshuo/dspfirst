figure
b = [2 1 1];
a = [2 2 1];
axes
hAx = gca;
hFig = get(gca,'Parent');
z = roots(b);
p = roots(a);
[hZ,hP]=zzplane(z,p);
set(hZ,'color','r','MarkerSize',8);
set(hP,'color','k','MarkerSize',8);
set(hAx,'Units','normalized')
set(hAx,'Position',[0.2 0.2 0.4 0.4])
set(get(hAx,'Xlabel'),'string','Real Part')
set(get(hAx,'Ylabel'),'string','Imaginary Part')
set(hFig,'Color',[1 1 1])