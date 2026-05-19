% Alpha Control Panel / EE2200ts Demonstration / EE2200
%
% Craig Ulmer  /  gt7667a at prism.gatech.edu  /  ulmer at eedsp.gatech.edu 
%
% NOTE:
%      The following variables are manipulated by this script. The user
%      should create these images before the script is run.
%  
%      xx  =  Original source Picture
%      xxa =  Picture that has been run through filter A
%      xxb =  Picture that has been run through filter B
%
% This script will allow the user to select what percentage of filters
% A and B should be used to generate an output. The following equation
% determines the percentages for the output.
%               100 x (1 - Alpha) = Percent due to filter A
%               100 x  Alpha      = Percent due to filter B
%
% Initially, a window is opened with the following options.
%
%     Alpha  -  A slider bar to determine the variable Alpha
%     Make New Plots - Generates new plots based on the slected alpha 
%     Print - Draw the current alpha, and send to printer
%     Allow Multiple Displays - When unchecked, will only generate
%             one output window(The script will revise the window 
%             each time a Make New Plots is selected. When Checked,
%             this script will generate a new window each time Make
%             New Plots is pressed, allowing for multiple alpha
%             plots to be displayed at once
%     Quit - Quits the script, clearing out all variables called by
%            this script. Note that figure windows are NOT killed,
%            allowing the user to keep what he or she has plotted.
%
% The Alpha Control Panel generates a window with the results of the stages
% of the system. Input, Filter A, Filter B, and Output are all plotted.
% Note that the Input and Output are SCALED in color, such as in the 
% "Show_img" function. The pictures for Filter A and Filter B are NOT
% scaled, resulting in true image representations. (If the Filter A and
% Filter B images WERE scaled, then they would remain constant for all
% alpha. The purpose is to see what the pictures look like at different
% percentages of intensity).
%
% BUGS:
%      Currently, if the user closes the ouput window with the window
%      close button, the alpha control pannel will try plotting to
%      a window that is not open. The result is a script failure. The
%      script needs to check to make sure the window is still there
%      before plotting(using some error detection). To avoid this, simply
%      instruct the user not to close the Plots Window until finished with
%      this script.
% 

% Open a window for the control pannel
id_control_win=figure('resize','off','units','normal','pos',[.1 .1 .4 .15],...
                      'numbertitle','off','name','Alpha Control Panel');

% Establish some initial values
alpha=0.5;
multi_win=0;
first_time=1;      % For determining if there is a plot window already open

% Rescale the input picture ahead of time to save time
mx=max(max(xx));     
mn=min(min(xx));
xin=round(255*(xx-mn)/(mx-mn));

% -/- Define the Alpha Controls -/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-
% Alpha Slider

sli_alpha = uicontrol(id_control_win,...
     'Style','slider','units','normal',...
     'Min',0,'Max',1,'val',alpha,...
     'pos',[0.10 0.33 0.30 0.20],...
     'CallBack',['alpha=get(sli_alpha,''val'');',...
                 'set(ed_alpha,''string'',num2str(alpha));']);

% Alpha Entry Box
ed_alpha_call = ['temp = str2num(get(ed_alpha,''string''));'...
               'if ((0 <= temp) & (temp <= 1)),', ...
               'alpha = temp; end, set(sli_alpha,''val'',alpha); '];

ed_alpha = uicontrol('style','edit','units','normal', ...
                   'pos', [0.30 0.70 0.10 0.20], ...
                   'string', num2str(alpha), 'val', alpha,...
                   'call', ed_alpha_call);

% alpha Text
uicontrol('style','text','units','normal',...
          'pos', [0.10 0.70 0.15 0.20],...
          'horizontalalignment','left','string','Alpha:',...
          'fore','c','back','k');

% -/- Define Plot Button -/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-
% Plot button

pb_plot_call = ['xlpa=xxa*(1-alpha);', ... % Compute
                'xbpa=xxb*(alpha);' , ...  % New
                'xout=xlpa+xbpa;' , ...    % Values
                'mx=max(max(xbpa));', ...                  % Rescale
                'mn=min(min(xbpa));', ...                  % Xout's
                'xbpa=round(255*(xbpa-mn)/(mx-mn));', ...  % Color
                'mx=max(max(xout));', ...                  % Rescale
                'mn=min(min(xout));', ...                  % Xout's
                'xout=round(255*(xout-mn)/(mx-mn));', ...  % Color
                'mx=max(max(xlpa));', ...                  % Rescale
                'mn=min(min(xlpa));', ...                  % Xout's
                'xlpa=round(255*(xlpa-mn)/(mx-mn));', ...  % Color              
              'if (multi_win+first_time),', ...  %if need a new plot window
                'plots_win_id=figure(''numbertitle'',''off'',', ...
                                   ' ''name'',[''System Plots for Alpha = '',num2str(alpha)]);',...
                'plot_axes_id=axes(''units'',''normal'',''pos'',[0 0 1 1]);',... 
                'axis(''off'');',... 
                'text(''pos'',[.20 .98],''string'',''Input'');',... 
                'text(''pos'',[.20 .49],''string'',''Filter A'');',...
                'text(''pos'',[.58 .98],''string'',''(1-Alpha)*Filter A + (Alpha)*Filter B'');',...
                'text(''pos'',[.75 .49],''string'',''Filter B'');',...
                'fig_in=axes(''pos'',[.015 .51 .45 .45]); image(xin); axis(''off'');', ...
                'first_time=0;',... 
              'else, ',...
                'figure(plots_win_id);',...
                'set(plots_win_id,''name'',[''System Plots for Alpha = '',num2str(alpha)]);', ...
                'delete(fig_out);delete(fig_lp);delete(fig_bp);delete(te_al_id);', ...
              'end;', ...
                'axes(plot_axes_id);', ... 
                'te_al_id = text(''pos'',[.43 .49],''string'',[''Alpha  = '',num2str(alpha)]);',...
                'fig_out=axes(''pos'',[.55 .51 .45 .45]); image(xout); axis(''off'');', ...
                'fig_lp=axes(''pos'',[.015 0.015 .45 .45]); image(xlpa); axis(''off'');', ...
                'fig_bp=axes(''pos'',[.55 0.015 .45 .45]); image(xbpa); axis(''off'');', ...
                'trusize;colormap(gray(256));']; 
               

pb_plot = uicontrol('style','push','units','normal', ...
                     'string','Make New Plots','pos',[0.60 0.66 0.40 0.30],...
                     'call',pb_plot_call);
 

% -/- Define Quit Button -/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-
% Quit button
% This cleans up a bunch of variables/calls that the script sets up.

pb_quit_call = [ 'delete(id_control_win);clear cb_call;clear multi_win;clear ed_alpha_call;',...
                 'clear id_control_win;clear mn;clear mx;clear pb_plot_call; clear pb_print_call;',...
                 'clear plots_win_id;clear fig_in;clear fig_lp;clear fig_out;clear sli_alpha;',...
                 'clear first_time; clear cb_multi_win; clear fig_bp;clear plot_axes_id;clear ed_alpha;', ...
                 'clear te_al_id;clear I; clear pb_plot; clear pb_print; clear pb_quit;', ...
                 'clear xbpa;clear xlpa;clear xout;clear xxin; clear pb_quit_call'];

pb_quit = uicontrol('style','push','units','normal', ...
                     'string','Quit','pos',[0.60 0.02 0.40 0.30],...
                     'call',pb_quit_call);

% -/- Define Print Button -/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-
% Print Button

pb_print_call = [pb_plot_call,'figure(plots_win_id);print'];

pb_print = uicontrol('style','push','units','normal', ...
                     'string','Print (For This Alpha)','pos',[0.60 0.34 0.40 0.30],...
                     'call',pb_print_call);

% -/- Multiple Windows cb -/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-
% Check Box

cb_call = 'multi_win= get(cb_multi_win,''val'');';
           
cb_multi_win = uicontrol('style','checkbox','units','normal', ...
                         'string','Allow Multiple Displays', ...
                         'pos',[0.05 0.05 0.50 0.15],...
                         'val',multi_win,'fore','c','back','k',...
                         'call',cb_call);
