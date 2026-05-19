h = animatedline('Marker','o');

axis([0 4*pi -1 1])
x = linspace(0,10*pi,1e6);
y = sin(x).^2-cos(x).^2;

pause(1);
for k = 1:length(x)
    addpoints(h,x(k),y(k));
    drawnow limitrate
end
drawnow