%% Practica 3 SAC

fileID = fopen('data_full.raw','r');
x = fread(fileID,inf,'single');

FsAM = 11025;
Fs = 60e3;
FsFinal = 4160;
fc = 2.4e3;

t = 1/Fs:1/Fs:(length(x)-1)/Fs;

% Obtenemos la señal en fase y cuadratura del archivo de entrada.
x_I = x(1:2:end);
x_Q = x(2:2:end);

x_FM = x_I + 1j*x_Q;

% Demodulameos la señal FM

x_demod_FM=angle(x(2:end).*conj(x(1:end-1)));   % señal demodulada
% figure;plot(t,x_demod);

% Demodulamos AM

x_demod_AM = amdemod(resample(x_demod_FM,11025,60000),fc,FsAM);
% figure; plot(x_demod_AM);

m = resample(x_demod_AM,4160,11025);
figure; plot(m)

fftx = fft(x_demod_FM);

f=linspace(0,Fs/2,length(x_demod_FM)/2-1)/1000;
figure;
plot(f,abs(fftx(1:length(fftx)/2-1)));