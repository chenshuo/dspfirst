%---
%=== Vowel Demo:
%  This script demonstrates the basic idea of harmonic sinusoids.
%  Five sinusoids with a common fundamental frequency are
%  added together, one at a time.
%  Thus we can see how the waveform changes as higher harmonics
%  are added in.  In addition, the sound of the waveform is
%  played at each step.
%
%  To run the demo just type vowel_d at the MATLAB prompt,
%   and hit <CR> whenever there is a pause.
%---
format compact
clf reset
whitebg(0.88*[1,1,1])
fs = 8000;
ZZ = 10000 * [ (0.0771 + j*1.2202);
              (-0.8865 + j*2.8048);
               (4.8001 - j*0.8995);
	           (0.1657 - j*1.3520);
	            0.4723              ];
%
Fo = 100;
ff = Fo * [ 2, 4, 5, 16, 17 ];  %-- row
dur = 4/Fo;
tt = 0 : (1/fs) : dur;
xi =  exp( -2i*pi*tt'*ff );   %--- components
xx =  xi * ZZ;
%
dur_long = 1.5;
ttt = 0 : (1/fs) : dur_long;

tms = tt*1000;   %--- convert to msec
subplot('Position',[0.12 0.6 0.8 0.3])
jkl = 1;
x1 = xi(:,jkl)*ZZ(jkl);
    hp = plot( tms, real( x1 ) );
	set(hp,'LineWidth',2)
	title('x = Re(A_2 exp(j*2*pi*2*f0*t) )','FontSize',16)
	set(gca,'FontSize',12)
    ylabel('Amplitude','FontSize',14)
disp('<CR> to play sound'),  pause
xxx = real(exp( -2i*pi*ttt'*ff(jkl) )*ZZ(jkl));
sound( xxx/max(abs(xxx)), fs );
disp('<CR> to continue'),  pause

jkl = 1:2;
x12 = xi(:,jkl) * ZZ(jkl);
subplot('Position',[0.12 0.07 0.8 0.35])
	hp = plot( tms, real(x12) );
	set(hp,'LineWidth',2)
	title('x = x + Re(A_4 exp(j*2*pi*4*f0*t) )','FontSize',16)
	set(gca,'FontSize',12)
	xlabel('time   (msec)','FontSize',14); ylabel('Amplitude','FontSize',14)
disp('<CR> to play sound'),  pause
xxx = real(exp( -2i*pi*ttt'*ff(jkl) )*ZZ(jkl));
sound( xxx/max(abs(xxx)), fs );
disp('<CR> to continue'),  pause
%----------
clf reset
jkl = 1:3;
x123 = xi(:,jkl) * ZZ(jkl);
subplot('Position',[0.12 0.6 0.8 0.3])
	hp = plot( tms, real(x123) );
	set(hp,'LineWidth',2)
	title('x = x + Re(A_5 exp(j*2*pi*5*f0*t) )','FontSize',16)
	set(gca,'FontSize',12)
	ylabel('Amplitude','FontSize',14)
disp('<CR> to play sound'),  pause
xxx = real(exp( -2i*pi*ttt'*ff(jkl) )*ZZ(jkl));
sound( xxx/max(abs(xxx)), fs );
disp('<CR> to continue'),  pause
%
jkl = 1:4;
x1234 = xi(:,jkl) * ZZ(jkl);
subplot('Position',[0.12 0.07 0.8 0.35])
	hp = plot( tms, real(x1234) );
	set(hp,'LineWidth',2)
	title('x = x + Re(A16 exp(j*2*pi*16*f0*t) )','FontSize',16)
	set(gca,'FontSize',12)
	xlabel('time   (msec)','FontSize',14); ylabel('Amplitude','FontSize',14)
disp('<CR> to play sound'),  pause
xxx = real(exp( -2i*pi*ttt'*ff(jkl) )*ZZ(jkl));
sound( xxx/max(abs(xxx)), fs );
disp('<CR> to continue'),  pause
%------
clf reset
subplot('Position',[0.12,0.1,0.8,0.4])
	hp = plot( tms, real(xx) );grid
	set(hp,'LineWidth',2)
	title('x = x + Re(A17 exp(j*2*pi*17*f0*t) )','FontSize',16)
	set(gca,'FontSize',12)
	xlabel('time   (msec)','FontSize',14); ylabel('Amplitude','FontSize',14)
disp('<CR> to play sound'),  pause
jkl = 1:5;
xxx = real(exp( -2i*pi*ttt'*ff(jkl) )*ZZ(jkl));
sound( xxx/max(abs(xxx)), fs );
