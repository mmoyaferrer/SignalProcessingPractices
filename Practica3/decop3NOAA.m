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

Nfft = 1500000;
FsAM = 11025;
Fs = 60e3;
FsFinal = 4160;
fc = 2.4e3;
%t = 1/Fs:1/Fs:(length(x)-1)/Fs;

% Obtenemos la señal en fase y cuadratura del archivo de entrada.
x_I = x(1:2:end);
x_Q = x(2:2:end);

x_FM = x_I + 1j*x_Q;

% Demodulameos la señal FM
x_demod_FM=angle(x_FM(2:end).*conj(x_FM(1:end-1)));   % señal demodulada
x_demod_FM=resample(x_demod_FM,11025,60000);

% Demodulamos AM
x_demod_AM = abs(x_demod_FM);

m = resample(x_demod_AM,4160,11025);

figure
plot(m)

%% OPCION FACIL

imageData=m(51097:1974058-1082);

for i=0:1:900
    vectorImag(i+1,:)=imageData(1+2080*i:2080+2080*i);
end



%% OPCION GOSELIANA

a=[1 1 0 0];
pulsoA=[zeros(1,4) a a a a a a a zeros(1,8)]; % pulso para el visible
corr_PulsoA=xcorr(m,pulsoA);
corr_PulsoA_shifted=circshift(corr_PulsoA,(length(corr_PulsoA)-1)/2 );
[picos,posiciones_picos]=findpeaks(corr_PulsoA_shifted,'MINPEAKHEIGHT',13,'MINPEAKDISTANCE',1900);



for i=1:1:length(posiciones_picos) -1
        vectorImag2(i,:)=resample(m(posiciones_picos(i):posiciones_picos(i+1)),2080,length(m(posiciones_picos(i):posiciones_picos(i+1))));  
end

subplot(2,1,1)
imshow(vectorImag)
title('Imagen sacada a ojo')
subplot(2,1,2)
imshow(vectorImag2)
title('Imagen goseliana')


figure
imshow(vectorImag2)











