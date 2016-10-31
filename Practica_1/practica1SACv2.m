%%% TRANSMISOR %%%


clear all

%% Inicialización variables

load x.txt
plot (x)
BitsCuatizacion=3; %¨2^B -1 niveles cuantizacion
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

    soundsc(x);
    %pause(5);
    soundsc(xCuantizada);


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

datosCodificadosTX=str2num(datosCodificadosTX')';
senalAnalogicaTX=reshape(bsxfun(@minus, 2*datosCodificadosTX, ones(4,1)), 1, []); %Sustituye 1 con 1 1 1 1 y cero con -1 -1 -1 -1

%% CANAL
%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%



%% Pasamos la señal recibida a binario

senalAnalogicaRX = senalAnalogicaTX;

senalDigitalRX = reshape(senalAnalogicaRX,4,[]); % Transformamos a una matrix 4 x n
senalDigitalRX = (senalDigitalRX(1,:) + 1)./2; % Nos quedamos con la primera fila, sumamos 1 a todos los elementos y dividimos por 2 para 
                                        % pasar de -1s y 1s a 0s y 1s.


%% Quitamos la codificacion manchester a los datos recibidos 
 
senalDigitalRXTransformada=reshape(senalDigitalRX,2*BitsCuatizacion,[]); %  Hacemos reshape de digital_RX, pasamos ésta a una matriz de 2*B filas y las columnas correspondientes, de manera que cada columna será una palabra manchester
senalDigitalRXTransformadaString=num2str(senalDigitalRXTransformada,'%1d')';          %  Pasamos aINT a str para poder decodificarla con la función manchester2bin, ya que es necesario que esta sea char, ponemos como argumento %1d para que no se metan espacios.

datosRecibidosDecodificados=[];

 for fila=1:1:length(senalDigitalRXTransformadaString)
     datosRecibidosDecodificados = [datosRecibidosDecodificados ; manchester2bin(senalDigitalRXTransformadaString(fila,:))];   
 end

%% Obtenemos el error de transmisión
errorTransmision=sum(palabraCodigoTXBinario-datosRecibidosDecodificados);

%% Decuantizamos la señal de la variables datosRecibidosDecodificados

palabraCodigoRXDecimal=bin2dec(datosRecibidosDecodificados)';

errorEntrePalabraCodigoTXyRX=sum(palabraCodigoRXDecimal-palabraCodigoTXDecimal);

numeroTotalNivelesCuantizacion=(2^BitsCuatizacion)-1;

xCuantizadaRX=zeros(1,length(palabraCodigoRXDecimal));
for i=1:1:length(nivelesCuantizacion)
    xCuantizadaRX(find(palabraCodigoRXDecimal(1,:)==numeroTotalNivelesCuantizacion))=nivelesCuantizacion(i);
    numeroTotalNivelesCuantizacion=numeroTotalNivelesCuantizacion-1;
end

xCuantizadaRX=xCuantizadaRX';

%% Obtenemos SNR entre señal cuantizada emitida y señal cuantizada recibida, es inf. ya que el error entre ambas es 0.
errorEntreXcuantizadaRXyTX=sum(xCuantizadaRX-xCuantizada);
SNRentreSenalesCuantizadas=10*log10((xCuantizadaRX'*xCuantizadaRX)/(errorEntreXcuantizadaRXyTX'*errorEntreXcuantizadaRXyTX));

%% Escuchamos la señal cuantizada recibida

soundsc(xCuantizadaRX');




