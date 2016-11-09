%% CANAL
%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%

BitsCuatizacion=8; %¨2^B -1 niveles cuantizacion

preambulo = [1 1 0 1 0 0 0 0 1 0 1 1 0 0 0 0 1 0 1 1 1 1 0 1 0 0 0 0 1 0 1 1 0 0 0 0 1 0 1 1];
postambulo = [0 0 1 0 1 1 0 1 0 0 1 0 1 1 0 1 0 0 0 0 1 1 0 1 0 0 1 0 1 1 0 1 0 0 1 0 1 1 0 0];


%% Algoritmo de detecci�n

senalDetectadaCanal = audiorecorder(48000, 8, 1);     % audiorecorder(Fs, NBITS, NCHANS)
recordblocking(senalDetectadaCanal,40); % speak into microphone...
%pause(senalDetectadaCanal);
%play(senalDetectadaCanal)
y = getaudiodata(senalDetectadaCanal);



%% Pasamos la señal recibida a binario


senalAnalogicaRX = y;


% Restauramos la se�al recibida para volver a -1s y 1s.

senalAnalogicaRX(find(senalAnalogicaRX < 0)) = -1 ;
senalAnalogicaRX(find(senalAnalogicaRX >= 0)) = 1 ;


senalDigitalRX = reshape(senalAnalogicaRX,4,[]); % Transformamos a una matrix 4 x n
senalDigitalRX = (senalDigitalRX(1,:) + 1)./2; % Nos quedamos con la primera fila, sumamos 1 a todos los elementos y dividimos por 2 para 
                                        % pasar de -1s y 1s a 0s y 1s.


%%% buscamos el preambulo y lo eliminamos

for i=1:length(senalDigitalRX)-length(preambulo)-1
    if(preambulo == senalDigitalRX(length(senalDigitalRX)-i-length(preambulo):length(senalDigitalRX)-i-1))
        indice = length(senalDigitalRX)-i-1;
    end
end

senalDigitalRX = senalDigitalRX(indice+1:end);

%%%% buscamos el postambulo y lo eliminamos

for i=1:length(senalDigitalRX)-length(preambulo)
    if(postambulo == senalDigitalRX(i+1:i+length(postambulo)))
        indice_post = i;
    end
end

senalDigitalRX = senalDigitalRX(1:indice_post);


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
