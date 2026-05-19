function h = makeplots(h)
%MAKEPLOTS Make the plots for the GUI

%---------------------------------------------------------------------------
% Plot z1 and z2
%---------------------------------------------------------------------------
set(h.Figure,'currentAxes',h.Axis.Input);
cla;
hold on;
ucplot(1,0,'k:');
switch h.Operation
case {'Inverse','Conjugate'}
   hObj = h.z1;
otherwise
   hObj = [h.z1 h.z2];
end
V = setaxislims(h.Axis.Input,hObj);
M = max([diff(V(1:2)) diff(V(3:4))]);
zcoords('k:');
basewidth  = 0.035*M*h.ArrowScale;
headwidth  = 2.5*basewidth;
headlength = 3.5*basewidth;
headinset  = 3*basewidth;
Params = {'basewidth',basewidth, 'headwidth', headwidth, ...
      'headlength',headlength, 'headinset',headinset};
h.Patch.z1 = plotvect([real(h.z1) imag(h.z1)],h.Colors.Input1,Params{:});
switch h.Operation
case {'Inverse','Conjugate'}
   % Do Nothing
otherwise
   h.Patch.z2 = plotvect([real(h.z2) imag(h.z2)],h.Colors.Input2,Params{:});
end
hold off;

%---------------------------------------------------------------------------
% Plot Answer and Guess
%---------------------------------------------------------------------------
z.Answer = getfield(h.z3,h.Operation);
r        = str2num(get(h.Edit.Radius, 'String'));
theta    = str2num(get(h.Edit.Angle, 'String'));
z.Guess  = r*exp(j*theta);

set(h.Figure,'currentAxes',h.Axis.Answer); 
cla; 
hold on;
ucplot(1,0,'k:');
V = setaxislims(h.Axis.Answer,z.Guess);
M = max([diff(V(1:2)) diff(V(3:4))]);
zcoords('k:');
basewidth  = 0.035*M*h.ArrowScale;
headwidth  = 2.5*basewidth;
headlength = 3.5*basewidth;
headinset  = 3*basewidth;
Params = {'basewidth',basewidth, 'headwidth', headwidth, ...
      'headlength',headlength, 'headinset',headinset};
if ~isempty(r) & ~isempty(theta)
   % Only plot guess if data entered is valid
   h.Patch.Guess  = plotvect([real(z.Guess) imag(z.Guess)],h.Colors.Guess,Params{:});
end
h.Patch.Answer = plotvect([real(z.Answer) imag(z.Answer)],h.Colors.Answer,Params{:});
hold off;

cellAns = {'z1+z2','z1-z2','z1*z2','z1/z2','1/z1','z1^*'};
cellOP = cellAns(get(h.Popup.Operation,'value'));
if get(h.Checkbox.ShowAnswer,'value')
   set(h.Patch.Answer,'Visible','on');
else
   set(h.Patch.Answer,'Visible','off');
end


%---------------------------------------------------------------------------
% Plot Vector sum, if necessary
%---------------------------------------------------------------------------
switch h.Operation
case {'Add','Subtract'}
   set(h.Figure,'currentAxes',h.Axis.Answer);
   hold on
   switch h.Operation
   case 'Add'
      h.Patch.VectorSum = zeros(2,1);
      h.Patch.VectorSum(1) = plotvect([real(h.z1) imag(h.z1)],h.Colors.Input1,Params{:});
      h.Patch.VectorSum(2) = plotvect([real(h.z2) imag(h.z2)],h.Colors.Input2, ...
         [real(h.z1) imag(h.z1)],Params{:});
   case 'Subtract'
      h.Patch.VectorSum = zeros(2,1);
      h.Patch.VectorSum(1) = plotvect([real(h.z1) imag(h.z1)],h.Colors.Input1,Params{:});
      h.Patch.VectorSum(2) = plotvect([real(-h.z2) imag(-h.z2)],h.Colors.Input2, ...
         [real(h.z1) imag(h.z1)],Params{:});
   otherwise
      error('Inconsistent options.  Programming error...this should never occur.')
   end
   hold off;
   if get(h.Checkbox.ShowVectorSum,'value')
      set(h.Patch.VectorSum,'Visible','on');
   else
      set(h.Patch.VectorSum,'Visible','off');
   end
end


%---------------------------------------------------------------------------
% Set axis limits as necessary
%---------------------------------------------------------------------------
% This could probably be incorporated into the logic above, but it works 
% fine here.
if get(h.Checkbox.ShowVectorSum,'value') & get(h.Checkbox.ShowAnswer,'Value')
   setaxislims(h.Axis.Answer,[z.Answer h.Guess h.z1 h.z2]);
elseif get(h.Checkbox.ShowVectorSum,'value')
   setaxislims(h.Axis.Answer,[z.Guess h.z1 h.z2]);
elseif get(h.Checkbox.ShowAnswer,'Value')
   setaxislims(h.Axis.Answer,[z.Guess h.z1 h.z2]);
else
   setaxislims(h.Axis.Answer,z.Guess);
end
