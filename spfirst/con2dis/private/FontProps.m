% FontProps

function fontprops(action)

if nargin == 0
   action = 'initialize';
end


switch action
   
case 'initialize'
   
figure('Units','Normalized', ... 
       'Position',[0.4 0.4 0.4 0.4], ...
       'DoubleBuffer','On');
    
% axis
axes('Units','Normalized',...
                  'Position',[0.3 0.4 0.4 0.4], ...
                  'Box','On');
xlabel('x-axis'); ylabel('y-axis');
Title('Title')

% Slider
uicontrol('Style','Slider','Units','Normalized', ...
          'Position',[0.7 0.4 0.05 0.4], ...
          'Callback','fontprops Slider', ...
          'Min',10,'Max',20,'Value',15);

% RadioButton
uicontrol('Style','radiobutton','Units','Normalized', ...
          'Position',[0.8 0.4 0.05 0.05], ...
          'CallBack','fontprops RadioButton');
text(1.2,0.5,'Bold');
set(gcf,'menubar','none');

case 'Slider'
   
hAxes = findobj(gcbf,'Type','axes');
SliderValue = get(findobj(gcbf,'Style','slider'), 'Value');
set(hAxes,'FontSize', SliderValue);

case 'RadioButton'
% make text bold ?
hAxes = findobj(gcbf,'Type','axes');
BoldValue = get(findobj(gcbf,'Style','RadioButton'),'Value');

if BoldValue == 1
   set(hAxes,'FontWeight','Bold');
else
   set(hAxes,'FontWeight','normal');
end
   
case 'OKButton'   
   
   
   
otherwise
   error('Illegal action');
end
