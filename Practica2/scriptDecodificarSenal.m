clear all;
close all;

clc;

Fs=200e3;

load('Pract2.mat');
x=reshape(x.Data,numel(x.Data),1);

t=1/Fs:1/Fs:(length(x)-1)/Fs;

xi=real(x);
xq=imag(x);

fftXi=fft(xi,Fs);
fftXq=fft(xq,Fs);


% Demodulacion FM
x_demod=angle(x(2:end).*conj(x(1:end-1)));   % Se?al demodulada. La frec instant?nea es la derivada de la fase
figure;plot(t,x_demod);
xlabel('Tiempo (s)');title('Senal FM demodulada MPX');

% Espectro de la se?al MPX

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
filtrodeenfasis = design(h, 'iirlpnorm');
%fvtool(DeemphasisFilter,'Color','White'); % Rojo: especificaciones. Azul: filtro dise?ado.



%% Filtro paso baja para obtener L+R
order_lowpass = 200;
fcutoff = 15000/(Fs/2);  

B_1 = fir1(order_lowpass,fcutoff);
x_filtLR = filter(B_1, 1, x_demod);


% Espectro de la se?al L+R
fftxLR = fft(x_filtLR);
fLR=linspace(0,Fs/2,length(x_filtLR)/2-1)/1000;
figure;
plot(fLR,abs(fftxLR(1:length(fftxLR)/2-1)));
xlabel('Frequency kHz');
ylabel('L+R X(f)');
title('L + R Part of Signal Spectrum');

%% Aplicamos filtro deemfasis

x_LR = filter(filtrodeenfasis, x_filtLR);
fftxLRDeemphasis = fft(x_LR);

figure;

plot(fLR,abs(fftxLRDeemphasis(1:length(fftxLRDeemphasis)/2-1)));
xlabel('Frequency kHz');
ylabel('Deemphasis L+R X(f)');
title('Deemphasis L + R Part of Signal Spectrum');

%soundsc(x_LR,Fs);

%% Filtro paso banda para obtener Portadora. 
%  Puesto que la se?al FM contiene una portadora implicita y posteriormente
%  nos sera necesaria para pasar a banda base la se?al L-R, obtendremos
%  dicha portadora de la se?al mediante un filtro paso banda y la
%  guardaremos como "carrier".

% Dise?amos el filtro, con orden 200 y la banda de frecuencias
% especificada.
order_bandpass = 200;
f_bandpass =[16000 23000]*2/Fs ;  

% Filtramos la se?al y la guardamos como carrier.
B_2 = fir1(order_bandpass,f_bandpass);
carrier = filter(B_2, 1, x_demod);

% Representamos el espectro de la se?al portadora, comprobando que
% obtenemos algo parecido a una se?al delta sin l?bulos.
fftx_carrier = fft(carrier);
figure;
plot(linspace(0,Fs/2,length(carrier)/2-1)/1000 , abs(fftx_carrier(1:length(fftx_carrier)/2-1)));
xlabel('Frequency kHz');
ylabel('Carrier X(f)');
title('Carrier Part of Signal Spectrum');

%% Obtenci?n L y R
%  A continuaci?n, obtendremos la parte del espectro que contiene la se?al
%  L-R, de manera que podremos sumar esta a la se?al L+R obtenida
%  previamente y obtener los canales L y R por separado.              

% Para ello, aplicamos en primer lugar un filtro FIR paso banda entre las
% frecuencias 23kHz y 53kHz.

% Dise?amos el filtro, con orden 200 y la banda de frecuencias
% especificada.
order_bandpass2 = 200;
f_bandpass2 =[23000 53000]*2/Fs;  

% Filtramos la se?al y la guardamos como x_filtLminusR.
B_3 = fir1(order_bandpass2,f_bandpass2);
x_filtLminusR = filter(B_3, 1, x_demod);

% Representamos el espectro de ?sta, comprobando que es correcto.
fftx_LminusR = fft(x_filtLminusR);

figure;
plot(linspace(0,Fs/2,length(x_filtLminusR)/2-1)/1000 , abs(fftx_LminusR(1:length(fftx_LminusR)/2-1)));
xlabel('Frequency kHz');
ylabel('L-R X(f)');
title('L-R Part of Signal Spectrum');


% A continuaci?n, pasamos la se?al L-R a banda base, le aplicamos un
% filtro paso baja (el mismo aplicado a L+R) y obtenemos los canales L y R.
x_LminusRBaseBand = carrier.^2 .* x_filtLminusR;
x_filtLminusRBaseBand = filter(B_1, 1, x_LminusRBaseBand); % Filtro paso baja.

