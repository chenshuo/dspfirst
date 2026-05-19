function out = ramp(t)

% This function creates a ramp or swatooth waveform. 

% Mustayeen Nayeem, July 25, 2002

yy = zeros(1,length(t));
xx= -1:0.01:0.99;
xx1= -1:0.01:0.98;
    
    yy(1)=0;
    yy(2:200)=xx1;
    yy(201:400)=xx;
    yy(401:600)=xx;
    yy(601)=0;
        
out = yy;


