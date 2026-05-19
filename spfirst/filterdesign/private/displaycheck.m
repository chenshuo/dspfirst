function displaycheck(hfigure)
%DISPLAYCHECK Adjusts figure and control colors depending
%on the system.

% Greg Krudysz, 23-Nov-2004

% if ispc
% switch version_str(1:index-1)
%     case 'Microsoft Windows 2000'
%         disp('2000')
%     case 'Microsoft Windows XP'
%         disp('XP')
% end
% else
%     
% end

fig_color   = get(hfigure,'color');
hui_button  = findall(hfigure,'style','pushbutton');
hui_tbutton = findall(hfigure,'style','togglebutton');
hui_radio   = findall(hfigure,'style','radiobutton');
hui_check   = findall(hfigure,'style','checkbox');
hui_text    = findall(hfigure,'style','text');

htx = findobj(hfigure,'type','text');

set([hui_button;hui_tbutton;hui_radio;hui_check;hui_text],'backgroundcolor',fig_color);
set(htx,'color',fig_color);
