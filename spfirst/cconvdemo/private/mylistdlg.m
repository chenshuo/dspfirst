function [Selection,OK,FunctionOutput] = mylistdlg(varargin)
%GETDATADLG  List selection dialog box with Function button.
%   [SELECTION,OK] = MYLISTDLG('ListString',S, ...) creates a modal dialog box
%   which allows you to select a string from the cell string list S.  OK is
%   1 if you push the OK button, or 0 if you either push the Cancel button or
%   close the figure.  SELECTION is the index of the selected strings or []
%   when OK is 0.
%
%   [SELECTION,OK,FOUT] = MYLISTDLG('ListString',S,'Function',F, ...)
%   creates a third button labeled 'Function...'.  The Function button calls the
%   function with the name given by the string F.  The output of the function is 
%   store in FOUT.  If arguments must be passed to the function, F can be a cell
%   whose first element is the function name and remaining cell elements are 
%   the extra arguments.  There are two special arguments 'LISTSTRING' and
%   'LISTVALUE' (must be in captials) which, when used within F, retrieve the current
%   listbox string or index value so that the user's list choice can be passed to the
%   function.  The keywords can be placed anywhere within a string argument.
%
%   [SELECTION,OK,FOUT] = MYLISTDLG('ListString',S','Function',F,'FuncEnableTest', FE, ...)
%   uses the test given by the string FE to find out when to enable and disable the
%   function button.  FE must evaluate to either 0 or 1 as it will be used within an IF 
%   statement.  The two keywords 'LISTSTRING' and 'LISTVALUE' can also be used within FE
%   as described above.  By default the function button is always enabled.
%
%      Ex.  FE = 'LISTVALUE<3'   The function button will be enabled only when
%                                the first two items in the list are selected.
%
%   Inputs are in parameter,value pairs:
%
%   Parameter           Description
%   -------------------------------
%   'ListString'        Cell array of strings for the list box.
%   'Function'          A string containing a function name to be called when the
%                       Function button is pushed or a cell giving the function name
%                       followed by function arguments.  The special keywords
%                       'LISTSTRING' and 'LISTVALUE' donote the current listbox string
%                       or index value.
%   'InitialValue'      Vector of indices of which items of the list box
%                       are initially selected; defaults to the first item.
%   'Name'              String for the figure's title. Defaults to ''.
%   'ReturnType'        'String' to return the list item or 'Value' to return
%                       its index
%   'PromptString'      String matrix or cell array of strings which appears 
%                       as text above the list box.  Defaults to {}.
%   'OKString'          String for the OK button; defaults to 'OK'.
%   'FunctionString'    String for the Function button; defaults to 'Function...'
%   'CancelString'      String for the Cancel button; defaults to 'Cancel'.

%   Jordan Rosenthal, 11/7/97

NO = 0; YES = 1;
L = length( varargin );
if ( rem( L, 2 ) ~= 0 ) &  ( L ~= 1 )
   error('Parameter/Values must come in pairs.')
end
Parameters = varargin(1:2:end);
for i = 1:length(Parameters), Parameters{i} = lower( Parameters{i} );, end;
if ~strmatch('ListString', Parameters), error('ListString must be given.'), end

switch varargin{1}
case 'OK'
   set(gcbf, 'UserData', 'OK')
case 'Function...'
   Function = getappdata(gcbf, 'Function');
   hListBox = findobj('Tag', 'ListBox');
   Value = get( hListBox, 'Value');
   ListString = get( hListBox, 'String');
   FunctionArgs = getappdata(gcbf, 'FunctionArgs');
   if isempty( FunctionArgs )
      setappdata(gcbf, 'Function Output', feval( Function ) );
   else
      for i = 1:length(FunctionArgs)
         FunctionArgs{i} = strrep( FunctionArgs{i}, 'LISTSTRING', ListString{Value} );
         FunctionArgs{i} = strrep( FunctionArgs{i}, 'LISTVALUE', Value );
      end   
      setappdata(gcbf, 'Function Output', feval( Function, FunctionArgs{:} ) );
   end
case 'Cancel'
   set(gcbf, 'UserData', 'Cancel')
case 'ListBox'
   if strcmp( get(gcbf, 'SelectionType'), 'open')
      set(gcbf, 'UserData', 'OK');
   else
      setappdata(gcbf, 'Function Output',[]);
      FuncEnableTest = getappdata(gcbf, 'FuncEnableTest');
      if ~isempty(FuncEnableTest)
         hListBox = findobj('Tag', 'ListBox');
         Value = get( hListBox, 'Value');
         ListString = get( hListBox, 'String');
         FuncEnableTest = strrep( FuncEnableTest, 'LISTSTRING', ListString{Value} );
         FuncEnableTest = strrep( FuncEnableTest, 'LISTVALUE', num2str(Value) );
         if eval(FuncEnableTest)
            set( findobj(gcbf, 'Tag', 'FunctionButton'), 'Enable' , 'on');
         else
            set( findobj(gcbf, 'Tag', 'FunctionButton'), 'Enable' , 'off');
         end
      end
   end
otherwise
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%%  Get Input Arguments  %%%
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   InitialValue         = 1;
   ReturnType           = 'Value';
   Name                 = '';
   PromptString         = {};
   OKString             = 'OK';
   FunctionString     = 'Function...';
   CancelString         = 'Cancel';
   nButtons             = 2;
   for i=1:2:length(varargin)
      switch lower( varargin{i} )
      case 'liststring'       , ListString     = cellstr( varargin{i+1} );
      case 'initialvalue'     , InitialValue   = varargin{i+1};
      case 'returntype'       , ReturnType     = varargin{i+1};
      case 'name'             , Name           = varargin{i+1};
      case 'promptstring'     , PromptString   = cellstr( varargin{i+1} );
      case 'okstring'         , OKString       = varargin{i+1};
      case 'functionstring'   , FunctionString = varargin{i+1};
      case 'function'
         Function = varargin{i+1};
         FunctionArgs = [];
         switch class(Function)
         case 'char'
            if ~exist( Function ), error('Function not found'), end;
         case 'cell'   
            if ~exist( Function{1} ), error('Function not found'), end;
            FunctionArgs = Function(2:end);
            Function = Function{1};
         otherwise
            error('Bad Function parameter.');
         end
         nButtons = 3;
      case 'funcenabletest'   , FuncEnableTest   = varargin{i+1};
         if ~isstr(FuncEnableTest), error('Function Enable Test must be a string'), end
         EnableTest = strrep( FuncEnableTest, 'LISTSTRING', ListString{InitialValue} );
         EnableTest = strrep( EnableTest, 'LISTVALUE', num2str(InitialValue) );
         if eval(EnableTest)
            FunctionEnable = 'on';
         else
            FunctionEnable = 'off';
         end
      case 'cancelstring'     , CancelString     = varargin{i+1};
      end
   end
   if (nButtons == 2) & (nargout == 3), error('Too many output arguments.'); end
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%%  Create Dialog Box  %%%
   %%%%%%%%%%%%%%%%%%%%%%%%%%%
   DlgUnits = get(0, 'DefaultFigureUnits');
   DlgPos = get(0, 'DefaultFigurePosition');
   Dlg_Props = { ...
         'Units'           , DlgUnits                           , ...   
         'CloseRequestFcn' , 'set(gcf,''UserData'',''Cancel'')' , ...
         'Name'            , Name                               , ...
         'Position'        , DlgPos                             , ...
         'WindowStyle'     , 'modal'                            , ...
         'Visible'         , 'Off'                              };
   Dlg = dialog( Dlg_Props{:} );
   if nButtons == 3,
      setappdata(Dlg, 'Function', Function);
      setappdata(Dlg, 'FunctionArgs', FunctionArgs);
      setappdata(Dlg, 'FuncEnableTest', FuncEnableTest);
      setappdata(Dlg, 'FunctionOutput', []);
   end
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%%  Setup Common Variables  %%%
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   ScreenSize = get(0,'ScreenSize');
   FontUnits = get(0, 'FactoryUIControlFontUnits');
   FontSize = get(0, 'FactoryUIControlFontSize');
   MaxHeight = ScreenSize(4)*.5;
   MaxWidth = ScreenSize(3)*.5;
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%%  Get PromptString Width and Height  %%%
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   TempText = uicontrol( Dlg      , ...
      'FontUnits'  , FontUnits    , ...
      'FontSize'   , FontSize     , ...
      'FontWeight' , 'bold'       , ...
      'Units'      , 'pixels'     , ...
      'Style'      , 'text'       , ...
      'String'     , PromptString );
   PromptStringExtent = get(TempText, 'Extent');
   PromptStringWidth = min( PromptStringExtent(3), MaxWidth);
   PromptStringHeight = min( PromptStringExtent(4), MaxHeight);
   delete(TempText);
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%%  Get Button Width and Height  %%%
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   TempButton = uicontrol( Dlg   , ...
      'FontUnits' , FontUnits    , ...   
      'FontSize'  , FontSize     , ...
      'Units'     , 'pixels'     , ...  
      'Style'     , 'pushbutton' );
   ButtonStrings = {OKString, FunctionString, CancelString};
   if nButtons == 2, ButtonStrings(2) = [];, end
   ButtonWidth = 0; ButtonHeight = 0;
   for i = 1:nButtons
      set(TempButton, 'String', ButtonStrings{i});
      ButtonExtent = get(TempButton, 'Extent');
      ButtonWidth = min( max(ButtonWidth, ButtonExtent(3) + 32), .5*MaxWidth);
      ButtonHeight = min( max(ButtonHeight, ButtonExtent(4) + 8), .5*MaxHeight);
   end
   delete(TempButton);
   ButtonSpacing = 8;
   AllButtonsHeight = nButtons*ButtonHeight + ButtonSpacing*(nButtons-1);

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%%  Get ListBox Width and Height  %%%
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   ScrollBarWidth = 40;
   TempListText = uicontrol( Dlg , ...
      'FontUnits'  , FontUnits   , ...
      'FontSize'   , FontSize    , ...
      'Units'      , 'pixels'    , ...
      'Style'      , 'text'      , ...
      'String'     , ListString  );
   ListBoxExtent = get(TempListText, 'Extent');
   ListBoxWidth = min( max( PromptStringWidth, ListBoxExtent(3) + ScrollBarWidth ), MaxWidth);
   ListBoxHeight = min( max( AllButtonsHeight, ListBoxExtent(4) + 8 ), MaxHeight);
   delete(TempListText);

   %%%%%%%%%%%%%%%%%%%%%%%
   %%%  Set Positions  %%%
   %%%%%%%%%%%%%%%%%%%%%%%
   XOffset = 16;
   YOffset = 16;
   DlgWidth = ListBoxWidth + ButtonWidth + 3*XOffset;
   DlgHeight = ListBoxHeight + PromptStringHeight + 2*YOffset;
   DlgLeft = (ScreenSize(3) - DlgWidth)/2;
   DlgBottom = (ScreenSize(4) - DlgHeight)/2;
   set(Dlg, 'Position', [DlgLeft DlgBottom DlgWidth DlgHeight]);
   
   PromptStringPos = [XOffset, YOffset + ListBoxHeight, PromptStringWidth, PromptStringHeight];
   ListBoxPos = [XOffset, YOffset, ListBoxWidth, ListBoxHeight];
   ButtonLeftPos  = ListBoxWidth + 2*XOffset;
   OKButtonPos = [ButtonLeftPos, YOffset + ListBoxHeight - ButtonHeight, ...
         ButtonWidth, ButtonHeight];
   FunctionButtonPos = [ButtonLeftPos, ...
         YOffset + ListBoxHeight - AllButtonsHeight + ButtonHeight + ButtonSpacing, ...
         ButtonWidth, ButtonHeight];
   CancelButtonPos = [ButtonLeftPos, YOffset + ListBoxHeight - AllButtonsHeight, ...
         ButtonWidth, ButtonHeight];
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%%  Create PromptString  %%%
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   hPromptString = uicontrol( Dlg             , ...
      'Style'               , 'text'          , ...
      'String'              , PromptString    , ...
      'FontWeight'          , 'bold'          , ...
      'HorizontalAlignment' , 'left'          , ...
      'Units'               , 'pixels'        , ...
      'Position'            , PromptStringPos );
   
   %%%%%%%%%%%%%%%%%%%%%%%%
   %%%  Create ListBox  %%%
   %%%%%%%%%%%%%%%%%%%%%%%%
   hListBox = uicontrol( Dlg                           , ...
      'Style'               , 'listbox'                , ...
      'BackgroundColor'     , 'white'                  , ...
      'Callback'            , 'mylistdlg(''ListBox'')' , ...
      'HorizontalAlignment' , 'left'                   , ...
      'Units'               , 'pixels'                 , ...
      'Position'            , ListBoxPos               , ...
      'String'              , ListString               , ...
      'Tag'                 , 'ListBox'                , ...
      'Value'               , InitialValue             );
   
   %%%%%%%%%%%%%%%%%%%%%%%%%
   %%%  Create Buttons  %%%
   %%%%%%%%%%%%%%%%%%%%%%%%%
   hOKButton = uicontrol( Dlg          , ...
      'Style'    , 'pushbutton'        , ...
      'Callback' , 'mylistdlg(''OK'')' , ...
      'String'   , OKString            , ...
      'Units'    , 'pixels'            , ...   
      'Position' , OKButtonPos         );
   if nButtons == 3
      hFunctionButton = uicontrol( Dlg             , ...
         'Style'    , 'pushbutton'                 , ...
         'Callback' , 'mylistdlg(''Function...'')' , ...
         'Enable'   , FunctionEnable               , ...
         'String'   , FunctionString               , ...
         'Units'    , 'pixels'                     , ...   
         'Position' , FunctionButtonPos            , ...
         'Tag'      , 'FunctionButton'             );
   end
   hCancelButton = uicontrol( Dlg          , ...
      'Style'    , 'pushbutton'            , ...
      'Callback' , 'mylistdlg(''Cancel'')' , ...
      'String'   , CancelString            , ...
      'Units'    , 'pixels'                , ...   
      'Position' , CancelButtonPos         );
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%%  Wait for Resume, Set Output Arguments and Exit %%%
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   set(Dlg, 'Visible', 'On');
   waitfor(Dlg,'UserData');
   switch get(Dlg,'UserData')
   case 'OK'
      OK = 1;
      if strcmp(ReturnType, 'Value')
         Selection = get(hListBox, 'Value');
      else
         Selection = ListString{ get(hListBox, 'Value') };
      end
      if nButtons == 3, FunctionOutput = getappdata(Dlg, 'Function Output');, end
   case 'Cancel'
      OK = 0;
      Selection = [];
      if nButtons == 3, FunctionOutput = [];, end
   end
   delete(Dlg)
end