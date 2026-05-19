function ReturnVal=DSPFirst(fn,arg)
% Run this to open a window with buttons leading to the live MATLAB demos.
% You will find links to 
%	Sinusoid Drill
%	Complex Number Drill
%	PEZ 3.1 / Pole/Zero Plotter
%	Music GUI
%	Beat Frequencies

Figure_Name='DSP First Matlab Demos';

if nargin == 0
	fn = 'init';
	delete(findobj('name',Figure_Name));
end;


%Activates the figure and makes sure it has been properly initialized

if ~strcmp(fn,'init')
	h_MainFig = gcf;

%If the current figure is not named Figure_Name then find 
%the figure that is and put its handle in h_MainFig. This will 
%be found by checking the children of root.

	if ~strcmp(get(h_MainFig,'name'),Figure_Name)
		h_figs=get(0,'children');
		h_MainFig = findobj(h_figs,'flat',...
				    'name',Figure_Name);

	%If the figure does not exist, initialize it and then
	%run the function that was originally intended

		if length(h_MainFig)==0
			TranLine('init');
			TranLine(fn);
			return;
		end;
	end;
end;

%____________________________________________________________________________

if strcmp(fn,'init')

	load dspf1
	if(~isstudent)	% load background image if we have full version
		load dspf2
	end

	if strcmp(computer,'PCWIN')
		Sep='\';
	elseif strcmp(computer,'MAC2')
		Sep=':';
	else
		Sep='/';
	end;
	
	DSPPath=which('dspfirst');
	if(strcmp(DSPPath, ''))
		error('dspfirst must be in your path');
	end
	
	xx = findstr(DSPPath, Sep);
	xx = xx(length(xx));	% get last element of xx
	DSPPath = DSPPath(1:xx-1);	% chop off dspfirst.m
	
	PathString1=[DSPPath Sep 'sinedri'];
	path(path,PathString1);

	PathString2=[DSPPath Sep 'zdrill'];
	path(path,PathString2);

	PathString3=[DSPPath Sep 'pez_31'];
	path(path,PathString3);
	
	PathString4=[DSPPath Sep 'musiclab'];
	path(path,PathString4);
	
	h_MainFig=figure('name',Figure_Name,...
	'number','off');
	
	h_axis=axes('pos',[0 0 1 1]);
	
	colormap(bigmap);
	if(exist('x'))
		image(x);
	else
		set(h_axis , 'YDir', 'reverse', ...
			'Xlim', [0.5 533.5], ...
			'Ylim', [0.5 400.5]);
	end
	hold on;
	top = 130;
	delta = 50;

	h_button1=image(button,...
			'xdata',[35:57],...
			'ydata',[top+0*delta,top+0*delta+20],...
			'button','sindrill');

	h_button2=image(button,...
			'xdata',[35:57],...
			'ydata',[top+1*delta:top+1*delta+20],...
			'button','zdrill');

	h_button3=image(button,...
			'xdata',[35:57],...
			'ydata',[top+2*delta:top+2*delta+20],...
			'button','pez');
			
	h_button4=image(button,...
			'xdata',[35:57],...
			'ydata',[top+3*delta:top+3*delta+20],...
			'button','musicgui');
			
	h_button5=image(button,...
			'xdata',[35:57],...
			'ydata',[top+4*delta:top+4*delta+20],...
			'button','beatcon');
			

	set(h_axis,'visible','off');
	y = -25;
	text(12.5,y+60,'DSP First:',...
	'fontname','times new roman',...
	'fontsize',32,...
	'color',[1 1 1]);

	text(12.5,y+90,'A Multimedia Approach',...
	'fontname','times new roman',...
	'fontsize',20,...
	'color',[1 1 1]);

	text(12.5,y+115,'by Jim McClellan, Ron Schafer, and Mark Yoder',...
	'fontname','times new roman',...
	'fontsize',12,...
	'fontangle','italic',...
	'fontweight','bold',...
	'color',[1 1 1]);

	text(400,54,'Matlab Demos',...
	'fontname','times new roman',...
	'fontsize',16,...
	'fontangle','italic',...
	'fontweight','bold',...
	'color',[1 1 1]);

	offset = 9;
	text(84,top+offset,'Sinusoid Drill',...
	'fontname','times new roman',...
	'fontsize',14,...
	'color',[1 1 1]);
	
	text(84,top+delta+offset,'Complex Number Drill',...
	'fontname','times new roman',...
	'fontsize',14,...
	'color',[1 1 1]);
	
	text(84,top+2*delta+offset,'PEZ V3.1: Pole/Zero Plotter',...
	'fontname','times new roman',...
	'fontsize',14,...
	'color',[1 1 1]);

	text(84,top+3*delta+offset,'Music GUI',...
	'fontname','times new roman',...
	'fontsize',14,...
	'color',[1 1 1]);

	text(84,top+4*delta+offset,'Beat Frequencies',...
	'fontname','times new roman',...
	'fontsize',14,...
	'color',[1 1 1]);

	if(~exist('x'))
		set(gcf, 'Position', [120 120 560 420]);
		set(gcf, 'Color', [0 0 0])
	end

end;	
