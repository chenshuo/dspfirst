function transform(OD,scale)
% @spfirst_obj/transform Set object properties to the specified values
% and return the updated object.
%
% See also @spfirst_obj/ ... get, set, buttondown

% Author(s): Greg Krudysz
%==============================================================
ver = version;
MATLABVER =str2double(ver(1:3));

tol = 1e-6;
obj_data = get(OD.Object,[OD.var 'data']);
ticks_old = get(OD.Axes,[OD.var 'tick']);
ticks = ticks_old*scale;
lim_old = get(OD.Axes,[OD.var 'lim']);
lim = lim_old*scale;
fontsize = get(OD.Axes,'fontsize');
scale_font = 1;
%---- multiple of pi? - format ----%
idx = find(abs(mod(ticks(find(ticks)),pi/4)) < tol);

if idx
    ticks = ticks(1):pi/4:ticks(end);
    ticks = ticks(find(abs(mod(ticks,pi/4)) < tol));
    
    if MATLABVER<8.4
        pi_str = 'p';
        set(OD.Axes,'fontname','symbol');
    else
        pi_str = '\pi';
        set(get(OD.Axes,[OD.var 'label']),'interpreter','latex');
    end
    
    for k = 1:length(ticks);
        if ticks(k) == 0
            xtl{k} = '0';
        elseif (1-abs(ticks(k)/pi)) < tol
            xtl{k} = [char(45-13*sign(ticks(k))) pi_str];
        else
            xtl{k} = [num2str(ticks(k)/pi) pi_str];
        end
    end

    %% -- old code
    %---------
    % % determine new yticks (symbolic multiples of pi/2)
    % %handles.old_font = get(handles.Plot1,'fontname');
    % if length([round(Ylim_min):Ylim_max]) < 5
    %     ytick = [round(Ylim_min):0.5:Ylim_max];
    % else
    %     ytick = [round(Ylim_min):Ylim_max];
    % end
    %
    % for k = 1:length(ytick)
    %     if ytick(k) == 0
    %         ytickL{k} = '0';
    %     elseif ytick(k) == 1
    %         ytickL{k} = 'p ';
    %     elseif ytick(k) == -1
    %         ytickL{k} = '-p ';
    %     else
    %         ytickL{k} = sprintf('%s%s',num2str(ytick(k)),'p ');
    %     end
    % end
    % %---------
    
    set(OD.Axes,'fontsize',scale_font*fontsize, ...
        [OD.var 'minortick'],'off', ...
        [OD.var 'tick'],ticks/pi, ...
        [OD.var 'ticklabel'],strtrim(xtl), ...
        [OD.var 'lim'],[lim(1)/pi lim(2)/pi]);  %[ticks(1)/pi ticks(end)/pi]);
else
    %----------------------------------%
    set(OD.Axes,'fontname','Helvetica', ...
        'fontsize',(1/scale_font)*fontsize, ...
        [OD.var 'minortick'],'on', ...
        [OD.var 'tick'],ticks*pi, ...
        [OD.var 'ticklabel'],ticks*pi, ...
        [OD.var 'lim'],[lim(1)*pi lim(2)*pi]);  %[ticks(1)*pi ticks(end)*pi]);
end
%set(OD.Object,[OD.var 'data'],obj_data*scale);