function handlesout = recal(handles, option)
% Update H(z)

N = 512;
pt = 25;

switch option
    case 'pole_to_poly'
        handles.a   = poly(handles.poleloc);
        handles.b   = poly(handles.zeroloc);
        handles.hz  = fftshift((fft(handles.k*handles.b,N))./(fft(handles.a,N)));
        handles.hn  = filter(handles.k*handles.b,handles.a,[1, zeros(1,pt-1)]);
    case 'poly_to_pole'
        handles.poleloc = roots(handles.a).';
        handles.zeroloc = roots(handles.b).';
        handles.hz      = fftshift((fft(handles.k*handles.b,N))./(fft(handles.a,N)));
        handles.hn      = filter(handles.k*handles.b,handles.a,[1, zeros(1,pt-1)]);
    otherwise
end

tol = 0.001;
n = length(handles.poleloc);
delete(findall(0,'tag','peztext'));
shift = 0.1;

if n ~= 0

    listpez = zeros(2,n);
    listpez(1,:) = nan;

    for i = 1:n
        listpez(1,i) = handles.poleloc(i);
        listpez(2,i) = 1;
        for j = 1:i-1
            if abs(real(handles.poleloc(i))-real(handles.poleloc(j)))<tol & abs(imag(handles.poleloc(i))-imag(handles.poleloc(j)))<tol
                listpez(1,i) = nan;
                listpez(2,j) = listpez(2,j) + 1;
            end
        end
    end

    multipez = find((listpez(2,:) > 1) & ~isnan(listpez(1,:)));

    if ~isempty(multipez)
        text(real(listpez(1,multipez))+shift,imag(listpez(1,multipez))+shift,...
            num2str(listpez(2,multipez).'),...
            'tag','peztext','parent',handles.axes_pzplot);
        text(real(listpez(1,multipez))+shift,imag(listpez(1,multipez))+shift,...
            num2str(listpez(2,multipez).'),...
            'tag','peztext','parent',handles.showplot_h.axes_pzplot);
    end
end

n = length(handles.zeroloc);

if n ~= 0

    listpez = zeros(2,n);
    listpez(1,:) = nan;

    for i = 1:n
        listpez(1,i) = handles.zeroloc(i);
        listpez(2,i) = 1;
        for j = 1:i-1
            if abs(real(handles.zeroloc(i))-real(handles.zeroloc(j)))<tol & abs(imag(handles.zeroloc(i))-imag(handles.zeroloc(j)))<tol
                listpez(1,i) = nan;
                listpez(2,j) = listpez(2,j) + 1;
            end
        end
    end

    multipez = find((listpez(2,:) > 1) & ~isnan(listpez(1,:)));

    if ~isempty(multipez)
        text(real(listpez(1,multipez))+shift,imag(listpez(1,multipez))+shift,...
            num2str(listpez(2,multipez).'),...
            'tag','peztext',...
            'parent',handles.axes_pzplot);
        text(real(listpez(1,multipez))+shift,imag(listpez(1,multipez))+shift,...
            num2str(listpez(2,multipez).'),...
            'tag','peztext',...
            'parent',handles.showplot_h.axes_pzplot);
    end
end

% Zero-padding
m = length(handles.poleloc);
handles.pole0 = zeros(1,n-m);
if length(handles.pole0) > 1
    text(shift,shift,num2str(length(handles.pole0)),...
        'tag','peztext','parent',handles.axes_pzplot);
    text(shift,shift,num2str(length(handles.pole0)),...
        'tag','peztext','parent',handles.showplot_h.axes_pzplot);
end
handles.zero0 = zeros(1,m-n);
if length(handles.zero0) > 1
    text(shift,shift,num2str(length(handles.zero0)),...
        'tag','peztext','parent',handles.axes_pzplot);
    text(shift,shift,num2str(length(handles.zero0)),...
        'tag','peztext','parent',handles.showplot_h.axes_pzplot);
end
%-----------------------------------------------------------------
% FORMULA text formatting
%-----------------------------------------------------------------
% Update formula string only if # of poles/zeros < 4
if max(length(find(handles.a)),length(find(handles.b))) > 7
    set(handles.formula_text,'vis','off');
else
    set(handles.formula_text,'vis','on');
    % zeros string bo + b1 z^(-1) + b2 z^(-2) + ...
    bb = handles.k*handles.b;
    bb = bb(2:end);
    b = num2str(handles.b(1)*handles.k);
    for zz = 1:length(bb)
        % check for special cases
        if ~(bb(zz) == 0)
            if isreal(bb(zz))
                if abs(bb(zz)) == 1
                    coeff = '';
                else
                    coeff = num2str(abs(bb(zz)));
                end
            else
                if real(bb(zz)) == 0
                    if abs(imag(bb(zz))) == 1
                        coeff = '';
                    else
                        coeff = num2str(abs(imag(bb(zz))));
                    end
                else
                    coeff = ['(' num2str(bb(zz)) ')'];
                end
            end

            % determine sign: '-' is 45, '+' is 43
            if isreal(bb(zz))
                sgn = char(44-(sign(bb(zz))));
            else
                if real(bb(zz)) == 0
                    sgn = char(44-(-sign(imag(bb(zz)))));
                else
                    sgn = '+';
                end
            end
            b = [b sgn coeff 'z^{' num2str(-zz) '}'];
        end
    end

    % poles string 1 - a1 z^(-1) - a2 z^(-2) + ...
    aa = handles.a(2:end);
    a = num2str(handles.a(1));
    for pp = 1:length(aa)
        % check for special cases
        if ~(aa(pp) == 0)
            if isreal(aa(pp))
                if abs(aa(pp)) == 1
                    coeff = '';
                else
                    coeff = num2str(abs(aa(pp)));
                end
            else
                if real(aa(pp)) == 0
                    if abs(imag(aa(pp))) == 1
                        coeff = '';
                    else
                        coeff = num2str(abs(imag(aa(pp))));
                    end
                else
                    coeff = ['(' num2str(aa(pp)) ')'];
                end
            end

            % determine sign: '-' is 45, '+' is 43
            if isreal(aa(pp))
                sgn = char(44-(sign(aa(pp))));
            else
                if real(aa(pp)) == 0
                    sgn = char(44-(-sign(imag(aa(pp)))));
                else
                sgn = '+';
                end
            end
            a = [a sgn coeff 'z^{' num2str(-pp) '}'];
        end
    end

    % gain string
    if handles.k == 0
        str = 'H(z) = 0';
    else
        str = ['$$H(z)=\frac{' b '}{' a '}$$'];
    end
    set(handles.formula_text,'str',str);
end
handlesout = handles;