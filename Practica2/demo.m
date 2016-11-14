
% Esta macro realiza la demodulacion de una se?al FM, obteni?ndose la se?al
% banda base MPX (multiplex).

clear all;
close all;
clc;


%load fm920.mat    % Grabaciones realizas
load Pract2.mat

Fs=200e3;         % La se?al equivalente paso baja est? muestreada a 200kHz

% Equivalente paso baja: xI+jxQ.
x=reshape(x.Data,numel(x.Data),1);
% figure(1);plot(x,'b.');
% title('Se?al modulada FM. Equivalente paso baja');
% xlabel('Real');ylabel('Imag');


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

% Demodulaci?n FM
z=angle(x(2:end).*conj(x(1:end-1)));   % Se?al demodulada. La frec instant?nea es la derivada de la fase
t=0:1/Fs:(length(z)-1)/Fs;
% figure;plot(t,z);
% xlabel('Tiempo (s)');title('Se?al FM demodulada MPX');

% Espectro de la se?al MPX
Z=fftshift(fft(z));
f=linspace(-Fs/2,Fs/2,length(Z));
figure;plot(f/1000,abs(Z));
xlabel('KHz');title('Espectro Se?al FM MPX');xlim([0 80])


% Recuperamos L+R (receptor mono). Filtramos paso-baja a 15KHz
h=fir1(200,15e3/(Fs/2));           % Filtro de fase lineal
zd=filter(h,1,z);
zmono=filter(DeemphasisFilter,zd);     % De?nfasis
% figure;plot(t,zmono);
% xlabel('Tiempo (s)');title('Se?al FM demodulada MPX - Tras Deemphasis');


% Submuestreamos a 48KHz y reproducimos la se?al
xo=resample(zmono,6,25);   % 200*6/25 = 48kHz
%soundsc(xo,48e3);


%%% PRACTICA %%%

% Filtrado de 19 KHz
delta = 1e-10;
firtono = fir1(200,[(19e3-delta)/(Fs/2) (19e3+delta)/(Fs/2)]);
tono = filter(firtono,1,z);
f=linspace(-Fs/2,Fs/2,length(abs(fftshift(fft(tono)))));
figure;plot(f/1000,abs(fftshift(fft(tono))));xlabel('Frecuencia (KHz)');title('Tonos obtenidos a partir de los 19 KHz');xlim([0 60]);
hold on;

% Generaci?n tono de 38 KHz
tono38 = tono.*tono;
delta = 1e-10;
firtono38 = fir1(200,[(38e3-delta)/(Fs/2) (38e3+delta)/(Fs/2)]);
tono38 = filter(firtono38,1,tono38);
f=linspace(-Fs/2,Fs/2,length(abs(fftshift(fft(tono38)))));
plot(f/1000,abs(fftshift(fft(tono38))),'r');

% Generaci?n tono de 57 KHz
tono57 = 3*tono - 4*tono.^3;
delta = 1e-10;
firtono57 = fir1(400,[(57e3-delta)/(Fs/2) (57e3+delta)/(Fs/2)]);
tono57 = filter(firtono57,1,tono57);
f=linspace(-Fs/2,Fs/2,length(abs(fftshift(fft(tono57)))));
plot(f/1000,abs(fftshift(fft(tono57))),'g');

% Obtenci?n (mediante filtrado) de L-R
delta = 15e3;
firLR = fir1(200,[(38e3-delta)/(Fs/2) (38e3+delta)/(Fs/2)]);
LRmod = filter(firLR,1,z);
f=linspace(-Fs/2,Fs/2,length(abs(fftshift(fft(LRmod)))));
figure;plot(f/1000,abs(fftshift(fft(LRmod))));xlabel('Frecuencia (KHz)');title('Se?al L-R modulada y filtrada');xlim([0 60]);

% Demodulaci?n y deenfasis en L-R
LmenosRenfasis = filter(h,1,LRmod.*tono38);
f=linspace(-Fs/2,Fs/2,length(abs(fftshift(fft(LmenosRenfasis)))));
figure;plot(f/1000,abs(fftshift(fft(LmenosRenfasis))));xlabel('Frecuencia (KHz)');title('Se?al L-R demodulada');xlim([0 20]);

LmenosR=filter(DeemphasisFilter,LmenosRenfasis);     % De?nfasis
f=linspace(-Fs/2,Fs/2,length(abs(fftshift(fft(LmenosR)))));
figure;plot(f/1000,abs(fftshift(fft(LmenosR))));xlabel('Frecuencia (KHz)');title('Se?al L-R demodulada y con filtro de deenfasis revertido');xlim([0 20]);

% Generaci?n de L y R
LmasR = zmono;
Lch = LmasR + LmenosR;
Rch = LmasR - LmenosR;

xoL=resample(Lch,6,25);   % 200*6/25 = 48kHz
xoR=resample(Rch,6,25);   % 200*6/25 = 48kHz
soundsc([xoR xoL],48e3);



%%% NO COMPLETO %%%
% % Obtenci?n RDS. 
% delta = 3e3;
% firRDS = fir1(200,[(57e3-delta)/(Fs/2) (57e3+delta)/(Fs/2)]);
% RDSmod = filter(firRDS,1,z);
% 
% % Demodulaci?n RDS
% fir2K=fir1(200,2e3/(Fs/2));
% RDSEnfasis = filter(fir2K,1,RDSmod.*tono57);
% %f=linspace(-Fs/2,Fs/2,length(abs(fftshift(fft(LmenosRenfasis)))));
% %figure;plot(f/1000,abs(fftshift(fft(LmenosRenfasis))));
% %figure;plot(t,LmenosRenfasis);
% RDS=filter(DeemphasisFilter,RDSEnfasis);     % De?nfasis
% f=linspace(-Fs/2,Fs/2,length(abs(fftshift(fft(RDS)))));
% %figure;plot(f/1000,abs(fftshift(fft(RDS))));
% %figure;plot(t,(fft(RDS)),'b.');
% 
% %Decodificaci?n RDS
% bitrate = 1187.5;
% dur = t(end);
% nsim = dur*bitrate;
% muesporsimb= length(RDS)/nsim;
% 
% d=qamdemod(downsample(RDS,84),2);
% 
% datos(1)=0;
% j=2;
% for i = 1:length(d)
%     if d(i) == 1
%         datos(j) = ~datos(j-1);
%     else
%         datos(j) = datos(j-1);
%     end
%     j=j+1;
% end
% 
% fase = angle(RDS);
% fasemuest = downsample(fase,84);
% 
% 
% figure;plot(fase,'b.')
% 
% 