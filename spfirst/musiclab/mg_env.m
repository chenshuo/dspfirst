function e = mg_env(len,attack)
%MG_ENV    make linearly tapered envelope for sinusoid 
%      (used as a support function for musicgui)
%  attack = duration of linear ramp at beginning and end
%            ramp at beginning is half as long
%     len = total length of the envelope
%       e = output vector containing the envelope

e = ones(1,len);
att1 = max(2,round(attack/2));
e(1:att1) = (0:(att1-1))/att1;
release = attack;
e(len:-1:len-release) = (0:release)/release; 
