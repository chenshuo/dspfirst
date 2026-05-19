function [h,BtnAxis] = uinumedit(varargin)
%UINUMEDIT A uicontrol that edits numbers
%   [h,BtnAxis] = UINUMEDIT('PropertyName1',value1,'PropertyName2',value2,...)
%   creates a user interface control designed to edit numbers in the
%   current figure window and returns a handle to it and the axis that the
%   button are drawn in.  The control consists of an edit box and a set of 
%   up/down arrows that increase or decrease the value in the edit box.
%
%   UINUMEDIT properties can be set at object creation time using
%   PropertyName/PropertyValue pair arguments to UINUMEDIT. Properties
%   specific to the arrow pair (see below) can only be set at creation
%   time while the edit box properties can be changed later using the SET
%   command along with the UINUMEDIT handle.
%
%   Execute GET(H) to see a list of the edit box object properties and its
%   current values.  Execute SET(H) to see a list of the edit box object
%   properties and legal property values.  See a reference guide for more
%   information.
%
%   Additional optional properties:
%
%      'StepSize' - the value that the arrows increase/decrease the edit box
%         contents.  The default StepSize is 1.
%      'ArrowWidth' - the width of the arrows given as a fraction of the width
%         of the UINUMEDIT control.  The default ArrowWidth is 0.2.
%      'Max' - the maximum number that can be set within the box.  The default
%         is Inf.
%      'Min' - the minumum number that can be set within the box.  The default
%         is -Inf.
%
%   See also SET, GET, UICONTROL

% Jordan Rosenthal, 12/14/97
% Revised 4/27/98

nArgs = nargin;
if nArgs == 0
   action = 'Initialize';
else
   action = varargin{1};
end

switch action
case 'Validate'
   StepSize = varargin{3};
   Min = varargin{3};
   Max = varargin{4};
   CallBack = varargin{5};
   Value = str2num( get(gcbo, 'String') );
   if Value >= Min & Value <= Max
      set(gcbo,'Value',Value);
      eval(CallBack);
   else
      set(gcbo,'String',get(gcbo,'Value'));
   end
case 'Increase'
   hEditBox = findobj('Type','uicontrol','Tag',varargin{2}); 
   %hEditBox = varargin{2};
   StepSize = varargin{3};
   Max = varargin{4};
   CallBack = varargin{5};
   CurrentValue = str2num( get(hEditBox, 'String') );
   NewValue = CurrentValue + StepSize;
   if NewValue <= Max
      set(hEditBox, 'value', NewValue, 'string', num2str(NewValue));
      eval(CallBack);
   end
case 'Decrease'
   hEditBox = findobj('Type','uicontrol','Tag',varargin{2});
   %hEditBox = varargin{2};   
   StepSize = varargin{3};
   Min = varargin{4};
   CallBack = varargin{5};
   CurrentValue = str2num( get(hEditBox, 'String') );
   NewValue = CurrentValue - StepSize;
   if NewValue >= Min
      set(hEditBox, 'value', NewValue, 'string', num2str(NewValue));
      eval(CallBack);
   end
otherwise
   if ( rem( nArgs, 2 ) ~= 0 ) &  ( nArgs ~= 1 )
      error('Invalid parameter/value pair arguments.')
   end
   Prop_Names = varargin(1:2:end);
   Prop_Vals = varargin(2:2:end);
   %%%  Get properties  %%%
   ArrowWidth = 0.2;
   CallBack = '';
   Min = -Inf;
   Max = Inf;
   Position = get(0,'DefaultUIControlPosition');
   Units = get(0,'DefaultUIControlUnits');
   StepSize = 1;
   String = 0;
   Value = 0;
   iErase = [];
   Tag = varargin{end};
   for i = 1:length(Prop_Names)
      switch lower( Prop_Names{i} )
      case 'arrowwidth'        , ArrowWidth = Prop_Vals{i}; iErase = [iErase; i];
      case 'callback'          , CallBack = Prop_Vals{i};   iErase = [iErase; i];
      case 'min'               , Min = Prop_Vals{i};        iErase = [iErase; i];
      case 'max'               , Max = Prop_Vals{i};        iErase = [iErase; i];
      case {'position', 'pos'} , Position = Prop_Vals{i};   iErase = [iErase; i];
      case 'units'             , Units = Prop_Vals{i};      iErase = [iErase; i];
      case 'stepsize'          , StepSize = Prop_Vals{i};   iErase = [iErase; i];
      case 'string'
         String = Prop_Vals{i};
         Value = str2num(String);
         iErase = [iErase; i];
      case 'value'
         error('Value property cannot be set.');
      case 'style'
         error('Style property cannot be set.');
      end
   end
   if ~isempty(iErase)
      Prop_Names(iErase) = [];
      Prop_Vals(iErase) = [];
   end
   
   %%%  Setup Edit control  %%%
   EditPos = Position;
   EditPos(3) = (1-ArrowWidth)*Position(3);
   EditCallBack = sprintf('uinumedit(''Validate'',%.16f,%.16f,%.16f,''%s'')', ...
      StepSize,Min,Max,strrep(CallBack,'''',''''''));
   hEdit = uicontrol('style','edit', ...
      'Units',Units, ...
      'Position',EditPos, ...
      'CallBack',EditCallBack, ...
      'HorizontalAlignment','left', ...
      'String',String, ...
      'Value',Value, ...
      'Tag',Tag, ...
      Prop_Names,Prop_Vals);
   
   %%%  Setup Button Group control  %%%
   IconFunctions = char({ ...
         ['text(0.5,1,''\uparrow'',''FontUnits'',''normal'',''FontWeight'',''Bold'',' ...
            '''VerticalAlignment'',''top'',''HorizontalAlignment'',''center'')']; ...
         ['text(0.5,0,''\downarrow'',''FontUnits'',''normal'',''FontWeight'',''Bold'',' ...
            '''VerticalAlignment'',''baseline'',''HorizontalAlignment'',''center'')'] });
   CallBacks = char({ ...
         sprintf('uinumedit(''Increase'',''%s'',%.16f,%.16f,''%s'')', ...
         Tag,StepSize,Max,strrep(CallBack,'''','''''')); ...
         sprintf('uinumedit(''Decrease'',''%s'',%.16f,%.16f,''%s'')', ...
         Tag,StepSize,Min,strrep(CallBack,'''','''''')); });     
     
   ArrowPos = EditPos;
   ArrowPos([1 3]) = [Position(1)+EditPos(3) ArrowWidth*Position(3)];
   ButtonID = char( {'up';'down'} );
   Props = {'GroupID',num2str(rand), ...
         'ButtonID', ButtonID, ...
         'Callbacks',CallBacks, ...
         'IconFunctions',IconFunctions, ...
         'BevelWidth', 0.05, ...
         'PressType','flash', ...
         'Units',get(hEdit,'Units'), ...
         'Position',ArrowPos };
   Btns = btngroup(Props{:});
   
   % Done
   if nargout == 1, h = hEdit;, end
   if nargout ==2, h = hEdit; BtnAxis = Btns; end
end