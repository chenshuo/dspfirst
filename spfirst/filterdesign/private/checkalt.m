function [e,h]=checkalt(x,y)
j=1;
len=length(x);
for i=1:len-1
    if sign(x(j))==sign(x(j+1))
        if abs(x(j))<=abs(x(j+1))
            x(j)=[];
            y(j)=[];
        else
            x(j+1)=[];
            y(j+1)=[];
        end
        j=j-1;
    end
    j=j+1;
end
e=x;
h=y;
