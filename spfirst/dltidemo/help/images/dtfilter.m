function dtfilter()
n = 0:29;
XLIMS = [-.5 31];
h_b = [1,2,1];
h_a = [1];
[hh_res, hh_range] = freqz(h_b, h_a, 512, 'whole');
hh_range = hh_range/2/pi - 0.5;
hh_res = fftshift(hh_res);

hh_mag = abs(hh_res);
hh_phase = angle(hh_res);

f = 0.2;
[qq, kMag] = min(abs(hh_range - f));
[qq, kMag2] = min(abs(hh_range + f));

hh_filt_mag = hh_mag(kMag);
hh_filt_phase = hh_phase(kMag);

hh_filt_mag_neg = hh_mag(kMag2);
hh_filt_phase_neg = hh_phase(kMag2);

if 0
FigProps = {'color',[1 1 1],...
	   'Units', 'Inches',...
	   'Position',[3 3 3 3]};
AxisProps = {'color',[1 1 1],...
	     'Position',[0.1 0.2 0.8 0.7], ...
	     'Visible','Off'};
figure,plot(hh_range, hh_mag, 'k')
text(-.25, 0,'-\omega_0','vert','top');
text(.23, 0,'\omega_0','vert','top');
ylabel_h = text('Horiz','center',...
		'Vert','baseline',...
		'Position',[-.52, 2],...
		'Rotation',90,...
		'String','|H(e^{j\omega})| \rightarrow');
hold on
plot(hh_range,zeros(length(hh_range)),'-k')
plot([hh_range(1) hh_range(1)],[0 4],'-k')
plot([hh_range(kMag) hh_range(kMag)], [0 hh_filt_mag],'-.k')
plot([hh_range(kMag2) hh_range(kMag2)], [0 hh_filt_mag_neg],'-.k')
plot([hh_range(1) hh_range(kMag)], [hh_filt_mag_neg hh_filt_mag_neg],'-.k')
hold off
%set(gca, 'Ylabel', ylabel_h);
set(gcf, FigProps{:});
set(gca, AxisProps{:});
if 0
   exportfig(gcf,'filter_mag.png','Height',2,'Format','png');
   %close(gcf);
end

FigProps = {'color',[1 1 1],...
	   'Units', 'Inches',...
	   'Position',[3 3 3 2]};
AxisProps = {'color',[1 1 1],...
	     'Position',[0.1 0.1 0.8 0.8], ...
	     'Visible','Off'};
figure,plot(hh_range, hh_phase, 'k')
text(-.25,0,'-\omega_0','vert','top');
text(.23,0,'\omega_0','vert','bottom');
ylabel_h = text('Horiz','center',...
		'Vert','baseline',...
		'Position',[-.52, .5],...
		'Rotation',90,...
		'String','\phi(e^{j\omega}) \rightarrow');
hold on
plot(hh_range,zeros(length(hh_range)),'-k')
plot([hh_range(kMag) hh_range(kMag)], [0 hh_filt_phase],'-.k')
plot([hh_range(kMag2) hh_range(kMag2)], [0 hh_filt_phase_neg],'-.k')
hold off
%set(gca, 'Ylabel', ylabel_h);
%text(.75,0,'w_0','vert','top');
set(gcf, FigProps{:});
set(gca, AxisProps{:});
if 0
   exportfig(gcf,'filter_phase.png','Height',1.5,'Format','png');
   %close(gcf);
end
end
f = [0.1 0.2 0.3];

for k = 1:3
  [qq, kMag] = min(abs(hh_range - f(k)));
  [qq, kMag2] = min(abs(hh_range + f(k)));

  hh_out_mag = hh_mag(kMag);
  hh_out_phase = hh_phase(kMag)/pi;
  
  x(k,:) = cos(2*pi*f(k)*n);
  y(k,:) = hh_out_mag*cos(2*pi*f(k)*n + hh_out_phase);
  
  % Input plots
  figure, 
  hA = stem(x(k,:), 'k', 'filled');
  set(hA, 'MarkerSize', 2);
  hold on
  hA = stem(XLIMS(2), 0,'>k','filled');
  set(hA, 'MarkerSize', 2);
  plot(XLIMS,[0 0],'-k');
  hY = stem(0, 1,'^k','filled');
  set(hY, 'MarkerSize', 2);
  plot([0 0], [-.1 1],'-k');
  
  hold off;
  
  text(XLIMS(1),0,'1','Vert','Top','Horiz','left')
  text(29,0,'n=30','Vert','Top')
  text(-0.25,1,'1','Horiz','right');
  
  %%  Set Figure properties  %%
  FigProps = { ...
      'color',[1 1 1], ...
      'Units','Inches', ...
      'Position', [3 3 2 1.5]};
  AxisProps = { ...
      'Color',[1 1 1], ...
      'Position',[0.1 0.1 0.8 0.7], ...
      'Visible','Off', ...
      'XLim',XLIMS, ...
      'YLim',[-inf inf] };
  
  set(gcf, FigProps{:});
  set(gca, AxisProps{:});
  if 1
    exportfig(gcf,['filter_ip', num2str(k), '.png'],'Height',.7,'Format','png');
    %close(gcf);
  end
  
  % Output plots
  figure, 
  hA = stem(y(k,:), 'k', 'filled');
  set(hA, 'MarkerSize', 2);
  axis([0 31 -4 4])
  hold on
  hA = stem(XLIMS(2), 0,'>k','filled');
  set(hA, 'MarkerSize', 2);
  plot(XLIMS,[0 0],'-k');
  hY = stem(0, 4,'^k','filled');
  set(hY, 'MarkerSize', 2);
  plot([0 0], [-.5 4],'-k');
  hold off;
  
  text(XLIMS(1),0,'1','Vert','Top','Horiz','left')
  text(29,0,'n=30','Vert','Top')
  text(-0.25,4,'4','Horiz','right');
  
  %%  Set Figure properties  %%
  FigProps = { ...
      'color',[1 1 1], ...
      'Units','Inches', ...
      'Position', [3 3 2 1.5]};
  AxisProps = { ...
      'Color',[1 1 1], ...
      'Position',[0.1 0.1 0.8 0.7], ...
      'Visible','Off', ...
      'XLim',XLIMS, ...
      'YLim',[-4 4] };
  
  set(gcf, FigProps{:});
  set(gca, AxisProps{:});
  if 1
    exportfig(gcf,['filter_op', num2str(k) ,'.png'],'Height',.7,'Format','png');
    %close(gcf);
  end
  
