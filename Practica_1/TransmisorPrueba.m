%%% TRANSMISOR %%%


clear all

%% Inicialización variables

load x.txt
plot (x)
BitsCuatizacion=2; %¨2^B -1 niveles cuantizacion
Vd = 2;  % Valor de amplitud de la señal a transmitir
guardar=0;

%% Normalizamos x

[x,Xmax,Xmin]=normalizar(x);


%% Cuantizamos x

quantum=(Xmax-Xmin)/(2^BitsCuatizacion-1);
xCuantizada=round((x+1)/quantum)*quantum-1; %Señal cuantizada en niveles, falta asignar un codigo de bits a cada nivel
%xq=normalizar(xq);
stem(xCuantizada)

%% Escuchamos señal y SNR

    %soundsc(x);
    %pause(5);
    %soundsc(xCuantizada);


errorCuantizacionEnTransmisor=x-xCuantizada; %% Error de cuantizacion, el único distinto a 0 en un sistema ideal.

SNRenTransmisor=10*log10((x'*x)/(errorCuantizacionEnTransmisor'*errorCuantizacionEnTransmisor));
if(guardar==1)
    cd D:\MASTER\SAC
    wavwrite(xCuantizada,'x_unifor'); % guardo señal cuantizada en wav
end

%% Compruebo codeword

nivelesCuantizacion=sort(unique(xCuantizada,'stable')); % niveles de cuantización | unique saca los diferentes niveles de la señal cuantizada
numeroTotalNivelesCuantizacion=(2^BitsCuatizacion)-1;
palabraCodigoTXDecimal=zeros(1,length(xCuantizada));

for i=1:1:length(nivelesCuantizacion)-1
    palabraCodigoTXDecimal(find(xCuantizada(:,1)==nivelesCuantizacion(i,1)))=numeroTotalNivelesCuantizacion;
    numeroTotalNivelesCuantizacion=numeroTotalNivelesCuantizacion-1;
end



% Lo paso a binario

palabraCodigoTXBinario=dec2bin(palabraCodigoTXDecimal);
 

%% Aplico un código de línea

datosCodificadosTX=[];

for fila=1:1:length(palabraCodigoTXBinario)
    datosCodificadosTX = strcat(datosCodificadosTX,bin2manchester(palabraCodigoTXBinario(fila,:)));
end

% % % % se muestrea la se�al codificada digital para enviarla por el canal.

%%%%% hay que a�ador el pre�mbulo para saber cuando llega la se�al
%%%%% codificada. El pre�mbulo debe ser una se�al no permitida por el
%%%%% codigo m�nchester.


preambulo = [1 1 1 1 0 0 0 0 1 1 1 1 0 0 0 0];
postambulo = [0 0 0 0 1 1 1 1 0 0 0 0 1 1 1 1];

datosCodificadosTX = str2num(datosCodificadosTX')';
datosCodificadosTX = [ preambulo datosCodificadosTX postambulo ] ;

senalAnalogicaTX = reshape(bsxfun(@minus, 2*datosCodificadosTX, ones(4,1)), 1, []); %Sustituye 1 con 1 1 1 1 y cero con -1 -1 -1 -1


%% Transmsi�n por line out micr�fono 

%soundsc(senalAnalogicaTX);


