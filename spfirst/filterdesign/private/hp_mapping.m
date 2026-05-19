function [theta,w]=hp_mapping(wp)
%   usage   [theta,w]=hp_mapping(wp)
%
%   where   theta = values of theta (original filter)
%           w = mapped valued of omega (transformed filter)
%           wp = desired passband cutoff in transformed filter in radians

w = 0:.01:pi;
theta_p = pi-wp;                                % set pass band frequency
a = -cos((theta_p+wp)/2)/cos((theta_p-wp)/2);   % set constant
Z = -(exp(-j*w)+a)./(1+a*exp(-j*w));            % pg 434 from old Oppenheim & Schafer book
theta = abs(angle(Z));
%plot(w/pi,theta/pi)