end

x_cum = sum(x);
y_cum = sum(y);
figure, 
hA = stem(n,x_cum,'k','filled');
set(hA, 'MarkerSize', 2);
updatePlot(XLIMS, [-3 3], 3)
if 1
   exportfig(gcf,'filter_ip_sum.png','Height',0.7,'Format','png');
   %close(gcf);
end

figure, 
hA = stem(n,y_cum,'k','filled');
set(hA, 'MarkerSize', 2);
updatePlot(XLIMS, [-3 8], 8)
if 1
  exportfig(gcf,'filter_op_sum.png','Height',0.7,'Format','png');
  %close(gcf);
end

function updatePlot(XLIMS, YLIMS, yMax)
  hold on
  hA = stem(XLIMS(2), 0,'>k','filled');
  set(hA, 'MarkerSize', 2);
  plot(XLIMS,[0 0],'-k');
  hY = stem(0, yMax,'^k','filled');
  set(hY, 'MarkerSize', 2);
  plot([0 0], [-.5 yMax],'-k');
  hold off;
  
  text(XLIMS(1),0,'1','Vert','Top','Horiz','left')
  text(29,0,'n=30','Vert','Top')
  text(-0.25, yMax, num2str(yMax),'Horiz','right');
  
  %%  Set Figure properties  %%
  FigProps = { ...
      'color',[1 1 1], ...
      'Units','Inches', ...
      'Position', [3 3 2 1.5]};
  AxisProps = { ...
      'Color',[1 1 1], ...
      'Position',[0.1 0.1 0.8 0.7], ...
      'Visible','Off', ...
      'XLim',XLIMS, ...
      'YLim',YLIMS };
  
  set(gcf, FigProps{:});
  set(gca, AxisProps{:});
  
%endfunction updatePlot

%f = -200:1/100:200;
%h = 1 ./ (1 + j*f./50);
%h_mag = abs(h);
%h_ph  = angle(h);
%
%in1 = find(f==25);
%in2 = find(f==50);
%in3 = find(f==75);
%
%%h_mag = abs(h(index));
%%h_ph  = angle(h(index));
%
%t = 0:1/1000:.1;
%x1 = 2*cos(2*pi*25*t);
%x2 =   cos(2*pi*50*t);
%x3 = 4*cos(2*pi*75*t);
%
%y1 = 2*h_mag(in1)*cos(2*pi*25*t + h_ph(in1));
%y2 = h_mag(in2)*cos(2*pi*50*t + h_ph(in2));
%y3 = 4*h_mag(in3)*cos(2*pi*75*t + h_ph(in3));
%
%figure, plot(t, x1)
%figure, plot(t, x2)
%figure, plot(t, x3)
%figure, plot(t, x1+x2+x3)
%
%figure, plot(t, y1)
%figure, plot(t, y2)
%figure, plot(t, y3)
%figure, plot(t, y1+y2+y3)
%figure, plot(f, abs(h))
%axis([-200 200 0 1])
%figure, plot(f, angle(h)/pi)
%
%fig_h1 = [2];
%fig_h2 = [1 3 4];
%fig_h3 = [6];
%fig_h4 = [5 7 8];
%
%set(fig_h1, 'Units','Normalized','Position',[0.5, 0.5, .2, .1])
%set(fig_h2, 'Units','Normalized','Position',[0.5, 0.5, .2, .15])
%set(fig_h3, 'Units','Normalized','Position',[0.5, 0.5, .2, .1])
%set(fig_h4, 'Units','Normalized','Position',[0.5, 0.5, .2, .15])
%
%fig_h5 = [9,10];
%set(fig_h5, 'Units','Normalized','Position',[0.5, 0.5, .2, .2])
