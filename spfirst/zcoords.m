function hz = zcoords( linetype )
%ZCOORDS    put co-ordinates on a z-plane diagram
%
%  usage:   hz = zcoords( <linetype> )
%       linetype = valid line type (see PLOT)
%            defaults to ':'
%         hz = graphics handle
if( nargin == 0 )
  vv = version;
  if( vv(1)>='5')
	linetype = 'b:';
  else
	linetype = 'w:';
  end
end
qq = axis; 
   next = lower(get(gca,'NextPlot'));   %--Ver 4.1
   isholdon = ishold;                   %--Ver 4.1
h = plot([qq(1),0; qq(2),0], [0,qq(3); 0,qq(4)], linetype );
   if ~isholdon;                        %--Ver 4.1
      set(gca,'NextPlot',next);         %--Ver 4.1
   end;                                 %--Ver 4.1
if nargout > 0
   hz = h;
end
