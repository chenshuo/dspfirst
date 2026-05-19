function display(f)
%DISPLAY Displays the EXPONENTIAL objects data.
%   DISPLAY(f) displays the objects data.  It is automatically called from
%   when the object is entered in the command window without terminating semicolon.
%
%   See also EXPONENTIAL

% Jordan Rosenthal, 12/16/97

Param_Names = char( {'Scaling Factor: ','Exponential Constant: ','Length: ','Delay: '} );
Param_Vals = [f.ScalingFactor, f.ExpConstant, f.Length, f.Delay];
Divider(1:length(f.Name)) = '-';
disp(' ');
disp(f.Name);
disp(Divider);
for i = 1:size(Param_Names,1)
   disp([Param_Names(i,:) num2str(Param_Vals(i))]);
end
disp(['Causality:            ' f.Causality]);
disp(' ');
