function [params,Wpass1,Wstop1,Wpass2,Wstop2,Rp_dB,Rs_dB,order_type,xscale,yscale,omega] = user(handles)
% Repetative code 

yscale = strcmp(get(handles.menu_y_scale,'checked'),'on') + 1; % 1-Mag, 2-Mag (dB)
xscale = strcmp(get(handles.menu_x_scale,'checked'),'on') + 1; % 1-Hz, 2-Norm
order_type = get(handles.SetOrder,'value');
params.Fsamp = str2double(get(handles.Fsamp,'string'));

if (xscale - 1)
    omega = '\omega';
    % passband and stopband values are in normalized units
    Wpass1 = str2double(get(handles.Fpass1,'string'));
    Wstop1 = str2double(get(handles.Fstop1,'string'));
    Wpass2 = str2double(get(handles.Fpass2,'string'));
    Wstop2 = str2double(get(handles.Fstop2,'string'));
    
    % convert to frequencies in Hz
    params.Fpass1 = Wpass1*params.Fsamp/2;
    params.Fstop1 = Wstop1*params.Fsamp/2;
    params.Fpass2 = Wpass2*params.Fsamp/2;
    params.Fstop2 = Wstop2*params.Fsamp/2; 
else
    omega = '';
    % passband and stopband values are in Hz units
    params.Fpass1 = str2double(get(handles.Fpass1,'string'));
    params.Fstop1 = str2double(get(handles.Fstop1,'string'));
    params.Fpass2 = str2double(get(handles.Fpass2,'string'));
    params.Fstop2 = str2double(get(handles.Fstop2,'string'));
    
    % convert to normalized frequencies
    Wpass1 = params.Fpass1/params.Fsamp*2;                                 
    Wstop1 = params.Fstop1/params.Fsamp*2;
    Wpass2 = params.Fpass2/params.Fsamp*2;
    Wstop2 = params.Fstop2/params.Fsamp*2;
end

params.Order = str2double(get(handles.Order,'string'));

if (yscale - 1)
    % magnitude is in dB 
    Rp_dB = str2double(get(handles.Rpass,'string'));
    Rs_dB = str2double(get(handles.Rstop,'string'));

    if Rp_dB > 0
        params.Rpass = 10; % out of bounds
    else
        params.Rpass = abs(10^(Rp_dB/20)-1);
    end
    params.Rstop = 10^(Rs_dB/20);
else
    % magnitude is linear
    params.Rpass = str2double(get(handles.Rpass,'string'));
    params.Rstop = str2double(get(handles.Rstop,'string'));
    
    Rp_dB = 20*log10(1-params.Rpass);
    if ~isnan(params.Rstop) && params.Rstop 
        Rs_dB = 20*log10(params.Rstop);
    else
        Rs_dB = -27.9588; 
    end
end