% Pintamos la se?al L-R en banda base.
fftx_LminusRBaseBand = fft(x_filtLminusRBaseBand);
figure;
plot(linspace(0,Fs/2,length(x_filtLminusRBaseBand)/2-1)/1000 , abs(fftx_LminusRBaseBand(1:length(fftx_LminusRBaseBand)/2-1)));
xlabel('Frequency kHz');
ylabel('L-R X(f)');
title('L-R Part banda base of Signal Spectrum');

% Aplicamos el filtro de deemfasis a la se?al L-R en banda base 
x_LminusRdeem = filter(filtrodeenfasis, x_filtLminusRBaseBand);

% Obtenemos el canal R sumando las se?ales L+R y L-R
R = x_LR + x_LminusRdeem;
% Obtenemos el canal L restando las se?ales L+R y L-R
L = x_LR - x_LminusRdeem;
x_RX = [ R';L'];

% soundsc(x_RX,Fs); % Audio final decodificado y dividido en L y R

%% Obtencion y decodificacion RBDS

% Primero, obtenemos el filtro conformador convolucionando un pulso coseno
% remonta<do con dos deltas en -Tsim/4 y Tsim/4

coseno_remontado = rcosine(4000,200000);
coseno_remontado = resample(coseno_remontado,128,length(coseno_remontado));
deltas = zeros(1,128);
deltas(3*length(deltas)/8)=-1;
deltas(5*length(deltas)/8)=1;
p = [conv(deltas,coseno_remontado) 0];
plot(p);

% En segundo lugar, procedemos a procesar RBDS

% Filtro paso banda para obtener RBDS
% Primeo se tiene que filtrar paso banda la se?al,centrada en 57Khz, con un
% anche de banda de 4812Hz. En este caso utilizamos un filtro fir.

order_bandpass3 = 2000;
f_bandpass3 =[54594 59406]*2/Fs;  % en internet --> BW=4812
B_4 = fir1(order_bandpass3,f_bandpass3);
x_filtRBDS = filter(B_4, 1, x_demod);

% Espectro de la se?al RDS

fftx_RBDS = fft(x_filtRBDS);

% Ahora representamos la se?al filtrada en la que vemos la se?al centrada
% en torno a 57Khz 

figure;
plot(linspace(0,Fs/2,length(x_filtRBDS)/2-1)/1000 , abs(fftx_RBDS(1:length(fftx_RBDS)/2-1)));
xlabel('Frequency kHz');
ylabel('RBDS X(f)');
title('RBDS Part of Signal Spectrum');

% Decodificamos RBDS

% Para demodular la se?al se tiene que multiplicar la se?al filtrada por el
% seno y por el coseno de 57Khz, obteniendo de esta manera la se?al en fase
% y cuadratura.

RBDS_fase=x_filtRBDS'.*cos(2*pi*57000*t);
RBDS_cuadratura=x_filtRBDS'.*sin(2*pi*57000*t);

% Para obtener un n?mero entero de muestras por s?mbolo, se hace un
% resample y cambiamos la frecuencia de muestreo a 152KHz.

RBDS_fase=resample(RBDS_fase,19,25); % Hacemos resample para q salgan 256 bits por simbolo, un n? entero de muestras por simbolo
RBDS_cuadratura=resample(RBDS_cuadratura,19,25);

Tsimb=1/1187.5; % Se define un nuevo tiempo de s?mbolo para la nueva Fs

% Filtramos la se?al por el puso conformador, para convolucionar la se?al
% con el pulso conformador simplmenete filtrammos por el pulso invertido.
% obteniendo la se?al en fase y caudratura.

x_fase_RDS=filter(fliplr(p),1,RBDS_fase);
x_cuadratura_RDS=filter(fliplr(p),1,RBDS_cuadratura);
x_RBDS_final=x_fase_RDS + 1i*x_cuadratura_RDS;

% Hacemos el diagrama de ojo para ver cual es el instante de tiempo
% adecuado para el muestreo, en este caso unas 48 muestras.

diagramaDeOjoFase=reshape(x_fase_RDS(1:end-224),256,[]);
diagramaDeOjoCuadratura=reshape(x_cuadratura_RDS(1:end-224),256,[]);
figure
plot(diagramaDeOjoFase);
figure
plot(diagramaDeOjoCuadratura)

% Extraer bitstream - Por aqu? nos hemos quedado  
% Hay que decidir un s?mbolo cada 256 muestras => 2 bits cada 256 muestras.
bitstream=qamdemod(x_filtRBDS,2);
figure;
plot(bitstream,'o');
title('BitStream sequence');
xlabel('Time t');
ylabel('Bit Value');

