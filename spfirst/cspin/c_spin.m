function c_spin(X,F,T)
%c_spin(X,F,T)
%-------------
%visualize phasors spinning in the complex plane and the resulting
%real and imaginary parts of the signal, together with the 
%corresponding spectral lines.
%Shows the initial state (t=0) when called, then hit any key to 
%start rolling.
%inputs: 
%  X - phasors values 
%      e.g., X=[1.2*exp(j*0.2*pi) 0.8*exp(-j*0.3*pi)];
%  F - phasors freqs
%      e.g., F=[0.8 -2.2];
%  T - time length to display
%      e.g., T=5 (optional, default is T=10).
%
%By Arie Yeredor, Feb. 2016

if any(size(X)~=size(F))
    error('X and F must have the same size');
end
X=X(:);
F=F(:);
if ~exist('T')
    T=10;   %default
end

maxx=max(abs(X));
maxlen=sum(abs(X));
scl=ceil(maxlen);
maxf=max(abs(F));

dt=max(0.01,min(T/4000,1/4/maxf));
if dt>1/2/maxf
    warning('max freq. too high - aliasing');
end
tt=0:dt:T;
NT=length(tt);
xr=zeros(1,NT);
xi=zeros(1,NT);

hf=figure(1);
set(hf,'position',[250 50 900 900],'color',[0.8 0.85 0.9],'WindowStyle','normal');
clf

%unit circle axes
huc=axes('position',[0.01 0.67 0.32 0.32],...
    'color',[0.95 0.95 0.7],'box','on','xtick',[],'ytick',[]);
axis(scl*[-1 1 -1 1])
hold on
plot(scl*[-1 1],[0 0],':k')
plot([0 0],scl*[-1 1],':k')
th=[0:100]/100*2*pi;
plot(cos(th),sin(th),'k')

%imag part axes
him=axes('position',[0.33 0.67 0.66 0.32],...
    'color',[0.95 0.9 0.9],'box','on','xtick',[],'ytick',[]);
axis([0 T -scl scl])
hold on
plot([0 T],[0 0],':k')
text(T/20,0.9*scl,'Imag\{z(t)\}')
text(0.97*T,0.1*scl,'t')
text(0.01*T,-0.1*scl,'0')
text(0.97*T,-0.1*scl,num2str(T))

%real part axes
hre=axes('position',[0.01 0.01 0.32 0.66],...
    'color',[0.9 0.95 0.9],'box','on','xtick',[],'ytick',[],'ydir','reverse');
axis([-scl scl 0 T])
hold on
plot([0 0],[0 T],':k')
text(0.9*scl,T/20,'Real\{z(t)\}','rotation',-90)
text(-0.1*scl,0.97*T,'t','rotation',-90)
text(0.1*scl,0.01*T,'0','rotation',-90)
text(0.1*scl,0.97*T,num2str(T),'rotation',-90)

%spectrum axes
hsp=axes('position',[0.33 0.01 0.66 0.66],...
    'color',[1 1 1],'box','on','xtick',[],'ytick',[]);
axis([maxf*[-1.1 1.3] maxx*[-0.1 1.1] ])
hold on
plot(maxf*1.05*[-1 1],[0 0],'k')
plot([0 0],[0 maxx],'k')
text(maxf*1.2,-maxx*0.05,'f')

N=length(X);
hph=zeros(N,1);
sx=0;
for n=1:N
    fn=F(n);
    xn=X(n);
    mured=(fn/maxf+1)/2;
    clr=[mured 1-mured 0];
    axes(huc)
    hph(n)=plot(real(sx)+[0 real(xn)],imag(sx)+[0 imag(xn)],'color',clr,'linewidth',2);
    sx=sx+xn;
    axes(hsp)
    %plot([fn fn],[0 abs(xn)],'color',clr,'linewidth',2)
    stem(fn,abs(xn),'color',clr,'linewidth',2)
    text(fn,-maxx*0.02,sprintf('%2.2f',fn))
    linval=[sprintf('%2.2f',abs(xn)) 'e^{' sprintf('%2.2f',angle(xn)/pi) '{\pi}j}'];
    text(fn+maxf/50,abs(xn),linval)
end
axes(huc)
hph1=plot([real(sx) scl],[imag(sx) imag(sx)],'c');
hpv1=plot([real(sx) real(sx)],[imag(sx) -scl],'c');
xr(1)=real(sx);
xi(1)=imag(sx);
axes(him)
hph2=plot([0 0],[imag(sx) imag(sx)],'c');
hpim=plot(tt,xi,'b','linewidth',2);
axes(hre)
hpv2=plot([real(sx) real(sx)],[0 0],'c');
hpre=plot(xr,tt,'b','linewidth',2);

disp('Strike any key to start rolling')
axes(hsp)
htxt=text(-maxf*0.4,1.03*maxx,'Strike any key to start rolling','fontsize',14,'color','r');
pause
set(htxt,'string','')

%start rolling
for nt=2:NT
    tic;
    t=tt(nt);
    xe=X.*exp(1j*2*pi*F*t);
    sx=0;
    for n=1:N
        xn=xe(n);
        set(hph(n),'xdata',real(sx)+[0 real(xn)],'ydata',imag(sx)+[0 imag(xn)]);
        sx=sx+xn;
    end
    xr(nt)=real(sx);
    xi(nt)=imag(sx);
    set(hph1,'xdata',[real(sx) scl],'ydata',[imag(sx) imag(sx)]);
    set(hpv1,'xdata',[real(sx) real(sx)],'ydata',[imag(sx) -scl]);
    set(hph2,'xdata',[0 t],'ydata',[imag(sx) imag(sx)]);
    set(hpim,'ydata',xi);
    set(hpv2,'xdata',[real(sx) real(sx)],'ydata',[0 t]);
    set(hpre,'xdata',xr);    
    drawnow
    pause(dt-toc)
end