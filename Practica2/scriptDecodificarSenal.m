clear all;
close all;

Fs=200e3;

load('Pract2.mat');
x=reshape(x.Data,numel(x.Data),1);

t=1/Fs:1/Fs:(length(x)-1)/Fs;

xi=real(x);
xq=imag(x);

fftXi=fft(xi,Fs);
fftXq=fft(xq,Fs);


% Demodulacion FM
x_demod=angle(x(2:end).*conj(x(1:end-1)));   % Se�al demodulada. La frec instant?nea es la derivada de la fase
figure;plot(t,x_demod);
xlabel('Tiempo (s)');title('Senal FM demodulada MPX');

% Espectro de la se�al MPX

fftx = fft(x_demod);

f=linspace(0,Fs/2,length(x_demod)/2-1)/1000;
figure;
plot(f,abs(fftx(1:length(fftx)/2-1)));
xlabel('Frequency kHz');
ylabel('X(f)');
title('Demoldulated Signal Spectrum');


% Filtro Deemphasis
N= 5; % Orden
B= 1; % Numero de bandas
F1 = [50 100 500 1000 2000 3000 4000 5000 6000 7000 8000 9000 10000 ...
    11000 12000 13000 14000 15000 16000 17000 18000 19000 20000 ...
    97656.25];  %  Vector de frecuencias
A1 = [1 0.998849369936505 0.973867785328633 0.904690437738119 ...
    0.727779804536824 0.577430872713986 0.468813382145265 ...
    0.390840895792402 0.333426412763235 0.290068119869315 ...
    0.256448403651772 0.229614864811236 0.207491351745491 ...
    0.189452351435659 0.174180687339161 0.161064563517827 ...
    0.149795925304488 0.140119958494001 0.131522483219224 ...
    0.123879658653037 0.117084660232024 0.111045253533364 ...
    0.105560150321593 0.0223872113856834]; %  Amplitud del vector

h = fdesign.arbmag('N,B,F,A', N, B, F1, A1, Fs);
DeemphasisFilter = design(h, 'iirlpnorm');
%fvtool(DeemphasisFilter,'Color','White'); % Rojo: especificaciones. Azul: filtro dise?ado.




% Filtro paso baja para obtener L+R

order_lowpass = 200;
fcutoff = 15000/(Fs/2);  

B_1 = fir1(order_lowpass,fcutoff);
 
%  Filter the signal with the FIR filter
x_filtLR = filter(B_1, 1, x_demod);


% Espectro de la se�al L+R

fftxLR = fft(x_filtLR);
fLR=linspace(0,Fs/2,length(x_filtLR)/2-1)/1000;
figure;
plot(fLR,abs(fftxLR(1:length(fftxLR)/2-1)));
xlabel('Frequency kHz');
ylabel('L+R X(f)');
title('L + R Part of Signal Spectrum');

% Aplicamos filtro deemfasis

x_LR = filter(DeemphasisFilter, x_filtLR);
fftxLRDeemphasis = fft(x_LR);

figure;

plot(fLR,abs(fftxLRDeemphasis(1:length(fftxLRDeemphasis)/2-1)));
xlabel('Frequency kHz');
ylabel('Deemphasis L+R X(f)');
title('Deemphasis L + R Part of Signal Spectrum');

soundsc(x_LR,Fs);

% Filtro paso banda para obtener Portadora

order_bandpass = 200;
f_bandpass =[16000 23000]*2/Fs ;  

B_2 = fir1(order_bandpass,f_bandpass);
 
%  Filter the signal with the FIR filter
carrier = filter(B_2, 1, x_demod);


% Espectro de la se�al portadora

fftx_carrier = fft(carrier);

figure;
plot(linspace(0,Fs/2,length(carrier)/2-1)/1000 , abs(fftx_carrier(1:length(fftx_carrier)/2-1)));
xlabel('Frequency kHz');
ylabel('Carrier X(f)');
title('Carrier Part of Signal Spectrum');

% Filtro paso banda para obtener L-R

order_bandpass2 = 200;
f_bandpass2 =[23000 53000]*2/Fs;  

B_3 = fir1(order_bandpass2,f_bandpass2);
 
%  Filter the signal with the FIR filter
x_filtLminusR = filter(B_3, 1, x_demod);

% Espectro de la se�al  L-R

fftx_LminusR = fft(x_filtLminusR);

figure;
plot(linspace(0,Fs/2,length(x_filtLminusR)/2-1)/1000 , abs(fftx_LminusR(1:length(fftx_LminusR)/2-1)));
xlabel('Frequency kHz');
ylabel('L-R X(f)');
title('L-R Part of Signal Spectrum');

% Pasamos la se�al L-R a banda base multiplicando por la portadora dos
% veces

x_LminusRBaseBand = carrier.^2 .* x_filtLminusR;
 
%  Filter the signal with the FIR filter
x_filtLminusRBaseBand = filter(B_1, 1, x_LminusRBaseBand);

fftx_LminusRBaseBand = fft(x_filtLminusRBaseBand);
figure;
plot(linspace(0,Fs/2,length(x_filtLminusRBaseBand)/2-1)/1000 , abs(fftx_LminusRBaseBand(1:length(fftx_LminusRBaseBand)/2-1)));
xlabel('Frequency kHz');
ylabel('L-R X(f)');
title('L-R Part banda base of Signal Spectrum');



% Filtro paso banda para obtener RBDS

order_bandpass3 = 200;
f_bandpass3 =[55000 58650]*2/Fs;  

B_4 = fir1(order_bandpass3,f_bandpass3);
 
%  Filter the signal with the FIR filter
x_filtRBDS = filter(B_4, 1, x_demod);

% Espectro de la se�al portadora

fftx_RBDS = fft(x_filtRBDS);

figure;
plot(linspace(0,Fs/2,length(x_filtRBDS)/2-1)/1000 , abs(fftx_RBDS(1:length(fftx_RBDS)/2-1)));
xlabel('Frequency kHz');
ylabel('RBDS X(f)');
title('RBDS Part of Signal Spectrum');






% soundsc(abs(x),Fs);
% plot(t,xi);