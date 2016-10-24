function [x,Xmax,Xmin] = normalizar(x)

Xmax=max(x);
Xmin=min(x);

if(Xmax>abs(Xmin))
    x=x/Xmax;
    Xmax=1;
    Xmin=Xmin/Xmax;
else
    x=x/abs(Xmin);
    Xmax=Xmax/abs(Xmin);
    Xmin=-1;
end

end

