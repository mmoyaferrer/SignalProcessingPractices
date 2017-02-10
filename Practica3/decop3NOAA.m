%% Practica 3 - SAC
% Recepción Analógica empleando el estándard APT.
%
%  Autores -> Manuel Moya Ferrer
%             Jose Manuel Garcia Gimeno
%             Juan Manuel Lopez Torralba

clear all
close all
clc


% Leemos el fichero de origen y cargamos los datos en la variable x
fileID = fopen('data_full.raw','r');
x = fread(fileID,inf,'single');
fclose(fileID);

% Definimos alguno parámetros iniciales

Nfft = 1500000;  % Tamaño de la FFT
FsAM = 11025;    % frecuencia de muestreo de la señal FM -> AM
Fs = 60e3;       % frecuencia de muestreo inicial
FsFinal = 4160;  % frecuencia de muestreo final
fc = 2.4e3;      % frecuencia de la portadora de AM

% Obtenemos la señal en fase y cuadratura del archivo de entrada.

x_I = x(1:2:end);
x_Q = x(2:2:end);

x_FM = x_I + 1j*x_Q;

%% A continuación se porcede a demodular las señales
% Se recuerda que la señal viene modulada primero en FM y luego en AM

% Demodulameos la señal FM
x_demod_FM=angle(x_FM(2:end).*conj(x_FM(1:end-1)));   % señal demodulada
x_demod_FM=resample(x_demod_FM,11025,60000);

% Demodulamos AM
x_demod_AM = abs(x_demod_FM);

m = resample(x_demod_AM,4160,11025);

figure
plot(m)
title('Senal mensaje demodulada')

%% A continuación se procede con la representación de la imágen transmitida
% por el satélite de dos maneras distintas.
%
% La primera opción será visualizar manualmente un pulso de sincronización,
% recortar esa parte de señal y representar cada 2080 pixels. Esta solución
% tiene el problema del efecto Doppler
%
% La segunda opción serña general el pulso de sincronización del canal
% visible y hallar la correlación con la señal mensaje demodulada, para así
% localizar su posición de forma automática y ya de paso eliminamos el
% efecto Doppler

% Opción Sencilla (con efecto Doppler)

imageData=m(51097:1974058-1082);

for i=0:1:900
    vectorImag(i+1,:)=imageData(1+2080*i:2080+2080*i);
end



% Opción öptima (Sin efecto Doppler)

a=[1 1 0 0];
pulsoA=[-1*ones(1,4) a a a a a a a -1*ones(1,8)]; % pulso para el visible
corr_PulsoA=xcorr(m,pulsoA);
corr_PulsoA_shifted=circshift(corr_PulsoA,(length(corr_PulsoA)-1)/2 );

% Con la función circshidt lo que hacemos es desplazar circularmente la
% señal, para quitarnos las partes inciciales que no son pulso de
% sincronización y que no nos interesan

[picos,posiciones_picos]=findpeaks(corr_PulsoA_shifted,'MINPEAKHEIGHT',7,'MINPEAKDISTANCE',2000);      % con 7 y 8 salen bien comparar

% La función findpeaks localiza los picos de una señal, a partir de unos
% parámetros como son el valor mínimo del pico, o la distancia mínima de
% separación entre los mismos

for i=1:1:length(posiciones_picos) -1
        vectorImag2(i,:)=resample(m(posiciones_picos(i):posiciones_picos(i+1)),2080,length(m(posiciones_picos(i):posiciones_picos(i+1))));  
end


%% Representación de las imágenes obtenidas por ambos métodos

subplot(2,1,1)
imshow(vectorImag)
title('Easy Implementation')
subplot(2,1,2)
imshow(vectorImag2)
title('Optimal Implementation')


figure
imshow(vectorImag2)
title('Optimal Implementation ( No Doppler Effect )')
figure
imshow(vectorImag)
title('Fast ( Easy ) Implementation')



% Lamentablemente, debido a la alta carga de trabajo, no hemos podido sacar
% el tiempo necesario para obtener la telemetría 






