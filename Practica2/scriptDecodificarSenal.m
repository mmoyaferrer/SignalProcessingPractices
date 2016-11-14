clear all;

Fs=200e3;
t=1/Fs:1/Fs:1;

load('Pract2.mat');
x=reshape(x.Data,numel(x.Data),1);

xi=real(x);
xq=imag(x);

fftXi=fft(xi,Fs);
fftXq=fft(xq,Fs);

%phaseX=angle(x);
%Dise?ar un filtro FIR pasabanda a frecuencias de 30 Hz y 3500 Hz por cada uno de los diferentes m?todos. Utilizar un mismo orden de filtro (por ejemplo N=44) y comparar las respuestas frecuenciales.

N=44;Fs=11020;Fny=Fs/2;
Bfir1 = fir1(N,[30 3500]/Fny);
Bfir2 = fir2(N,[0 10 30 3500 3600 Fny]/Fny,[0 0 1 1 0 0]);
Bfirls = firls(N,[0 10 30 3500 3600 Fny]/Fny,[0 0 1 1 0 0]);
Bremez = remez(N,[0 10 30 3500 3600 Fny]/Fny,[0 0 1 1 0 0]);


soundsc(abs(x),Fs);
plot(t,xi);
