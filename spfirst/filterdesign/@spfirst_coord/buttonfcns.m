function varargout = buttonfcns(OD,action)
%function varargout = buttonfcns(OD,action)
% @spfirst_coord/buttonfcns - execute upon action:
%
%   'ButtonDown'   - object has been pressed
%   'WindowMotion' - motion over object
%
% See also @spfirst_coord/ ... get, set

% Author(s): Greg Krudysz
%==============================================================

switch action
    %===%==================================================================
    case 'ButtonDown'
        %==================================================================
        set(OD,'visible','off');
        %==================================================================
    case 'WindowMotion'
        %==================================================================      
       xvals = get(OD.Line,'xdata');
       yvals = get(OD.Line,'ydata');
       set(OD.Axes,'units','norm');
       ylim = get(OD.Axes,'ylim');
       current_pt = get(OD.Axes,'currentpoint');
       xtoll  = (xvals(end)-xvals(1))/length(xvals);
       ytoll  = (max(yvals)-min(yvals))/length(yvals);
       xindex = find(abs(xvals-current_pt(1)) < xtoll);
       dindex = find(abs(yvals(xindex)-current_pt(3)) < 2*ytoll);     
       
       if ~isempty(dindex) %& ~isempty(yindex)
           if strcmp(get(get(OD.Axes,'xlabel'),'string'),'Frequency (rad)')
              xscale = '\pi';
           else
               xscale = '';
           end
           
           set(OD.Text,'pos',[xvals(xindex(1)),yvals(xindex(1)),0],'string',['({\color{blue} ' num2str(xvals(xindex(1))) '{\fontsize{13}' xscale '}} , {\color{blue}' num2str(yvals(xindex(1))) '} )']);                 
           set(OD.Point,'vis','on','xdata',xvals(xindex(1)),'ydata',yvals(xindex(1)));        
           set(OD.LineX,'xdata',[xvals(xindex(1)) xvals(xindex(1))],'ydata',[ylim(1) yvals(xindex(1))],'vis','on');
           set(OD.LineY,'xdata',[0 xvals(xindex(1))],'ydata',[yvals(xindex(1)) yvals(xindex(1))],'vis','on');
       else
           set(OD.Text,'string','');
           set([OD.Point,OD.LineX,OD.LineY],'vis','off');
       end
        %==================================================================
end