function [FontTnew,BoldTnew,FontAnew,BoldAnew] = axesfontdlg(action)
%
% AXESFONTDLG Axes Font Size dialog box.
%  [x,y] = AXESFONTDLG creates a modal dialog box that returns the font size
%  and font weight of the axes selected in the dialog box.
%  x - returns Font Size of the axes
%  y - returns '0' ('normal') or '1' ('bold') for font style of the axes
%
%  Gregory Krudysz, 10/25/01

if nargin == 1 & isstr(action)
   % Perform action
switch action
   
  
% UPDATE GUI   
case 'Slider1'
hAxesF = findobj(gcf,'Tag','axesFont');
hSliderVal1 = get(findobj(gcf,'Tag','Slider11'), 'Value');
set(hAxesF,'FontSize', hSliderVal1);

case 'Slider2'
htextF1 = findobj(gcf,'Tag','TitleText');
htextF2 = findobj(gcf,'Tag','BoldText');
hSliderVal2 = get(findobj(gcf,'Tag','Slider22'), 'Value');
set([htextF1 htextF2],'FontSize', hSliderVal2);

case 'RadioButton1'
   % make text bold ?
   hAxes = findobj(gcbf,'Type','axes');
   hButton1 = findobj(gcf,'Tag','RadioButton11');
   BoldValue = get(hButton1,'Value');
   
if BoldValue == 1
   % ADD THIS:  set(hAxes,'LineWidth',0.9);
   set(hAxes,'FontWeight','bold');
   set(hButton1,'Value',1);
else
   set(hAxes,'FontWeight','normal');
   set(hButton1,'Value',0);
end


case 'RadioButton2'
   % make text bold ?
   htextTitle = findobj(gcf,'Tag','TitleText');
   hButton2 = findobj(gcf,'Tag','RadioButton22');
   BoldValue = get(hButton2,'Value');
   
if BoldValue == 1
   set(htextTitle,'FontWeight','bold');
   set(hButton2,'Value',BoldValue);
else
   set(htextTitle,'FontWeight','normal');
   set(hButton2,'Value',BoldValue);
end

case 'OK'
   
set(gcbf,'UserData',1)
   
otherwise
   error('Illegal action');
   
end %switch
 
elseif nargin == 0 | ~isstr(action)
   if nargin ==0
      
   MyData = get(0,'UserData')
   FontT = MyData(1);
   BoldT = MyData(2);
   FontA = MyData(3);
   BoldA = MyData(4);
  

   if isunix
      SetFontValA = 0.09;
      SetFontValT = 0.6;
   elseif strcmp('MAC2',computer)
      SetFontValA = 0.044;
      SetFontValT = 0.6;
   else
      SetFontValA = 0.0797;
      SetFontValT = 0.6;
   end
   
   MinValT = SetFontValT - 0.25*SetFontValT;
   MaxValT = SetFontValT + 0.25*SetFontValT;
   MinValA = SetFontValA - 0.25*SetFontValA;
   MaxValA = SetFontValA + 0.25*SetFontValA;
   end
   
   
% CREATE GUI (Initialize)   
% figure

hDlgFont = dialog('Name','Axes Font Size', ...
                  'CloseRequestFcn','axesfontdlg OK', ...   
                  'Units','Normalized', ...
                  'Position',[0.33 0.33 0.33 0.33], ...
                  'DoubleBuffer','On');
    
% axis               
hAxesFont = axes('Parent',hDlgFont,'Units','Normalized',...
   				  'FontUnits','Normalized',...
                 'Position',[0.3 0.5 0.4 0.4],'Xtick',[0 0.5 1], ...
                 'Ytick',[0.5 1],'Tag','axesFont', ...
                 'Box','On');

% Slider1
hSlider1 = uicontrol('Parent',hDlgFont,'Style','Slider','Units','Normalized', ...
                     'Tag','Slider11', ...
                     'Position',[0.3 0.35 0.4 0.05], ...
                     'Callback','axesfontdlg Slider1', ...  
                     'SliderStep',[0.1 0.2], ...
                     'Min',MinValA,'Max',MaxValA,'Value',FontA);
                 
% Slider2
hSlider2 = uicontrol('Parent',hDlgFont,'Style','Slider','Units','Normalized', ...
                     'Tag','Slider22', ...
                     'Position',[0.3 0.25 0.4 0.05], ...
                     'Callback','axesfontdlg Slider2', ...  
                     'SliderStep',[0.1 0.2], ...
                     'Min',MinValT,'Max',MaxValT,'Value',FontT);
% RadioButton1
hButton1 = uicontrol('Parent',hDlgFont, ...
   					  'Tag','RadioButton11',...
                    'Style','radiobutton','Units','Normalized', ...
                    'Position',[0.8 0.4 0.05 0.05], ...
                    'CallBack','axesfontdlg RadioButton1',...
                    'Min',0,'Max',1,'Value',BoldA);
% RadioButton2                
hButton2 = uicontrol('Parent',hDlgFont, ...
                    'Tag','RadioButton22', ...
                    'Style','radiobutton','Units','Normalized', ...
                    'Position',[0.8 0.3 0.05 0.05], ...
                    'CallBack','axesfontdlg RadioButton2',...
                    'Min',0,'Max',1,'Value',BoldT);
            
                 
text(-0.1,-0.55,'Text Font Size','HorizontalAlignment','Right');                   
text(-0.1,-0.3,'Axis FontSize','HorizontalAlignment','Right');    
text(0.5,1.1,'Font Size','HorizontalAlignment','Center','Tag','TitleText');                 
text(1.25,0.2,'Bold','Parent',hAxesFont,'Tag','BoldText');
                 
  if BoldT == 1;
  	  set(findobj(gcbf,'Tag','TitleText'),'FontWeight','bold');
  end
    
  if BoldA == 1;
  	  set(hAxesFont,'FontWeight','bold');
  end
          
%Setup OK Button
uicontrol('Parent',hDlgFont, ...
          'Units','normalized', ...
          'Callback','axesfontdlg OK', ...
       	 'FontWeight','Bold', ...
          'Position',[0.375 0.1 0.25 0.1], ...
          'String','OK', ...
          'Style','pushbutton');
   
waitfor(hDlgFont,'UserData');

FontTnew = 0.72;     %get(hSlider1,'Value') %get(fingobj(gcf,'Tag','axesFont'),'FontSize')  
BoldTnew = 1;        %get(hButton,'Value');
FontAnew = 0.06;     %get(hSlider1,'Value') %get(fingobj(gcf,'Tag','axesFont'),'FontSize')  
BoldAnew = 1;        %get(hButton,'Value');



delete(hDlgFont);

else
   error('Too many input arguments.'); 
end